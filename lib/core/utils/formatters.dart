class Formatters {
  Formatters._();

  /// Formats bytes into human-readable size (KB, MB, GB).
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Formats duration in milliseconds into human-readable string.
  static String duration(int ms) {
    if (ms < 1000) return '${ms}ms';
    final seconds = ms / 1000;
    if (seconds < 60) return '${seconds.toStringAsFixed(1)}s';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes}m ${remainingSeconds}s';
  }

  /// Formats DateTime into relative time string (e.g. "2h ago", "Yesterday").
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Formats file extension for display.
  static String formatExtension(String ext) {
    return ext.replaceAll('.', '').toUpperCase();
  }

  /// Formats a format string as uppercase badge label.
  static String formatBadge(String format) => format.toUpperCase();

  /// Returns human-readable size difference string.
  static String sizeDiff(int original, int converted) {
    final diff = original - converted;
    final pct = original > 0 ? (diff / original * 100).abs() : 0;
    if (diff > 0) return '${pct.toStringAsFixed(0)}% smaller';
    if (diff < 0) return '${pct.toStringAsFixed(0)}% larger';
    return 'Same size';
  }
}
