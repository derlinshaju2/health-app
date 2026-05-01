"use client";

import { MainLayout } from "@/components/layout/main-layout";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Progress } from "@/components/ui/progress";
import { useState } from "react";
import { Activity, AlertTriangle, Heart, Info } from "lucide-react";

export default function DiseasePredictionPage() {
  const [formData, setFormData] = useState({
    age: "",
    gender: "",
    bloodPressureSystolic: "",
    bloodPressureDiastolic: "",
    bloodSugar: "",
    cholesterol: "",
    bmi: "",
    smoking: "",
    activityLevel: "",
  });

  const [showResults, setShowResults] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setLoading(true);
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 2000));
    setLoading(false);
    setShowResults(true);
  };

  const riskLevels = {
    cardiovascular: 72,
    diabetes: 45,
    respiratory: 28,
    neurological: 15,
  };

  const getRiskBadge = (level: number) => {
    if (level >= 70) {
      return (
        <Badge className="bg-red-100 text-red-800 border-red-200">
          High Risk
        </Badge>
      );
    } else if (level >= 40) {
      return (
        <Badge className="bg-yellow-100 text-yellow-800 border-yellow-200">
          Medium Risk
        </Badge>
      );
    } else {
      return (
        <Badge className="bg-green-100 text-green-800 border-green-200">
          Low Risk
        </Badge>
      );
    }
  };

  return (
    <MainLayout>
      <div className="space-y-8">
        {/* Header */}
        <div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Disease Prediction
          </h1>
          <p className="text-gray-600">
            AI-powered health risk assessment based on your health metrics
          </p>
        </div>

        {/* Health Input Form */}
        <Card>
          <CardHeader>
            <CardTitle>Enter Your Health Data</CardTitle>
            <CardDescription>
              Provide accurate health information for personalized risk assessment
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Personal Information */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="age">Age</Label>
                <Input
                  id="age"
                  type="number"
                  placeholder="35"
                  value={formData.age}
                  onChange={(e) =>
                    setFormData({ ...formData, age: e.target.value })
                  }
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="gender">Gender</Label>
                <Select
                  value={formData.gender}
                  onValueChange={(value) =>
                    setFormData({ ...formData, gender: value || "" })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select gender" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="male">Male</SelectItem>
                    <SelectItem value="female">Female</SelectItem>
                    <SelectItem value="other">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Blood Pressure */}
            <div className="space-y-2">
              <Label>Blood Pressure (mmHg)</Label>
              <div className="grid grid-cols-2 gap-4">
                <Input
                  type="number"
                  placeholder="Systolic (120)"
                  value={formData.bloodPressureSystolic}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      bloodPressureSystolic: e.target.value,
                    })
                  }
                />
                <Input
                  type="number"
                  placeholder="Diastolic (80)"
                  value={formData.bloodPressureDiastolic}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      bloodPressureDiastolic: e.target.value,
                    })
                  }
                />
              </div>
            </div>

            {/* Blood Metrics */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="bloodSugar">Blood Sugar (mg/dL)</Label>
                <Input
                  id="bloodSugar"
                  type="number"
                  placeholder="100"
                  value={formData.bloodSugar}
                  onChange={(e) =>
                    setFormData({ ...formData, bloodSugar: e.target.value })
                  }
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="cholesterol">Cholesterol (mg/dL)</Label>
                <Input
                  id="cholesterol"
                  type="number"
                  placeholder="200"
                  value={formData.cholesterol}
                  onChange={(e) =>
                    setFormData({ ...formData, cholesterol: e.target.value })
                  }
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="bmi">BMI</Label>
                <Input
                  id="bmi"
                  type="number"
                  placeholder="22.5"
                  value={formData.bmi}
                  onChange={(e) =>
                    setFormData({ ...formData, bmi: e.target.value })
                  }
                />
              </div>
            </div>

            {/* Lifestyle Factors */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="smoking">Smoking Status</Label>
                <Select
                  value={formData.smoking}
                  onValueChange={(value) =>
                    setFormData({ ...formData, smoking: value || "" })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="never">Never Smoked</SelectItem>
                    <SelectItem value="former">Former Smoker</SelectItem>
                    <SelectItem value="current">Current Smoker</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="activity">Activity Level</Label>
                <Select
                  value={formData.activityLevel}
                  onValueChange={(value) =>
                    setFormData({ ...formData, activityLevel: value || "" })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select activity" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="sedentary">Sedentary</SelectItem>
                    <SelectItem value="light">Light Activity</SelectItem>
                    <SelectItem value="moderate">Moderate Activity</SelectItem>
                    <SelectItem value="active">Very Active</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Submit Button */}
            <Button
              onClick={handleSubmit}
              disabled={loading}
              className="w-full bg-gradient-to-r from-primary to-secondary"
              size="lg"
            >
              {loading ? "Analyzing..." : "Analyze Health Risks"}
            </Button>
          </CardContent>
        </Card>

        {/* Risk Assessment Results */}
        {showResults && (
          <>
            <Card>
              <CardHeader>
                <CardTitle>Risk Assessment Results</CardTitle>
                <CardDescription>
                  Based on your health data, here are your risk levels
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Cardiovascular Risk */}
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Heart className="h-5 w-5 text-red-500" />
                      <span className="font-semibold">Cardiovascular Disease</span>
                    </div>
                    {getRiskBadge(riskLevels.cardiovascular)}
                  </div>
                  <Progress value={riskLevels.cardiovascular} className="h-3" />
                  <p className="text-sm text-gray-600">
                    {riskLevels.cardiovascular >= 70
                      ? "High risk detected. Consider consulting a cardiologist."
                      : "Moderate risk factors present. Monitor blood pressure regularly."}
                  </p>
                </div>

                {/* Diabetes Risk */}
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Activity className="h-5 w-5 text-blue-500" />
                      <span className="font-semibold">Type 2 Diabetes</span>
                    </div>
                    {getRiskBadge(riskLevels.diabetes)}
                  </div>
                  <Progress value={riskLevels.diabetes} className="h-3" />
                  <p className="text-sm text-gray-600">
                    {riskLevels.diabetes >= 40
                      ? "Elevated blood sugar detected. Monitor glucose levels."
                      : "Blood sugar levels within normal range."}
                  </p>
                </div>

                {/* Respiratory Risk */}
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Activity className="h-5 w-5 text-purple-500" />
                      <span className="font-semibold">Respiratory Diseases</span>
                    </div>
                    {getRiskBadge(riskLevels.respiratory)}
                  </div>
                  <Progress value={riskLevels.respiratory} className="h-3" />
                  <p className="text-sm text-gray-600">
                    Low to moderate risk. Maintain healthy lifestyle habits.
                  </p>
                </div>

                {/* Neurological Risk */}
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Activity className="h-5 w-5 text-green-500" />
                      <span className="font-semibold">Neurological Disorders</span>
                    </div>
                    {getRiskBadge(riskLevels.neurological)}
                  </div>
                  <Progress value={riskLevels.neurological} className="h-3" />
                  <p className="text-sm text-gray-600">
                    Low risk detected. Continue healthy lifestyle practices.
                  </p>
                </div>
              </CardContent>
            </Card>

            {/* Recommendations */}
            <Card>
              <CardHeader>
                <CardTitle>Personalized Recommendations</CardTitle>
                <CardDescription>
                  Actionable steps to reduce your health risks
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <Alert>
                    <AlertTriangle className="h-4 w-4" />
                    <AlertDescription>
                      <strong>Immediate Actions:</strong>
                      <ul className="list-disc list-inside mt-2 space-y-1">
                        <li>
                          Monitor blood pressure weekly and maintain a heart-healthy
                          diet low in sodium
                        </li>
                        <li>
                          Engage in at least 150 minutes of moderate-intensity
                          exercise per week
                        </li>
                        <li>
                          Schedule regular check-ups with your healthcare provider
                        </li>
                      </ul>
                    </AlertDescription>
                  </Alert>

                  <Alert>
                    <Info className="h-4 w-4" />
                    <AlertDescription>
                      <strong>Lifestyle Modifications:</strong>
                      <ul className="list-disc list-inside mt-2 space-y-1">
                        <li>Quit smoking if you're a current smoker</li>
                        <li>Limit alcohol consumption to moderate levels</li>
                        <li>Manage stress through relaxation techniques</li>
                        <li>Maintain a healthy weight through balanced nutrition</li>
                      </ul>
                    </AlertDescription>
                  </Alert>
                </div>
              </CardContent>
            </Card>
          </>
        )}
      </div>
    </MainLayout>
  );
}
