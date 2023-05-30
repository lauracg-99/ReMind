
// Supongamos que tienes una clase 'Solicitud' que representa la solicitud de supervisión
class Solicitud {
  String? id;
  String uidBoss;
  String emailBoss;
  String emailSup;
  String estado;
  String uidSup;
  String fotoSup;

  //Solicitud({ this.id, this.mensaje, this.receptorUserId});

  Solicitud({
    String? id,
    required this.uidBoss,
    required this.emailBoss,
    required this.emailSup,
    required this.estado,
    required this.uidSup,
    required this.fotoSup
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uidBoss': uidBoss,
      'emailBoss': emailBoss,
      'emailSup': emailSup,
      'estado': estado,
      'uidSup': uidSup,
      'fotoSup': fotoSup
    }..removeWhere((key, value) => value == null);
  }

  factory Solicitud.fromMap(Map<String, dynamic> map) {
    return Solicitud(
      id: map['id'] ?? '',
      uidBoss: map['uidBoss'] ?? '',
      emailBoss: map['emailBoss'] ?? '',
      emailSup: map['emailSup'] ?? '',
      estado: map['estado'] ?? '',
      uidSup: map['uidSup'] ?? '',
      fotoSup: map['fotoSup'] ?? ''
    );
  }
}

