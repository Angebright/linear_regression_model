import pickle
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from pathlib import Path 

# Path to the models declaration 
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "../linear_regression/best_model.pkl"
FEATURE_COLUMNS_PATH = BASE_DIR / "../linear_regression/feature_columns.pkl"

# Load the saved Random Forest model as was the best performing model
with open(MODEL_PATH, "rb") as f:
    model = pickle.load(f)

# Load training feature columns
with open(FEATURE_COLUMNS_PATH, "rb") as f:
    TRAINING_COLUMNS = pickle.load(f)

# function for Prediction
def predict_delay(cost: float, prof_fees: float, const_costs: float, lat: float, lon: float, contractor_count: int, province: str, dept: str, sector: str, nature: str, funding: str) -> float:
    """
    Predict project delay days using the saved best performing model.
    """

    # 1. FIX: Standardize the text to match the exact casing used in training.
    # This prevents different predictions if the user types lowercase in the app.
    province_clean = province.strip().title()
    # Fix the unique casing for KwaZulu-Natal
    if province_clean == "Kwazulu-Natal":
        province_clean = "KwaZulu-Natal"
        
    dept_clean = dept.strip().title()
    sector_clean = sector.strip().title()
    nature_clean = nature.strip().title()
    funding_clean = funding.strip().title()

    # Build the full DataFrame with exactly the columns expected
    input_data = pd.DataFrame([{
        "estimated_total_project_cost": cost,
        "total_professional_fees": prof_fees,
        "total_construction_costs": const_costs,
        "latitude": lat,
        "longitude": lon,
        "contractor_project_count": contractor_count,
        "province": province_clean,
        "department": dept_clean,
        "sector": sector_clean,
        "nature_of_investment": nature_clean,
        "primary_funding_source": funding_clean
    }])

    # Transform categorical inputs into one-hot encoded features
    input_encoded = pd.get_dummies(input_data)
    
    # Populate all other required features to match the model’s training data
    input_final = input_encoded.reindex(columns=TRAINING_COLUMNS, fill_value=0)

    # Predict the user input
    predicted_value = model.predict(input_final)

    return float(predicted_value[0])


# Function to retrain the model with new dataset
def retrain_model(df: pd.DataFrame):
    global model

    expected_columns = [
        "delay_days", "estimated_total_project_cost", "total_professional_fees", 
        "total_construction_costs", "latitude", "longitude", "province", 
        "department", "sector", "nature_of_investment", "primary_funding_source", 
        "contractor_project_count"
    ]

    if list(df.columns) != expected_columns:
        raise ValueError(f"Dataset must have columns: {expected_columns}")

    df = df.dropna().reset_index(drop=True)

    numerical_data = pd.get_dummies(df)

    X = numerical_data.drop("delay_days", axis=1)
    y = numerical_data["delay_days"]

    X = X.reindex(columns=TRAINING_COLUMNS, fill_value=0)

    new_model = RandomForestRegressor(n_estimators=100, random_state=42)
    new_model.fit(X, y)
    
    # Save as I overwrite new retrained model result
    with open(MODEL_PATH, "wb") as f:
        pickle.dump(new_model, f)

    model = new_model

    return {
        "message": "Model retrained successfully",
        "rows_used": len(df),
        "features_used": X.shape[1]
    }