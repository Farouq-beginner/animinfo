class SplashState {
  // Reset to false on app start/refresh; set to true after splash completes.
  static bool shown = false;
  // If user opened a deep link before splash, keep it here to resume after splash.
  static String? pendingPath;
}
