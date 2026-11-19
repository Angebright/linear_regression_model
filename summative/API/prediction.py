from fastapi import FastAPI, HTTPException, UploadFile, File
import pandas as pd
import uvicorn
import io
from model_script import predict_delay, retrain_model
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware

class PredictionInput(BaseModel):
    cost: float = Field(..., ge=0, description="Estimated total project cost in Rand")
    prof_fees: float = Field(..., ge=0, description="Total professional fees")
    const_costs: float = Field(..., ge=0, description="Total construction costs")
    lat: float = Field(..., ge=-90, le=90, description="Latitude")
    lon: float = Field(..., ge=-180, le=180, description="Longitude")
    contractor_count: int = Field(..., ge=0, description="Number of projects by this contractor")
    province: str = Field(..., min_length=2)
    dept: str = Field(..., min_length=2)
    sector: str = Field(..., min_length=2)
    nature: str = Field(..., min_length=2)
    funding: str = Field(..., min_length=2)

app = FastAPI(
    title="Infrastructure Delay Prediction API",
    description="Predict project delay days and retrain model",
    version="1.0.0"
)

# --- CORS Configuration ---
# Allow Origins: Local Flutter web debug (http://localhost:8080) and the deployed Render frontend.
# Restrict: We do not use the wildcard "*" to prevent unauthorized websites from making requests.
# Allow Methods: We only allow GET (for docs) and POST (for predict/retrain).
# Allow Headers: Allow all headers to ensure JSON content-type passes through.
# Allow Credentials: Set to True to allow cookies/auth headers if needed later.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://infrastructure-delay-api.onrender.com"],
    allow_origin_regex=r"http://localhost:\d+",
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

# First endpoint responding to the root URL
@app.get("/")
def home():
    return {"message": "API is running successfully. Use /predict to get delay predictions and /retrain to retrain the model with new data."}

# Predict delay endpoint
@app.post("/predict")
def predict(input_data: PredictionInput):
    try:
        return {
            "predicted_delay_days": predict_delay(
                input_data.cost,
                input_data.prof_fees,
                input_data.const_costs,
                input_data.lat,
                input_data.lon,
                input_data.contractor_count,
                input_data.province,
                input_data.dept,
                input_data.sector,
                input_data.nature,
                input_data.funding
            )
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    
# Retrain the new uploaded dataset endpoint
@app.post("/retrain")
async def retrain(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        df = pd.read_csv(io.BytesIO(contents))
        result = retrain_model(df)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Run the API with uvicorn
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)