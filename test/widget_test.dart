

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer_app/app.dart';

void main() {
  testWidgets('Teste inicial do Pomodoro Timer', (tester) async {
    await tester.pumpWidget(const PomodoroApp());

    // Verifica se o título do aplicativo aparece.
    expect(find.text('Pomodoro Timer'), findsOneWidget);

    // Verifica se o cronômetro inicia em 25 minutos.
    expect(find.text('25:00'), findsOneWidget);

    // Verifica se o botão de iniciar existe.
    expect(find.text('Iniciar'), findsOneWidget);

    // Verifica se a área de tarefas aparece.
    expect(find.text('Minhas tarefas'), findsOneWidget);
  });
}
