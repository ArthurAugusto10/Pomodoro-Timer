import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_timer_app/app.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Tela inicial apresenta cronômetro e tarefas', (tester) async {
    await tester.pumpWidget(const PomodoroApp());
    await tester.pumpAndSettle();
    expect(find.text('Pomodoro Timer'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);
    expect(find.text('Minhas tarefas'), findsOneWidget);
  });
}
