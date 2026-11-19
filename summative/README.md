# Linear Regression Model - South African Infrastructure Delay Prediction

## Mission and Problem Description

My mission is modernizing infrastructure project delivery in South Africa by using technology and Machine Learning. The problem I look forward to solving is the massive cost and time overruns in government construction projects, which negatively impact service delivery. By helping project managers and city planners predict project delays (in days) based on project size, budget, contractor track record, and site type, it will enable them to plan resources early, reduce cost overruns, and deliver infrastructure on time.

## Data Source

The dataset I used is the South African Infrastructure Projects dataset from the National Treasury's Infrastructure Reporting Model (IRM), hosted on Vulekamali. This dataset contains comprehensive real-world data on provincial infrastructure projects, including budgets, locations, contractors, and estimated completion dates.

**Source**: https://vulekamali.gov.za/provincial-infrastructure/

## Dataset Description

- **Time Period**: 2023-24 Q1 snapshot
- **Location**: South Africa (various provinces)
- **Target Variable**: Delay (days) - Engineered mathematically from the difference between the contracted construction end date and the estimated completion date.
- **Features**: Estimated Total Project Cost, Professional Fees, Construction Costs, Latitude, Longitude, Province, Department, Sector, Nature of Investment, Primary Funding Source, and Contractor Project Count.
- **Dataset Size**: Rich dataset with over 7,400 rows after cleaning, covering Education, Health, Transport, Human Settlements, and other sectors.

## Models Implemented

1. **Linear Regression** - Basic regression model (Closed Form)
2. **SGD Regressor** - Linear regression with Gradient Descent optimization
3. **Decision Tree Regressor** - Tree-based model
4. **Random Forest Regressor** - Ensemble model

## Best Performing Model

The **Random Forest Regressor** achieved the best performance based on MSE (Mean Squared Error) evaluation, as it handles the complex, non-linear variance of infrastructure delays much better than pure linear models. The model has been saved as `best_model.pkl`.

## Prediction Script (Python Script)

A prediction script is included that uses the best model to predict project delay days based on user inputs. You can check the last code cell in the notebook provided inside `summative/linear_regression/` directory and see the `predict_delay()` function in the notebook.

## API Endpoint

A publicly available API endpoint is provided for predictions:

**Prediction Endpoint**: [https://infrastructure-delay-api.onrender.com/docs](https://infrastructure-delay-api.onrender.com/docs)

And next select **/predict** endpoint to try it out and return the prediction.

_**#### NB:** You may need to wait for some seconds (<60 seconds) for a URL to return back online, because I used a free basic plan on the Render hosting platform!!_

### How It Works

The API accepts POST requests with the following input parameters:
- `cost` (float): Estimated total project cost in Rand
- `prof_fees` (float): Total professional fees
- `const_costs` (float): Total construction costs
- `lat` (float): Latitude (-90 to 90)
- `lon` (float): Longitude (-180 to 180)
- `contractor_count` (int): Number of projects by this contractor
- `province` (str): South African province (e.g., "KwaZulu-Natal")
- `dept` (str): Government department (e.g., "Education")
- `sector` (str): Sector (e.g., "Education")
- `nature` (str): Nature of investment (e.g., "Upgrading")
- `funding` (str): Primary funding source (e.g., "Equitable Share")

The prediction is handled by two main files:
- **[`summative/API/prediction.py`](summative/API/prediction.py)**: Defines the FastAPI endpoints (`/predict` and `/retrain`) and handles HTTP requests.
- **[`summative/API/model_script.py`](summative/API/model_script.py)**: Contains the `predict_delay()` function that loads the trained Random Forest model and returns predictions.

### Example Request

```json
{
  "cost": 5000000,
  "prof_fees": 500000,
  "const_costs": 4500000,
  "lat": -30.5,
  "lon": 30.4,
  "contractor_count": 5,
  "province": "KwaZulu-Natal",
  "dept": "Education",
  "sector": "Education",
  "nature": "Upgrading",
  "funding": "Equitable Share"
}

{
  "predicted_delay_days": 12.5
}
```

You can test the API using Swagger UI at: https://infrastructure-delay-api.onrender.com/docs (mentioned above)
## Video Demo
Watch the YouTube video demo here

# How to Run the Mobile App (InfraDelay)
The mobile app is located in the summative/flutter_app directory. Follow these steps to run it:

# Prerequisites
Install Flutter SDK: Download and install Flutter from flutter.dev

Android Studio or VS Code: Install an IDE with Flutter support

Android Emulator or Physical Device: For testing on Android

Installation Steps
Navigate to the app directory:

```
cd summative/flutter_app
Get dependencies:

```
flutter pub get
Run the app:

```
flutter run
Using the App
Launch the app - The InfraDelay app will open with a dark-themed interface

Enter Project Details - Input the 11 variables (cost, fees, construction costs, coordinates, contractor count, province, etc.)

Get Prediction - Tap the "Predict" button to get your prediction

View Result - The predicted delay in days will be displayed

## Optional: Retrain the Model
The app also allows you to retrain the model with new data:

Tap the "Upload CSV" button

Select a CSV file with the required format (columns: delay_days, estimated_total_project_cost, total_professional_fees, total_construction_costs, latitude, longitude, province, department, sector, nature_of_investment, primary_funding_source, contractor_project_count)

Tap "Retrain Model" to retrain with the new data

## Files Structure
```text
linear_regression_model/
├── README.md
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb
│   │   ├── Dataset.csv
│   │   ├── best_model.pkl
│   │   ├── feature_columns.pkl
│   ├── API/
│   │   ├── prediction.py
│   │   ├── model_script.py
│   │   ├── requirements.txt
│   ├── flutter_app/
│   │   ├── lib/
│   │   ├── pubspec.yaml
text
```