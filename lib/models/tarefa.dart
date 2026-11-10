
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
}
