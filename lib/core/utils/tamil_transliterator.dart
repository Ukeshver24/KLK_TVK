/// Client-side Tamil Localization and Transliteration Utility for Location Names
class TamilTransliterator {
  static const Map<String, String> _placeDict = {
    // Taluks
    'kallakurichi': 'கள்ளக்குறிச்சி',
    'chinnasalem': 'சின்னசேலம்',
    'chinna salem': 'சின்னசேலம்',
    'sankarapuram': 'சங்கராபுரம்',
    'tirukkoyilur': 'திருக்கோவிலூர்',
    'thirukoilur': 'திருக்கோவிலூர்',
    'ulundurpet': 'உளுந்தூர்பேட்டை',
    'ulundurpettai': 'உளுந்தூர்பேட்டை',
    'kalvarayan hills': 'கல்வராயன் மலை',
    'kalvarayan': 'கல்வராயன்',
    'rishivandiyam': 'ரிஷிவந்தியம்',
    'thiyagadurgam': 'தியாகதுருகம்',

    // Villages
    'kallakurichi municipality (town wards 1-21)': 'கள்ளக்குறிச்சி நகராட்சி (Town Wards 1-21)',
    'kallakurichi municipality': 'கள்ளக்குறிச்சி நகராட்சி',
    'anthiyur': 'அந்தியூர்',
    'asakalathur': 'அசகளத்தூர்',
    'alathur': 'ஆலத்தூர்',
    'iravathangudi': 'இரவத்தங்குடி',
    'rayarpalayam': 'இராயர்பாளையம்',
    'indili': 'இந்திலி',
    'esanthai': 'ஈசாந்தை',
    'eyanur': 'ஈயனூர்',
    'eravar': 'எரவார்',
    'eranji': 'எறஞ்சி',
    'emmappar': 'எமப்பேர்',
    'emappur': 'ஏமப்பூர்',
    'eliyathur': 'எலியத்தூர்',
    'kachakkudi': 'காச்சக்குடி',
    'ka.mamanandal': 'க.மாமனந்தல்',
    'kanangur': 'கணங்கூர்',
    'kandachimangalam': 'கண்டாச்சிமங்கலம்',
    'kaniyamoor': 'கணியாமூர்',
    'karunapuram': 'கருணாபுரம்',
    'karanur': 'காரனூர்',
    'kattanandal': 'காட்டானந்தல்',
    'keezhnariyappanur': 'கீழ்நாரியப்பனூர்',
    'keezhpoondi': 'கீழ்பூண்டி',
    'kuthiraichandal': 'குதிரைச்சந்தல்',
    'gurubeedapuram': 'குருபீடபுரம்',
    'koonthalur': 'கூந்தலூர்',
    'kongarayapalayam': 'கொங்கராயபாளையம்',
    'sadayampattu': 'சடையம்பட்டு',
    'siruvangur': 'சிறுவங்கூர்',
    'sithalandur': 'சித்தாலந்தூர்',
    'sitheripattu': 'சித்தேரிப்பட்டு',
    'chinnamampattu': 'சின்னமாம்பட்டு',
    'sembakurichi': 'செம்பாக்குறிச்சி',
    'somandarkudi': 'சோமண்டார்குடி',
    'thachur': 'தச்சூர்',
    'thenkeeranur': 'தென்கீரனூர்',
    'neelamangalam': 'நீலமங்கலம்',
    'parigam': 'பரிகம்',
    'porasakkurichi': 'பொருசக்குறிச்சி',
    'porpalakurichi': 'பொற்பலாக்குறிச்சி',
    'madur': 'மாடூர்',
    'mathur': 'மாத்தூர்',
    'varanjaram': 'வரஞ்சரம்',
    'virugavur': 'விருகாவூர்',
    'vilambavur': 'விளாம்பாவூர்',
    'veerasozhapuram': 'வீரசோழபுரம்',
    'vengaivadi': 'வேங்கைவாடி',
    'vettavalam': 'வெட்டவலம்',
    'kallanatham': 'கல்லாநத்தம்',
    'other area / hamlet': 'மற்றவை / பிற பகுதி (Other Area)',
    'other area': 'மற்றவை / பிற பகுதி',
    'other': 'மற்றவை',
  };

  /// Check if string contains Tamil script
  static bool isTamil(String text) {
    return RegExp(r'[\u0B80-\u0BFF]').hasMatch(text);
  }

  /// Localize any place name to Tamil
  static String toTamil(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return clean;
    if (isTamil(clean)) return clean;

    final lower = clean.toLowerCase();
    if (_placeDict.containsKey(lower)) {
      return _placeDict[lower]!;
    }

    // Check Ward pattern e.g. "Ward 5"
    final wardMatch = RegExp(r'^(?:town\s+)?ward\s*(\d+.*)$', caseSensitive: false).firstMatch(lower);
    if (wardMatch != null) {
      return 'வார்டு ${wardMatch.group(1)}';
    }

    // Common suffix replacements
    String result = lower;
    final suffixMap = {
      'palayam': 'பாளையம்',
      'pattinam': 'பட்டினம்',
      'patti': 'பட்டி',
      'pattu': 'பட்டு',
      'puram': 'புரம்',
      'mangalam': 'மங்கலம்',
      'nallur': 'நல்லூர்',
      'kudi': 'குடி',
      'cheri': 'சேரி',
      'nagar': 'நகர்',
      'thoppu': 'தோப்பு',
      'medu': 'மேடு',
      'kadu': 'காடு',
      'valasu': 'வலசு',
      'pakkam': 'பாக்கம்',
      'salem': 'சேலம்',
      'kurichi': 'குறிச்சி',
      'chandal': 'சந்தல்',
      'kulam': 'குளம்',
      'kottai': 'கோட்டை',
      'oor': 'ஊர்',
      'ur': 'ஊர்',
    };

    for (final entry in suffixMap.entries) {
      if (result.endsWith(entry.key) && result.length > entry.key.length) {
        final prefix = result.substring(0, result.length - entry.key.length);
        return '${toTamil(prefix)}${entry.value}';
      }
    }

    return clean;
  }
}
