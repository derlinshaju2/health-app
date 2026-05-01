import { MainLayout } from "@/components/layout/main-layout";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Separator } from "@/components/ui/separator";
import {
  Activity,
  Apple,
  Droplets,
  Moon,
  Target,
  TrendingUp,
} from "lucide-react";

export default function DashboardPage() {
  return (
    <MainLayout>
      <div className="space-y-8">
        {/* Header */}
        <div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Dashboard
          </h1>
          <p className="text-gray-600">
            Welcome back! Here's your health overview for today.
          </p>
        </div>

        {/* Health Overview Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Daily Steps
              </CardTitle>
              <Activity className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">8,547</div>
              <Progress value={85} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                85% of daily goal (10,000 steps)
              </p>
              <Badge className="mt-2 bg-green-100 text-green-800 border-green-200">
                <TrendingUp className="h-3 w-3 mr-1" />
                +12% vs yesterday
              </Badge>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Calories
              </CardTitle>
              <Apple className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">1,850</div>
              <Progress value={74} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                74% of daily goal (2,500 calories)
              </p>
              <Badge className="mt-2 bg-blue-100 text-blue-800 border-blue-200">
                On track
              </Badge>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Water Intake
              </CardTitle>
              <Droplets className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">2.1L</div>
              <Progress value={70} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                70% of daily goal (3 liters)
              </p>
              <Badge className="mt-2 bg-yellow-100 text-yellow-800 border-yellow-200">
                Keep drinking!
              </Badge>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Sleep
              </CardTitle>
              <Moon className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">7.2h</div>
              <Progress value={90} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                90% of daily goal (8 hours)
              </p>
              <Badge className="mt-2 bg-green-100 text-green-800 border-green-200">
                Great sleep!
              </Badge>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                BMI
              </CardTitle>
              <Target className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">22.4</div>
              <Progress value={75} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                Normal weight (18.5 - 24.9)
              </p>
              <Badge className="mt-2 bg-green-100 text-green-800 border-green-200">
                Healthy range
              </Badge>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-gray-600">
                Health Score
              </CardTitle>
              <Activity className="h-5 w-5 text-primary" />
            </CardHeader>
            <CardContent>
              <div className="text-3xl font-bold text-gray-900 mb-2">85</div>
              <Progress value={85} className="h-2 mb-2" />
              <p className="text-xs text-gray-600">
                Based on your recent health metrics
              </p>
              <Badge className="mt-2 bg-primary text-white">
                Excellent
              </Badge>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activity */}
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
            <CardDescription>Your latest health activities</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center">
                  <Activity className="h-5 w-5 text-green-600" />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-gray-900">
                    Completed Morning Yoga Session
                  </p>
                  <p className="text-sm text-gray-600">Today, 6:30 AM</p>
                </div>
                <Badge className="bg-green-100 text-green-800 border-green-200">
                  +180 cal
                </Badge>
              </div>

              <Separator />

              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                  <Droplets className="h-5 w-5 text-blue-600" />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-gray-900">
                    Reached Daily Water Goal
                  </p>
                  <p className="text-sm text-gray-600">Today, 4:15 PM</p>
                </div>
                <Badge className="bg-blue-100 text-blue-800 border-blue-200">
                  3L ✓
                </Badge>
              </div>

              <Separator />

              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center">
                  <Apple className="h-5 w-5 text-purple-600" />
                </div>
                <div className="flex-1">
                  <p className="font-medium text-gray-900">
                    Logged Healthy Lunch
                  </p>
                  <p className="text-sm text-gray-600">Today, 1:00 PM</p>
                </div>
                <Badge className="bg-purple-100 text-purple-800 border-purple-200">
                  550 kcal
                </Badge>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}
