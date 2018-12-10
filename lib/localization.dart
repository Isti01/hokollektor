var locale = 'en';

String getText(String textKey) => localizedTexts[locale][textKey];

const localizations = [
//  'hu',
//  'sr',
//  'sr_Latn',
  'en',
];

const Map<String, Map<String, String>> localizedTexts = {
  'hu': {},
  'sr': {},
  'sr_Latn': {},
  'en': {
    noInternet: 'No Internet Connection',
    fetchFailed: 'Fetch Failed',
    connectionError: "Connection Error",
    invalidUsername: "Invalid Username",
    invalidPassword: "Invalid Password",
    correctPass: "Password minimum length is 8 characters"
        " and must contain numbers and letters",
    failedToLoadChart: "Falied to load!",
    tempKoll: "Collector Temperature",
    tempOutside: "Outside Temperature",
    tempInside: "Inside Temperature",
    koll: 'Kollektor',
    outside: 'Kint',
    inside: 'Benti',
    pickInterval: "Pick Time interval",
    cancel: 'Cancel',
    save: 'Save',
    weeklyChart: "Weekly Chart",
    dailyChart: "Daily Chart",
    hourlyChart: "Hourly Chart",
    realtimeChart: "RealTime Chart",
    customChart: "Custom Chart",
    home: "Home",
    charts: "Charts",
    configureHeader: 'Tap To Configure',
    chartHeader: 'Tap For More Charts',
    profiles: "Profiles",
    optimal: 'Optimal',
    minimal: 'Minimal',
    maximal: 'Maximal',
    manual: 'Manual',
    custom: 'Custom',
    house: 'House',
    minTemp: 'Min Temperature: ',
    maxTemp: 'Max Temperature: ',
    tapToReload: 'Tap to reload',
    manualConf: "Manual Configuration",
    vent0: 'Ventilator #0',
    vent1: 'Ventilator #1',
    user: 'Username',
    pass: "Password",
    stayLoggedIn: 'Stay Logged In',
    login: 'Login',
    expanded: 'Expanded',
    simplified: 'Simplified',
    noTextAdded: "No Text Added",
    invalidUserInfo: "Invalid User information",
    onDeg: 'on',
  },
};

const fetchFailed = 'fetchFailed',
    invalidUsername = 'invalidUsername',
    noInternet = 'noInternet',
    connectionError = "connectionError",
    correctPass = "correctPass",
    tempKoll = 'tempKoll',
    tempOutside = 'tempOutside',
    tempInside = 'tempInside',
    koll = 'koll',
    outside = 'outside',
    inside = 'inside',
    cancel = 'cancel',
    save = 'save',
    home = 'home',
    charts = 'charts',
    minTemp = 'minTemp',
    maxTemp = 'maxTemp',
    stayLoggedIn = 'stayLoggedIn',
    tapToReload = 'tapToReload',
    configureHeader = 'configureHeader',
    chartHeader = 'chartHeader',
    weeklyChart = 'weeklyChart',
    dailyChart = 'dailyChart',
    hourlyChart = 'hourlyChart',
    realtimeChart = 'realtimeChart',
    customChart = 'customChart',
    profiles = 'profiles',
    optimal = 'optimal',
    minimal = 'minimal',
    maximal = 'maximal',
    manualConf = 'manualConf',
    vent0 = 'vent0',
    vent1 = 'vent1',
    manual = 'manual',
    expanded = 'expanded',
    simplified = 'simplfied',
    onDeg = 'onDeg',
    custom = 'custom',
    house = 'house',
    noTextAdded = 'noTextAdded',
    user = 'user',
    pass = 'pass',
    invalidUserInfo = 'invalidUserInfo',
    login = 'login',
    pickInterval = 'pickInterval',
    failedToLoadChart = 'failedToLoadChart',
    invalidPassword = "invalidPassword";
