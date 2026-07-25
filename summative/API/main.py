import os
from typing import Literal

import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

_DIR = os.path.dirname(__file__)
_DATA_DIR = os.path.join(_DIR, "..", "linear_regression")
_TRAINING_DATA_PATH = os.path.join(_DIR, "training_data.csv")

_model = joblib.load(os.path.join(_DIR, "best_model.pkl"))
_scaler = joblib.load(os.path.join(_DIR, "scaler.pkl"))
_encoders = joblib.load(os.path.join(_DIR, "encoders.pkl"))

FEATURE_ORDER = [
    "age", "gender", "ethnicity", "jundice", "austim",
    "contry_of_res", "used_app_before", "relation", "age_group",
]


def _classes(col: str) -> tuple:
    return tuple(_encoders[col].classes_.tolist())


GenderLiteral = Literal[_classes("gender")]
EthnicityLiteral = Literal[_classes("ethnicity")]
JundiceLiteral = Literal[_classes("jundice")]
AustimLiteral = Literal[_classes("austim")]
CountryLiteral = Literal[_classes("contry_of_res")]
UsedAppLiteral = Literal[_classes("used_app_before")]
RelationLiteral = Literal[_classes("relation")]
AgeGroupLiteral = Literal[_classes("age_group")]


class PredictRequest(BaseModel):
    age: float = Field(ge=1, le=100)
    gender: GenderLiteral
    ethnicity: EthnicityLiteral
    jundice: JundiceLiteral
    austim: AustimLiteral
    contry_of_res: CountryLiteral
    used_app_before: UsedAppLiteral
    relation: RelationLiteral
    age_group: AgeGroupLiteral


app = FastAPI(title="Autism Screening Result Predictor")

# Explicit origin list instead of "*" - allow_credentials=True with a wildcard
# origin would let any site read responses using a logged-in user's session.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "https://linear-regression-model-3iyp.onrender.com",
    ],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
    allow_credentials=True,
)


@app.get("/")
def root():
    return {"message": "Autism screening result predictor API. See /docs for usage."}


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return JSONResponse(status_code=400, content={"detail": exc.errors()})


def _encode_row(payload: PredictRequest) -> np.ndarray:
    row = []
    for col in FEATURE_ORDER:
        value = getattr(payload, col)
        if col == "age":
            row.append(float(value))
        else:
            row.append(float(_encoders[col].transform([value])[0]))
    return np.array(row).reshape(1, -1)


@app.post("/predict")
def predict(payload: PredictRequest):
    try:
        X = _encode_row(payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=f"Could not encode input: {exc}")

    X_scaled = _scaler.transform(X)
    prediction = float(_model.predict(X_scaled)[0])
    return {"predicted_result": prediction}


def _load_training_data() -> pd.DataFrame:
    if os.path.exists(_TRAINING_DATA_PATH):
        return pd.read_csv(_TRAINING_DATA_PATH)

    adult = pd.read_csv(os.path.join(_DATA_DIR, "Autism_Adult_Data.csv"))
    adult["age_group"] = "adult"
    child = pd.read_csv(os.path.join(_DATA_DIR, "Autism_Child_Data.csv"))
    child["age_group"] = "child"
    adolescent = pd.read_csv(os.path.join(_DATA_DIR, "Autism_Adolescent_Data.csv"))
    adolescent["age_group"] = "adolescent"
    df = pd.concat([adult, child, adolescent], ignore_index=True)

    df["ethnicity"] = df["ethnicity"].replace("?", "Unknown")
    df["relation"] = df["relation"].replace("?", "Unknown")
    df["age"] = pd.to_numeric(df["age"], errors="coerce")
    df = df.dropna(subset=["age"])
    df = df[df["age"] <= 120]

    df = df[FEATURE_ORDER + ["result"]].reset_index(drop=True)
    df.to_csv(_TRAINING_DATA_PATH, index=False)
    return df


def _encode_df(df: pd.DataFrame) -> pd.DataFrame:
    encoded = df.copy()
    for col in FEATURE_ORDER:
        if col != "age":
            encoded[col] = _encoders[col].transform(encoded[col])
    return encoded


@app.post("/retrain")
async def retrain(file: UploadFile = File(...)):
    global _model, _scaler

    required_cols = set(FEATURE_ORDER + ["result"])
    try:
        new_data = pd.read_csv(file.file)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Could not read CSV: {exc}")

    if not required_cols.issubset(new_data.columns):
        missing = required_cols - set(new_data.columns)
        raise HTTPException(status_code=400, detail=f"Missing columns: {sorted(missing)}")

    existing_data = _load_training_data()
    combined = pd.concat(
        [existing_data, new_data[FEATURE_ORDER + ["result"]]], ignore_index=True
    )

    try:
        encoded = _encode_df(combined)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=f"Unseen category in upload: {exc}")

    X = encoded[FEATURE_ORDER]
    y = encoded["result"]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    mse_before = mean_squared_error(y_test, _model.predict(_scaler.transform(X_test)))

    new_scaler = StandardScaler()
    X_train_scaled = new_scaler.fit_transform(X_train)
    X_test_scaled = new_scaler.transform(X_test)

    new_model = RandomForestRegressor(random_state=42)
    new_model.fit(X_train_scaled, y_train)
    mse_after = mean_squared_error(y_test, new_model.predict(X_test_scaled))

    joblib.dump(new_model, os.path.join(_DIR, "best_model.pkl"))
    joblib.dump(new_scaler, os.path.join(_DIR, "scaler.pkl"))
    combined.to_csv(_TRAINING_DATA_PATH, index=False)

    _model = new_model
    _scaler = new_scaler

    return {"mse_before": mse_before, "mse_after": mse_after}
