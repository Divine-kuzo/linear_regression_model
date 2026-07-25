# Autism Screening Result Prediction

## Mission
Predict a person's AQ-10 autism screening `result` using only accessible,
non-behavioral information (age, family history of autism, country of
residence, jaundice at birth, etc.) rather than the full 10-question
behavioral interview. This supports lightweight pre-screening in regions or
families without easy access to the full assessment.

## Dataset
Source: Fadi Thabtah, UCI Machine Learning Repository — Adult, Child, and
Adolescent Autism Screening Data. The three age-group datasets
(`Autism_Adult_Data.csv`, `Autism_Child_Data.csv`,
`Autism_Adolescent_Data.csv`) were merged into a single DataFrame, tagged
with an `age_group` column, and cleaned down to **1093 rows**.

## Why A1–A10 are excluded
`result` is the arithmetic sum of the ten `A1_Score`–`A10_Score` behavioral
answers, so including them as features would let the model just re-add them
up — a trivial, deterministic mapping that requires the very behavioral
checklist the mission is trying to avoid. They're dropped entirely, along
with `Class/ASD` (a direct threshold of `result`, i.e. leakage) and `id` (a
row identifier).

See `summative/linear_regression/multivariate.ipynb` for the full pipeline
and `summative/API/prediction.py` for the standalone prediction script.
