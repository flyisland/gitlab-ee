export const formData = {
  firstName: 'Joe',
  lastName: 'Doe',
  companyName: 'ACME',
  companySize: '1-99',
  phoneNumber: '192919',
  country: 'US',
};

export const COUNTRY_WITH_STATES = 'CN';
export const STATE = 'SH';
export const COUNTRIES = [
  { id: COUNTRY_WITH_STATES, name: 'China', flag: '🇨🇳', internationalDialCode: '86' },
  { id: 'CA', name: 'Canada', flag: '🇨🇦', internationalDialCode: '1' },
  { id: 'NL', name: 'Netherlands', flag: '🇳🇱', internationalDialCode: '31' },
];

export const STATES = [
  { countryId: COUNTRY_WITH_STATES, id: STATE, name: 'Shanghai' },
  { countryId: 'CA', id: 'BC', name: 'British Columbia' },
];
