var locale = "en";

void initLocale(String loc) {
  if (localizations.contains(loc))
    locale = loc;
  else {
    locale = "en";
    print("no such localization: $loc");
  }
}

String getText(String textKey) =>
    localizedTexts[locale][textKey] ?? "_nincs ilyen string_";

const localizations = [
  "hu",
//  "sr",
//  "sr_Latn",
  // "en",
];

const Map<String, Map<String, String>> localizedTexts = {
  "hu": {
    noInternet: "Nincs Internet Kapcsolat",
    fetchFailed: "Tartalom Letöltése Sikertelen",
    connectionError: "Kapcsolódási Hiba",
    invalidUsername: "Hiba A Felhasználónévben",
    invalidPassword: "Hiba A Jelszóban",
    correctPass: "A jelszónak minimum 8 karakter hosszúnak kell lennie"
        " és tartalmaznia kell betűket és számokat",
    failedToLoadChart: "A Betöltés Sikertelen",
    tempKoll: "Kollektor Hőmérséklete",
    tempOutside: "Kinti Hőmérséklet",
    tempInside: "Benti Hőmérséklet",
    koll: "Kollektor",
    outside: "Kinti",
    inside: "Benti",
    pickInterval: "Válasszon Ki Egy Időtartamot",
    cancel: "Mégse",
    save: "Mentés",
    weeklyChart: "Heti Grafikon",
    dailyChart: "Napi Grafikon",
    hourlyChart: "Egy Órás Grafikon",
    realtimeChart: "Valós Idejű Grafikon",
    customChart: "Egyedi Grafikon",
    home: "Kezdőlap",
    charts: "Grafikonok",
    configureHeader: "Koppintson A Konfigurációhoz",
    chartHeader: "Koppintson A Grafikon Kiválasztásához",
    profiles: "Profilok",
    optimal: "Optimális",
    minimal: "Minimális",
    maximal: "Maximális",
    manual: "Manuális",
    custom: "Egyedi",
    house: "Ház",
    minTemp: "Minimum Hőmérséklet: ",
    maxTemp: "Maximum Hőmérséklet: ",
    tapToReload: "Koppintson Az Újratöltéshez",
    manualConf: "Manuális Konfiguráció",
    vent0: "Ventilátor #0",
    vent1: "Ventilátor #1",
    user: "Felhasználónév",
    pass: "Jelszó",
    stayLoggedIn: "Maradjon Bejelentkezve",
    login: "Bejelentkezés",
    expanded: "Kiterjesztett",
    simplified: "Lecsökkentett",
    noTextAdded: "Nincs Szöveg Megadva",
    invalidUserInfo: "Hibás Jelszó Vagy Felhasználónév",
    onDeg: "on",
    profileMinimalDescription:
        "A ventilátorok sebessége kisebb, a benti hőmérséklet alacsonyabb.",
    profileMaximalDescription:
        "A ventilátorok sebessége a lehető legnagyobb, a benti hőmérséklet magasabb.",
    profileOptimalDescription:
        "A vetilátorok sebessége és a benti hőmérséklet optimális.",
    profileCustomDescription:
        "A felhasználó szabja meg adott hőfokokon a ventilátorok sebességét.",
    profileManualDescription:
        "A ventillátorok sebességének manuális beállítása."
  },
  "sr": {},
  "sr_Latn": {},
  "en": {
    noInternet: "No Internet Connection",
    fetchFailed: "Fetch Failed",
    connectionError: "Connection Error",
    invalidUsername: "Invalid Username",
    invalidPassword: "Invalid Password",
    correctPass: "Password minimum length is 8 characters"
        " and must contain numbers and letters",
    failedToLoadChart: "Falied To Load",
    tempKoll: "Collector Temperature",
    tempOutside: "Outside Temperature",
    tempInside: "Inside Temperature",
    koll: "Collector",
    outside: "Outside",
    inside: "Inside",
    pickInterval: "Pick Time Interval",
    cancel: "Cancel",
    save: "Save",
    weeklyChart: "Weekly Chart",
    dailyChart: "Daily Chart",
    hourlyChart: "Hourly Chart",
    realtimeChart: "RealTime Chart",
    customChart: "Custom Chart",
    home: "Home",
    charts: "Charts",
    configureHeader: "Tap To Configure",
    chartHeader: "Tap For More Charts",
    profiles: "Profiles",
    optimal: "Optimal",
    minimal: "Minimal",
    maximal: "Maximal",
    manual: "Manual",
    custom: "Custom",
    house: "House",
    minTemp: "Min Temperature: ",
    maxTemp: "Max Temperature: ",
    tapToReload: "Tap To Reload",
    manualConf: "Manual Configuration",
    vent0: "Fan #0",
    vent1: "Fan #1",
    user: "Username",
    pass: "Password",
    stayLoggedIn: "Stay Logged In",
    login: "Sign In",
    expanded: "Expanded",
    simplified: "Simplified",
    noTextAdded: "No Text Added",
    invalidUserInfo: "Invalid User Information",
    onDeg: "on",
  },
};

const fetchFailed = "fetchFailed",
    invalidUsername = "invalidUsername",
    noInternet = "noInternet",
    connectionError = "connectionError",
    correctPass = "correctPass",
    tempKoll = "tempKoll",
    tempOutside = "tempOutside",
    tempInside = "tempInside",
    koll = "koll",
    outside = "outside",
    inside = "inside",
    cancel = "cancel",
    save = "save",
    home = "home",
    charts = "charts",
    minTemp = "minTemp",
    maxTemp = "maxTemp",
    stayLoggedIn = "stayLoggedIn",
    tapToReload = "tapToReload",
    configureHeader = "configureHeader",
    chartHeader = "chartHeader",
    weeklyChart = "weeklyChart",
    dailyChart = "dailyChart",
    hourlyChart = "hourlyChart",
    realtimeChart = "realtimeChart",
    customChart = "customChart",
    profiles = "profiles",
    optimal = "optimal",
    minimal = "minimal",
    maximal = "maximal",
    manualConf = "manualConf",
    vent0 = "vent0",
    vent1 = "vent1",
    manual = "manual",
    expanded = "expanded",
    simplified = "simplfied",
    onDeg = "onDeg",
    custom = "custom",
    house = "house",
    noTextAdded = "noTextAdded",
    user = "user",
    pass = "pass",
    invalidUserInfo = "invalidUserInfo",
    login = "login",
    pickInterval = "pickInterval",
    failedToLoadChart = "failedToLoadChart",
    invalidPassword = "invalidPassword",
    profileMinimalDescription = "profileMinimalDescription",
    profileMaximalDescription = "profileMaximalDescription",
    profileOptimalDescription = "profileOptimalDescription",
    profileCustomDescription = "profileCustomDescription",
    profileManualDescription = "profileManualDescription";

bool test(String locale) {
  if (!localizations.contains(locale)) return false;

  if (localizedTexts[locale][fetchFailed] == null) return false;
  if (localizedTexts[locale][invalidUsername] == null) return false;
  if (localizedTexts[locale][noInternet] == null) return false;
  if (localizedTexts[locale][connectionError] == null) return false;
  if (localizedTexts[locale][correctPass] == null) return false;
  if (localizedTexts[locale][tempKoll] == null) return false;
  if (localizedTexts[locale][tempOutside] == null) return false;
  if (localizedTexts[locale][tempInside] == null) return false;
  if (localizedTexts[locale][koll] == null) return false;
  if (localizedTexts[locale][outside] == null) return false;
  if (localizedTexts[locale][inside] == null) return false;
  if (localizedTexts[locale][cancel] == null) return false;
  if (localizedTexts[locale][save] == null) return false;
  if (localizedTexts[locale][home] == null) return false;
  if (localizedTexts[locale][charts] == null) return false;
  if (localizedTexts[locale][minTemp] == null) return false;
  if (localizedTexts[locale][maxTemp] == null) return false;
  if (localizedTexts[locale][stayLoggedIn] == null) return false;
  if (localizedTexts[locale][tapToReload] == null) return false;
  if (localizedTexts[locale][configureHeader] == null) return false;
  if (localizedTexts[locale][chartHeader] == null) return false;
  if (localizedTexts[locale][weeklyChart] == null) return false;
  if (localizedTexts[locale][dailyChart] == null) return false;
  if (localizedTexts[locale][hourlyChart] == null) return false;
  if (localizedTexts[locale][realtimeChart] == null) return false;
  if (localizedTexts[locale][customChart] == null) return false;
  if (localizedTexts[locale][profiles] == null) return false;
  if (localizedTexts[locale][optimal] == null) return false;
  if (localizedTexts[locale][minimal] == null) return false;
  if (localizedTexts[locale][maximal] == null) return false;
  if (localizedTexts[locale][manualConf] == null) return false;
  if (localizedTexts[locale][vent0] == null) return false;
  if (localizedTexts[locale][vent1] == null) return false;
  if (localizedTexts[locale][manual] == null) return false;
  if (localizedTexts[locale][expanded] == null) return false;
  if (localizedTexts[locale][simplified] == null) return false;
  if (localizedTexts[locale][onDeg] == null) return false;
  if (localizedTexts[locale][custom] == null) return false;
  if (localizedTexts[locale][house] == null) return false;
  if (localizedTexts[locale][noTextAdded] == null) return false;
  if (localizedTexts[locale][user] == null) return false;
  if (localizedTexts[locale][pass] == null) return false;
  if (localizedTexts[locale][invalidUserInfo] == null) return false;
  if (localizedTexts[locale][login] == null) return false;
  if (localizedTexts[locale][pickInterval] == null) return false;
  if (localizedTexts[locale][failedToLoadChart] == null) return false;
  if (localizedTexts[locale][invalidPassword] == null) return false;

  return false;
}
