// Accepted category values for the screening form's free-text fields.
//
// These are copied verbatim from summative/API/encoders.pkl (the same
// source the API's Pydantic Literal types are generated from in main.py's
// `_classes()` helper). Keep in sync if encoders.pkl is retrained/changed.
class BoboValidValues {
  static const gender = ['f', 'm'];

  static const ethnicity = [
    'Asian',
    'Black',
    'Hispanic',
    'Latino',
    'Middle Eastern ',
    'Others',
    'Pasifika',
    'South Asian',
    'Turkish',
    'Unknown',
    'White-European',
    'others',
  ];

  static const jundice = ['no', 'yes'];

  static const austim = ['no', 'yes'];

  static const contryOfRes = [
    'Afghanistan', 'Albania', 'AmericanSamoa', 'Angola', 'Anguilla', 'Argentina',
    'Armenia', 'Aruba', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain',
    'Bangladesh', 'Belgium', 'Bhutan', 'Bolivia', 'Brazil', 'Bulgaria', 'Burundi',
    'Canada', 'Chile', 'China', 'Comoros', 'Costa Rica', 'Croatia', 'Cyprus',
    'Czech Republic', 'Ecuador', 'Egypt', 'Ethiopia', 'Europe', 'Finland', 'France',
    'Georgia', 'Germany', 'Ghana', 'Greenland', 'Hong Kong', 'Iceland', 'India',
    'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Isle of Man', 'Italy', 'Japan', 'Jordan',
    'Kazakhstan', 'Kuwait', 'Latvia', 'Lebanon', 'Libya', 'Malaysia', 'Malta',
    'Mexico', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria',
    'Norway', 'Oman', 'Pakistan', 'Philippines', 'Portugal', 'Qatar', 'Romania',
    'Russia', 'Saudi Arabia', 'Serbia', 'Sierra Leone', 'South Africa', 'South Korea',
    'Spain', 'Sri Lanka', 'Sweden', 'Syria', 'Tonga', 'Turkey', 'U.S. Outlying Islands',
    'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay',
    'Viet Nam',
  ];

  static const usedAppBefore = ['no', 'yes'];

  static const relation = [
    'Health care professional',
    'Others',
    'Parent',
    'Relative',
    'Self',
    'Unknown',
    'self',
  ];

  static const ageGroup = ['adolescent', 'adult', 'child'];
}
