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
import { useState } from "react";
import { Info } from "lucide-react";

export default function BMICalculatorPage() {
  const [height, setHeight] = useState("");
  const [weight, setWeight] = useState("");
  const [unit, setUnit] = useState<string>("metric");
  const [bmi, setBMI] = useState<number | null>(null);
  const [category, setCategory] = useState("");

  const calculateBMI = () => {
    const h = parseFloat(height);
    const w = parseFloat(weight);

    if (!h || !w || h <= 0 || w <= 0) return;

    let bmiValue: number;

    if (unit === "metric") {
      // Metric: BMI = weight (kg) / height (m)²
      bmiValue = w / ((h / 100) * (h / 100));
    } else {
      // Imperial: BMI = 703 × weight (lbs) / height (in)²
      bmiValue = (703 * w) / (h * h);
    }

    setBMI(Math.round(bmiValue * 10) / 10);

    if (bmiValue < 18.5) {
      setCategory("Underweight");
    } else if (bmiValue < 25) {
      setCategory("Normal weight");
    } else if (bmiValue < 30) {
      setCategory("Overweight");
    } else {
      setCategory("Obese");
    }
  };

  const getBMIBadge = () => {
    if (!bmi) return null;

    if (bmi < 18.5) {
      return (
        <Badge className="bg-yellow-100 text-yellow-800 border-yellow-200 text-lg px-4 py-2">
          Underweight
        </Badge>
      );
    } else if (bmi < 25) {
      return (
        <Badge className="bg-green-100 text-green-800 border-green-200 text-lg px-4 py-2">
          Normal weight
        </Badge>
      );
    } else if (bmi < 30) {
      return (
        <Badge className="bg-orange-100 text-orange-800 border-orange-200 text-lg px-4 py-2">
          Overweight
        </Badge>
      );
    } else {
      return (
        <Badge className="bg-red-100 text-red-800 border-red-200 text-lg px-4 py-2">
          Obese
        </Badge>
      );
    }
  };

  const getHealthTips = () => {
    if (!bmi) return null;

    if (bmi < 18.5) {
      return (
        <Alert>
          <Info className="h-4 w-4" />
          <AlertDescription>
            <strong>Health Tips:</strong> Consider increasing your calorie intake
            with nutrient-rich foods. Focus on lean proteins, whole grains, and
            healthy fats. Strength training can help build muscle mass.
          </AlertDescription>
        </Alert>
      );
    } else if (bmi < 25) {
      return (
        <Alert>
          <Info className="h-4 w-4" />
          <AlertDescription>
            <strong>Great job!</strong> Your BMI is in the healthy range. Maintain
            your current lifestyle with balanced nutrition and regular exercise
            to stay healthy.
          </AlertDescription>
        </Alert>
      );
    } else if (bmi < 30) {
      return (
        <Alert>
          <Info className="h-4 w-4" />
          <AlertDescription>
            <strong>Health Tips:</strong> Consider incorporating more physical
            activity into your routine. Focus on a balanced diet with portion
            control. Consult a healthcare provider for personalized advice.
          </AlertDescription>
        </Alert>
      );
    } else {
      return (
        <Alert>
          <Info className="h-4 w-4" />
          <AlertDescription>
            <strong>Health Tips:</strong> Consider consulting a healthcare
            provider for a personalized weight management plan. Focus on gradual,
            sustainable lifestyle changes with diet and exercise.
          </AlertDescription>
        </Alert>
      );
    }
  };

  return (
    <MainLayout>
      <div className="space-y-8 max-w-4xl mx-auto">
        {/* Header */}
        <div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            BMI Calculator
          </h1>
          <p className="text-gray-600">
            Calculate your Body Mass Index and get personalized health recommendations.
          </p>
        </div>

        {/* BMI Calculator Card */}
        <Card>
          <CardHeader>
            <CardTitle>Calculate Your BMI</CardTitle>
            <CardDescription>
              Enter your height and weight to calculate your BMI
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Unit Selection */}
            <div className="space-y-2">
              <Label>Measurement Unit</Label>
              <Select
                value={unit}
                onValueChange={(value) => setUnit(value || "metric")}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="metric">Metric (cm/kg)</SelectItem>
                  <SelectItem value="imperial">Imperial (in/lbs)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Height Input */}
            <div className="space-y-2">
              <Label htmlFor="height">
                Height ({unit === "metric" ? "cm" : "inches"})
              </Label>
              <Input
                id="height"
                type="number"
                placeholder={unit === "metric" ? "175" : "69"}
                value={height}
                onChange={(e) => setHeight(e.target.value)}
              />
            </div>

            {/* Weight Input */}
            <div className="space-y-2">
              <Label htmlFor="weight">
                Weight ({unit === "metric" ? "kg" : "lbs"})
              </Label>
              <Input
                id="weight"
                type="number"
                placeholder={unit === "metric" ? "70" : "154"}
                value={weight}
                onChange={(e) => setWeight(e.target.value)}
              />
            </div>

            {/* Calculate Button */}
            <Button
              onClick={calculateBMI}
              className="w-full bg-gradient-to-r from-primary to-secondary"
              size="lg"
            >
              Calculate BMI
            </Button>
          </CardContent>
        </Card>

        {/* BMI Results */}
        {bmi !== null && (
          <Card>
            <CardHeader>
              <CardTitle>Your Results</CardTitle>
              <CardDescription>
                Based on your inputs, here's your BMI assessment
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* BMI Value */}
              <div className="text-center">
                <div className="text-7xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent mb-4">
                  {bmi}
                </div>
                <div className="flex justify-center mb-4">{getBMIBadge()}</div>
                <p className="text-gray-600">
                  Your BMI is {bmi}, which falls into the{" "}
                  <strong>{category}</strong> category
                </p>
              </div>

              {/* BMI Categories */}
              <div className="space-y-3">
                <h3 className="font-semibold text-gray-900">BMI Categories:</h3>
                <div className="grid grid-cols-2 gap-3">
                  <div
                    className={`p-3 rounded-lg border-2 ${
                      bmi < 18.5
                        ? "border-yellow-400 bg-yellow-50"
                        : "border-gray-200"
                    }`}
                  >
                    <div className="font-medium">Underweight</div>
                    <div className="text-sm text-gray-600">&lt; 18.5</div>
                  </div>
                  <div
                    className={`p-3 rounded-lg border-2 ${
                      bmi >= 18.5 && bmi < 25
                        ? "border-green-400 bg-green-50"
                        : "border-gray-200"
                    }`}
                  >
                    <div className="font-medium">Normal weight</div>
                    <div className="text-sm text-gray-600">18.5 - 24.9</div>
                  </div>
                  <div
                    className={`p-3 rounded-lg border-2 ${
                      bmi >= 25 && bmi < 30
                        ? "border-orange-400 bg-orange-50"
                        : "border-gray-200"
                    }`}
                  >
                    <div className="font-medium">Overweight</div>
                    <div className="text-sm text-gray-600">25 - 29.9</div>
                  </div>
                  <div
                    className={`p-3 rounded-lg border-2 ${
                      bmi >= 30 ? "border-red-400 bg-red-50" : "border-gray-200"
                    }`}
                  >
                    <div className="font-medium">Obese</div>
                    <div className="text-sm text-gray-600">≥ 30</div>
                  </div>
                </div>
              </div>

              {/* Health Tips */}
              {getHealthTips()}
            </CardContent>
          </Card>
        )}
      </div>
    </MainLayout>
  );
}
