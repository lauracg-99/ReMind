class UserEntity {
  final String uId;
  final String email;
  final String? name;
  final String? rol;
  final String? uidSupervised;
  final String? emailSup;
  final String? image;

  UserEntity({
    required this.uId,
    required this.email,
    this.name,
    this.rol,
    this.uidSupervised,
    this.emailSup,
    required this.image,
  });
}
