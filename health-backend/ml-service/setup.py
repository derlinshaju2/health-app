#!/usr/bin/env python3
"""
Quick fix script for common startup issues
"""

import os
import sys
import subprocess

def check_python_version():
    """Check Python version"""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8+ required")
        return False
    print(f"✅ Python version: {version.major}.{version.minor}.{version.micro}")
    return True

def install_dependencies():
    """Install Python dependencies"""
    print("📦 Installing Python dependencies...")
    try:
        subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"],
                       check=True, capture_output=True)
        print("✅ Dependencies installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install dependencies: {e}")
        return False

def create_models_directory():
    """Create models directory if it doesn't exist"""
    models_dir = os.path.join(os.path.dirname(__file__), 'models')
    if not os.path.exists(models_dir):
        os.makedirs(models_dir)
        print("✅ Created models directory")
    return True

def main():
    print("🔧 Checking ML Service setup...")

    if not check_python_version():
        sys.exit(1)

    if not install_dependencies():
        sys.exit(1)

    if not create_models_directory():
        sys.exit(1)

    print("✅ ML Service setup complete!")
    print("🚀 You can now run: python app.py")

if __name__ == "__main__":
    main()