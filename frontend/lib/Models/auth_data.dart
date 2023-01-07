class AuthData {
  final String issuer;
  final String secret;
  final bool totp;
  final String user;

  AuthData(
      {required this.issuer,
      required this.secret,
      required this.totp,
      required this.user});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      issuer: json['issuer'],
      secret: json['secret'],
      totp: json['totp'],
      user: json['user'],
    );
  }
}
