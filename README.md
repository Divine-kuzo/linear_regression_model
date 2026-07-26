# Autism Screening Result Predictor

## What this project does
This predicts someone's AQ-10 autism screening result using simple,
non-behavioral info: age, family history, country, jaundice at birth,
relation to the person screened, prior app use, and age group. No
behavioral questions needed. It's built for lightweight pre-screening in
regions or families that don't have easy access to a full assessment.
The data comes from three UCI datasets by Fadi Thabtah (Adult, Child, and
Adolescent autism screening), merged into one set of about 1093 rows
after cleaning.

## Live API
- Swagger UI: https://linear-regression-model-3iyp.onrender.com/docs
- Use this page to try the `/predict` and `/retrain` endpoints directly
  in the browser, no setup needed.

## Demo video
YouTube link: https://youtu.be/lcFCw1PXW-U

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

## Running the Flutter app
1. Install dependencies: `uv sync` (for the API) or `flutter pub get`
   (for the app itself).
2. Connect an Android device, or start an emulator.
3. From `summative/FlutterApp`, run `flutter run`.
4. Pick your device when prompted. Fill in the 9 fields and tap Predict.

<!-- auto-deploy check -->
