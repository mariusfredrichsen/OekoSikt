import 'package:frontend/core/models/transaction_categories.dart';

class TransactionCategorizer {
  // ── Weight tiers ──────────────────────────────────────────────
  // Exact merchant names are worth more than generic category words.
  static const int _exactMerchantWeight = 20;
  static const int _genericKeywordWeight = 8;

  // ── Public API ────────────────────────────────────────────────
  static TransactionCategory categorize({
    required String description,
    required String type,
    required String subType,
    required String recipientName,
    required String message,
    required double? amountIn,
    required double? amountOut,
  }) {
    // 1. Structural rules (salary, transfers, etc.) — cheapest check first
    final structural = _structuralCategory(
      type: type,
      subType: subType,
      description: description,
      recipientName: recipientName,
      message: message,
      amountIn: amountIn,
      amountOut: amountOut,
    );
    if (structural != null) return structural;

    // 2. Clean → normalize → tokenize → score
    final cleaned = _cleanDescription(description);
    final combined = '$cleaned $message $recipientName';
    final normalized = _normalize(combined);

    return _matchAdvanced(normalized);
  }

  // ── Description cleaning ──────────────────────────────────────
  // Strips payment-method prefixes that every Norwegian bank adds
  // before the actual merchant name.
  static String _cleanDescription(String desc) {
    // Vipps variants: "Vipps*Rema", "VIPPS - Oda", "Vipps: Kiwi" …
    final vipps = RegExp(r'vipps[\s*\-:]+(.+)', caseSensitive: false);
    final vippsMatch = vipps.firstMatch(desc);
    if (vippsMatch != null && vippsMatch.groupCount >= 1) {
      return vippsMatch.group(1)!.trim();
    }

    // Common bank prefixes — strip prefix, keep merchant info after it
    final prefixes = RegExp(
      r'^(visa\s*vare|visa\s*kjoep|visa|mastercard|nettgiro\s*til|'
      r'nettgiro|avtalegiro|brevgiro|straksbet|betaling|bet\.|'
      r'varekjop|varekjoep|kredittrente|kortkjop|kortbetaling|'
      r'mobilepay|apple\s*pay|google\s*pay)\s*[:\-]?\s*',
      caseSensitive: false,
    );
    desc = desc.replaceFirst(prefixes, '');

    return desc.trim();
  }

  // ── Normalization ─────────────────────────────────────────────
  // Converts the input into a canonical form suitable for keyword
  // matching with \\b word-boundary regex.
  static String _normalize(String input) {
    var s = input.toLowerCase();

    // Norwegian → ASCII
    s = s
        .replaceAll('æ', 'ae')
        .replaceAll('ø', 'o')
        .replaceAll('å', 'a')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e');

    // Turn common delimiters into spaces
    s = s.replaceAll(
      RegExp(
        r'[_\-#*,./\\+:;|(){}[\]"'
        "'"
        r'`~&@!=]',
      ),
      ' ',
    );

    // Remove company suffixes (AS, ASA, AB, NUF, SA, DA, ANS, ENK)
    s = s.replaceAll(RegExp(r'\b(as|asa|ab|nuf|sa|da|ans|enk)\b'), '');

    // Remove country codes appearing as isolated tokens
    s = s.replaceAll(
      RegExp(r'\b(nor|no|swe|se|dnk|dk|gbr|gb|usa|us|fin|fi|deu|de)\b'),
      '',
    );

    // Remove city / location names commonly appended by card terminals
    s = s.replaceAll(
      RegExp(
        r'\b(oslo|bergen|trondheim|stavanger|tromso|kristiansand|drammen|'
        r'fredrikstad|sarpsborg|lillestrom|bodo|moss|arendal|tonsberg|'
        r'haugesund|sandnes|alesund|sandefjord|porsgrunn|skien|'
        r'lorenskog|billingstad|fornebu|lysaker|sandvika|asker|'
        r'ski|kolbotn|nesoddtangen|jessheim|gardermoen|majorstuen|'
        r'gronland|storo|nydalen|nationaltheatret|aker brygge)\b',
      ),
      '',
    );

    // Remove dates in all common formats
    // DD.MM.YYYY, DD/MM/YYYY, DD-MM-YYYY, DD.MM, YYYY-MM-DD
    s = s.replaceAll(RegExp(r'\b\d{4}[\-/.]\d{2}[\-/.]\d{2}\b'), ' ');
    s = s.replaceAll(RegExp(r'\b\d{2}[\-/.]\d{2}[\-/.]\d{2,4}\b'), ' ');
    s = s.replaceAll(RegExp(r'\b\d{2}[\s.]\d{2}\b'), ' ');

    // Remove standalone numbers (transaction refs, terminal IDs)
    // but keep numbers glued to words like "7eleven" or "rema1000"
    s = s.replaceAll(RegExp(r'\b\d{3,}\b'), ' ');

    // Remove short isolated digits (01, 23) but not meaningful ones
    s = s.replaceAll(RegExp(r'(?<=\s)\d{1,2}(?=\s)'), ' ');

    // Remove currency codes
    s = s.replaceAll(RegExp(r'\b(nok|sek|dkk|eur|usd|gbp|chf)\b'), '');

    // Remove "kl" (klokken/time prefix)
    s = s.replaceAll(RegExp(r'\bkl\b'), '');

    // Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    return s;
  }

  // ── Structural rules ──────────────────────────────────────────
  // Fast path for transactions that can be categorized by metadata
  // alone, without inspecting the description.
  static TransactionCategory? _structuralCategory({
    required String type,
    required String subType,
    required String description,
    required String recipientName,
    required String message,
    required double? amountIn,
    required double? amountOut,
  }) {
    final t = type.toLowerCase().trim();
    final st = subType.toLowerCase().trim();
    final desc = description.toLowerCase();
    final msg = message.toLowerCase();

    // ── Income ──
    if (amountIn != null && amountIn > 0) {
      // Salary keywords in any field
      if (_containsAny(desc + msg, [
        'lonn',
        'lønn',
        'salary',
        'feriepenger',
        'bonus',
      ])) {
        return TransactionCategory.income;
      }
      // Government payments
      if (_containsAny(desc + msg, [
        'nav ',
        'skatteetaten',
        'skatteoppgjor',
        'tilgode',
        'stipend',
        'lanekassen',
      ])) {
        return TransactionCategory.income;
      }
      // Large recurring inbound that looks like salary (> 15 000 NOK)
      if (amountIn >= 15000 &&
          (t == 'innbetaling' || st == 'lonn' || st == 'lønn')) {
        return TransactionCategory.income;
      }
    }

    // ── Internal / savings transfers ──
    if (t == 'overforing' ||
        t == 'overføring' ||
        st == 'overforing' ||
        st == 'overføring') {
      return TransactionCategory.transfer;
    }
    if (_containsAny(desc, [
      'sparekonto',
      'spareavtale',
      'fond',
      'egen konto',
      'mellom egne',
      'bsu',
      'boligsparing',
      'høyrente',
      'hoyrente',
      'brukskonto',
      'bufferkonto',
    ])) {
      return TransactionCategory.transfer;
    }
    if (_containsAny(msg, [
      'bsu',
      'boligsparing',
      'sparekonto',
      'mellom egne',
      'egen konto',
    ])) {
      return TransactionCategory.transfer;
    }

    // ── Avtalegiro / recurring bills ──
    if (t.contains('avtalegiro') ||
        st.contains('avtalegiro') ||
        desc.contains('avtalegiro')) {
      if (_containsAny(desc + msg + recipientName.toLowerCase(), [
        'sio bolig',
        'studentsamskipnad',
      ])) {
        return TransactionCategory.housing;
      }
      if (_containsAny(desc + msg + recipientName.toLowerCase(), [
        'sio athletica',
        'osi volleyball',
        'skimore',
      ])) {
        return TransactionCategory.utilities;
      }
      // Generic avtalegiro — likely a bill
      return TransactionCategory.utilities;
    }

    // ── Loan / mortgage payments ──
    if (_containsAny(desc + msg, [
      'nedbet',
      'avdrag',
      'rente',
      'boliglan',
      'boliglån',
    ])) {
      return TransactionCategory.housing;
    }

    return null;
  }

  static bool _containsAny(String text, List<String> needles) {
    for (final n in needles) {
      if (text.contains(n)) return true;
    }
    return false;
  }

  // ── Advanced keyword scoring ──────────────────────────────────
  static TransactionCategory _matchAdvanced(String normalized) {
    final scores = <TransactionCategory, int>{};

    // Score exact-merchant keywords (high weight)
    _merchantKeywords.forEach((category, keywords) {
      for (final kw in keywords) {
        final regex = RegExp('\\b${RegExp.escape(kw)}\\b');
        if (regex.hasMatch(normalized)) {
          scores[category] = (scores[category] ?? 0) + _exactMerchantWeight;
        }
      }
    });

    // Score generic/descriptive keywords (lower weight)
    _genericKeywords.forEach((category, keywords) {
      for (final kw in keywords) {
        final regex = RegExp('\\b${RegExp.escape(kw)}\\b');
        if (regex.hasMatch(normalized)) {
          scores[category] = (scores[category] ?? 0) + _genericKeywordWeight;
        }
      }
    });

    // Also check for compound/partial matches (e.g. "rema1000" as one token)
    _compoundPatterns.forEach((category, patterns) {
      for (final p in patterns) {
        if (normalized.contains(p)) {
          scores[category] = (scores[category] ?? 0) + _exactMerchantWeight;
        }
      }
    });

    if (scores.isEmpty) return TransactionCategory.uncategorized;

    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // ═══════════════════════════════════════════════════════════════
  // KEYWORD DATABASES
  // ═══════════════════════════════════════════════════════════════

  // ── Compound patterns (substring match, no word boundaries) ───
  static const Map<TransactionCategory, List<String>> _compoundPatterns = {
    TransactionCategory.food: [
      'rema1000',
      'coop extra',
      'coopextra',
      'coopprix',
      'coopmega',
      'coopmeny',
      'coopobs',
      'coopmarked',
      '7eleven',
      '7 eleven',
      'hellofresh',
      'adamsmatkasse',
      'chili dagligvar', // truncated "Chili Dagligvare" grocery
      'informatikkafe', // UiO bar/café (sometimes triple-k)
      'informatikkkafe', // UiO bar/café alternate spelling
      'bake me up', // cookie store
      'bakemeup',
      'bastard burger', // burger restaurant
      'flamme burger', // burger restaurant
      'los tacos', // taco restaurant
      'lostacos',
      'tryvannwyller', // café
      'sweetelle', // dessert restaurant
      'mcd ', // McDonald's terminal abbreviation
    ],
    TransactionCategory.transport: ['circlek', 'unox', 'okq8'],
    TransactionCategory.shopping: [
      'clasohlson',
      'clas ohl', // truncated "Clas Ohlson" from terminals
      'sport1',
      'obsbygg',
      'ritualscosmetics', // Rituals cosmetics store
      'lekekassen', // online hobby store
    ],
    TransactionCategory.utilities: [
      'icenet',
      'iceno',
      'airwallet', // laundry / washing service
    ],
    TransactionCategory.health: ['apotek1', 'drdropin', 'baretrening'],
    TransactionCategory.entertainment: [
      'tv2play',
      'tv2sumo',
      'hbomax',
      'disneyplus',
      'steam games', // Steam gaming platform
      'steamgames',
      'spilloteket', // bar with boardgames
      'cybernetisk', // student bar (Cybernetisk Selskab)
    ],
  };

  // ── Exact merchant keywords (high confidence) ─────────────────
  static const Map<TransactionCategory, List<String>> _merchantKeywords = {
    // ────────────── FOOD & DINING ──────────────
    TransactionCategory.food: [
      // Grocery chains
      'rema', 'rema 1000', 'kiwi', 'meny', 'spar', 'joker', 'bunnpris',
      'coop', 'coop extra', 'coop prix', 'coop mega', 'coop obs', 'coop marked',
      'extra', 'prix', 'obs', 'marked',
      'europris mat', 'holdbart',

      // Online grocery & meal kits
      'oda', 'kolonial', 'godtlevert', 'adams matkasse', 'hello fresh',
      'roede', 'linas matkasse',

      // Delivery apps
      'foodora', 'wolt', 'just eat', 'uber eats',

      // Fast food & chains
      'mcdonalds', 'mcdonald', 'burger king', 'max burger', 'max hamburgare',
      'subway', 'peppes', 'peppes pizza', 'dominos', 'domino', 'pizzabakeren',
      'dolly dimples', 'egon', 'tgi fridays', 'hans pa hjornet',
      'deli de luca', 'bit', 'jafs',
      'sabrura', // sushi restaurant
      'los tacos', // taco restaurant
      'bastard burger', // burger restaurant
      'flamme burger', // burger restaurant
      'koie', // ramen restaurant
      'mathallen', // restaurant / food hall
      // Coffee & bakery
      'espresso house', 'kaffebrenneriet', 'starbucks', 'wayne',
      'stockfleths', 'fuglen', 'java', 'tim wendelboe', 'supreme roastworks',
      'godt brod', 'baker hansen', 'w b samson', 'apent bakeri',
      'backstube', 'starbucks coffee',
      'bake me up', // cookie store
      'tryvannwyller', // café
      'sweetelle', // dessert restaurant
      // Alcohol
      'vinmonopolet',

      // Convenience / kiosks
      'narvesen', '7 eleven', 'mix', 'busstop',

      // Restaurants (generic names that appear in descriptions)
      'maaemo', 'statholdergaarden', 'brasserie', 'smalhans',
    ],

    // ────────────── TRANSPORT ──────────────
    TransactionCategory.transport: [
      // Rail & long distance
      'vy', 'vy tog', 'vy app', 'flytoget', 'sj nord', 'go ahead nordic',

      // Air
      'sas', 'norwegian', 'wideroe', 'flyr', 'norse atlantic',

      // Public transit by region
      'ruter', 'entur', 'skyss', 'brakar', 'atb', 'kolumbus',
      'tide', 'boreal', 'nordland fylke', 'tromsfylkes', 'innlandet',
      'vestfold', 'telemark', 'agder kollektiv', 'fram',
      'ostfold kollektiv', 'okt', 'akershus',

      // Ferry
      'fjord1', 'torghatten', 'ferje', 'norled', 'boreal sjoe',
      'hurtigruten', 'color line', 'fjord line', 'stena line', 'dfds',

      // Parking
      'easypark', 'europark', 'apcoa', 'onepark', 'aimo', 'aimo park',
      'autopay', 'parkering', 'indigo park', 'q park', 'p hus',

      // Toll / road
      'fjellinjen', 'autopass', 'vegamot', 'bompengeselskap', 'bompenger',
      'vegfinans', 'ferde', 'e6', 'fremtind service', 'skyttelpass',

      // Taxi & ride-hailing
      'oslo taxi', 'norgestaxi', 'taxifix', 'uber', 'bolt',
      'taxisentralen', '02323', '08000',

      // Micro-mobility
      'ryde', 'vooi', 'tier', 'voi', 'lime', 'bird',

      // Car rental & sharing
      'hyre', 'otto', 'bilkollektivet', 'hertz', 'avis', 'sixt',
      'europcar', 'budget', 'enterprise',

      // Fuel & charging
      'circle k', 'shell', 'esso', 'yx', 'uno x', 'okq8',
      'bensinstasjonen', 'st1', 'mer', 'recharge', 'ionity',
      'tesla supercharger', 'easee', 'zaptec', 'fortum lade',
      'elbil', 'ladestasjonen',
    ],

    // ───────────���── SHOPPING ──────────────
    TransactionCategory.shopping: [
      // Electronics
      'elkjop', 'power', 'netonnet', 'net on net', 'komplett',
      'eplehuset', 'multicom', 'proshop', 'dustin',

      // Home & hardware
      'clas ohlson', 'biltema', 'jula', 'ikea', 'obs bygg',
      'megaflis', 'maxbo', 'montér', 'monter', 'byggmax', 'bauhaus',
      'jernia', 'bohus', 'skeidar', 'living', 'home and cottage',
      'jysk', 'møbelringen', 'mobelringen',

      // Fashion & beauty
      'hm', 'h m', 'zara', 'mango', 'cubus', 'dressmann', 'bik bok',
      'kappahl', 'lindex', 'jack jones', 'volt', 'carlings',
      'match', 'weekday', 'monki', 'cos', 'arket',
      'zalando', 'boozt', 'miinto', 'nelly', 'stayhard', 'nakd',

      // Sport
      'xxl', 'sport 1', 'stadium', 'anton sport', 'sport outlet',
      'gresvig', 'milsluker', 'gsport',

      // Books / media
      'ark', 'norli', 'akademika', 'adlibris', 'platekompaniet',

      // Hobby stores
      'outland', // comics / games / hobby store
      'lekekassen', // online hobby store
      // Discount / variety
      'rusta', 'europris', 'nille', 'tigris', 'sodestream',
      'ahlens', 'flying tiger', 'sostrene grene',

      // Beauty
      'lyko', 'rituals', 'kicks', 'normal', 'vita',
      'theBody shop', 'lush', 'bangerhead',

      // Garden / pets
      'plantasjen', 'felleskjopet', 'felleskjoepet', 'musti',

      // Home decor
      'kid', 'princess', 'kremmerhuset', 'hay', 'designtorget',
      'tilbords', 'kitchn',

      // General online
      'amazon', 'ebay', 'wish', 'aliexpress', 'etsy', 'finn',
    ],

    // ────────────── HOUSING ──────────────
    TransactionCategory.housing: [
      // Housing associations
      'obos', 'usbl', 'bate', 'vestbo', 'bonord',
      'tobb', 'bbl', 'borettslag', 'sameie',

      // Rent / shared costs
      'husleie', 'felleskostnader', 'fellesutgifter',

      // Municipal charges
      'kommunekasse', 'kommunale avgifter', 'eiendomsskatt',
      'renovasjon', 'vann og avlop', 'vann avlop',

      // Insurance (home / contents)
      'if forsikring', 'gjensidige', 'storebrand forsikring',
      'tryg', 'fremtind', 'eika forsikring', 'frende',
      'knif', 'codan', 'sparebank forsikring',
      'innbo', 'innboforsikring', 'husforsikring', 'boligforsikring',

      // Home security
      'verisure', 'sector alarm', 'boligalarm',
      'securitas', 'avarn', 'nokas',

      // Home services
      'vaktmester', 'renhold', 'flyttebyra', 'vaskehjelp',
    ],

    // ────────────── UTILITIES / BILLS ──────────────
    TransactionCategory.utilities: [
      // Electricity providers
      'tibber', 'fjordkraft', 'hafslund', 'fortum', 'norgesenergi',
      'agva', 'motkraft', 'gudbrandsdal energi', 'lyse',
      'askoy energi', 'tromskraft', 'ishavskraft', 'helgeland kraft',
      'nordkraft', 'lofotkraft', 'tafjord',

      // Grid companies
      'elvia', 'bkk nett', 'bkk', 'tensio', 'lede', 'glitre nett',
      'nett', 'nettleie', 'lnett', 'agder energi nett', 'fagne',

      // Mobile operators
      'telia', 'telenor', 'ice', 'ice net', 'mycall', 'talkmore',
      'onecall', 'chilimobil', 'happybytes', 'fjordkraft mobil',
      'release', 'phonero', 'lycamobile', 'lebara',

      // Internet / fiber
      'altibox', 'viken fiber', 'globalconnect', 'broadnet',
      'nextgentel', 'homenet', 'eidsiva bredbånd', 'lynet',
      'telio', 'canal digital', 'get', 'telia bredband',
    ],

    // ────────────── HEALTH & WELLNESS ──────────────
    TransactionCategory.health: [
      // Pharmacy
      'apotek 1', 'vitusapotek', 'boots apotek', 'farmasiet', 'ditt apotek',

      // Gym / fitness
      'sats', 'evo', 'evo fitness', 'friskis', 'friskis svettis',
      'bare trening', 'family sports club', 'fresh fitness',
      'nr1 fitness', 'gain', 'stamina', 'elixia',
      'sio athletica', // SIO student gym
      'osi volleyball', // university sport club
      'skimore', // skiing membership
      // Hair / beauty services
      'cutters', 'nikita', 'sayso', 'adam eve',
      'green brothers', 'lemon', 'salongen',

      // Medical
      'dr dropin', 'volvat', 'aleris', 'kry', 'hjemmelegene',
      'hjelp24', 'eurofinns', 'furst', 'unilabs',

      // Dental
      'tannlege', 'oris', 'colosseum tannlege', 'opus dental',

      // Vision
      'specsavers', 'synsam', 'krogh optikk', 'brilleland',
      'interoptik', 'extra optical',

      // Therapy / specialists
      'memira', 'ifocus', 'kiropraktor', 'fysioterapeut',
      'osteopat', 'psykolog', 'mentalHelse',

      // Hospital / emergency
      'sykehus', 'legevakt', 'legekontor', 'fastlege', 'helfo',
    ],

    // ────────────── ENTERTAINMENT ──────────────
    TransactionCategory.entertainment: [
      // Streaming video
      'netflix', 'hbo', 'hbo max', 'disney', 'disney plus',
      'viaplay', 'discovery', 'discovery plus', 'tv2 play', 'tv 2 play',
      'paramount', 'apple tv', 'youtube premium', 'crunchyroll',
      'mubi', 'nrk lisens',

      // Streaming music / audio
      'spotify', 'tidal', 'apple music', 'audible', 'podimo',
      'storytel', 'fabel',

      // Gaming
      'steam', 'playstation', 'xbox', 'nintendo', 'epic games',
      'blizzard', 'riot games', 'twitch', 'roblox',

      // Cinema
      'odeon', 'nordisk film', 'kino', 'filmweb', 'sf kino',
      'borg kino', 'bergen kino', 'trondheim kino',

      // Events & tickets
      'ticketmaster', 'eventim', 'billettservice', 'tikkio',
      'hoopla', 'konsert', 'festival',

      // News / media subscriptions
      'aftenposten', 'vg', 'dagbladet', 'dagens naeringsliv', 'dn',
      'e24', 'nettavisen', 'bergens tidende', 'bt', 'adresseavisen',
      'stavanger aftenblad', 'faedrelandsvennen', 'nordlys',
      'itromso', 'nrk',

      // Gambling
      'norsk tipping', 'rikstoto', 'betsson', 'unibet', 'comeon',

      // Attractions
      'tusenfryd', 'tivoli', 'kristiansand dyrepark', 'hunderfossen',
      'bodo glimt', 'museum', 'zoo', 'akvariet',
      'holmenkollen', 'vigeland', 'kon tiki',
    ],

    // ────────────── INCOME ──────────────
    TransactionCategory.income: [
      'lonn',
      'salary',
      'nav',
      'skatteetaten',
      'tilgode',
      'skatteoppgjor',
      'utbytte',
      'feriepenger',
      'pensjon',
      'stipend',
      'lanekassen',
      'barnetrygd',
      'kontantstotte',
      'sykepenger',
      'dagpenger',
      'arbeidsavklaringspenger',
      'uforetrygd',
      'alderspensjon',
      'etterbetaling',
      'refusjon',
      'tilbakebetaling',
    ],

    // ────────────── TRANSFERS ──────────────
    TransactionCategory.transfer: [
      'overforing',
      'overforsel',
      'sparing',
      'spareavtale',
      'fond',
      'fondssparing',
      'aksjer',
      'investering',
      'nordnet',
      'kron',
      'dnb',
      'sbanken',
      'nordea',
      'danske bank',
      'handelsbanken',
      'sparebanken',
      'klarna',
      'paypal',
      'revolut',
      'wise',
      'transferwise',
      'vipps overf',
      'mellom egne',
      'intern overforing',
    ],
  };

  // ── Generic / descriptive keywords (lower weight) ─────────────
  // These are common words that suggest a category but aren't unique
  // merchant names.  They receive a lower score to avoid false
  // positives when they appear in unrelated descriptions.
  static const Map<TransactionCategory, List<String>> _genericKeywords = {
    TransactionCategory.food: [
      'matbutikk',
      'dagligvare',
      'bakeri',
      'cafe',
      'kafé',
      'kafe',
      'restaurant',
      'spisested',
      'sushi',
      'pizza',
      'kebab',
      'thai',
      'kinesisk',
      'indisk',
      'catering',
      'lunsj',
      'middag',
      'matlevering',
      'takeaway',
      'take away',
    ],
    TransactionCategory.transport: [
      'bensin',
      'diesel',
      'drivstoff',
      'parkering',
      'bompenger',
      'buss',
      'tog',
      'trikk',
      'tbane',
      'fly',
      'flybillett',
      'bilutleie',
      'bilverksted',
      'dekkskift',
      'eu kontroll',
      'lastebil',
      'bildeler',
      'elbil',
      'lading',
      'ladestasjon',
    ],
    TransactionCategory.shopping: [
      'butikk',
      'klaer',
      'sko',
      'smykker',
      'tilbehor',
      'elektronikk',
      'data',
      'mobil',
      'netthandel',
      'nettbutikk',
      'gave',
      'blomster',
      'interiør',
      'interior',
      'mobler',
      'moebel',
    ],
    TransactionCategory.housing: [
      'husleie',
      'leie',
      'bolig',
      'leilighet',
      'hus',
      'forsikring',
      'innbo',
      'alarm',
      'vedlikehold',
      'oppussing',
      'rorlegger',
      'elektriker',
      'snekker',
      'maler',
    ],
    TransactionCategory.utilities: [
      'strom',
      'strøm',
      'nettleie',
      'mobil',
      'telefon',
      'bredband',
      'bredbånd',
      'internett',
      'fiber',
      'tv pakke',
    ],
    TransactionCategory.health: [
      'apotek',
      'lege',
      'tannlege',
      'sykehus',
      'helse',
      'trening',
      'gym',
      'frisor',
      'terapi',
      'medisin',
      'resept',
      'behandling',
      'konsultasjon',
      'linser',
      'briller',
      'optikk',
    ],
    TransactionCategory.entertainment: [
      'kino',
      'konsert',
      'teater',
      'museum',
      'utstilling',
      'abonnement',
      'streaming',
      'spill',
      'underholdning',
      'festival',
      'billett',
      'bowling',
      'minigolf',
    ],
    TransactionCategory.income: [
      'inntekt',
      'godtgjorelse',
      'honorar',
      'provisjon',
      'utbetaling',
      'avkastning',
      'renter innbetalt',
    ],
    TransactionCategory.transfer: [
      'overforing',
      'overføring',
      'sparing',
      'investering',
      'fond',
      'konto',
      'betaling til',
      'innbetaling',
    ],
  };
}
