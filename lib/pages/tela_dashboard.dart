import 'package:flutter/material.dart';
import '../models/sessao_pomodoro.dart';
import '../themes/app_theme.dart';
import '../widgets/app_background.dart';

class TelaDashboard extends StatelessWidget {
  final List<SessaoPomodoro> sessoes;

  const TelaDashboard({super.key, required this.sessoes});

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<SessaoPomodoro> _doDia(DateTime dia) => sessoes
      .where((s) => _mesmoDia(s.concluidaEm.toLocal(), dia))
      .toList();

  int _focos(List<SessaoPomodoro> lista) =>
      lista.where((s) => s.tipo == 'Foco').length;

  int _tempoFoco(List<SessaoPomodoro> lista) => lista
      .where((s) => s.tipo == 'Foco')
      .fold<int>(0, (total, s) => total + s.duracaoSegundos);

  String _duracao(int segundos) {
    if (segundos < 60) return '${segundos}s';
    final h = segundos ~/ 3600;
    final m = (segundos % 3600) ~/ 60;
    final s = segundos % 60;
    if (h > 0) return '${h}h ${m}min';
    return s > 0 ? '${m}min ${s}s' : '${m}min';
  }

  Widget _indicador(IconData icone, String titulo, String valor, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 27, color: cor),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(valor,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            Text(titulo, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _grafico() {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dias = List.generate(7, (i) => hoje.subtract(Duration(days: 6 - i)));
    final valores = dias.map((dia) => _focos(_doDia(dia))).toList();
    final maximo = valores.fold<int>(1, (max, valor) => valor > max ? valor : max);
    const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ciclos de foco — últimos 7 dias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sessões concluídas por dia',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            SizedBox(
              height: 195,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final altura = valores[i] / maximo * 125.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${valores[i]}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 7),
                          Container(
                            height: altura,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AppTheme.purple, AppTheme.cyan],
                              ),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(nomes[dias[i].weekday - 1],
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo geral',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.task_alt, color: AppTheme.cyan),
              title: const Text('Total de ciclos de foco'),
              trailing: Text('${_focos(sessoes)}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule, color: AppTheme.purple),
              title: const Text('Tempo total de foco'),
              trailing: Text(_duracao(_tempoFoco(sessoes))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history, color: AppTheme.pink),
              title: const Text('Sessões registradas'),
              trailing: Text('${sessoes.length}'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoje = _doDia(DateTime.now());
    final pausas = hoje.where((s) => s.tipo != 'Foco').length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      
appBar: AppBar(
  title: const Text(
    'Dashboard de Produtividade',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,

  // Fundo escuro para combinar com o Cyberpunk Neon
  backgroundColor: const Color(0xFF0B1020),
  foregroundColor: const Color(0xFF22D3EE),

  elevation: 0,
  surfaceTintColor: Colors.transparent,

  // Botão de voltar personalizado
  leading: IconButton(
    tooltip: 'Voltar',
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: Color(0xFF22D3EE),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
),

      body: AppBackground(
        imagePath: 'assets/images/backgrounds/bg_dashboard.jpg',
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
                    const Text('Seu desempenho',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Acompanhe seus resultados reais',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    LayoutBuilder(builder: (context, constraints) {
                      final colunas = constraints.maxWidth < 640 ? 2 : 4;
                      return GridView.count(
                        crossAxisCount: colunas,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: colunas == 4 ? 1.12 : 1.2,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          _indicador(Icons.timer, 'Ciclos de foco',
                              '${_focos(hoje)}', AppTheme.purple),
                          _indicador(Icons.access_time, 'Tempo focado',
                              _duracao(_tempoFoco(hoje)), AppTheme.cyan),
                          _indicador(Icons.coffee, 'Pausas concluídas',
                              '$pausas', AppTheme.orange),
                          _indicador(Icons.calendar_today, 'Sessões hoje',
                              '${hoje.length}', AppTheme.mint),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),
                    _grafico(),
                    const SizedBox(height: 20),
                    _resumo(),
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
