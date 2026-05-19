class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class EmailAlreadyRegisteredException extends AuthException {
  const EmailAlreadyRegisteredException()
      : super('Akun belum terdaftar. Silakan Sign Up terlebih dahulu.');
}

class EmailNotFoundException extends AuthException {
  const EmailNotFoundException()
      : super('Akun belum terdaftar. Silakan Sign Up terlebih dahulu.');
}

class WrongPasswordException extends AuthException {
  const WrongPasswordException() : super('Password salah. Coba lagi.');
}