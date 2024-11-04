import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rl_inventory/main.dart';
import 'package:rl_inventory/pages/login_page.dart'; // Cambia 'your_app_name' con il nome del tuo pacchetto

void main() {
  testWidgets('App displays the LoginPage', (WidgetTester tester) async {
    await tester
        .pumpWidget(const MyApp()); // Sostituisci con il tuo widget principale

    // Verifica che la LoginPage venga caricata correttamente
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login'),
        findsOneWidget); // Verifica che il testo "Login" sia presente
  });

  testWidgets('Navigating from LoginPage to HomePage',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(const MyApp()); // Sostituisci con il tuo widget principale

    // Trova il pulsante di login
    final loginButton = find.byType(ElevatedButton);

    // Simula il tocco sul pulsante di login
    await tester.tap(loginButton);
    await tester.pumpAndSettle(); // Aspetta che le animazioni siano completate

    // Verifica che la HomePage sia visibile
    expect(find.text('Welcome to RL Inventory!'),
        findsOneWidget); // Assicurati che questo testo sia presente nella HomePage
  });
}
