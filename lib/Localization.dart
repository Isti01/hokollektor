var locale = "en", preferredLanguage;

void Function() onLocaleChange;

String getPreferredLanguage() {
  if (preferredLanguage == null || !localizations.contains(preferredLanguage))
    return "";
  return preferredLanguage;
}

List<String> getLanguageOptions() {
  final options = localizations.map((val) => val).toList();
  options.add("");
  return options;
}

languageToOption(language) {
  switch (language) {
    case "hu":
      return getText(langHu);
    case "sr":
      return getText(langSrCiril);
    case "sr_Latn":
      return getText(langSrLatn);
    case "en":
      return getText(langEn);
    default:
      return getText(langAuto);
  }
}

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
  "en",
  "hu",
  "sr",
  "sr_Latn",
];

List<String> get narrowWeekdays {
  switch (locale) {
    case "hu":
      return ["V", "H", "K", "Sz", "Cs", "P", "Sz"];
    case "sr":
      return ["Н", "П", "У", "С", "Ч", "П", "С"];
    case "sr_Latn":
      return ["N", "P", "U", "S", "Č", "P", "S"];
    default:
      return ["S", "M", "T", "W", "T", "F", "S"];
  }
}

String formatMonthYear(DateTime date) =>
    "${months[date.month - 1]} ${date.year}";

String formatDecimal(int number) {
  return number.toString();
}

int get firstDayOfWeekIndex {
  switch (locale) {
    case "hu":
    case "sr":
    case "sr_Latn":
      return 1;
    default:
      return 0;
  }
}

List<String> get months {
  switch (locale) {
    case "hu":
      return [
        "Január",
        "Február",
        "Március",
        "Április",
        "Május",
        "Június",
        "Július",
        "Augusztus",
        "Szeptember",
        "Október",
        "November",
        "December",
      ];
    case "sr":
      return [
        "Јануар",
        "Фебруар",
        "Март",
        "Април",
        "Мај",
        "Јун",
        "Јул",
        "Август",
        "Септембар",
        "Октобар",
        "Новембар",
        "Децембар",
      ];
    case "sr_Latn":
      return [
        "Januar",
        "Februar",
        "Mart",
        "April",
        "Maj",
        "Jun",
        "Jul",
        "Avgust",
        "Septembar",
        "Oktobar",
        "Novembar",
        "Decembar",
      ];
    default:
      return [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
      ];
  }
}

const Map<String, Map<String, String>> localizedTexts = {
  "hu": {
    noInternet: "Nincs Internet Kapcsolat",
    invalidUsername: "Hiba A Felhasználónévben",
    invalidPassword: "Hiba A Jelszóban",
    correctPass:
        "A jelszónak minimum 8 karakter hosszúnak kell lennie és tartalmaznia kell betűket és számokat",
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
        "A ventillátorok sebességének manuális beállítása.",
    presentationTime: "Ugrás a prezentációhoz!",
    appName: "Collector App",
    aboutCollector: "A kollektorról",
    aboutCollectorText:
        "Péter tanár úr 2017 tavaszán készítette el a kollektort\n\nMi kaptuk a lehetőséget, hogy vezérlést készítsünk hozzá.",
    aboutCollectorImageDescription: "A tanár úr és a kollektor",
    collectorControlling: "A vezérlés",
    collectorControllingText:
        "Beszereltünk egy Node MCU-t és hőszenzorokat, amivel valós időben mérjük a hőmérsékletet, és vezéreljük a kollektort.",
    theApplication: "Az App",
    theApplicationText:
        "A célunk az, hogy bárhol hozzáférhessünk a kollektorhoz, ezért készült ez az applikáció.",
    collectorControllingImageDescription: "A vezérlés egy édesség dobozban",
    langHu: "Magyar",
    langEn: "Angol",
    langSrLatn: "Szerb Latin",
    langSrCiril: "Szerb Cirill",
    langAuto: "Automatikus",
    changeLanguage: "Nyelv megváltoztatása",
    signInAsGuest: "Belépés vendégként",
    or: "vagy"
  },
  "sr": {
    noInternet: "Нема интернет конекције",
    invalidUsername: "Погрешно корисничко име",
    invalidPassword: "Погрешна лозинка",
    correctPass:
        "Лозинка мора да се састоји од најмање 8 карактера и мора да садржи слова и бројеве.",
    failedToLoadChart: "Неуспешно учитавање",
    tempKoll: "Температура колектора",
    tempOutside: "Спољна температура",
    tempInside: "Унутрашња температура",
    koll: "Колектор",
    outside: "Спољна",
    inside: "Унутрашња",
    pickInterval: "Изаберите временски период",
    cancel: "Отказати",
    save: "Сачувати",
    weeklyChart: "Недељни графикон",
    dailyChart: "Дневни графикон",
    hourlyChart: "Једносатни графикон",
    realtimeChart: "Графикон у реалном времену",
    customChart: "Јединствени графикон",
    home: "Почетна страница ",
    charts: "Графикони",
    configureHeader: "Притисните за конфигурације",
    chartHeader: "Притисните за избор графикона ",
    profiles: "Профили ",
    optimal: "Оптималан",
    minimal: "Минималан",
    maximal: "Максималан",
    manual: "Мануалан",
    custom: "Јединствен",
    house: "Кућа",
    minTemp: "Минимална температура: ",
    maxTemp: "Максимална температура: ",
    tapToReload: "Притисните за освезавање",
    manualConf: "Мануална конфигурација",
    vent0: "Вентилатор #0",
    vent1: "Вентилатор #1",
    user: "Корисничко име ",
    pass: "Лозинка",
    stayLoggedIn: "Останите пријављени",
    login: "Пријављивање",
    expanded: "Проширен",
    simplified: "Смањен",
    noTextAdded: "Није дат текст.",
    invalidUserInfo: "Погрешна лозинка или корисничко име.",
    onDeg: "он",
    profileMinimalDescription:
        "Брзина вентилатора је мања, унутрашња температура је нижа.",
    profileMaximalDescription:
        "Брзина вентилатора је маxимална, унутрашња температура је виша.",
    profileOptimalDescription:
        "Брзина вентилатора и унутрашња температура су оптимални.",
    profileCustomDescription:
        "Корисник бира брзину вентилатора на основу температуре.",
    profileManualDescription: "Брзина вентилатора се мануално подешава.",
    presentationTime: "Скок до презентације!",
    appName: "Collector App",
    aboutCollector: "О колектору",
    aboutCollectorText:
        "Наш професор је направио соларни колектор  2017. године.\n\nНаша група је добила прилику да направи контролну јединицу за управљење колектором.",
    aboutCollectorImageDescription: "Професор и колектор",
    collectorControlling: "Управљање",
    collectorControllingText:
        "Уградили смо један Node MCU и топлотни сензор са којим меримо температуру у реалном времену и управљамо колектором.",
    theApplication: "Апликација",
    theApplicationText:
        "Наш циљ је да колектор буде доступан са било које локације, зато је направљена ова апликација.",
    collectorControllingImageDescription:
        "Контролна јединица у кутији за слаткише",
    langHu: "Мађарски",
    langEn: "Енглески",
    langSrLatn: "Српски (Латиница)",
    langSrCiril: "Српски (Ћирилица)",
    langAuto: "Аутоматски",
    changeLanguage: "Промена језика",
    signInAsGuest: "Улогуј се као гост",
    or: "или"
  },
  "sr_Latn": {
    noInternet: "Nema internet konekcije",
    invalidUsername: "Pogrešno korisničko ime",
    invalidPassword: "Pogrešna lozinka",
    correctPass:
        "Lozinka mora da se sastoji od najmanje 8 karaktera i mora da sadrži slova i brojeve.",
    failedToLoadChart: "Neuspešno učitavanje",
    tempKoll: "Temperatura kolektora",
    tempOutside: "Spoljna temperatura",
    tempInside: "Unutrašnja temperatura",
    koll: "Kolektor",
    outside: "Spoljna",
    inside: "Unutrašnja",
    pickInterval: "Izaberite vremenski period",
    cancel: "Otkazati",
    save: "Sačuvati",
    weeklyChart: "Nedeljni grafikon",
    dailyChart: "Dnevni grafikon",
    hourlyChart: "Jednosatni grafikon",
    realtimeChart: "Grafikon u realnom vremenu",
    customChart: "Jedinstveni grafikon",
    home: "Početna stranica ",
    charts: "Grafikoni",
    configureHeader: "Pritisnite za konfiguracije",
    chartHeader: "Pritisnite za izbor grafikona ",
    profiles: "Profili ",
    optimal: "Optimalan",
    minimal: "Minimalan",
    maximal: "Maksimalan",
    manual: "Manualan",
    custom: "Jedinstven",
    house: "Kuća",
    minTemp: "Minimalna temperatura: ",
    maxTemp: "Maksimalna temperatura: ",
    tapToReload: "Pritisnite za osvezavanje",
    manualConf: "Manualna konfiguracija",
    vent0: "Ventilator #0",
    vent1: "Ventilator #1",
    user: "Korisničko ime ",
    pass: "Lozinka",
    stayLoggedIn: "Ostanite prijavljeni",
    login: "Prijavljivanje",
    expanded: "Proširen",
    simplified: "Smanjen",
    noTextAdded: "Nije dat tekst.",
    invalidUserInfo: "Pogrešna lozinka ili korisničko ime.",
    onDeg: "on",
    profileMinimalDescription:
        "Brzina ventilatora je manja, unutrašnja temperatura je niža.",
    profileMaximalDescription:
        "Brzina ventilatora je maximalna, unutrašnja temperatura je viša.",
    profileOptimalDescription:
        "Brzina ventilatora i unutrašnja temperatura su optimalni.",
    profileCustomDescription:
        "Korisnik bira brzinu ventilatora na osnovu temperature.",
    profileManualDescription: "Brzina ventilatora se manualno podešava.",
    presentationTime: "Skok do prezentacije!",
    appName: "Collector App",
    aboutCollector: "O kolektoru",
    aboutCollectorText:
        "Naš profesor je napravio solarni kolektor  2017. godine.\n\nNaša grupa je dobila priliku da napravi kontrolnu jedinicu za upravljenje kolektorom.",
    aboutCollectorImageDescription: "Profesor i kolektor",
    collectorControlling: "Upravljanje",
    collectorControllingText:
        "Ugradili smo jedan Node MCU i toplotni senzor sa kojim merimo temperaturu u realnom vremenu i upravljamo kolektorom.",
    theApplication: "Aplikacija",
    theApplicationText:
        "Naš cilj je da kolektor bude dostupan sa bilo koje lokacije, zato je napravljena ova aplikacija.",
    collectorControllingImageDescription:
        "Kontrolna jedinica u kutiji za slatkiše",
    langHu: "Mađarski",
    langEn: "Engleski",
    langSrLatn: "Srpski (Latinica)",
    langSrCiril: "Srpski (Ćirilica)",
    langAuto: "Automatski",
    changeLanguage: "Promena jezika",
    signInAsGuest: "Uloguj se kao gost",
    or: "ili"
  },
  "en": {
    noInternet: "No Internet Connection",
    invalidUsername: "Invalid Username",
    invalidPassword: "Invalid Password",
    correctPass:
        "Password minimum length is 8 characters and must contain numbers and letters",
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
    stayLoggedIn: "Stay Signed in",
    login: "Sign In",
    expanded: "Expanded",
    simplified: "Simplified",
    noTextAdded: "No Text Added",
    invalidUserInfo: "Invalid User Information",
    onDeg: "on",
    profileMinimalDescription:
        "Fan speed and the inside temperature are lower.",
    profileMaximalDescription:
        "Fan speed and the inside temperature are higher.",
    profileOptimalDescription:
        "Fan speed, and the inside temperature are optimal.",
    profileCustomDescription:
        "Create custom profile, set the fan speed relative to the temperature.",
    profileManualDescription: "Set the fan speed manually.",
    presentationTime: "Presentation Time!",
    appName: "Collector App",
    aboutCollector: "About the collector",
    aboutCollectorText:
        "Péter, our IT teacher in the spring of 2017 finished the collector.\n\nWe got the opportunity to automate it.",
    aboutCollectorImageDescription: "Péter and the collector",
    collectorControlling: "The control",
    collectorControllingText:
        "First, we installed the Node MCU and three heat sensors, then we could measure and monitor the temperatures realtime and we could control the collector.",
    theApplication: "The application",
    theApplicationText:
        "We made this app with these goals, make the collector accessible from anywhere, and make everything as simple as possible.",
    collectorControllingImageDescription:
        "All the electronics in one candy box",
    langHu: "Hungarian",
    langEn: "English",
    langSrLatn: "Serbian Latin",
    langSrCiril: "Serbian Cyrillic",
    langAuto: "Automatic",
    changeLanguage: "Change Lanugage",
    signInAsGuest: "Sign in as Guest",
    or: "or"
  },
};

const invalidUsername = "invalidUsername",
    noInternet = "noInternet",
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
    profileManualDescription = "profileManualDescription",
    presentationTime = "presentationTime",
    appName = "appName",
    aboutCollector = "aboutCollector",
    aboutCollectorText = "aboutCollectorText",
    aboutCollectorImageDescription = "aboutCollectorImageDescription",
    collectorControlling = "collectorControlling",
    collectorControllingText = "collectorControllingText",
    theApplication = "theApplication",
    theApplicationText = "theApplicationText",
    collectorControllingImageDescription =
        "collectorControllingImageDescription",
    langHu = 'langHu',
    langEn = 'langEn',
    langSrLatn = 'langSrLatn',
    langSrCiril = 'langSrCiril',
    langAuto = 'langAuto',
    changeLanguage = "changeLanguage",
    signInAsGuest = 'signInAsGuest',
    or = "or";

bool test(String locale) {
  if (!localizations.contains(locale)) return false;

  if (localizedTexts[locale][invalidUsername] == null ||
      localizedTexts[locale][noInternet] == null ||
      localizedTexts[locale][correctPass] == null ||
      localizedTexts[locale][tempKoll] == null ||
      localizedTexts[locale][tempOutside] == null ||
      localizedTexts[locale][tempInside] == null ||
      localizedTexts[locale][koll] == null ||
      localizedTexts[locale][outside] == null ||
      localizedTexts[locale][inside] == null ||
      localizedTexts[locale][cancel] == null ||
      localizedTexts[locale][save] == null ||
      localizedTexts[locale][home] == null ||
      localizedTexts[locale][charts] == null ||
      localizedTexts[locale][minTemp] == null ||
      localizedTexts[locale][maxTemp] == null ||
      localizedTexts[locale][stayLoggedIn] == null ||
      localizedTexts[locale][tapToReload] == null ||
      localizedTexts[locale][configureHeader] == null ||
      localizedTexts[locale][chartHeader] == null ||
      localizedTexts[locale][weeklyChart] == null ||
      localizedTexts[locale][dailyChart] == null ||
      localizedTexts[locale][hourlyChart] == null ||
      localizedTexts[locale][realtimeChart] == null ||
      localizedTexts[locale][customChart] == null ||
      localizedTexts[locale][profiles] == null ||
      localizedTexts[locale][optimal] == null ||
      localizedTexts[locale][minimal] == null ||
      localizedTexts[locale][maximal] == null ||
      localizedTexts[locale][manualConf] == null ||
      localizedTexts[locale][vent0] == null ||
      localizedTexts[locale][vent1] == null ||
      localizedTexts[locale][manual] == null ||
      localizedTexts[locale][expanded] == null ||
      localizedTexts[locale][simplified] == null ||
      localizedTexts[locale][onDeg] == null ||
      localizedTexts[locale][custom] == null ||
      localizedTexts[locale][house] == null ||
      localizedTexts[locale][noTextAdded] == null ||
      localizedTexts[locale][user] == null ||
      localizedTexts[locale][pass] == null ||
      localizedTexts[locale][invalidUserInfo] == null ||
      localizedTexts[locale][login] == null ||
      localizedTexts[locale][pickInterval] == null ||
      localizedTexts[locale][failedToLoadChart] == null ||
      localizedTexts[locale][invalidPassword] == null ||
      localizedTexts[locale][profileMinimalDescription] == null ||
      localizedTexts[locale][profileMaximalDescription] == null ||
      localizedTexts[locale][profileOptimalDescription] == null ||
      localizedTexts[locale][profileCustomDescription] == null ||
      localizedTexts[locale][profileManualDescription] == null ||
      localizedTexts[locale][presentationTime] == null ||
      localizedTexts[locale][appName] == null ||
      localizedTexts[locale][aboutCollector] == null ||
      localizedTexts[locale][aboutCollectorText] == null ||
      localizedTexts[locale][aboutCollectorImageDescription] == null ||
      localizedTexts[locale][collectorControlling] == null ||
      localizedTexts[locale][collectorControllingText] == null ||
      localizedTexts[locale][theApplication] == null ||
      localizedTexts[locale][theApplicationText] == null ||
      localizedTexts[locale][collectorControllingImageDescription] == null ||
      localizedTexts[locale][langHu] == null ||
      localizedTexts[locale][langEn] == null ||
      localizedTexts[locale][langSrLatn] == null ||
      localizedTexts[locale][langSrCiril] == null ||
      localizedTexts[locale][langAuto] == null ||
      localizedTexts[locale][changeLanguage] == null) return false;

  return true;
}
