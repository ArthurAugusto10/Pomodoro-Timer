import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../models/sessao_pomodoro.dart';
import '../repositories/repositorio_tarefas.dart';
import '../repositories/repositorio_sessoes.dart';
import '../themes/app_theme.dart';
import '../widgets/app_background.dart';
import 'tela_dashboard.dart';

enum ModoTimer { foco, pausaCurta, pausaLonga }

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final _repositorioTarefas = RepositorioTarefas();
  final _repositorioSessoes = RepositorioSessoes();
  final _tarefaController = TextEditingController();
  final List<Tarefa> _tarefas = [];
  final List<SessaoPomodoro> _sessoes = [];

  bool _carregandoTarefas = true;
  bool _carregandoSessoes = true;
  ModoTimer _modo = ModoTimer.foco;
  int _segundosRestantes = 25 * 60;
  Timer? _timer;
  DateTime? _prazo;
  bool _executando = false;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
    _carregarSessoes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tarefaController.dispose();
    super.dispose();
  }

  int _duracao(ModoTimer modo) {
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
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  int get _ciclosHoje {
    final agora = DateTime.now();
    return _sessoes.where((sessao) {
      final dia = sessao.concluidaEm.toLocal();
      return sessao.tipo == 'Foco' &&
          dia.year == agora.year &&
          dia.month == agora.month &&
          dia.day == agora.day;
    }).length;
  }

  void _mensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> _carregarTarefas() async {
    try {
      final tarefas = await _repositorioTarefas.carregarTarefas();
      if (!mounted) return;
      setState(() {
        _tarefas..clear()..addAll(tarefas);
      });
    } catch (erro) {
      debugPrint('Erro ao carregar tarefas: $erro');
      _mensagem('Não foi possível carregar as tarefas.');
    } finally {
      if (mounted) setState(() => _carregandoTarefas = false);
    }
  }

  Future<void> _salvarTarefas() async {
    try {
      await _repositorioTarefas.salvarTarefas(_tarefas);
    } catch (erro) {
      debugPrint('Erro ao salvar tarefas: $erro');
      _mensagem('Não foi possível salvar as tarefas.');
    }
  }

  Future<void> _carregarSessoes() async {
    try {
      final sessoes = await _repositorioSessoes.carregarSessoes();
      if (!mounted) return;
      setState(() {
        _sessoes..clear()..addAll(sessoes);
      });
    } catch (erro) {
      debugPrint('Erro ao carregar sessões: $erro');
      _mensagem('Não foi possível carregar o histórico.');
    } finally {
      if (mounted) setState(() => _carregandoSessoes = false);
    }
  }

  void _adicionarTarefa() {
    if (_carregandoTarefas) return;
    final titulo = _tarefaController.text.trim();
    if (titulo.isEmpty) return;
    setState(() {
      _tarefas.add(Tarefa(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: titulo,
      ));
    });
    _tarefaController.clear();
    FocusScope.of(context).unfocus();
    _salvarTarefas();
  }

  void _alternarTarefa(Tarefa tarefa, bool? valor) {
    if (_carregandoTarefas) return;
    setState(() => tarefa.concluida = valor ?? false);
    _salvarTarefas();
  }

  void _removerTarefa(Tarefa tarefa) {
    if (_carregandoTarefas) return;
    setState(() => _tarefas.remove(tarefa));
    _salvarTarefas();
  }

  void _alterarModo(ModoTimer modo) {
    _timer?.cancel();
    setState(() {
      _modo = modo;
      _segundosRestantes = _duracao(modo);
      _prazo = null;
      _executando = false;
    });
  }

  void _iniciarOuPausar() {
    if (_executando) {
      _pausarTimer();
    } else {
      _iniciarTimer();
    }
  }

  void _iniciarTimer() {
    if (_executando || _segundosRestantes <= 0 || _carregandoSessoes) return;
    _prazo = DateTime.now().add(Duration(seconds: _segundosRestantes));
    setState(() => _executando = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _atualizarTimer());
  }

  void _atualizarTimer() {
    if (!mounted || !_executando || _prazo == null) return;
    final faltam = _prazo!.difference(DateTime.now()).inMilliseconds;
    final restante = faltam <= 0 ? 0 : (faltam / 1000).ceil();
    if (restante > 0) {
      if (restante != _segundosRestantes) {
        setState(() => _segundosRestantes = restante);
      }
      return;
    }
    _timer?.cancel();
    final modoConcluido = _modo;
    final duracao = _duracao(modoConcluido);
    setState(() {
      _executando = false;
      _prazo = null;
      _segundosRestantes = 0;
    });
    _registrarSessao(modoConcluido, duracao);
  }

  void _pausarTimer() {
    if (!_executando) return;
    _atualizarTimer();
    if (!_executando) return;
    _timer?.cancel();
    setState(() {
      _executando = false;
      _prazo = null;
    });
  }

  void _reiniciarTimer() {
    _timer?.cancel();
    setState(() {
      _executando = false;
      _prazo = null;
      _segundosRestantes = _duracao(_modo);
    });
  }

  Future<void> _registrarSessao(ModoTimer modo, int duracao) async {
    final agora = DateTime.now();
    final tipo = switch (modo) {
      ModoTimer.foco => 'Foco',
      ModoTimer.pausaCurta => 'Pausa curta',
      ModoTimer.pausaLonga => 'Pausa longa',
    };
    final sessao = SessaoPomodoro(
      id: agora.microsecondsSinceEpoch.toString(),
      tipo: tipo,
      duracaoSegundos: duracao,
      concluidaEm: agora,
    );
    try {
      await _repositorioSessoes.adicionarSessao(sessao);
      if (!mounted) return;
      setState(() => _sessoes.insert(0, sessao));
      _mensagem('Sessão concluída e registrada!');
    } catch (erro) {
      debugPrint('Erro ao salvar sessão: $erro');
      _mensagem('Sessão encerrada, mas não foi possível salvar.');
    }
  }

  String _formatarData(DateTime original) {
    final data = original.toLocal();
    String dois(int n) => n.toString().padLeft(2, '0');
    return '${dois(data.day)}/${dois(data.month)}/${data.year} às ${dois(data.hour)}:${dois(data.minute)}';
  }

  String _formatarDuracao(int segundos) {
    final minutos = segundos ~/ 60;
    final resto = segundos % 60;
    return resto == 0 ? '$minutos min' : '$minutos min ${resto}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            tooltip: 'Dashboard de produtividade',
            icon: const Icon(Icons.bar_chart, color: AppTheme.cyan),
            onPressed: _carregandoSessoes
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaDashboard(sessoes: List.of(_sessoes)),
                      ),
                    ),
          ),
        ],
      ),
      body: AppBackground(
        imagePath: 'assets/images/backgrounds/bg_home.jpg',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Text('HORA DE MANTER O FOCO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.cyan,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        )),
                    const SizedBox(height: 22),
                    SegmentedButton<ModoTimer>(
                      segments: const [
                        ButtonSegment(value: ModoTimer.foco, label: Text('Foco')),
                        ButtonSegment(value: ModoTimer.pausaCurta, label: Text('Curta')),
                        ButtonSegment(value: ModoTimer.pausaLonga, label: Text('Longa')),
                      ],
                      selected: {_modo},
                      onSelectionChanged: (selecionados) => _alterarModo(selecionados.first),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                        child: Column(
                          children: [
                            const Icon(Icons.bolt, color: AppTheme.pink, size: 30),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _tempoFormatado,
                                style: const TextStyle(
                                  color: AppTheme.cyan,
                                  fontSize: 76,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _carregandoSessoes ? null : _iniciarOuPausar,
                                  icon: Icon(_executando ? Icons.pause : Icons.play_arrow),
                                  label: Text(_executando ? 'Pausar' : 'Iniciar'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _reiniciarTimer,
                                  icon: const Icon(Icons.restart_alt),
                                  label: const Text('Reiniciar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Text('PRODUTIVIDADE DE HOJE',
                                style: TextStyle(color: AppTheme.purple, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Ciclos concluídos: $_ciclosHoje',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Histórico de sessões',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (_carregandoSessoes)
                      const Center(child: CircularProgressIndicator())
                    else if (_sessoes.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('Nenhuma sessão concluída ainda.', textAlign: TextAlign.center),
                        ),
                      )
                    else
                      ..._sessoes.take(10).map((sessao) => Card(
                            key: ValueKey(sessao.id),
                            child: ListTile(
                              leading: Icon(
                                sessao.tipo == 'Foco' ? Icons.timer : Icons.coffee,
                                color: sessao.tipo == 'Foco' ? AppTheme.cyan : AppTheme.pink,
                              ),
                              title: Text(sessao.tipo),
                              subtitle: Text(_formatarData(sessao.concluidaEm)),
                              trailing: Text(_formatarDuracao(sessao.duracaoSegundos)),
                            ),
                          )),
                    const SizedBox(height: 25),
                    const Text('Minhas tarefas',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tarefaController,
                            enabled: !_carregandoTarefas,
                            decoration: const InputDecoration(hintText: 'Nova tarefa...'),
                            onSubmitted: (_) => _adicionarTarefa(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          tooltip: 'Adicionar tarefa',
                          onPressed: _carregandoTarefas ? null : _adicionarTarefa,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_carregandoTarefas)
                      const Center(child: CircularProgressIndicator())
                    else if (_tarefas.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Nenhuma tarefa cadastrada.', textAlign: TextAlign.center),
                      )
                    else
                      ..._tarefas.map((tarefa) => Card(
                            key: ValueKey(tarefa.id),
                            child: CheckboxListTile(
                              value: tarefa.concluida,
                              onChanged: (v) => _alternarTarefa(tarefa, v),
                              title: Text(
                                tarefa.titulo,
                                style: TextStyle(
                                  decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.pink),
                                onPressed: () => _removerTarefa(tarefa),
                              ),
                            ),
                          )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
