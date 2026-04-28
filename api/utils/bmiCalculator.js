/**
 * Calculate BMI from weight and height
 * @param {number} weight - Weight in kilograms
 * @param {number} height - Height in centimeters
 * @returns {object} BMI value and category
 */
const calculateBMI = (weight, height) => {
  if (!weight || !height || weight <= 0 || height <= 0) {
    return {
      value: null,
      category: null
    };
  }

  const heightInMeters = height / 100;
  const bmi = weight / (heightInMeters * heightInMeters);

  return {
    value: parseFloat(bmi.toFixed(1)),
    category: getBMICategory(bmi)
  };
};

/**
 * Get BMI category from BMI value
 * @param {number} bmi - BMI value
 * @returns {string} BMI category
 */
const getBMICategory = (bmi) => {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal weight';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
};

/**
 * Get health recommendations based on BMI category
 * @param {string} category - BMI category
 * @returns {array} Array of recommendations
 */
const getBMIRecommendations = (category) => {
  const recommendations = {
    Underweight: [
      'Increase calorie intake with nutrient-dense foods',
      'Include protein-rich foods in your diet',
      'Consider strength training to build muscle mass',
      'Consult a nutritionist for personalized weight gain plan'
    ],
    'Normal weight': [
      'Maintain current balanced diet',
      'Continue regular physical activity',
      'Monitor weight regularly',
      'Stay hydrated and get adequate sleep'
    ],
    Overweight: [
      'Create a moderate calorie deficit',
      'Increase physical activity to 150 minutes per week',
      'Focus on whole foods and reduce processed foods',
      'Consider portion control'
    ],
    Obese: [
      'Consult a healthcare provider for weight management plan',
      'Aim for 5-10% weight loss for health benefits',
      'Gradually increase physical activity under medical supervision',
      'Consider working with a dietitian'
    ]
  };

  return recommendations[category] || [];
};

/**
 * Calculate ideal weight range based on height
 * @param {number} height - Height in centimeters
 * @returns {object} Min and max ideal weight in kg
 */
const calculateIdealWeight = (height) => {
  const heightInMeters = height / 100;

  // Normal BMI range is 18.5 - 24.9
  const minWeight = 18.5 * heightInMeters * heightInMeters;
  const maxWeight = 24.9 * heightInMeters * heightInMeters;

  return {
    min: Math.round(minWeight),
    max: Math.round(maxWeight)
  };
};

module.exports = {
  calculateBMI,
  getBMICategory,
  getBMIRecommendations,
  calculateIdealWeight
};