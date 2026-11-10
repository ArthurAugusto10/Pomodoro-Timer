
import 'dart:async';

import 'package:flutter/material.dart';
import '../models/tarefa.dart';

enum ModoTimer {
  foco,
  pausaCurta,
  pausaLonga,
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  Timer? _timer;

  ModoTimer _modoAtual = ModoTimer.foco;

  int _segundosRestantes = 25 * 60;
  bool _executando = false;
  int _ciclosConcluidos = 0;

  final List<Tarefa> _tarefas = [];
  final TextEditingController _tarefaController =
      TextEditingController();

  int _duracaoModo(ModoTimer modo) {
    switch (modo) {
      case ModoTimer.foco:
        return 25 * 60;
      case ModoTimer.pausaCurta:
        return 5 * 60;
      case ModoTimer.pausaLonga:
        return 15 * 60;
    }
  }

  String get _tempoFormatado {
    final minutos = _segundosRestantes ~/ 60;
    final segundos = _segundosRestantes % 60;

    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundos.toString().padLeft(2, '0')}';
  }

  void _alterarModo(ModoTimer modo) {
    _timer?.cancel();

    setState(() {
      _modoAtual = modo;
      _segundosRestantes = _duracaoModo(modo);
      _executando = false;
    });
  }

  void _iniciarTimer() {
    if (_executando || _segundosRestantes == 0) return;

    setState(() {
      _executando = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        if (_segundosRestantes > 1) {
          setState(() {
            _segundosRestantes--;
          });
        } else {
          timer.cancel();

          setState(() {
            _segundosRestantes = 0;
            _executando = false;

            if (_modoAtual == ModoTimer.foco) {
              _ciclosConcluidos++;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ciclo finalizado!'),
            ),
          );
        }
      },
    );
  }

  void _pausarTimer() {
    _timer?.cancel();

    setState(() {
      _executando = false;
    });
  }

  void _reiniciarTimer() {
    _timer?.cancel();

    setState(() {
      _segundosRestantes = _duracaoModo(_modoAtual);
      _executando = false;
    });
  }

  void _adicionarTarefa() {
    final titulo = _tarefaController.text.trim();

    if (titulo.isEmpty) return;

    setState(() {
      _tarefas.add(
        Tarefa(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          titulo: titulo,
        ),
      );
    });

    _tarefaController.clear();
    FocusScope.of(context).unfocus();
  }

  void _alternarTarefa(Tarefa tarefa, bool? valor) {
    setState(() {
      tarefa.concluida = valor ?? false;
    });
  }

  void _removerTarefa(Tarefa tarefa) {
    setState(() {
      _tarefas.remove(tarefa);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tarefaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        centerTitle: true,
        backgroundColor: const Color(0xFF151521),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
                'Hora de manter o foco!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              SegmentedButton<ModoTimer>(
                segments: const [
                  ButtonSegment(
                    value: ModoTimer.foco,
                    label: Text('Foco'),
                  ),
                  ButtonSegment(
                    value: ModoTimer.pausaCurta,
                    label: Text('Curta'),
                  ),
                  ButtonSegment(
                    value: ModoTimer.pausaLonga,
                    label: Text('Longa'),
                  ),
                ],
                selected: {_modoAtual},
                onSelectionChanged: (selecionados) {
                  _alterarModo(selecionados.first);
                },
              ),

              const SizedBox(height: 35),

              Text(
                _tempoFormatado,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 25),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        _executando ? _pausarTimer : _iniciarTimer,
                    icon: Icon(
                      _executando
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      _executando ? 'Pausar' : 'Iniciar',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _reiniciarTimer,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Produtividade de hoje',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ciclos concluídos: $_ciclosConcluidos',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Minhas tarefas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tarefaController,
                      decoration: const InputDecoration(
                        hintText: 'Nova tarefa...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _adicionarTarefa(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _adicionarTarefa,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (_tarefas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Nenhuma tarefa cadastrada.',
                    textAlign: TextAlign.center,
                  ),
                ),

              ..._tarefas.map(
                (tarefa) => Card(
                  child: CheckboxListTile(
                    value: tarefa.concluida,
                    onChanged: (valor) {
                      _alternarTarefa(tarefa, valor);
                    },
                    title: Text(
                      tarefa.titulo,
                      style: TextStyle(
                        decoration: tarefa.concluida
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removerTarefa(tarefa),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
