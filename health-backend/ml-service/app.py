from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
import sys

# Add parent directory to path to import modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

load_dotenv()

app = Flask(__name__)
CORS(app)

# Configuration
PORT = int(os.getenv('ML_SERVICE_PORT', 8000))
DEBUG = os.getenv('FLASK_ENV', 'development') == 'development'

# Global variables to store models
models = {}
model_metadata = {}

def load_models():
    """Load trained ML models"""
    try:
        import joblib
        models_path = os.path.join(os.path.dirname(__file__), 'models')

        # Check if models directory exists and has trained models
        if os.path.exists(models_path):
            model_files = {
                'hypertension_model': 'hypertension_model.pkl',
                'diabetes_model': 'diabetes_model.pkl',
                'heart_disease_model': 'heart_disease_model.pkl',
                'obesity_model': 'obesity_model.pkl'
            }

            for model_name, filename in model_files.items():
                model_path = os.path.join(models_path, filename)
                if os.path.exists(model_path):
                    models[model_name] = joblib.load(model_path)
                    print(f"✅ Loaded {model_name} from {filename}")

            if models:
                model_metadata['version'] = '1.0.0'
                model_metadata['status'] = 'loaded'
            else:
                model_metadata['status'] = 'fallback'
        else:
            print("⚠️  No trained models found, using fallback rule-based predictions")
            model_metadata['status'] = 'fallback'
    except Exception as e:
        print(f"⚠️  Error loading models: {str(e)}")
        model_metadata['status'] = 'fallback'

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'success',
        'message': 'ML Service is running',
        'models': model_metadata.get('status', 'unknown'),
        'version': model_metadata.get('version', 'unknown')
    })

@app.route('/predict', methods=['POST'])
def predict():
    """Generate disease predictions based on health metrics"""
    try:
        data = request.get_json()

        # Extract features from request
        features = {
            'age': int(data.get('age', 45)),
            'gender': data.get('gender', 'other'),
            'bmi': float(data.get('bmi', 25.0)),
            'blood_pressure_systolic': int(data.get('blood_pressure_systolic', 120)),
            'blood_pressure_diastolic': int(data.get('blood_pressure_diastolic', 80)),
            'blood_sugar': float(data.get('blood_sugar', 100.0)),
            'cholesterol_total': float(data.get('cholesterol_total', 200.0)),
            'cholesterol_ldl': float(data.get('cholesterol_ldl', 100.0)),
            'cholesterol_hdl': float(data.get('cholesterol_hdl', 50.0)),
            'smoking': int(data.get('smoking', 0)),
            'activity_level': int(data.get('activity_level', 1)),
            'family_history_diabetes': int(data.get('family_history_diabetes', 0)),
            'family_history_hypertension': int(data.get('family_history_hypertension', 0))
        }

        # Generate predictions using ML models or fallback
        predictions = generate_predictions(features)

        return jsonify({
            'status': 'success',
            'predictions': predictions,
            'model_version': model_metadata.get('version', 'rule-based-fallback'),
            'features_used': list(features.keys())
        })

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/models/status', methods=['GET'])
def models_status():
    """Get status of loaded models"""
    return jsonify({
        'models_loaded': list(models.keys()),
        'metadata': model_metadata,
        'fallback_mode': model_metadata.get('status') == 'fallback'
    })

def generate_predictions(features):
    """Generate predictions using ML models or fallback rules"""

    if models and model_metadata.get('status') != 'fallback':
        # Use trained ML models
        return predict_with_models(features)
    else:
        # Use rule-based fallback
        return predict_with_rules(features)

def predict_with_models(features):
    """Generate predictions using trained ML models"""

    import numpy as np

    # Prepare feature array (order must match training)
    feature_array = np.array([[
        features['age'],
        features['bmi'],
        features['blood_pressure_systolic'],
        features['blood_pressure_diastolic'],
        features['blood_sugar'],
        features['cholesterol_total'],
        features['smoking'],
        features['activity_level']
    ]])

    predictions = []

    # Hypertension prediction
    if 'hypertension_model' in models:
        hypertension_prob = models['hypertension_model'].predict_proba(feature_array)[0][1]
        predictions.append({
            'disease': 'hypertension',
            'risk_score': float(hypertension_prob * 100),
            'factors': get_risk_factors('hypertension', features)
        })

    # Diabetes prediction
    if 'diabetes_model' in models:
        diabetes_prob = models['diabetes_model'].predict_proba(feature_array)[0][1]
        predictions.append({
            'disease': 'diabetes',
            'risk_score': float(diabetes_prob * 100),
            'factors': get_risk_factors('diabetes', features)
        })

    # Heart disease prediction
    if 'heart_disease_model' in models:
        heart_disease_prob = models['heart_disease_model'].predict_proba(feature_array)[0][1]
        predictions.append({
            'disease': 'heart_disease',
            'risk_score': float(heart_disease_prob * 100),
            'factors': get_risk_factors('heart_disease', features)
        })

    # Obesity prediction
    if 'obesity_model' in models:
        obesity_prob = models['obesity_model'].predict_proba(feature_array)[0][1]
        predictions.append({
            'disease': 'obesity_related',
            'risk_score': float(obesity_prob * 100),
            'factors': get_risk_factors('obesity_related', features)
        })

    return predictions

def predict_with_rules(features):
    """Generate predictions using rule-based logic"""

    predictions = []

    # Hypertension risk calculation
    hypertension_risk = calculate_hypertension_risk(features)
    predictions.append({
        'disease': 'hypertension',
        'risk_score': hypertension_risk,
        'factors': get_risk_factors('hypertension', features)
    })

    # Diabetes risk calculation
    diabetes_risk = calculate_diabetes_risk(features)
    predictions.append({
        'disease': 'diabetes',
        'risk_score': diabetes_risk,
        'factors': get_risk_factors('diabetes', features)
    })

    # Heart disease risk calculation
    heart_disease_risk = calculate_heart_disease_risk(features)
    predictions.append({
        'disease': 'heart_disease',
        'risk_score': heart_disease_risk,
        'factors': get_risk_factors('heart_disease', features)
    })

    # Obesity-related conditions risk
    obesity_risk = calculate_obesity_risk(features)
    predictions.append({
        'disease': 'obesity_related',
        'risk_score': obesity_risk,
        'factors': get_risk_factors('obesity_related', features)
    })

    return predictions

def calculate_hypertension_risk(features):
    """Calculate hypertension risk using rules"""
    risk = 25  # Base risk

    if features['blood_pressure_systolic'] >= 140 or features['blood_pressure_diastolic'] >= 90:
        risk += 30
    elif features['blood_pressure_systolic'] >= 120 or features['blood_pressure_diastolic'] >= 80:
        risk += 15

    if features['age'] > 50:
        risk += 10
    if features['bmi'] > 30:
        risk += 15
    if features['smoking'] == 1:
        risk += 10
    if features['activity_level'] < 3:
        risk += 10

    return min(100, risk)

def calculate_diabetes_risk(features):
    """Calculate diabetes risk using rules"""
    risk = 20  # Base risk

    if features['blood_sugar'] > 126:
        risk += 35
    elif features['blood_sugar'] > 100:
        risk += 20

    if features['bmi'] > 30:
        risk += 15
    if features['family_history_diabetes'] == 1:
        risk += 15
    if features['age'] > 45:
        risk += 10
    if features['activity_level'] < 3:
        risk += 10

    return min(100, risk)

def calculate_heart_disease_risk(features):
    """Calculate heart disease risk using rules"""
    risk = 15  # Base risk

    if features['cholesterol_total'] > 240:
        risk += 25
    elif features['cholesterol_total'] > 200:
        risk += 15

    if features['blood_pressure_systolic'] > 140 or features['blood_pressure_diastolic'] > 90:
        risk += 20
    if features['age'] > 55:
        risk += 15
    if features['smoking'] == 1:
        risk += 20
    if features['bmi'] > 30:
        risk += 10

    return min(100, risk)

def calculate_obesity_risk(features):
    """Calculate obesity-related risk using rules"""
    if features['bmi'] > 35:
        return 80
    elif features['bmi'] > 30:
        return 60
    elif features['bmi'] > 25:
        return 40
    else:
        return 20

def get_risk_factors(disease, features):
    """Get contributing risk factors for a disease"""

    factors = []

    if disease == 'hypertension':
        if features['blood_pressure_systolic'] > 120 or features['blood_pressure_diastolic'] > 80:
            factors.append('Elevated Blood Pressure')
        if features['age'] > 50:
            factors.append('Age > 50')
        if features['bmi'] > 30:
            factors.append('Obesity')
        if features['smoking'] == 1:
            factors.append('Smoking')
        if features['activity_level'] < 3:
            factors.append('Low Activity Level')

    elif disease == 'diabetes':
        if features['blood_sugar'] > 100:
            factors.append('Elevated Blood Sugar')
        if features['bmi'] > 30:
            factors.append('Obesity')
        if features['family_history_diabetes'] == 1:
            factors.append('Family History')
        if features['age'] > 45:
            factors.append('Age > 45')

    elif disease == 'heart_disease':
        if features['cholesterol_total'] > 200:
            factors.append('High Cholesterol')
        if features['blood_pressure_systolic'] > 120:
            factors.append('High Blood Pressure')
        if features['age'] > 55:
            factors.append('Age > 55')
        if features['smoking'] == 1:
            factors.append('Smoking')
        if features['bmi'] > 30:
            factors.append('Obesity')

    elif disease == 'obesity_related':
        if features['bmi'] > 30:
            factors.append('High BMI')
        if features['activity_level'] < 3:
            factors.append('Low Activity Level')

    return factors if factors else ['General Risk Factors']

if __name__ == '__main__':
    print("Starting ML Service...")
    load_models()
    print(f"ML Service ready on port {PORT}")
    app.run(host='0.0.0.0', port=PORT, debug=DEBUG)