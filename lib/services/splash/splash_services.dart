class SplashServices {

  Future<void> waitForSplash() async {
    await Future.delayed(const Duration(seconds: 6));
  }

  //  Future upgrade 
  Future<bool> checkUserLoggedIn() async {
    // Example: SharedPreferences / Firebase check
    return false;
  }
}