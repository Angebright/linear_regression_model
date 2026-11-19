import joblib
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from pathlib import Path

# Path to the models declaration 
BASE_DIR = Path(__file__).resolve().parent
MODEL_PATH = BASE_DIR / "best_model.pkl"
FEATURE_COLUMNS_PATH = BASE_DIR / "feature_columns.pkl"

# Load the saved model using joblib (fixes the UnpicklingError)
try:
    model = joblib.load(MODEL_PATH)
except Exception as e:
    print(f"Error loading model: {e}")
    model = None

# Load training feature columns using joblib
try:
    TRAINING_COLUMNS = joblib.load(FEATURE_COLUMNS_PATH)
except Exception as e:
    print(f"Error loading feature columns: {e}")
    TRAINING_COLUMNS = []

# Function for Prediction
def predict_delay(cost: float, prof_fees: float, const_costs: float, lat: float, lon: float, contractor_count: int, province: str, dept: str, sector: str, nature: str, funding: str) -> float:
    """
    Predict project delay using the saved model.
    """
    # 1. Create a DataFrame with the single row of input
    input_data = pd.DataFrame([{
        "estimated_total_project_cost": cost,
        "total_professional_fees": prof_fees,
        "total_construction_costs": const_costs,
        "latitude": lat,
        "longitude": lon,
        "contractor_project_count": contractor_count,
        "province": province,
        "department": dept,
        "sector": sector,
        "nature_of_investment": nature,
        "primary_funding_source": funding
    }])

    # 2. Apply One-Hot Encoding (same as training)
    input_encoded = pd.get_dummies(input_data)

    # 3. Reindex to match the exact training columns (fills missing dummy columns with 0)
    input_final = input_encoded.reindex(columns=TRAINING_COLUMNS, fill_value=0)

    # 4. Predict
    predicted_value = model.predict(input_final)

    return float(predicted_value[0])


# Function to retrain the model with new dataset
def retrain_model(df: pd.DataFrame):
    global model

    # Expected columns for infrastructure data
    expected_columns = [
        "delay_days", "estimated_total_project_cost", "total_professional_fees", 
        "total_construction_costs", "latitude", "longitude", "province", 
        "department", "sector", "nature_of_investment", "primary_funding_source", 
        "contractor_project_count"
    ]

    if list(df.columns) != expected_columns:
        raise ValueError(f"Dataset must have columns: {expected_columns}")

    df = df.dropna().reset_index(drop=True)

    # Encode and prepare data
    numerical_data = pd.get_dummies(df)
    X = numerical_data.drop("delay_days", axis=1)
    y = numerical_data["delay_days"]

    # Align with original training columns
    X = X.reindex(columns=TRAINING_COLUMNS, fill_value=0)

    new_model = RandomForestRegressor(n_estimators=100, random_state=42)
    new_model.fit(X, y)
    
    # Overwrite the saved model using joblib
    joblib.dump(new_model, MODEL_PATH)

    model = new_model

    return {
        "message": "Model retrained successfully on Infrastructure data",
        "rows_used": len(df),
        "features_used": X.shape[1]
    }