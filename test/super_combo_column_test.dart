import 'package:flutter_test/flutter_test.dart';
import 'package:super_table_field/super_table_field.dart';

void main() {
  test('raw combo bridge preserves typed display callbacks', () {
    final SuperColumn column = SuperComboColumn<String>(
      key: 'account',
      label: 'Account',
      values: const ['1010 · Cash'],
      display: (value) => value.split(' · ').last,
    );

    final combo = column as SuperComboColumn;
    final suggestion = combo.buildSuggestion(
      <dynamic>['1010 · Cash'],
      0,
      '1010 · Cash',
    );

    expect(suggestion.value, '1010 · Cash');
    expect(suggestion.label, 'Cash');
  });

  test('raw combo bridge uses custom suggestionBuilder', () {
    final SuperColumn column = SuperComboColumn<String>(
      key: 'account',
      label: 'Account',
      values: const ['1010 · Cash'],
      suggestionBuilder: (items, index, account) {
        final parts = account.split(' · ');
        return AutoSuggestion<String>(
          value: account,
          label: parts.last,
          description: parts.first,
        );
      },
    );

    final combo = column as SuperComboColumn;
    final suggestion = combo.buildSuggestion(
      <dynamic>['1010 · Cash'],
      0,
      '1010 · Cash',
    );

    expect(suggestion.value, '1010 · Cash');
    expect(suggestion.label, 'Cash');
    expect(suggestion.description, '1010');
  });
}
