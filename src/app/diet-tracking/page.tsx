"use client";

import { MainLayout } from "@/components/layout/main-layout";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useState } from "react";
import {
  Apple,
  Droplets,
  Utensils,
  Plus,
  CheckCircle2,
  AlertCircle,
} from "lucide-react";

export default function DietTrackingPage() {
  const [waterIntake, setWaterIntake] = useState(2);
  const [mealCalories, setMealCalories] = useState("");

  const dailyCalorieGoal = 2500;
  const currentCalories = 1850;
  const waterGoal = 3;

  const macros = {
    protein: { current: 120, goal: 150, unit: "g" },
    carbs: { current: 200, goal: 300, unit: "g" },
    fats: { current: 65, goal: 80, unit: "g" },
  };

  const meals = [
    {
      name: "Breakfast",
      time: "8:00 AM",
      calories: 450,
      items: "Oatmeal with berries, Greek yogurt, Green tea",
    },
    {
      name: "Lunch",
      time: "1:00 PM",
      calories: 650,
      items: "Grilled chicken salad, Brown rice, Fresh fruit",
    },
    {
      name: "Snack",
      time: "4:00 PM",
      calories: 200,
      items: "Almonds, Apple, Protein shake",
    },
    {
      name: "Dinner",
      time: "7:30 PM",
      calories: 550,
      items: "Salmon, Quinoa, Steamed vegetables",
    },
  ];

  const addWater = () => {
    if (waterIntake < waterGoal) {
      setWaterIntake(waterIntake + 0.25);
    }
  };

  const addMeal = () => {
    if (mealCalories) {
      // In a real app, this would add to the meal log
      alert(`Adding meal with ${mealCalories} calories`);
      setMealCalories("");
    }
  };

  return (
    <MainLayout>
      <div className="space-y-8">
        {/* Header */}
        <div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Diet & Nutrition
          </h1>
          <p className="text-gray-600">
            Track your meals, monitor nutrition, and achieve your health goals
          </p>
        </div>

        {/* Daily Overview */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Calories
              </CardTitle>
              <Utensils className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">
                {currentCalories}
              </div>
              <Progress
                value={(currentCalories / dailyCalorieGoal) * 100}
                className="h-2 mb-2"
              />
              <p className="text-xs text-gray-600">
                {Math.round((currentCalories / dailyCalorieGoal) * 100)}% of daily
                goal ({dailyCalorieGoal} cal)
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Water Intake
              </CardTitle>
              <Droplets className="h-5 w-5 text-blue-500" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">
                {waterIntake}L
              </div>
              <Progress value={(waterIntake / waterGoal) * 100} className="h-2 mb-2" />
              <p className="text-xs text-gray-600 mb-3">
                {Math.round((waterIntake / waterGoal) * 100)}% of daily goal (
                {waterGoal}L)
              </p>
              <Button onClick={addWater} size="sm" className="w-full">
                <Plus className="h-4 w-4 mr-1" />
                Add Glass (+250ml)
              </Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Meals Logged
              </CardTitle>
              <Apple className="h-5 w-5 text-green-500" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">4</div>
              <Progress value={80} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                Great progress! Log your dinner to complete the day.
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Nutrition Tabs */}
        <Tabs defaultValue="macros" className="space-y-6">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="macros">Macros</TabsTrigger>
            <TabsTrigger value="meals">Meals</TabsTrigger>
            <TabsTrigger value="log">Log Meal</TabsTrigger>
            <TabsTrigger value="tips">Tips</TabsTrigger>
          </TabsList>

          {/* Macros Tab */}
          <TabsContent value="macros" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Macronutrient Breakdown</CardTitle>
                <CardDescription>
                  Track your daily protein, carbs, and fats
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Protein */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="font-medium">Protein</span>
                    <Badge variant="outline">
                      {macros.protein.current}/{macros.protein.goal}
                      {macros.protein.unit}
                    </Badge>
                  </div>
                  <Progress
                    value={(macros.protein.current / macros.protein.goal) * 100}
                    className="h-3"
                  />
                  <p className="text-sm text-gray-600">
                    {macros.protein.current >= macros.protein.goal ? (
                      <span className="flex items-center text-green-600">
                        <CheckCircle2 className="h-4 w-4 mr-1" />
                        Goal reached!
                      </span>
                    ) : (
                      <span className="flex items-center text-yellow-600">
                        <AlertCircle className="h-4 w-4 mr-1" />
                        Need {macros.protein.goal - macros.protein.current}g more
                      </span>
                    )}
                  </p>
                </div>

                {/* Carbs */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="font-medium">Carbohydrates</span>
                    <Badge variant="outline">
                      {macros.carbs.current}/{macros.carbs.goal}
                      {macros.carbs.unit}
                    </Badge>
                  </div>
                  <Progress
                    value={(macros.carbs.current / macros.carbs.goal) * 100}
                    className="h-3"
                  />
                  <p className="text-sm text-gray-600">
                    Focus on complex carbs from whole grains, fruits, and vegetables.
                  </p>
                </div>

                {/* Fats */}
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="font-medium">Fats</span>
                    <Badge variant="outline">
                      {macros.fats.current}/{macros.fats.goal}
                      {macros.fats.unit}
                    </Badge>
                  </div>
                  <Progress
                    value={(macros.fats.current / macros.fats.goal) * 100}
                    className="h-3"
                  />
                  <p className="text-sm text-gray-600">
                    Include healthy fats from avocados, nuts, and olive oil.
                  </p>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Meals Tab */}
          <TabsContent value="meals" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Today's Meals</CardTitle>
                <CardDescription>Your food log for today</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {meals.map((meal, index) => (
                    <div
                      key={index}
                      className="flex items-start gap-4 p-4 border rounded-lg hover:bg-gray-50 transition-colors"
                    >
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold">
                        {meal.name[0]}
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center justify-between mb-1">
                          <h3 className="font-semibold">{meal.name}</h3>
                          <Badge variant="outline">{meal.time}</Badge>
                        </div>
                        <p className="text-sm text-gray-600 mb-2">{meal.items}</p>
                        <Badge className="bg-primary text-white">
                          {meal.calories} calories
                        </Badge>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Log Meal Tab */}
          <TabsContent value="log" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Log Your Meal</CardTitle>
                <CardDescription>Add what you've eaten to track your nutrition</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label>Meal Type</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select meal type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="breakfast">Breakfast</SelectItem>
                      <SelectItem value="lunch">Lunch</SelectItem>
                      <SelectItem value="dinner">Dinner</SelectItem>
                      <SelectItem value="snack">Snack</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>Food Items</Label>
                  <Input placeholder="e.g., Grilled chicken, Brown rice, Broccoli" />
                </div>

                <div className="space-y-2">
                  <Label>Calories</Label>
                  <Input
                    type="number"
                    placeholder="500"
                    value={mealCalories}
                    onChange={(e) => setMealCalories(e.target.value)}
                  />
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label>Protein (g)</Label>
                    <Input type="number" placeholder="30" />
                  </div>
                  <div className="space-y-2">
                    <Label>Carbs (g)</Label>
                    <Input type="number" placeholder="45" />
                  </div>
                  <div className="space-y-2">
                    <Label>Fats (g)</Label>
                    <Input type="number" placeholder="15" />
                  </div>
                </div>

                <Button
                  onClick={addMeal}
                  className="w-full bg-gradient-to-r from-primary to-secondary"
                  size="lg"
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Log Meal
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Tips Tab */}
          <TabsContent value="tips" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Nutrition Tips</CardTitle>
                <CardDescription>
                  Personalized recommendations for your health journey
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
                    <h3 className="font-semibold text-blue-900 mb-2">
                      💧 Stay Hydrated
                    </h3>
                    <p className="text-sm text-blue-800">
                      Drink at least 8 glasses of water daily. Proper hydration aids
                      digestion and helps maintain energy levels.
                    </p>
                  </div>

                  <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                    <h3 className="font-semibold text-green-900 mb-2">
                      🥗 Eat More Vegetables
                    </h3>
                    <p className="text-sm text-green-800">
                      Aim for at least 5 servings of vegetables daily. They provide
                      essential vitamins, minerals, and fiber.
                    </p>
                  </div>

                  <div className="p-4 bg-purple-50 border border-purple-200 rounded-lg">
                    <h3 className="font-semibold text-purple-900 mb-2">
                      🍳 Prioritize Protein
                    </h3>
                    <p className="text-sm text-purple-800">
                      Include protein in every meal. It helps build muscle, keeps you
                      full longer, and supports metabolism.
                    </p>
                  </div>

                  <div className="p-4 bg-orange-50 border border-orange-200 rounded-lg">
                    <h3 className="font-semibold text-orange-900 mb-2">
                      🍎 Choose Whole Foods
                    </h3>
                    <p className="text-sm text-orange-800">
                      Opt for whole, unprocessed foods. They're more nutritious and
                      help reduce intake of added sugars and unhealthy fats.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </MainLayout>
  );
}
