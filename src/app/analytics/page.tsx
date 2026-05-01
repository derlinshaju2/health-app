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
import {
  Trophy,
  Star,
  TrendingUp,
  Award,
  Target,
  Download,
  Share2,
} from "lucide-react";

export default function AnalyticsPage() {
  const healthScore = 87;

  const achievements = [
    { name: "Calorie Champion", icon: "🔥", earned: true, description: "Logged meals for 30 days straight" },
    { name: "Yoga Devotee", icon: "🧘", earned: true, description: "Completed 20 yoga sessions this month" },
    { name: "Hydration Hero", icon: "💧", earned: true, description: "Met water goals for 7 consecutive days" },
    { name: "Weight Warrior", icon: "⚖️", earned: true, description: "Achieved 2.5 kg weight loss goal" },
    { name: "Step Master", icon: "🏃", earned: false, description: "Reach 10,000 daily steps for 30 days", progress: "18/30 days" },
    { name: "Nutrition Expert", icon: "🥗", earned: false, description: "Log 100 healthy meals", progress: "67/100 meals" },
  ];

  const weeklyData = [
    { day: "Mon", steps: 85, sleep: 70, water: 90, exercise: 75 },
    { day: "Tue", steps: 90, sleep: 80, water: 85, exercise: 85 },
    { day: "Wed", steps: 75, sleep: 65, water: 88, exercise: 70 },
    { day: "Thu", steps: 95, sleep: 85, water: 92, exercise: 90 },
    { day: "Fri", steps: 88, sleep: 75, water: 80, exercise: 82 },
    { day: "Sat", steps: 92, sleep: 90, water: 95, exercise: 88 },
    { day: "Sun", steps: 70, sleep: 60, water: 85, exercise: 75 },
  ];

  const scoreComponents = [
    { name: "Physical Activity", score: 92, icon: "🏃" },
    { name: "Nutrition", score: 85, icon: "🥗" },
    { name: "Sleep Quality", score: 88, icon: "😴" },
    { name: "Hydration", score: 70, icon: "💧" },
    { name: "Stress Management", score: 90, icon: "🧘" },
  ];

  return (
    <MainLayout>
      <div className="space-y-8">
        {/* Header */}
        <div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Analytics</h1>
          <p className="text-gray-600">
            Comprehensive health insights and progress tracking
          </p>
        </div>

        {/* Health Score Dashboard */}
        <Card>
          <CardHeader>
            <CardTitle>Your Overall Health Score</CardTitle>
            <CardDescription>
              Based on your recent health metrics and activities
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col md:flex-row items-center gap-8">
              {/* Main Score */}
              <div className="flex-shrink-0">
                <div className="w-48 h-48 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center shadow-2xl">
                  <div className="text-center text-white">
                    <div className="text-6xl font-bold">{healthScore}</div>
                    <div className="text-lg">Excellent</div>
                  </div>
                </div>
              </div>

              {/* Score Components */}
              <div className="flex-1 space-y-4">
                <h3 className="text-lg font-semibold">Score Components</h3>
                {scoreComponents.map((component) => (
                  <div key={component.name} className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium">
                        {component.icon} {component.name}
                      </span>
                      <Badge variant="outline">{component.score}/100</Badge>
                    </div>
                    <Progress value={component.score} className="h-2" />
                  </div>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Analytics Tabs */}
        <Tabs defaultValue="achievements" className="space-y-6">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="achievements">Achievements</TabsTrigger>
            <TabsTrigger value="weekly">Weekly Report</TabsTrigger>
            <TabsTrigger value="trends">Trends</TabsTrigger>
            <TabsTrigger value="export">Export</TabsTrigger>
          </TabsList>

          {/* Achievements Tab */}
          <TabsContent value="achievements" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Achievements & Milestones</CardTitle>
                <CardDescription>Your health journey accomplishments</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {achievements.map((achievement) => (
                    <div
                      key={achievement.name}
                      className={`p-4 rounded-lg border-2 transition-all ${
                        achievement.earned
                          ? "border-green-200 bg-green-50"
                          : "border-gray-200 bg-gray-50 opacity-70"
                      }`}
                    >
                      <div className="flex items-start gap-4">
                        <div className="text-4xl">{achievement.icon}</div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className="font-semibold">{achievement.name}</h3>
                            {achievement.earned && (
                              <Badge className="bg-green-100 text-green-800 border-green-200">
                                <Trophy className="h-3 w-3 mr-1" />
                                Earned
                              </Badge>
                            )}
                          </div>
                          <p className="text-sm text-gray-600 mb-2">
                            {achievement.description}
                          </p>
                          {!achievement.earned && achievement.progress && (
                            <div className="flex items-center gap-2">
                              <Progress value={60} className="h-2 flex-1" />
                              <span className="text-xs text-gray-600">
                                {achievement.progress}
                              </span>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Weekly Report Tab */}
          <TabsContent value="weekly" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Weekly Health Report</CardTitle>
                <CardDescription>Your health metrics over the past 7 days</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  {/* Daily Metrics */}
                  <div>
                    <h3 className="font-semibold mb-4">Daily Health Metrics</h3>
                    <div className="grid grid-cols-7 gap-2">
                      {weeklyData.map((day) => (
                        <div key={day.day} className="text-center">
                          <div className="text-xs font-medium mb-2">{day.day}</div>
                          <div className="flex flex-col gap-1">
                            <div
                              className="h-12 bg-green-500 rounded"
                              style={{ height: `${day.steps * 1.5}px` }}
                              title={`Steps: ${day.steps}%`}
                            />
                            <div
                              className="h-12 bg-blue-500 rounded"
                              style={{ height: `${day.sleep * 1.5}px` }}
                              title={`Sleep: ${day.sleep}%`}
                            />
                            <div
                              className="h-12 bg-cyan-500 rounded"
                              style={{ height: `${day.water * 1.5}px` }}
                              title={`Water: ${day.water}%`}
                            />
                            <div
                              className="h-12 bg-purple-500 rounded"
                              style={{ height: `${day.exercise * 1.5}px` }}
                              title={`Exercise: ${day.exercise}%`}
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                    <div className="flex justify-center gap-6 mt-4 text-sm">
                      <div className="flex items-center gap-2">
                        <div className="w-4 h-4 bg-green-500 rounded"></div>
                        <span>Exercise</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <div className="w-4 h-4 bg-blue-500 rounded"></div>
                        <span>Sleep</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <div className="w-4 h-4 bg-cyan-500 rounded"></div>
                        <span>Water</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <div className="w-4 h-4 bg-purple-500 rounded"></div>
                        <span>Mindfulness</span>
                      </div>
                    </div>
                  </div>

                  {/* Weekly Summary */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                      <h3 className="font-semibold text-green-900 mb-2 flex items-center gap-2">
                        <TrendingUp className="h-4 w-4" />
                        This Week's Highlights
                      </h3>
                      <ul className="text-sm text-green-800 space-y-1">
                        <li>✅ Increased daily steps by 12%</li>
                        <li>✅ Improved sleep consistency by 5%</li>
                        <li>✅ Added 2 extra yoga sessions</li>
                        <li>✅ Better hydration throughout the week</li>
                      </ul>
                    </div>

                    <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                      <h3 className="font-semibold text-yellow-900 mb-2 flex items-center gap-2">
                        <Target className="h-4 w-4" />
                        Areas for Improvement
                      </h3>
                      <ul className="text-sm text-yellow-800 space-y-1">
                        <li>🎯 Add strength training 2x per week</li>
                        <li>🎯 Increase fiber intake for better digestion</li>
                        <li>🎯 Practice stress management techniques</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Trends Tab */}
          <TabsContent value="trends" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Health Trends</CardTitle>
                <CardDescription>Your progress over time</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="font-medium">Weight Trend</span>
                      <Badge className="bg-green-100 text-green-800 border-green-200">
                        <TrendingUp className="h-3 w-3 mr-1" />
                        On Track
                      </Badge>
                    </div>
                    <Progress value={75} className="h-3" />
                    <p className="text-sm text-gray-600">
                      Lost 2.5 kg over the past month - 50% towards your goal
                    </p>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="font-medium">Calorie Consistency</span>
                      <Badge className="bg-blue-100 text-blue-800 border-blue-200">
                        <Star className="h-3 w-3 mr-1" />
                        Excellent
                      </Badge>
                    </div>
                    <Progress value={90} className="h-3" />
                    <p className="text-sm text-gray-600">
                      Maintained consistent calorie intake for 28 days
                    </p>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="font-medium">Exercise Frequency</span>
                      <Badge className="bg-purple-100 text-purple-800 border-purple-200">
                        <Award className="h-3 w-3 mr-1" />
                        Great Progress
                      </Badge>
                    </div>
                    <Progress value={85} className="h-3" />
                    <p className="text-sm text-gray-600">
                      Completed 5 workouts per week on average
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Export Tab */}
          <TabsContent value="export" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Export & Share Your Data</CardTitle>
                <CardDescription>
                  Download reports or share your progress
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="p-4 border rounded-lg space-y-3">
                    <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center">
                      <Download className="h-6 w-6 text-blue-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold">Download Reports</h3>
                      <p className="text-sm text-gray-600">
                        Export your health data as detailed PDF reports
                      </p>
                    </div>
                    <Button className="w-full" variant="outline">
                      Download PDF
                    </Button>
                  </div>

                  <div className="p-4 border rounded-lg space-y-3">
                    <div className="w-12 h-12 rounded-lg bg-green-100 flex items-center justify-center">
                      <Share2 className="h-6 w-6 text-green-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold">Share Progress</h3>
                      <p className="text-sm text-gray-600">
                        Share your achievements with friends and family
                      </p>
                    </div>
                    <Button className="w-full" variant="outline">
                      Share
                    </Button>
                  </div>

                  <div className="p-4 border rounded-lg space-y-3">
                    <div className="w-12 h-12 rounded-lg bg-purple-100 flex items-center justify-center">
                      <TrendingUp className="h-6 w-6 text-purple-600" />
                    </div>
                    <div>
                      <h3 className="font-semibold">View Trends</h3>
                      <p className="text-sm text-gray-600">
                        Analyze your health trends over time
                      </p>
                    </div>
                    <Button className="w-full" variant="outline">
                      View Analytics
                    </Button>
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
