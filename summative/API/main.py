import os
from typing import Literal

import joblib
from pydantic import BaseModel, Field

_DIR = os.path.dirname(__file__)
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
