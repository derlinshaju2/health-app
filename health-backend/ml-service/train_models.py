import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import os
from datetime import datetime

class HealthMLModelTrainer:
    def __init__(self, n_samples=10000, test_size=0.2, random_state=42):
        self.n_samples = n_samples
        self.test_size = test_size
        self.random_state = random_state
        self.models = {}
        self.scalers = {}
        self.model_metadata = {}

        # Create models directory if it doesn't exist
        self.models_dir = os.path.join(os.path.dirname(__file__), 'models')
        os.makedirs(self.models_dir, exist_ok=True)

    def generate_synthetic_data(self):
        """Generate synthetic health data for training"""
        np.random.seed(self.random_state)

        # Generate features based on real health data distributions
        data = {
            'age': np.random.normal(45, 15, self.n_samples).clip(18, 90),
            'bmi': np.random.normal(27, 5, self.n_samples).clip(15, 50),
            'blood_pressure_systolic': np.random.normal(125, 20, self.n_samples).clip(90, 200),
            'blood_pressure_diastolic': np.random.normal(82, 12, self.n_samples).clip(60, 130),
            'blood_sugar': np.random.normal(100, 25, self.n_samples).clip(70, 200),
            'cholesterol_total': np.random.normal(200, 40, self.n_samples).clip(150, 350),
            'smoking': np.random.choice([0, 1], self.n_samples, p=[0.7, 0.3]),
            'activity_level': np.random.choice([1, 2, 3, 4, 5], self.n_samples, p=[0.3, 0.3, 0.25, 0.1, 0.05])
        }

        df = pd.DataFrame(data)

        # Generate target variables based on risk factors
        df['target_hypertension'] = self._generate_hypertension_target(df)
        df['target_diabetes'] = self._generate_diabetes_target(df)
        df['target_heart_disease'] = self._generate_heart_disease_target(df)
        df['target_obesity'] = self._generate_obesity_target(df)

        return df

    def _generate_hypertension_target(self, df):
        """Generate hypertension target based on risk factors"""
        risk_scores = (
            (df['blood_pressure_systolic'] > 140).astype(int) * 2 +
            (df['blood_pressure_diastolic'] > 90).astype(int) * 2 +
            (df['age'] > 50).astype(int) +
            (df['bmi'] > 30).astype(int) +
            df['smoking'] +
            (df['activity_level'] < 3).astype(int)
        )
        # Add some randomness
        noise = np.random.normal(0, 1, len(df))
        return ((risk_scores + noise) > 2).astype(int)

    def _generate_diabetes_target(self, df):
        """Generate diabetes target based on risk factors"""
        risk_scores = (
            (df['blood_sugar'] > 126).astype(int) * 2 +
            (df['blood_sugar'] > 100).astype(int) +
            (df['bmi'] > 30).astype(int) +
            (df['age'] > 45).astype(int) +
            (df['activity_level'] < 3).astype(int)
        )
        noise = np.random.normal(0, 1, len(df))
        return ((risk_scores + noise) > 2).astype(int)

    def _generate_heart_disease_target(self, df):
        """Generate heart disease target based on risk factors"""
        risk_scores = (
            (df['cholesterol_total'] > 240).astype(int) * 2 +
            (df['blood_pressure_systolic'] > 140).astype(int) +
            (df['age'] > 55).astype(int) +
            df['smoking'] * 2 +
            (df['bmi'] > 30).astype(int)
        )
        noise = np.random.normal(0, 1, len(df))
        return ((risk_scores + noise) > 2).astype(int)

    def _generate_obesity_target(self, df):
        """Generate obesity target based on BMI"""
        return (df['bmi'] > 30).astype(int)

    def prepare_features(self, df):
        """Prepare feature matrix"""
        feature_columns = [
            'age', 'bmi', 'blood_pressure_systolic', 'blood_pressure_diastolic',
            'blood_sugar', 'cholesterol_total', 'smoking', 'activity_level'
        ]
        return df[feature_columns].values

    def train_hypertension_model(self, X, y):
        """Train Random Forest model for hypertension prediction"""
        print("\n🔬 Training Hypertension Prediction Model...")

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=self.test_size, random_state=self.random_state, stratify=y
        )

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train Random Forest
        rf_model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=2,
            random_state=self.random_state,
            class_weight='balanced'
        )

        rf_model.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred = rf_model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)

        print(f"   ✅ Hypertension Model Accuracy: {accuracy:.2%}")
        print(f"   📊 Classification Report:")
        print(f"   {classification_report(y_test, y_pred, target_names=['Low Risk', 'High Risk'])}")

        # Store model and scaler
        self.models['hypertension_model'] = rf_model
        self.scalers['hypertension_scaler'] = scaler

        # Store metadata
        self.model_metadata['hypertension'] = {
            'accuracy': float(accuracy),
            'feature_importance': dict(zip([
                'age', 'bmi', 'blood_pressure_systolic', 'blood_pressure_diastolic',
                'blood_sugar', 'cholesterol_total', 'smoking', 'activity_level'
            ], rf_model.feature_importances_.tolist())),
            'trained_at': datetime.now().isoformat()
        }

        return rf_model, scaler, accuracy

    def train_diabetes_model(self, X, y):
        """Train Logistic Regression model for diabetes prediction"""
        print("\n🔬 Training Diabetes Prediction Model...")

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=self.test_size, random_state=self.random_state, stratify=y
        )

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train Logistic Regression
        lr_model = LogisticRegression(
            max_iter=1000,
            class_weight='balanced',
            random_state=self.random_state
        )

        lr_model.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred = lr_model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)

        print(f"   ✅ Diabetes Model Accuracy: {accuracy:.2%}")
        print(f"   📊 Classification Report:")
        print(f"   {classification_report(y_test, y_pred, target_names=['Low Risk', 'High Risk'])}")

        # Store model and scaler
        self.models['diabetes_model'] = lr_model
        self.scalers['diabetes_scaler'] = scaler

        # Store metadata
        self.model_metadata['diabetes'] = {
            'accuracy': float(accuracy),
            'feature_coefficients': dict(zip([
                'age', 'bmi', 'blood_pressure_systolic', 'blood_pressure_diastolic',
                'blood_sugar', 'cholesterol_total', 'smoking', 'activity_level'
            ], lr_model.coef_[0].tolist())),
            'trained_at': datetime.now().isoformat()
        }

        return lr_model, scaler, accuracy

    def train_heart_disease_model(self, X, y):
        """Train Decision Tree model for heart disease prediction"""
        print("\n🔬 Training Heart Disease Prediction Model...")

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=self.test_size, random_state=self.random_state, stratify=y
        )

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train Decision Tree
        dt_model = DecisionTreeClassifier(
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=2,
            class_weight='balanced',
            random_state=self.random_state
        )

        dt_model.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred = dt_model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)

        print(f"   ✅ Heart Disease Model Accuracy: {accuracy:.2%}")
        print(f"   📊 Classification Report:")
        print(f"   {classification_report(y_test, y_pred, target_names=['Low Risk', 'High Risk'])}")

        # Store model and scaler
        self.models['heart_disease_model'] = dt_model
        self.scalers['heart_disease_scaler'] = scaler

        # Store metadata
        self.model_metadata['heart_disease'] = {
            'accuracy': float(accuracy),
            'feature_importance': dict(zip([
                'age', 'bmi', 'blood_pressure_systolic', 'blood_pressure_diastolic',
                'blood_sugar', 'cholesterol_total', 'smoking', 'activity_level'
            ], dt_model.feature_importances_.tolist())),
            'trained_at': datetime.now().isoformat()
        }

        return dt_model, scaler, accuracy

    def train_obesity_model(self, X, y):
        """Train SVM model for obesity-related conditions prediction"""
        print("\n🔬 Training Obesity-Related Conditions Model...")

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=self.test_size, random_state=self.random_state, stratify=y
        )

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train SVM
        svm_model = SVC(
            kernel='rbf',
            probability=True,
            class_weight='balanced',
            random_state=self.random_state
        )

        svm_model.fit(X_train_scaled, y_train)

        # Evaluate
        y_pred = svm_model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)

        print(f"   ✅ Obesity Model Accuracy: {accuracy:.2%}")
        print(f"   📊 Classification Report:")
        print(f"   {classification_report(y_test, y_pred, target_names=['Low Risk', 'High Risk'])}")

        # Store model and scaler
        self.models['obesity_model'] = svm_model
        self.scalers['obesity_scaler'] = scaler

        # Store metadata
        self.model_metadata['obesity'] = {
            'accuracy': float(accuracy),
            'trained_at': datetime.now().isoformat()
        }

        return svm_model, scaler, accuracy

    def save_models(self):
        """Save trained models and scalers to disk"""
        print("\n💾 Saving trained models...")

        model_files = {
            'hypertension_model.pkl': self.models['hypertension_model'],
            'hypertension_scaler.pkl': self.scalers['hypertension_scaler'],
            'diabetes_model.pkl': self.models['diabetes_model'],
            'diabetes_scaler.pkl': self.scalers['diabetes_scaler'],
            'heart_disease_model.pkl': self.models['heart_disease_model'],
            'heart_disease_scaler.pkl': self.scalers['heart_disease_scaler'],
            'obesity_model.pkl': self.models['obesity_model'],
            'obesity_scaler.pkl': self.scalers['obesity_scaler']
        }

        for filename, object_to_save in model_files.items():
            filepath = os.path.join(self.models_dir, filename)
            joblib.dump(object_to_save, filepath)
            print(f"   ✅ Saved {filename}")

        # Save metadata
        metadata_path = os.path.join(self.models_dir, 'model_metadata.json')
        import json
        with open(metadata_path, 'w') as f:
            json.dump(self.model_metadata, f, indent=2)
        print(f"   ✅ Saved model_metadata.json")

    def train_all_models(self):
        """Train all disease prediction models"""
        print("=" * 60)
        print("🏥 Health Disease Prediction ML Model Training")
        print("=" * 60)
        print(f"📊 Training with {self.n_samples} synthetic samples")
        print(f"🔢 Random State: {self.random_state}")
        print(f"📈 Test Size: {self.test_size}")

        # Generate synthetic data
        print("\n📊 Generating synthetic health data...")
        df = self.generate_synthetic_data()
        print(f"   ✅ Generated {len(df)} samples")

        # Prepare features
        X = self.prepare_features(df)

        # Train each model
        self.train_hypertension_model(X, df['target_hypertension'])
        self.train_diabetes_model(X, df['target_diabetes'])
        self.train_heart_disease_model(X, df['target_heart_disease'])
        self.train_obesity_model(X, df['target_obesity'])

        # Save models
        self.save_models()

        print("\n" + "=" * 60)
        print("🎉 Model Training Complete!")
        print("=" * 60)
        print("\n📊 Model Performance Summary:")
        for model_name, metadata in self.model_metadata.items():
            print(f"   {model_name.capitalize()}: {metadata['accuracy']:.2%} accuracy")

        print("\n💡 Models saved to:", self.models_dir)
        print("🚀 Ready to make predictions!")

if __name__ == "__main__":
    # Initialize trainer
    trainer = HealthMLModelTrainer(
        n_samples=10000,
        test_size=0.2,
        random_state=42
    )

    # Train all models
    trainer.train_all_models()