class Tarefa {
  final String id;
  final String titulo;
  bool concluida;
  int pomodorosEstimados;
  int pomodorosRealizados;

  Tarefa({
    required this.id,
    required this.titulo,
    this.concluida = false,
    this.pomodorosEstimados = 1,
    this.pomodorosRealizados = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'concluida': concluida,
        'pomodorosEstimados': pomodorosEstimados,
        'pomodorosRealizados': pomodorosRealizados,
      };

  factory Tarefa.fromJson(Map<String, dynamic> json) => Tarefa(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        concluida: json['concluida'] as bool? ?? false,
        pomodorosEstimados: json['pomodorosEstimados'] as int? ?? 1,
        pomodorosRealizados: json['pomodorosRealizados'] as int? ?? 0,
      );
}
