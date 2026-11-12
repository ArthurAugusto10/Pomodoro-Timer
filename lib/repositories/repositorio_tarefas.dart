import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarefa.dart';

class RepositorioTarefas {
  // Mantém a mesma chave da versão anterior para preservar tarefas.
  static const _chave = 'pomodoro_tarefas_v1';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  Future<void> _fila = Future<void>.value();

  Future<List<Tarefa>> carregarTarefas() async {
    final dados = await _prefs.getString(_chave);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List<dynamic>;
    return lista
        .map((item) => Tarefa.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> salvarTarefas(List<Tarefa> tarefas) {
    // Captura um snapshot antes de adicionar à fila.
    final json = jsonEncode(tarefas.map((t) => t.toJson()).toList());
    _fila = _fila.catchError((Object _) {}).then((_) async {
      await _prefs.setString(_chave, json);
    });
    return _fila;
  }
}
