# super_table_field example

Runnable gallery for `super_table_field 2.8.0`, using `super_core 3.3.0`,
`super_auto_suggestion_box 1.2.0`, and `super_form_field 1.8.2+`.

```bash
flutter pub get
flutter run
```

The launcher demonstrates the responsive `SuperScaffold` page frame,
`SuperSectionCard` surfaces, light/dark themes, and LTR/RTL switching.

## Example 21 — Column width fit

The gallery includes a dedicated `SuperColumnWidthFit` screen covering all
four 2.8.0 sizing strategies:

- `none` — fixed declared/default width.
- `auto` — equal responsive width across auto columns.
- `maxCell` — widest rendered cell content.
- `fit` — base width plus an equal share of otherwise-empty viewport space.

Resize the example window while viewing the screen to see `auto` and `fit`
respond to the live table viewport.

