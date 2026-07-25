# Autism Screening Result Predictor

## What this project does
This predicts someone's AQ-10 autism screening score using simple info -
age, family history, country, jaundice at birth - instead of the full
10-question test. The idea is to help with quick pre-screening in places
where the full test isn't easy to get.

## Live API
- API URL: (fill in after deploying)
- Docs: (fill in after deploying)/docs

## Demo video
YouTube link: (add after recording)

## Dataset
Data comes from three UCI datasets by Fadi Thabtah (Adult, Child, and
Adolescent autism screening). They were merged into one file, tagged with
an `age_group` column, and cleaned down to 1093 rows. The `A1-A10` answers
were dropped since `result` is just their sum - keeping them would let the
model cheat instead of actually predicting anything.

## Running the API locally
```
uv sync
cd summative/API
uv run uvicorn main:app --reload
```
Then open `http://127.0.0.1:8000/docs` to try it out.

See `summative/linear_regression/multivariate.ipynb` for the full
data-cleaning and model-training pipeline.
