import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sessao_pomodoro.dart';

class RepositorioSessoes {
  // Mantém a chave original para preservar o histórico.
  static const _chave = 'pomodoro_sessoes_v1';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  Future<void> _fila = Future<void>.value();

  Future<List<SessaoPomodoro>> carregarSessoes() async {
    final dados = await _prefs.getString(_chave);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List<dynamic>;
    final sessoes = lista
        .map((item) => SessaoPomodoro.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    sessoes.sort((a, b) => b.concluidaEm.compareTo(a.concluidaEm));
    return sessoes;
  }

  Future<void> adicionarSessao(SessaoPomodoro sessao) {
    _fila = _fila.catchError((Object _) {}).then((_) async {
      final sessoes = await carregarSessoes();
      if (sessoes.any((s) => s.id == sessao.id)) return;
      sessoes.insert(0, sessao);
      await _prefs.setString(
        _chave,
        jsonEncode(sessoes.map((s) => s.toJson()).toList()),
      );
    });
    return _fila;
  }
}
