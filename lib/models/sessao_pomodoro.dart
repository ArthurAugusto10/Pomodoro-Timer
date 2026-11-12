class SessaoPomodoro {
  final String id;
  final String tipo;
  final int duracaoSegundos;
  final DateTime concluidaEm;

  SessaoPomodoro({
    required this.id,
    required this.tipo,
    required this.duracaoSegundos,
    required this.concluidaEm,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'duracaoSegundos': duracaoSegundos,
        'concluidaEm': concluidaEm.toIso8601String(),
      };

  factory SessaoPomodoro.fromJson(Map<String, dynamic> json) => SessaoPomodoro(
        id: json['id'] as String,
        tipo: json['tipo'] as String,
        duracaoSegundos: json['duracaoSegundos'] as int,
        concluidaEm: DateTime.parse(json['concluidaEm'] as String),
      );
}
