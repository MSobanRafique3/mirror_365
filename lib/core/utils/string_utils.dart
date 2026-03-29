class StringUtils {
  StringUtils._();

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static String titleCase(String s) {
    return s.split(' ').map(capitalize).join(' ');
  }

  static String truncate(String s, int maxLength, {String ellipsis = '...'}) {
    if (s.length <= maxLength) return s;
    return '${s.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  static String pluralize(int count, String singular, [String? plural]) {
    if (count == 1) return '$count $singular';
    return '$count ${plural ?? '${singular}s'}';
  }

  static String formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
