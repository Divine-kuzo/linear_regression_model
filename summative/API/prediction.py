import os
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

_DIR = os.path.dirname(__file__)
_model = joblib.load(os.path.join(_DIR, "best_model.pkl"))
_scaler = joblib.load(os.path.join(_DIR, "scaler.pkl"))

# Order matches Step 4 of multivariate.ipynb.
FEATURE_ORDER = [
    "age", "gender", "ethnicity", "jundice", "austim",
    "contry_of_res", "used_app_before", "relation", "age_group",
]


def predict(features: list) -> float:
    if len(features) != len(FEATURE_ORDER):
        raise ValueError(f"Expected {len(FEATURE_ORDER)} features, got {len(features)}")
    X = np.array(features, dtype=float).reshape(1, -1)
    X_scaled = _scaler.transform(X)
    return float(_model.predict(X_scaled)[0])


if __name__ == "__main__":
    data_dir = os.path.join(_DIR, "..", "linear_regression")

    adult = pd.read_csv(os.path.join(data_dir, "Autism_Adult_Data.csv"))
    adult["age_group"] = "adult"
    child = pd.read_csv(os.path.join(data_dir, "Autism_Child_Data.csv"))
    child["age_group"] = "child"
    adolescent = pd.read_csv(os.path.join(data_dir, "Autism_Adolescent_Data.csv"))
    adolescent["age_group"] = "adolescent"
    df = pd.concat([adult, child, adolescent], ignore_index=True)

    df = df.drop(columns=["id", "Class/ASD"])
    df["ethnicity"] = df["ethnicity"].replace("?", "Unknown")
    df["relation"] = df["relation"].replace("?", "Unknown")
    df["age"] = pd.to_numeric(df["age"], errors="coerce")
    df = df.dropna(subset=["age"])
    df = df[df["age"] <= 120].reset_index(drop=True)
    df = df.drop(columns=[f"A{i}_Score" for i in range(1, 11)])

    for col in ["gender", "ethnicity", "jundice", "austim", "contry_of_res",
                "used_app_before", "relation", "age_group", "age_desc"]:
        df[col] = LabelEncoder().fit_transform(df[col])

    X = df[FEATURE_ORDER]
    y = df["result"]
    _, X_test, _, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    row = X_test.iloc[0]
    actual = y_test.iloc[0]
    prediction = predict(row.tolist())

    print(f"Prediction: {prediction:.2f}")
    print(f"Actual: {actual}")
