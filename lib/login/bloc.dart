class LogInException implements Exception {}

class Bloc {
  Future<void> login(String email, String password) {
    throw LogInException();
  }
}
