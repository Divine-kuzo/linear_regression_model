import os
from typing import Literal

import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

_DIR = os.path.dirname(__file__)
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
        "https://autism-screening-app.example.com",  # placeholder: deployed Flutter app origin
    ],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
    allow_credentials=True,
)


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
