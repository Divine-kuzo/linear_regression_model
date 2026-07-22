import os
import joblib
import numpy as np

_DIR = os.path.dirname(__file__)
_model = joblib.load(os.path.join(_DIR, "best_model.pkl"))
_scaler = joblib.load(os.path.join(_DIR, "scaler.pkl"))

# Order matches training features: Age_Mons, then label-encoded
# Sex, Ethnicity, Jaundice, Family_mem_with_ASD.
FEATURE_ORDER = ["Age_Mons", "Sex", "Ethnicity", "Jaundice", "Family_mem_with_ASD"]


def predict(features: list) -> float:
    if len(features) != len(FEATURE_ORDER):
        raise ValueError(f"Expected {len(FEATURE_ORDER)} features, got {len(features)}")
    X = np.array(features, dtype=float).reshape(1, -1)
    X_scaled = _scaler.transform(X)
    return float(_model.predict(X_scaled)[0])
