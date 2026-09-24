import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_table_field/super_table_field.dart';

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  const hostKey = ValueKey<String>('combo-test-host');
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SizedBox(key: hostKey),
      ),
    ),
  );
  return tester.element(find.byKey(hostKey));
}

void main() {
  testWidgets('raw combo bridge preserves typed display callbacks', (tester) async {
    final context = await _pumpHost(tester);
    final SuperColumn column = SuperComboColumn<String>(
      key: 'account',
      label: 'Account',
      values: const ['1010 · Cash'],
      display: (value) => value.split(' · ').last,
    );

    final combo = column as SuperComboColumn;
    final suggestion = combo.buildSuggestion(
      context,
      <dynamic>['1010 · Cash'],
      0,
      '1010 · Cash',
    );

    expect(suggestion.value, '1010 · Cash');
    expect(suggestion.titleText, 'Cash');
  });

  testWidgets('raw combo bridge uses custom suggestionBuilder', (tester) async {
    final context = await _pumpHost(tester);
    final SuperColumn column = SuperComboColumn<String>(
      key: 'account',
      label: 'Account',
      values: const ['1010 · Cash'],
      suggestionBuilder: (context, items, index, account) {
        final parts = account.split(' · ');
        return SuperAutoSuggestionsItem<String>(
          value: account,
          titleText: parts.last,
          descriptionText: parts.first,
        );
      },
    );

    final combo = column as SuperComboColumn;
    final suggestion = combo.buildSuggestion(
      context,
      <dynamic>['1010 · Cash'],
      0,
      '1010 · Cash',
    );

    expect(suggestion.value, '1010 · Cash');
    expect(suggestion.titleText, 'Cash');
    expect(suggestion.descriptionText, '1010');
  });

  testWidgets('combo exposes 1.7.0 remote scheduling options', (tester) async {
    final column = SuperComboColumn<String>(
      key: 'account',
      label: 'Account',
      debounce: const Duration(milliseconds: 275),
      minResult: 2,
    );

    expect(column.debounce, const Duration(milliseconds: 275));
    expect(column.minResult, 2);
  });

}
