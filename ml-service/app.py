from flask import Flask, request, jsonify
from flask_cors import CORS
import datetime

app = Flask(__name__)
CORS(app)

def calculate_bmi(weight_kg, height_cm):
    """Calculate BMI from weight (kg) and height (cm)"""
    height_m = height_cm / 100
    return weight_kg / (height_m * height_m)

def predict_disease_risk(health_data):
    """
    Predict disease risk based on health metrics
    Returns risk level (Low, Medium, High) and explanation
    """
    risk_factors = []
    risk_score = 0

    # Blood Pressure Analysis
    if health_data.get('bloodPressure'):
        systolic = health_data['bloodPressure']['systolic']
        diastolic = health_data['bloodPressure']['diastolic']

        if systolic >= 140 or diastolic >= 90:
            risk_score += 3
            risk_factors.append("High blood pressure (Hypertension)")
        elif systolic >= 120 or diastolic >= 80:
            risk_score += 2
            risk_factors.append("Elevated blood pressure")
        elif systolic < 90 or diastolic < 60:
            risk_score += 1
            risk_factors.append("Low blood pressure")

    # Blood Sugar Analysis
    if health_data.get('bloodSugar') is not None:
        blood_sugar = health_data['bloodSugar']

        if blood_sugar >= 126:
            risk_score += 4
            risk_factors.append("High blood sugar (Diabetes range)")
        elif blood_sugar >= 100:
            risk_score += 2
            risk_factors.append("Elevated blood sugar (Pre-diabetes)")
        elif blood_sugar < 70:
            risk_score += 1
            risk_factors.append("Low blood sugar (Hypoglycemia)")

    # BMI Analysis
    if health_data.get('bmi'):
        bmi = health_data['bmi']

        if bmi >= 35:
            risk_score += 4
            risk_factors.append(f"Obesity Class II (BMI: {bmi:.1f})")
        elif bmi >= 30:
            risk_score += 3
            risk_factors.append(f"Obesity Class I (BMI: {bmi:.1f})")
        elif bmi >= 25:
            risk_score += 2
            risk_factors.append(f"Overweight (BMI: {bmi:.1f})")
        elif bmi < 18.5:
            risk_score += 1
            risk_factors.append(f"Underweight (BMI: {bmi:.1f})")

    # Cholesterol Analysis
    if health_data.get('cholesterol'):
        total = health_data['cholesterol'].get('total')
        ldl = health_data['cholesterol'].get('ldl')
        hdl = health_data['cholesterol'].get('hdl')

        if total and total >= 240:
            risk_score += 3
            risk_factors.append(f"High total cholesterol ({total} mg/dL)")
        elif ldl and ldl >= 160:
            risk_score += 3
            risk_factors.append(f"High LDL cholesterol ({ldl} mg/dL)")
        elif hdl and hdl < 40:
            risk_score += 2
            risk_factors.append(f"Low HDL cholesterol ({hdl} mg/dL)")

    # Determine risk level
    if risk_score >= 8:
        risk_level = "High"
        risk_color = "#ef4444"  # Red
        recommendation = "Consult a healthcare professional immediately. Your health metrics indicate significant risk factors."
    elif risk_score >= 4:
        risk_level = "Medium"
        risk_color = "#f59e0b"  # Yellow/Orange
        recommendation = "Consider lifestyle changes and schedule a check-up with a healthcare provider."
    else:
        risk_level = "Low"
        risk_color = "#10b981"  # Green
        recommendation = "Your health metrics are within normal ranges. Continue maintaining a healthy lifestyle."

    # Generate detailed explanation
    explanation = {
        "riskLevel": risk_level,
        "riskScore": risk_score,
        "riskFactors": risk_factors if risk_factors else ["No significant risk factors detected"],
        "recommendation": recommendation,
        "color": risk_color,
        "timestamp": datetime.datetime.now().isoformat()
    }

    return explanation

@app.route('/predict', methods=['POST'])
def predict():
    """
    Predict disease risk based on health metrics

    Expected JSON body:
    {
        "bloodPressure": {"systolic": 120, "diastolic": 80},
        "bloodSugar": 95,
        "bmi": 24.5,
        "cholesterol": {"total": 180, "ldl": 100, "hdl": 45}
    }
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({
                "status": "error",
                "message": "No data provided"
            }), 400

        # Validate that at least one metric is provided
        if not any(key in data for key in ['bloodPressure', 'bloodSugar', 'bmi', 'cholesterol']):
            return jsonify({
                "status": "error",
                "message": "At least one health metric must be provided"
            }), 400

        # Make prediction
        prediction = predict_disease_risk(data)

        return jsonify({
            "status": "success",
            "data": prediction
        }), 200

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "success",
        "message": "AI Prediction Service is running",
        "service": "ML Health Risk Predictor",
        "version": "1.0.0"
    }), 200

@app.route('/', methods=['GET'])
def home():
    """Root endpoint"""
    return jsonify({
        "service": "AI Health Prediction Service",
        "version": "1.0.0",
        "endpoints": {
            "/predict": "POST - Get disease risk prediction",
            "/health": "GET - Health check"
        }
    }), 200

if __name__ == '__main__':
    port = int(5001)  # Different port from main backend
    debug = True  # Set to False in production
    app.run(host='0.0.0.0', port=port, debug=debug)