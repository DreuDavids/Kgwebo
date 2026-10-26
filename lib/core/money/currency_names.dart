/// Spoken currency names and aliases for Ask and forms.
abstract final class CurrencyNames {
  static String spoken(String code) {
    return switch (code.trim().toUpperCase()) {
      'BWP' => 'pula',
      'ZAR' => 'rand',
      'NAD' => 'Namibia dollars',
      'USD' => 'US dollars',
      _ => code.trim().toUpperCase(),
    };
  }

  static Set<String> aliases(String code) {
    return switch (code.trim().toUpperCase()) {
      'BWP' => {'bwp', 'pula', 'pulas', 'p'},
      'ZAR' => {'zar', 'rand', 'rands', 'r'},
      'NAD' => {'nad'},
      'USD' => {'usd', 'dollar', 'dollars'},
      _ => {code.trim().toLowerCase()},
    };
  }

  static String? codeOf(String? raw) {
    if (raw == null) {
      return null;
    }
    final token = raw.trim().toLowerCase();
    if (token.isEmpty) {
      return null;
    }
    if (aliases('BWP').contains(token)) {
      return 'BWP';
    }
    if (aliases('ZAR').contains(token)) {
      return 'ZAR';
    }
    if (aliases('NAD').contains(token)) {
      return 'NAD';
    }
    if (aliases('USD').contains(token)) {
      return 'USD';
    }
    if (RegExp(r'^[a-z]{3}$').hasMatch(token)) {
      return token.toUpperCase();
    }
    return null;
  }
}
