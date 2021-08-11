class AuthException with Exception {
  final String key;
  static const Map<String, String> errors = {
    'EMAIL_EXISTS': 'Esse e-mail já está em uso',
    'OPERATION_NOT_ALLOWED': 'Operação não permitida',
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'Tente mais tarde',
    'EMAIL_NOT_FOUND': 'E-mail não encontrado',
    'INVALID_PASSWORD': 'Senha inválida',
    'USER_DISABLED': 'Usuário desativado',
  };

  const AuthException(this.key);

  @override
  String toString() {
    if (errors.containsKey(key))
      return errors[key];
    else
      return 'Ocorreu um erro';
  }
}
