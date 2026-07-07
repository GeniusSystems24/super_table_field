# SuperTableField Package Requirements and Issues

In the `flutter/super-table-field` flutter package as Version 2.2.0, implement the following requirements:

## Task 1: Add interaction and selection events

Add support for the following callbacks to the table and its relevant cells, rows, columns, or other selectable elements:

* `onTap`
* `onDoubleTap`
* `onSelect`
* `onLongPress` for mobile and touch-based platforms
* `onRightClick` for desktop and web platforms where secondary-click input is available

Ensure that:

* Each callback provides useful context, including, where applicable:

  * Selected row
  * Selected column
  * Cell value
  * Row index
  * Column index
  * Selection state
  * Interaction target type, such as table, row, column, header, or cell
  * Pointer or platform information when relevant

* `onSelect` is triggered whenever a supported row, column, cell, or table element becomes selected.
* Mobile, web, and desktop interactions behave appropriately for their respective platforms.
* The callbacks do not conflict with one another.
* `onDoubleTap` does not cause unintended duplicate `onTap` actions.
* Long-press and secondary-click behavior does not unintentionally trigger normal tap or selection actions.
* All new callbacks are optional.
* Existing APIs remain backward-compatible.

## Task 2: Add visibility and behavior controls for all table components

Provide configuration options that allow developers to independently show, hide, enable, or disable every optional part of the table interface, including:

* Keyboard shortcuts
* Copy actions
* Paste actions
* Context menus
* Selection controls
* Toolbar actions
* Editing controls
* Navigation controls
* Headers
* Row indicators
* Column indicators
* Resize controls
* Column reorder controls
* Sorting controls
* Filtering controls
* Any other auxiliary table components, menus, shortcuts, or actions

Ensure that:

* Every configurable component has an independent option.
* Visibility and enabled-state options are separate where both states are meaningful.
* The configuration API uses clear and consistent naming.
* Default values preserve the package’s current behavior.
* Hidden components cannot be accessed through another interaction unless explicitly allowed by configuration.
* Disabled components remain visible when configured to be visible but cannot be activated.
* Disabling a visual control also disables its associated keyboard shortcut, context-menu action, gesture, or alternative interaction unless explicitly allowed through a separate configuration option.
* The visibility and behavior settings work consistently across mobile, web, and desktop platforms.
* Runtime configuration changes update the table correctly without requiring it to be recreated unnecessarily.
* Existing APIs remain backward-compatible.

## Task 3: Add column sizing, reordering, and multi-column sorting properties

Extend the public column configuration API with the following properties:

* `minimumWidth` — optional minimum width for the column.
* `maximumWidth` — optional maximum width for the column.
* `allowReorder` — controls whether the column can be moved to another position among the table columns. Its default value must be `false`.
* `allowSort` — controls whether rows can be sorted using the column. Its default value must be `false`.

Ensure that:

### Column width constraints

* `minimumWidth` and `maximumWidth` are optional.
* The column width never becomes smaller than `minimumWidth` when it is provided.
* The column width never becomes larger than `maximumWidth` when it is provided.
* Width constraints apply to:

  * Initial column layout
  * Programmatic width changes
  * Pointer-based resizing
  * Touch-based resizing
  * Responsive layout changes

* Invalid configurations, such as `minimumWidth` being greater than `maximumWidth`, are handled predictably through assertions, validation errors, or another approach consistent with the package’s existing architecture.
* Existing width behavior remains unchanged when neither property is provided.

### Column reordering

* A column can only be reordered when its `allowReorder` value is `true`.
* Reordering must support moving a column before or after other reorderable columns.
* Reordering must preserve the relationship between:

  * Column configuration
  * Header
  * Cell values
  * Selection state
  * Editing state
  * Sorting state
  * Filtering state
  * Navigation state

* Reordering must not corrupt row data or callback index information.
* Callback context must clearly distinguish between the column’s current visual index and any stable column identifier when both are available.
* Non-reorderable columns must not be moved through drag-and-drop, touch gestures, keyboard commands, context-menu actions, or programmatic UI controls unless a separate explicit API permits it.
* Reordering must behave consistently across supported platforms.

### Single-column and multi-column sorting

* A column can only participate in sorting when its `allowSort` value is `true`.
* Support ascending, descending, and unsorted states where appropriate.
* Support sorting rows by multiple columns.
* Multi-column sorting must preserve an explicit priority order.
* The sorting API must expose enough information to determine:

  * Which columns are sorted
  * The direction of each sort
  * The priority of each sorted column

* The user must be able to add, remove, or change a column in the multi-column sort configuration through platform-appropriate interactions.
* The current sort priority should be visually identifiable when sorting indicators are enabled.
* Stable sorting should be used where appropriate so rows with equal values retain predictable ordering.
* Sorting must correctly handle null values and mixed supported value types according to a documented policy.
* Sorting must not unexpectedly discard the current selection, editing state, or navigation state.
* Sorting controls and interactions must respect the visibility and enabled-state configurations introduced in Task 2.
* Existing behavior must remain unchanged for columns where `allowSort` is omitted or set to `false`.

## Task 4: Improve column interaction on touch screens

Add a touch-friendly mechanism for resizing and managing columns on mobile devices, tablets, and other touch-enabled screens.

Support a gesture such as `doubleTapAndMove` for column resizing, or implement another touch interaction that is more reliable and appropriate for Flutter touch interfaces.

Ensure that:

* Users can resize columns without requiring precise mouse-style pointer positioning.
* The selected gesture does not conflict with:

  * `onTap`
  * `onDoubleTap`
  * `onLongPress`
  * Cell editing
  * Row, column, or cell selection
  * Scrolling
  * Drag-based column reordering

* If `doubleTapAndMove` is implemented:

  * A double tap on an eligible resize area enters resize mode.
  * Moving the pointer or finger while resize mode is active updates the column width.
  * Releasing or cancelling the gesture ends resize mode safely.
  * A double tap without movement does not accidentally resize the column.
  * The gesture does not generate unintended duplicate `onTap` or `onDoubleTap` callbacks.
* If another gesture is selected instead, document why it is more suitable and ensure that it provides equivalent usability.
* Touch resize targets are large enough to be usable on common mobile and tablet screen sizes.
* The interaction provides clear visual feedback when resize mode starts, updates, and ends.
* Touch-based resizing respects `minimumWidth` and `maximumWidth`.
* Touch-based resizing respects all resize visibility and enabled-state options.
* Disabled or hidden resize controls cannot be activated through a gesture.
* Column resizing and column reordering use clearly distinguishable gestures or interaction areas.
* Gesture cancellation, pointer interruption, scrolling, orientation changes, and widget disposal do not leave the table in an invalid interaction state.
* Pointer-based desktop resizing continues to work as before.
* Existing APIs remain backward-compatible.
* Any new gesture configuration is optional and has a sensible default that preserves existing behavior.

## Task 5: Create a complete example screen

Create a fully functional example screen that demonstrates all features and use cases of `super-table-field`.

The example screen must include:

* A realistic table with multiple rows and columns.
* Editable and non-editable cells.
* Row, column, and cell selection.
* Single-tap handling using `onTap`.
* Double-tap handling using `onDoubleTap`.
* Selection handling using `onSelect`.
* Long-press handling on mobile using `onLongPress`.
* Right-click handling on desktop using `onRightClick`.
* Copy and paste functionality.
* Keyboard shortcuts.
* Context menus.
* Single-column sorting.
* Multi-column sorting with visible sort priorities.
* Filtering, if supported.
* Cell, row, and column navigation.
* Editing controls.
* Table resizing and column resizing.
* Touch-friendly column resizing on mobile and tablet layouts.
* Columns configured with `minimumWidth` and `maximumWidth`.
* Reorderable and non-reorderable columns.
* Sortable and non-sortable columns.
* Column reordering through supported pointer and touch interactions.
* Examples of showing and hiding every configurable table component.
* Examples of enabling and disabling every configurable action.
* A settings panel or controls that allow users to toggle table features at runtime.
* Runtime controls for changing:

  * Selection behavior
  * Editing behavior
  * Copy and paste behavior
  * Keyboard shortcuts
  * Context menus
  * Sorting
  * Multi-column sorting
  * Filtering
  * Column resizing
  * Touch resizing
  * Column reordering
  * Headers and indicators
  * Navigation controls

* A visible event log showing:

  * Which callback was triggered
  * Interaction target type
  * Row index
  * Column index
  * Stable column identifier, when available
  * Cell value
  * Selection information
  * Sort information
  * Column reorder information
  * Previous and updated column widths where applicable

* Responsive behavior for mobile, tablet, web, and desktop layouts.
* Clear instructions within the example explaining the available mouse, keyboard, and touch interactions.

The example must be complete and runnable without requiring developers to add missing code.

Organize the example clearly so that developers can understand how to use each feature independently and how to combine multiple features.

## Documentation requirements

Update the public API documentation to include:

* Descriptions of all new callbacks.
* Callback parameter documentation.
* Platform-specific callback behavior.
* Callback precedence and conflict-resolution behavior.
* All new visibility and behavior configuration options.
* The difference between hidden and disabled components.
* Documentation for:

  * `minimumWidth`
  * `maximumWidth`
  * `allowReorder`
  * `allowSort`

* Column-width validation and constraint behavior.
* Column-reordering behavior and limitations.
* Single-column sorting.
* Multi-column sorting and sort priority.
* Null-value and mixed-value sorting behavior.
* Touch-friendly resizing gestures.
* Gesture conflict-resolution rules.
* Platform-specific resize and reorder behavior.
* Complete usage examples.
* A reference to the full example screen.
* Migration notes if any existing behavior is affected.
* A clear statement of all default values.
* Any accessibility considerations for keyboard, pointer, and touch interactions.

## Testing requirements

Add or update tests covering:

### Interaction callbacks

* `onTap`
* `onDoubleTap`
* `onSelect`
* Mobile and touch-platform `onLongPress`
* Desktop and web `onRightClick`
* Callback context values
* Event ordering
* Event interaction conflicts
* Prevention of unintended duplicate tap events

### Selection

* Row selection
* Column selection
* Cell selection
* Selection-state callback context
* Selection preservation after sorting, resizing, and reordering

### Configuration

* Visibility configurations
* Enable and disable configurations
* Hidden-versus-disabled behavior
* Prevention of access through alternative interactions
* Runtime configuration changes
* Default-value compatibility

### Column sizing

* `minimumWidth`
* `maximumWidth`
* Width values within the configured range
* Width values below the minimum
* Width values above the maximum
* Invalid minimum and maximum combinations
* Initial layout constraints
* Programmatic resizing
* Pointer-based resizing
* Touch-based resizing
* Responsive layout changes

### Column reordering

* Reordering an allowed column
* Rejecting reorder attempts for a non-reorderable column
* Moving columns in both directions
* Reordering through pointer interactions
* Reordering through touch interactions
* Reordering with fixed or non-reorderable columns
* Preservation of headers and cell data
* Preservation of selection and editing state
* Correct callback indexes after reordering
* Runtime changes to `allowReorder`

### Sorting

* Sorting an allowed column
* Rejecting sort attempts for a non-sortable column
* Ascending sorting
* Descending sorting
* Clearing sorting
* Multi-column sorting
* Sort-priority changes
* Stable sorting
* Null-value sorting
* Supported mixed-value behavior
* Sorting after column reordering
* Sorting while selection or editing is active
* Runtime changes to `allowSort`

### Touch interactions

* Entering touch resize mode
* Updating the width during touch resize
* Completing touch resize
* Cancelling touch resize
* Respecting minimum and maximum widths
* Preventing conflicts with scrolling
* Preventing conflicts with selection
* Preventing conflicts with editing
* Preventing conflicts with long-press actions
* Preventing conflicts with double-tap callbacks
* Preventing conflicts with column reordering
* Pointer interruption and widget disposal
* Orientation and responsive-layout changes during or after interaction

### Platform and compatibility coverage

* Mobile behavior
* Tablet and touch-screen behavior
* Web behavior
* Desktop behavior
* Keyboard behavior
* Pointer behavior
* Backward compatibility
* Existing tests continuing to pass
* The complete example screen
* Runtime feature toggles in the example screen

Use widget tests, unit tests, integration tests, and golden tests where appropriate and consistent with the package’s existing testing approach.

## General requirements

* Follow the package’s existing architecture, naming conventions, and coding style.
* Avoid unnecessary architectural rewrites.
* Do not introduce breaking changes unless absolutely necessary.
* Keep all new APIs optional and backward-compatible.
* Use platform-aware pointer, keyboard, and touch input handling.
* Prefer stable identifiers for rows and columns when interaction state must survive sorting or reordering.
* Preserve current default behavior unless a requirement explicitly defines a new default.
* Add comments only where they improve maintainability.
* Ensure accessibility support for keyboard, pointer, and touch users where applicable.
* Run formatting, static analysis, and all tests.
* Ensure that all existing tests continue to pass.
* Provide a summary of the implemented changes.
* List all modified and added files.
* Mention any platform limitations or design decisions.
* Report the results of formatting, static analysis, and test execution.

### Documentation

* Update the documentation in `README.md` using pub.dev package documentation style and principles.
* Update `CHANGELOG.md`.
* Update ai skill.

---
