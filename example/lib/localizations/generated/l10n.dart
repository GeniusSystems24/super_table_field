import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SuperTableExampleLocalization
/// returned by `SuperTableExampleLocalization.of(context)`.
///
/// Applications need to include `SuperTableExampleLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SuperTableExampleLocalization.localizationsDelegates,
///   supportedLocales: SuperTableExampleLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SuperTableExampleLocalization.supportedLocales
/// property.
abstract class SuperTableExampleLocalization {
  SuperTableExampleLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SuperTableExampleLocalization of(BuildContext context) {
    return Localizations.of<SuperTableExampleLocalization>(
      context,
      SuperTableExampleLocalization,
    )!;
  }

  static const LocalizationsDelegate<SuperTableExampleLocalization> delegate =
      _SuperTableExampleLocalizationDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Table Field'**
  String get appTitle;

  /// No description provided for @galleryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SUPER TABLE FIELD • GALLERY'**
  String get galleryEyebrow;

  /// No description provided for @componentDemos.
  ///
  /// In en, this message translates to:
  /// **'Component Demos'**
  String get componentDemos;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية (RTL)'**
  String get switchToArabic;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'English (LTR)'**
  String get switchToEnglish;

  /// No description provided for @searchExamples.
  ///
  /// In en, this message translates to:
  /// **'Search examples...'**
  String get searchExamples;

  /// No description provided for @noExamplesFound.
  ///
  /// In en, this message translates to:
  /// **'No examples found.'**
  String get noExamplesFound;

  /// No description provided for @superTable.
  ///
  /// In en, this message translates to:
  /// **'Super Table'**
  String get superTable;

  /// No description provided for @superTableDescription.
  ///
  /// In en, this message translates to:
  /// **'Editable/readable grid · typed columns · combo ⇒ SuperAutoSuggestionsBox'**
  String get superTableDescription;

  /// No description provided for @readOnlyReport.
  ///
  /// In en, this message translates to:
  /// **'Read-only report'**
  String get readOnlyReport;

  /// No description provided for @readOnlyReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Readable mode · typed model · conditional row styling'**
  String get readOnlyReportDescription;

  /// No description provided for @editableJournal.
  ///
  /// In en, this message translates to:
  /// **'Editable journal'**
  String get editableJournal;

  /// No description provided for @editableJournalDescription.
  ///
  /// In en, this message translates to:
  /// **'Validator + onChange · Ctrl+Enter insert · live balance'**
  String get editableJournalDescription;

  /// No description provided for @asyncCombo.
  ///
  /// In en, this message translates to:
  /// **'Async combo'**
  String get asyncCombo;

  /// No description provided for @asyncComboDescription.
  ///
  /// In en, this message translates to:
  /// **'SuperComboColumn sourceController · fingerPrint rebuild'**
  String get asyncComboDescription;

  /// No description provided for @controllerDriven.
  ///
  /// In en, this message translates to:
  /// **'Controller-driven'**
  String get controllerDriven;

  /// No description provided for @controllerDrivenDescription.
  ///
  /// In en, this message translates to:
  /// **'setMode · onLoadMore · programmatic filters + selection'**
  String get controllerDrivenDescription;

  /// No description provided for @stylingAndFilters.
  ///
  /// In en, this message translates to:
  /// **'Styling & filters'**
  String get stylingAndFilters;

  /// No description provided for @stylingAndFiltersDescription.
  ///
  /// In en, this message translates to:
  /// **'Cell/row styles · FilterItem dropdowns · onKey'**
  String get stylingAndFiltersDescription;

  /// No description provided for @playground.
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get playground;

  /// No description provided for @playgroundDescription.
  ///
  /// In en, this message translates to:
  /// **'Full toolbar · mode/search/select/paging/totals/filters'**
  String get playgroundDescription;

  /// No description provided for @changeTracking.
  ///
  /// In en, this message translates to:
  /// **'Change tracking'**
  String get changeTracking;

  /// No description provided for @changeTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'trackChanges · dirty cells · changes delta · save/revert'**
  String get changeTrackingDescription;

  /// No description provided for @selectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Selection statistics'**
  String get selectionStatistics;

  /// No description provided for @selectionStatisticsDescription.
  ///
  /// In en, this message translates to:
  /// **'multiCells · selectionStats · custom Sum/Avg/Min/Max summary'**
  String get selectionStatisticsDescription;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'toCsv / toTsv / toJsonRows · respects filter + sort'**
  String get exportDescription;

  /// No description provided for @aggregations.
  ///
  /// In en, this message translates to:
  /// **'Aggregations'**
  String get aggregations;

  /// No description provided for @aggregationsDescription.
  ///
  /// In en, this message translates to:
  /// **'min / max / custom aggregator · weighted average · aggLabel'**
  String get aggregationsDescription;

  /// No description provided for @cellLocking.
  ///
  /// In en, this message translates to:
  /// **'Cell locking'**
  String get cellLocking;

  /// No description provided for @cellLockingDescription.
  ///
  /// In en, this message translates to:
  /// **'cellEditable · lock posted rows · read-only cells'**
  String get cellLockingDescription;

  /// No description provided for @rowReordering.
  ///
  /// In en, this message translates to:
  /// **'Row reordering'**
  String get rowReordering;

  /// No description provided for @rowReorderingDescription.
  ///
  /// In en, this message translates to:
  /// **'moveRowUp / moveRowDown / moveRow · undo'**
  String get rowReorderingDescription;

  /// No description provided for @groupAggregates.
  ///
  /// In en, this message translates to:
  /// **'Group aggregates · Hidden columns'**
  String get groupAggregates;

  /// No description provided for @groupAggregatesDescription.
  ///
  /// In en, this message translates to:
  /// **'groupAggregates / aggregateBy / grandTotals · filter+group-only columns'**
  String get groupAggregatesDescription;

  /// No description provided for @expandableRows.
  ///
  /// In en, this message translates to:
  /// **'Expandable rows'**
  String get expandableRows;

  /// No description provided for @expandableRowsDescription.
  ///
  /// In en, this message translates to:
  /// **'SuperRowExpansion · multi & single mode · per-row heights · animated panels'**
  String get expandableRowsDescription;

  /// No description provided for @validationAndSavedViews.
  ///
  /// In en, this message translates to:
  /// **'Validation · saved views'**
  String get validationAndSavedViews;

  /// No description provided for @validationAndSavedViewsDescription.
  ///
  /// In en, this message translates to:
  /// **'validateAll + unique · isValid gate · viewStateJson / applyViewJson'**
  String get validationAndSavedViewsDescription;

  /// No description provided for @fillAndGroupFooters.
  ///
  /// In en, this message translates to:
  /// **'Fill · group footers · revert'**
  String get fillAndGroupFooters;

  /// No description provided for @fillAndGroupFootersDescription.
  ///
  /// In en, this message translates to:
  /// **'⌘D/⌘R fill · Σ subtotal rows · revert cell/row'**
  String get fillAndGroupFootersDescription;

  /// No description provided for @interactionEvents.
  ///
  /// In en, this message translates to:
  /// **'Interaction events'**
  String get interactionEvents;

  /// No description provided for @interactionEventsDescription.
  ///
  /// In en, this message translates to:
  /// **'SuperInteractions · onRowActivate · cell/row taps · selection + sort'**
  String get interactionEventsDescription;

  /// No description provided for @columnConfig.
  ///
  /// In en, this message translates to:
  /// **'Column config'**
  String get columnConfig;

  /// No description provided for @columnConfigDescription.
  ///
  /// In en, this message translates to:
  /// **'showSuperColumnManager · reorder / pin / show-hide · pins persist in views'**
  String get columnConfigDescription;

  /// No description provided for @showcase.
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get showcase;

  /// No description provided for @tableStyles.
  ///
  /// In en, this message translates to:
  /// **'Table styles'**
  String get tableStyles;

  /// No description provided for @columnWidthFit.
  ///
  /// In en, this message translates to:
  /// **'Column width fit'**
  String get columnWidthFit;

  /// No description provided for @bigDataLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Big data · Load more'**
  String get bigDataLoadMore;

  /// No description provided for @enumerationSelect.
  ///
  /// In en, this message translates to:
  /// **'Enumeration select'**
  String get enumerationSelect;

  /// No description provided for @oneReadOnlyReport.
  ///
  /// In en, this message translates to:
  /// **'1 · Read-only report'**
  String get oneReadOnlyReport;

  /// No description provided for @twoEditableJournal.
  ///
  /// In en, this message translates to:
  /// **'2 · Editable journal'**
  String get twoEditableJournal;

  /// No description provided for @validatorPlusOnChangeCtrlPlusEnterInsertLiveBalance.
  ///
  /// In en, this message translates to:
  /// **'validator + onChange · Ctrl+Enter insert · live balance'**
  String get validatorPlusOnChangeCtrlPlusEnterInsertLiveBalance;

  /// No description provided for @threeAsyncCombo.
  ///
  /// In en, this message translates to:
  /// **'3 · Async combo'**
  String get threeAsyncCombo;

  /// No description provided for @fourControllerDriven.
  ///
  /// In en, this message translates to:
  /// **'4 · Controller-driven'**
  String get fourControllerDriven;

  /// No description provided for @fiveStylingAndFilters.
  ///
  /// In en, this message translates to:
  /// **'5 · Styling & filters'**
  String get fiveStylingAndFilters;

  /// No description provided for @sixPlayground.
  ///
  /// In en, this message translates to:
  /// **'6 · Playground'**
  String get sixPlayground;

  /// No description provided for @sevenChangeTracking.
  ///
  /// In en, this message translates to:
  /// **'7 · Change tracking'**
  String get sevenChangeTracking;

  /// No description provided for @eightSelectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'8 · Selection statistics'**
  String get eightSelectionStatistics;

  /// No description provided for @nineExport.
  ///
  /// In en, this message translates to:
  /// **'9 · Export'**
  String get nineExport;

  /// No description provided for @tenAggregations.
  ///
  /// In en, this message translates to:
  /// **'10 · Aggregations'**
  String get tenAggregations;

  /// No description provided for @elevenCellLocking.
  ///
  /// In en, this message translates to:
  /// **'11 · Cell locking'**
  String get elevenCellLocking;

  /// No description provided for @twelveRowReordering.
  ///
  /// In en, this message translates to:
  /// **'12 · Row reordering'**
  String get twelveRowReordering;

  /// No description provided for @thirteenGroupAggregatesHiddenColumns.
  ///
  /// In en, this message translates to:
  /// **'13 · Group aggregates · Hidden columns'**
  String get thirteenGroupAggregatesHiddenColumns;

  /// No description provided for @fourteenExpandableRows.
  ///
  /// In en, this message translates to:
  /// **'14 · Expandable rows'**
  String get fourteenExpandableRows;

  /// No description provided for @fifteenValidationSavedViews.
  ///
  /// In en, this message translates to:
  /// **'15 · Validation · saved views'**
  String get fifteenValidationSavedViews;

  /// No description provided for @sixteenFillGroupFootersRevert.
  ///
  /// In en, this message translates to:
  /// **'16 · Fill · group footers · revert'**
  String get sixteenFillGroupFootersRevert;

  /// No description provided for @seventeenInteractionEvents.
  ///
  /// In en, this message translates to:
  /// **'17 · Interaction events'**
  String get seventeenInteractionEvents;

  /// No description provided for @eighteenColumnConfig.
  ///
  /// In en, this message translates to:
  /// **'18 · Column config'**
  String get eighteenColumnConfig;

  /// No description provided for @nineteenShowcase.
  ///
  /// In en, this message translates to:
  /// **'19 · Showcase'**
  String get nineteenShowcase;

  /// No description provided for @interactionsPlusColumnManagerPlusGroupingPlusTotalsPlusTrackingPc4d7ca8.
  ///
  /// In en, this message translates to:
  /// **'Interactions + column manager + grouping + totals + tracking + export'**
  String
  get interactionsPlusColumnManagerPlusGroupingPlusTotalsPlusTrackingPc4d7ca8;

  /// No description provided for @twentyTableStyles.
  ///
  /// In en, this message translates to:
  /// **'20 - Table styles'**
  String get twentyTableStyles;

  /// No description provided for @optionalSuperTableStylePresetsBandingGroupFootersTotals.
  ///
  /// In en, this message translates to:
  /// **'Optional SuperTableStyle presets - banding - group footers - totals'**
  String get optionalSuperTableStylePresetsBandingGroupFootersTotals;

  /// No description provided for @twentyOneColumnWidthFit.
  ///
  /// In en, this message translates to:
  /// **'21 · Column width fit'**
  String get twentyOneColumnWidthFit;

  /// No description provided for @noneAutoMaxCellFitResponsiveViewportSizing.
  ///
  /// In en, this message translates to:
  /// **'none · auto · maxCell · fit · responsive viewport sizing'**
  String get noneAutoMaxCellFitResponsiveViewportSizing;

  /// No description provided for @twentyTwoBigDataLoadMore.
  ///
  /// In en, this message translates to:
  /// **'22 · Big data load-more'**
  String get twentyTwoBigDataLoadMore;

  /// No description provided for @message1k5k10kRowsPerLoad100kMaxPerformanceCounters.
  ///
  /// In en, this message translates to:
  /// **'1k / 5k / 10k rows per load · 100k max · performance counters'**
  String get message1k5k10kRowsPerLoad100kMaxPerformanceCounters;

  /// No description provided for @twentyThreeEnumerationSelect.
  ///
  /// In en, this message translates to:
  /// **'23 · Enumeration select'**
  String get twentyThreeEnumerationSelect;

  /// No description provided for @superEnumerationColumnSuperSelectFormFieldRowAwareSources.
  ///
  /// In en, this message translates to:
  /// **'SuperEnumerationColumn · SuperSelectFormField · row-aware sources'**
  String get superEnumerationColumnSuperSelectFormFieldRowAwareSources;

  /// No description provided for @componentDemoseb5e41.
  ///
  /// In en, this message translates to:
  /// **'Component Demos مكتبة المكونات'**
  String get componentDemoseb5e41;

  /// No description provided for @sKU.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sKU;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @lineTotal.
  ///
  /// In en, this message translates to:
  /// **'Line Total'**
  String get lineTotal;

  /// No description provided for @fill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get fill;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @sUPERTABLEUNIFIEDDATAGRID.
  ///
  /// In en, this message translates to:
  /// **'SUPER TABLE • UNIFIED DATA GRID'**
  String get sUPERTABLEUNIFIEDDATAGRID;

  /// No description provided for @issueInventory.
  ///
  /// In en, this message translates to:
  /// **'Issue Inventory'**
  String get issueInventory;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @readable.
  ///
  /// In en, this message translates to:
  /// **'Readable'**
  String get readable;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @cell.
  ///
  /// In en, this message translates to:
  /// **'Cell'**
  String get cell;

  /// No description provided for @groupByCategory.
  ///
  /// In en, this message translates to:
  /// **'Group by category'**
  String get groupByCategory;

  /// No description provided for @searchRows.
  ///
  /// In en, this message translates to:
  /// **'Search rows…'**
  String get searchRows;

  /// No description provided for @unitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit Cost'**
  String get unitCost;

  /// No description provided for @mINCOST.
  ///
  /// In en, this message translates to:
  /// **'MIN COST'**
  String get mINCOST;

  /// No description provided for @costMax.
  ///
  /// In en, this message translates to:
  /// **'Cost (max)'**
  String get costMax;

  /// No description provided for @mAXCOST.
  ///
  /// In en, this message translates to:
  /// **'MAX COST'**
  String get mAXCOST;

  /// No description provided for @wAC.
  ///
  /// In en, this message translates to:
  /// **'WAC'**
  String get wAC;

  /// No description provided for @wTDAVG.
  ///
  /// In en, this message translates to:
  /// **'WTD AVG'**
  String get wTDAVG;

  /// No description provided for @theTotalsRowShowsQtySumTheCostMinMaxAndAQuantityWeightedAverageC039559c.
  ///
  /// In en, this message translates to:
  /// **'The totals row shows Qty (sum), the cost min/max, and a quantity-weighted average (custom aggregator). Right-click a row → Group by → Category to see them roll up per group.'**
  String
  get theTotalsRowShowsQtySumTheCostMinMaxAndAQuantityWeightedAverageC039559c;

  /// No description provided for @toggleGroupByCategory.
  ///
  /// In en, this message translates to:
  /// **'Toggle group by Category'**
  String get toggleGroupByCategory;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @postedRowsAreLockedDoubleClickTheirCellsNothingHappensChangeARow5099657.
  ///
  /// In en, this message translates to:
  /// **'Posted rows are locked. Double-click their cells — nothing happens. Change a row’s Status to Draft to unlock its other cells.'**
  String
  get postedRowsAreLockedDoubleClickTheirCellsNothingHappensChangeARow5099657;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @clickARowNumberToSelectItThenUseTheButtonsBelowOrRightClickToMov5036271.
  ///
  /// In en, this message translates to:
  /// **'Click a row number to select it, then use the buttons below — or right-click → Move row up / down. ⌘Z undoes a move.'**
  String
  get clickARowNumberToSelectItThenUseTheButtonsBelowOrRightClickToMov5036271;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stockValue;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @groupAggregatesHiddenColumns.
  ///
  /// In en, this message translates to:
  /// **'Group Aggregates - Hidden Columns'**
  String get groupAggregatesHiddenColumns;

  /// No description provided for @regionAndSupplierAreHiddenColumnsTheGridNeverRendersThemButTheCh9d8dca7.
  ///
  /// In en, this message translates to:
  /// **'Region and Supplier are hidden columns. The grid never renders them, but the chips filter by Region and the rollup groups by Region then Category through the controller API.'**
  String
  get regionAndSupplierAreHiddenColumnsTheGridNeverRendersThemButTheCh9d8dca7;

  /// No description provided for @visibleRows.
  ///
  /// In en, this message translates to:
  /// **'Visible rows'**
  String get visibleRows;

  /// No description provided for @visibleRegions.
  ///
  /// In en, this message translates to:
  /// **'Visible regions'**
  String get visibleRegions;

  /// No description provided for @totalQty.
  ///
  /// In en, this message translates to:
  /// **'Total qty'**
  String get totalQty;

  /// No description provided for @qty77e74d.
  ///
  /// In en, this message translates to:
  /// **'qty'**
  String get qty77e74d;

  /// No description provided for @stockValuefdb1ac.
  ///
  /// In en, this message translates to:
  /// **'Stock value'**
  String get stockValuefdb1ac;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get value;

  /// No description provided for @allRegions.
  ///
  /// In en, this message translates to:
  /// **'All regions'**
  String get allRegions;

  /// No description provided for @pROGRAMMATICROLLUP.
  ///
  /// In en, this message translates to:
  /// **'PROGRAMMATIC ROLLUP'**
  String get pROGRAMMATICROLLUP;

  /// No description provided for @groupAggregatesRegionCategory.
  ///
  /// In en, this message translates to:
  /// **'groupAggregates(region / category)'**
  String get groupAggregatesRegionCategory;

  /// No description provided for @noRowsMatchTheCurrentFilter.
  ///
  /// In en, this message translates to:
  /// **'No rows match the current filter.'**
  String get noRowsMatchTheCurrentFilter;

  /// No description provided for @grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand total'**
  String get grandTotal;

  /// No description provided for @openingBalanceCashAndEquity.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance — Cash & Equity'**
  String get openingBalanceCashAndEquity;

  /// No description provided for @purchaseOfficeEquipment.
  ///
  /// In en, this message translates to:
  /// **'Purchase — Office Equipment'**
  String get purchaseOfficeEquipment;

  /// No description provided for @salesRevenueQ1InvoiceBatch.
  ///
  /// In en, this message translates to:
  /// **'Sales Revenue — Q1 Invoice Batch'**
  String get salesRevenueQ1InvoiceBatch;

  /// No description provided for @payrollJanuary2024.
  ///
  /// In en, this message translates to:
  /// **'Payroll — January 2024'**
  String get payrollJanuary2024;

  /// No description provided for @depreciationOfficeEquipment.
  ///
  /// In en, this message translates to:
  /// **'Depreciation — Office Equipment'**
  String get depreciationOfficeEquipment;

  /// No description provided for @cashReceiptAccountsReceivable.
  ///
  /// In en, this message translates to:
  /// **'Cash Receipt — Accounts Receivable'**
  String get cashReceiptAccountsReceivable;

  /// No description provided for @inventoryPurchaseRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Inventory Purchase — Raw Materials'**
  String get inventoryPurchaseRawMaterials;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @totalDebit.
  ///
  /// In en, this message translates to:
  /// **'Total Debit'**
  String get totalDebit;

  /// No description provided for @totalCredit.
  ///
  /// In en, this message translates to:
  /// **'Total Credit'**
  String get totalCredit;

  /// No description provided for @expandableRows020fb0.
  ///
  /// In en, this message translates to:
  /// **'Expandable Rows'**
  String get expandableRows020fb0;

  /// No description provided for @eXPANSIONMODE.
  ///
  /// In en, this message translates to:
  /// **'EXPANSION MODE'**
  String get eXPANSIONMODE;

  /// No description provided for @multi.
  ///
  /// In en, this message translates to:
  /// **'Multi'**
  String get multi;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @singleModeOnlyOneRowCanBeOpenAtATimeAccordion.
  ///
  /// In en, this message translates to:
  /// **'Single mode — only one row can be open at a time (accordion).'**
  String get singleModeOnlyOneRowCanBeOpenAtATimeAccordion;

  /// No description provided for @multiModeMultipleRowsCanBeExpandedSimultaneously.
  ///
  /// In en, this message translates to:
  /// **'Multi mode — multiple rows can be expanded simultaneously.'**
  String get multiModeMultipleRowsCanBeExpandedSimultaneously;

  /// No description provided for @tapTheChevronInTheRowNumberColumnToExpand.
  ///
  /// In en, this message translates to:
  /// **'Tap the chevron (▾) in the row number column to expand.'**
  String get tapTheChevronInTheRowNumberColumnToExpand;

  /// No description provided for @aCCOUNT.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get aCCOUNT;

  /// No description provided for @nARRATION.
  ///
  /// In en, this message translates to:
  /// **'NARRATION'**
  String get nARRATION;

  /// No description provided for @dEBIT.
  ///
  /// In en, this message translates to:
  /// **'DEBIT'**
  String get dEBIT;

  /// No description provided for @cREDIT.
  ///
  /// In en, this message translates to:
  /// **'CREDIT'**
  String get cREDIT;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'On hand'**
  String get onHand;

  /// No description provided for @unitCostb16e07.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCostb16e07;

  /// No description provided for @cannotPostFixTheValidationIssuesFirst.
  ///
  /// In en, this message translates to:
  /// **'Cannot post — fix the validation issues first.'**
  String get cannotPostFixTheValidationIssuesFirst;

  /// No description provided for @postedBaselineCapturedCellsAreCleanAgain.
  ///
  /// In en, this message translates to:
  /// **'Posted ✓  (baseline captured — cells are clean again)'**
  String get postedBaselineCapturedCellsAreCleanAgain;

  /// No description provided for @viewSavedCharsOfJSON.
  ///
  /// In en, this message translates to:
  /// **'View saved ({savedViewCount} chars of JSON).'**
  String viewSavedCharsOfJSON(Object savedViewCount);

  /// No description provided for @viewRestoredOrderWidthsSortAndFiltersAreBack.
  ///
  /// In en, this message translates to:
  /// **'View restored — order, widths, sort and filters are back.'**
  String get viewRestoredOrderWidthsSortAndFiltersAreBack;

  /// No description provided for @validationSummarySavedViews.
  ///
  /// In en, this message translates to:
  /// **'Validation summary · saved views'**
  String get validationSummarySavedViews;

  /// No description provided for @sKUIsRequiredANDUniqueTryDuplicatingOneOrLeaveItBlankThenHitVali3f35562.
  ///
  /// In en, this message translates to:
  /// **'SKU is required AND unique — try duplicating one, or leave it blank, then hit Validate. Post is gated on controller.isValid. Save view snapshots the grid layout (drag a column, resize, sort, filter…) and Restore brings it back.'**
  String
  get sKUIsRequiredANDUniqueTryDuplicatingOneOrLeaveItBlankThenHitVali3f35562;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @saveView.
  ///
  /// In en, this message translates to:
  /// **'Save view'**
  String get saveView;

  /// No description provided for @restoreView.
  ///
  /// In en, this message translates to:
  /// **'Restore view'**
  String get restoreView;

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get resetView;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @bin.
  ///
  /// In en, this message translates to:
  /// **'Bin'**
  String get bin;

  /// No description provided for @fillDownRightGroupFooters.
  ///
  /// In en, this message translates to:
  /// **'Fill down/right · group footers'**
  String get fillDownRightGroupFooters;

  /// No description provided for @editableSelectARangeSpanningRowsPressCommandCtrlPlusDToFillDownC05fc021.
  ///
  /// In en, this message translates to:
  /// **'Editable: select a range spanning rows, press ⌘/Ctrl+D to fill down (⌘/Ctrl+R fills right). Edit a cell, then right-click the row → Revert cell / Revert row. Switch to readable for group footers.'**
  String
  get editableSelectARangeSpanningRowsPressCommandCtrlPlusDToFillDownC05fc021;

  /// No description provided for @readableGroupedByWarehouseWithGroupFootersOnEachGroupClosesWithAb03b87f.
  ///
  /// In en, this message translates to:
  /// **'Readable: grouped by Warehouse with groupFooters on — each group closes with a Σ subtotal row. Collapse groups from their headers.'**
  String
  get readableGroupedByWarehouseWithGroupFootersOnEachGroupClosesWithAb03b87f;

  /// No description provided for @readablePlusGrouped.
  ///
  /// In en, this message translates to:
  /// **'Readable + grouped'**
  String get readablePlusGrouped;

  /// No description provided for @backToEditable.
  ///
  /// In en, this message translates to:
  /// **'Back to editable'**
  String get backToEditable;

  /// No description provided for @fillDown.
  ///
  /// In en, this message translates to:
  /// **'Fill down'**
  String get fillDown;

  /// No description provided for @fillRight.
  ///
  /// In en, this message translates to:
  /// **'Fill right'**
  String get fillRight;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get orderNumber;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @doubleClickARowOrSelectPlusEnterToOpenItClickCellsRightClickDrag4ff3c2c.
  ///
  /// In en, this message translates to:
  /// **'Double-click a row (or select + Enter) to open it. Click cells, right-click, drag a range, or sort a column — every gesture flows through SuperInteractions into the panel on the right. The grid still behaves exactly as normal.'**
  String
  get doubleClickARowOrSelectPlusEnterToOpenItClickCellsRightClickDrag4ff3c2c;

  /// No description provided for @sortByTotalProgrammatic.
  ///
  /// In en, this message translates to:
  /// **'Sort by total ↓ (programmatic)'**
  String get sortByTotalProgrammatic;

  /// No description provided for @clearSort.
  ///
  /// In en, this message translates to:
  /// **'Clear sort'**
  String get clearSort;

  /// No description provided for @eVENTLOG.
  ///
  /// In en, this message translates to:
  /// **'EVENT LOG'**
  String get eVENTLOG;

  /// No description provided for @interactWithTheGrid.
  ///
  /// In en, this message translates to:
  /// **'Interact with the grid…'**
  String get interactWithTheGrid;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order {no}'**
  String order(Object no);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @costCentre.
  ///
  /// In en, this message translates to:
  /// **'Cost centre'**
  String get costCentre;

  /// No description provided for @debit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get debit;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @viewSavedOrderWidthsVisibilityANDPinsChars.
  ///
  /// In en, this message translates to:
  /// **'View saved — order, widths, visibility AND pins ({savedViewCount} chars).'**
  String viewSavedOrderWidthsVisibilityANDPinsChars(Object savedViewCount);

  /// No description provided for @viewRestoredColumnsAreBackWhereYouLeftThem.
  ///
  /// In en, this message translates to:
  /// **'View restored — columns are back where you left them.'**
  String get viewRestoredColumnsAreBackWhereYouLeftThem;

  /// No description provided for @reshapeTheGridOpenColumnsDragRowsToReorderClickTheEyeToHideAndPi4f6b1e8.
  ///
  /// In en, this message translates to:
  /// **'Reshape the grid: open Columns…, drag rows to reorder, click the eye to hide, and pin to an edge. Or right-click a header. Account is pinned left to start. Save then restore to confirm the whole layout — pins included — survives as JSON.'**
  String
  get reshapeTheGridOpenColumnsDragRowsToReorderClickTheEyeToHideAndPi4f6b1e8;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns…'**
  String get columns;

  /// No description provided for @pinBalanceRight.
  ///
  /// In en, this message translates to:
  /// **'Pin balance right'**
  String get pinBalanceRight;

  /// No description provided for @toggleCostCentre.
  ///
  /// In en, this message translates to:
  /// **'Toggle cost centre'**
  String get toggleCostCentre;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @lotSerial.
  ///
  /// In en, this message translates to:
  /// **'Lot / Serial'**
  String get lotSerial;

  /// No description provided for @lotIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Lot is required'**
  String get lotIsRequired;

  /// No description provided for @inventoryStateOf.
  ///
  /// In en, this message translates to:
  /// **'Inventory state {index} of {itemsCount}'**
  String inventoryStateOf(Object index, Object itemsCount);

  /// No description provided for @qtyCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Qty cannot be negative'**
  String get qtyCannotBeNegative;

  /// No description provided for @discPercent.
  ///
  /// In en, this message translates to:
  /// **'Disc %'**
  String get discPercent;

  /// No description provided for @managerApprovalRequired.
  ///
  /// In en, this message translates to:
  /// **'Manager approval required'**
  String get managerApprovalRequired;

  /// No description provided for @pickUnit.
  ///
  /// In en, this message translates to:
  /// **'Pick unit'**
  String get pickUnit;

  /// No description provided for @aVG.
  ///
  /// In en, this message translates to:
  /// **'AVG'**
  String get aVG;

  /// No description provided for @netValue.
  ///
  /// In en, this message translates to:
  /// **'Net Value'**
  String get netValue;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevel;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @amber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get amber;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @cyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get cyan;

  /// No description provided for @useYYYYMMDD.
  ///
  /// In en, this message translates to:
  /// **'Use YYYY-MM-DD'**
  String get useYYYYMMDD;

  /// No description provided for @vendorURL.
  ///
  /// In en, this message translates to:
  /// **'Vendor URL'**
  String get vendorURL;

  /// No description provided for @ref.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get ref;

  /// No description provided for @groupedByWarehouseAndCategory.
  ///
  /// In en, this message translates to:
  /// **'Grouped by warehouse and category.'**
  String get groupedByWarehouseAndCategory;

  /// No description provided for @groupingCleared.
  ///
  /// In en, this message translates to:
  /// **'Grouping cleared.'**
  String get groupingCleared;

  /// No description provided for @loadingMode.
  ///
  /// In en, this message translates to:
  /// **'Loading mode: {pagination}.'**
  String loadingMode(Object pagination);

  /// No description provided for @loadedMoreRows.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} more rows.'**
  String loadedMoreRows(Object count);

  /// No description provided for @copiedRowsAsCSV.
  ///
  /// In en, this message translates to:
  /// **'Copied {sortedRowsCount} rows as CSV.'**
  String copiedRowsAsCSV(Object sortedRowsCount);

  /// No description provided for @allRowsValid.
  ///
  /// In en, this message translates to:
  /// **'All rows valid.'**
  String get allRowsValid;

  /// No description provided for @validationIssueS.
  ///
  /// In en, this message translates to:
  /// **'{errorCount} validation issue(s).'**
  String validationIssueS(Object errorCount);

  /// No description provided for @viewStateSavedInMemory.
  ///
  /// In en, this message translates to:
  /// **'View state saved in memory.'**
  String get viewStateSavedInMemory;

  /// No description provided for @noSavedViewYet.
  ///
  /// In en, this message translates to:
  /// **'No saved view yet.'**
  String get noSavedViewYet;

  /// No description provided for @savedViewRestored.
  ///
  /// In en, this message translates to:
  /// **'Saved view restored.'**
  String get savedViewRestored;

  /// No description provided for @viewStateReset.
  ///
  /// In en, this message translates to:
  /// **'View state reset.'**
  String get viewStateReset;

  /// No description provided for @newEditableRowAdded.
  ///
  /// In en, this message translates to:
  /// **'New editable row added.'**
  String get newEditableRowAdded;

  /// No description provided for @focusedRowMovedUp.
  ///
  /// In en, this message translates to:
  /// **'Focused row moved up.'**
  String get focusedRowMovedUp;

  /// No description provided for @focusedRowMovedDown.
  ///
  /// In en, this message translates to:
  /// **'Focused row moved down.'**
  String get focusedRowMovedDown;

  /// No description provided for @fillDownAppliedToTheCurrentSelection.
  ///
  /// In en, this message translates to:
  /// **'Fill down applied to the current selection.'**
  String get fillDownAppliedToTheCurrentSelection;

  /// No description provided for @fillRightAppliedToTheCurrentSelection.
  ///
  /// In en, this message translates to:
  /// **'Fill right applied to the current selection.'**
  String get fillRightAppliedToTheCurrentSelection;

  /// No description provided for @changesRejected.
  ///
  /// In en, this message translates to:
  /// **'Changes rejected.'**
  String get changesRejected;

  /// No description provided for @changesAccepted.
  ///
  /// In en, this message translates to:
  /// **'Changes accepted.'**
  String get changesAccepted;

  /// No description provided for @showcaseAllColumnTypes.
  ///
  /// In en, this message translates to:
  /// **'Showcase - all column types'**
  String get showcaseAllColumnTypes;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open {sku} - {name}'**
  String open(Object sku, Object name);

  /// No description provided for @doubleTap.
  ///
  /// In en, this message translates to:
  /// **'Double tap {label}: {details}'**
  String doubleTap(Object label, Object details);

  /// No description provided for @contextMenuOn.
  ///
  /// In en, this message translates to:
  /// **'Context menu on {label}.'**
  String contextMenuOn(Object label);

  /// No description provided for @cellsSelectedSumAvg.
  ///
  /// In en, this message translates to:
  /// **'{cellsCount} cells selected - sum {sum} - avg {average}'**
  String cellsSelectedSumAvg(Object cellsCount, Object sum, Object average);

  /// No description provided for @cursorRowColumn.
  ///
  /// In en, this message translates to:
  /// **'Cursor row {r}, column {c}.'**
  String cursorRowColumn(Object r, Object c);

  /// No description provided for @sorted.
  ///
  /// In en, this message translates to:
  /// **'Sorted {columnLabel} {desc}.'**
  String sorted(Object columnLabel, Object desc);

  /// No description provided for @sortCleared.
  ///
  /// In en, this message translates to:
  /// **'Sort cleared.'**
  String get sortCleared;

  /// No description provided for @editable.
  ///
  /// In en, this message translates to:
  /// **'Editable'**
  String get editable;

  /// No description provided for @columnscf723c.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columnscf723c;

  /// No description provided for @ungroup.
  ///
  /// In en, this message translates to:
  /// **'Ungroup'**
  String get ungroup;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @totals.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get totals;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @jSONBtn.
  ///
  /// In en, this message translates to:
  /// **'JSON btn'**
  String get jSONBtn;

  /// No description provided for @undoBtn.
  ///
  /// In en, this message translates to:
  /// **'Undo btn'**
  String get undoBtn;

  /// No description provided for @redoBtn.
  ///
  /// In en, this message translates to:
  /// **'Redo btn'**
  String get redoBtn;

  /// No description provided for @addRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get addRow;

  /// No description provided for @copyCSV.
  ///
  /// In en, this message translates to:
  /// **'Copy CSV'**
  String get copyCSV;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @lOAD.
  ///
  /// In en, this message translates to:
  /// **'LOAD '**
  String get lOAD;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @loadPlus.
  ///
  /// In en, this message translates to:
  /// **'Load+'**
  String get loadPlus;

  /// No description provided for @infinite.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get infinite;

  /// No description provided for @salesRep.
  ///
  /// In en, this message translates to:
  /// **'Sales Rep'**
  String get salesRep;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @segment.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get segment;

  /// No description provided for @opening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get opening;

  /// No description provided for @closing.
  ///
  /// In en, this message translates to:
  /// **'Closing'**
  String get closing;

  /// No description provided for @code110Px.
  ///
  /// In en, this message translates to:
  /// **'Code · 110 px'**
  String get code110Px;

  /// No description provided for @name220Px.
  ///
  /// In en, this message translates to:
  /// **'Name · 220 px'**
  String get name220Px;

  /// No description provided for @status140Px.
  ///
  /// In en, this message translates to:
  /// **'Status · 140 px'**
  String get status140Px;

  /// No description provided for @fixed120Px.
  ///
  /// In en, this message translates to:
  /// **'Fixed · 120 px'**
  String get fixed120Px;

  /// No description provided for @autoADeclared80.
  ///
  /// In en, this message translates to:
  /// **'Auto A · declared 80'**
  String get autoADeclared80;

  /// No description provided for @autoBDeclared220.
  ///
  /// In en, this message translates to:
  /// **'Auto B · declared 220'**
  String get autoBDeclared220;

  /// No description provided for @autoCDeclared100.
  ///
  /// In en, this message translates to:
  /// **'Auto C · declared 100'**
  String get autoCDeclared100;

  /// No description provided for @codeMaxCell.
  ///
  /// In en, this message translates to:
  /// **'Code · maxCell'**
  String get codeMaxCell;

  /// No description provided for @descriptionMaxCell.
  ///
  /// In en, this message translates to:
  /// **'Description · maxCell'**
  String get descriptionMaxCell;

  /// No description provided for @noteMaxCell.
  ///
  /// In en, this message translates to:
  /// **'Note · maxCell'**
  String get noteMaxCell;

  /// No description provided for @fitABase150.
  ///
  /// In en, this message translates to:
  /// **'Fit A · base 150'**
  String get fitABase150;

  /// No description provided for @fitBBase150.
  ///
  /// In en, this message translates to:
  /// **'Fit B · base 150'**
  String get fitBBase150;

  /// No description provided for @sUPERCOLUMNWIDTHFITTwoEightZero.
  ///
  /// In en, this message translates to:
  /// **'SUPER COLUMN WIDTH FIT · 2.8.0'**
  String get sUPERCOLUMNWIDTHFITTwoEightZero;

  /// No description provided for @fourWaysToSizeTableColumns.
  ///
  /// In en, this message translates to:
  /// **'Four ways to size table columns'**
  String get fourWaysToSizeTableColumns;

  /// No description provided for @resizeThisWindowWhileViewingTheAutoAndFitSectionsTheTablesResolvf66f1f9.
  ///
  /// In en, this message translates to:
  /// **'Resize this window while viewing the Auto and Fit sections. The tables resolve their widths from the live horizontal viewport.'**
  String
  get resizeThisWindowWhileViewingTheAutoAndFitSectionsTheTablesResolvf66f1f9;

  /// No description provided for @superColumnWidthFitNone.
  ///
  /// In en, this message translates to:
  /// **'SuperColumnWidthFit.none'**
  String get superColumnWidthFitNone;

  /// No description provided for @oneNoneFixedWidth.
  ///
  /// In en, this message translates to:
  /// **'1 · None — fixed width'**
  String get oneNoneFixedWidth;

  /// No description provided for @usesTheColumnWidthExactlyAsDeclaredIfWidthIsNotSpecifiedTheTyped1d19a8c.
  ///
  /// In en, this message translates to:
  /// **'Uses the column width exactly as declared. If width is not specified, the typed column keeps its existing default width.'**
  String
  get usesTheColumnWidthExactlyAsDeclaredIfWidthIsNotSpecifiedTheTyped1d19a8c;

  /// No description provided for @superColumnWidthFitAuto.
  ///
  /// In en, this message translates to:
  /// **'SuperColumnWidthFit.auto'**
  String get superColumnWidthFitAuto;

  /// No description provided for @twoAutoEqualResponsiveWidth.
  ///
  /// In en, this message translates to:
  /// **'2 · Auto — equal responsive width'**
  String get twoAutoEqualResponsiveWidth;

  /// No description provided for @allAutoColumnsReceiveTheSameWidthFromTheHorizontalSpaceLeftAfterc1a55d1.
  ///
  /// In en, this message translates to:
  /// **'All auto columns receive the same width from the horizontal space left after fixed, intrinsic and fit-base widths are reserved.'**
  String
  get allAutoColumnsReceiveTheSameWidthFromTheHorizontalSpaceLeftAfterc1a55d1;

  /// No description provided for @superColumnWidthFitMaxCell.
  ///
  /// In en, this message translates to:
  /// **'SuperColumnWidthFit.maxCell'**
  String get superColumnWidthFitMaxCell;

  /// No description provided for @threeMaxCellIntrinsicContentWidth.
  ///
  /// In en, this message translates to:
  /// **'3 · Max cell — intrinsic content width'**
  String get threeMaxCellIntrinsicContentWidth;

  /// No description provided for @measuresRenderedRowTextAndUsesTheWidestVisibleCellContentPlusNor8947460.
  ///
  /// In en, this message translates to:
  /// **'Measures rendered row text and uses the widest visible cell content plus normal horizontal cell padding.'**
  String
  get measuresRenderedRowTextAndUsesTheWidestVisibleCellContentPlusNor8947460;

  /// No description provided for @superColumnWidthFitFit.
  ///
  /// In en, this message translates to:
  /// **'SuperColumnWidthFit.fit'**
  String get superColumnWidthFitFit;

  /// No description provided for @fourFitFillOtherwiseEmptySpace.
  ///
  /// In en, this message translates to:
  /// **'4 · Fit — fill otherwise-empty space'**
  String get fourFitFillOtherwiseEmptySpace;

  /// No description provided for @startsFromTheDeclaredBaseWidthAnyViewportWidthStillUnusedAfterAl2e61e70.
  ///
  /// In en, this message translates to:
  /// **'Starts from the declared base width. Any viewport width still unused after all columns resolve is divided equally between fit columns.'**
  String
  get startsFromTheDeclaredBaseWidthAnyViewportWidthStillUnusedAfterAl2e61e70;

  /// No description provided for @manualWidthOverride.
  ///
  /// In en, this message translates to:
  /// **'Manual width override'**
  String get manualWidthOverride;

  /// No description provided for @controllerSetWidthKeyPxAlwaysWinsOverWidthFitCallControllerReset0192e51.
  ///
  /// In en, this message translates to:
  /// **'controller.setWidth(key, px) always wins over widthFit. Call controller.resetWidth(key) to remove the manual override and return to the declared width-fit behavior.'**
  String
  get controllerSetWidthKeyPxAlwaysWinsOverWidthFitCallControllerReset0192e51;

  /// No description provided for @iD.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get iD;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @bigDataLoadMoreStressTest.
  ///
  /// In en, this message translates to:
  /// **'Big-data load-more stress test'**
  String get bigDataLoadMoreStressTest;

  /// No description provided for @eachLoadAppendsALargeBatchScrollToTheBottomForAutomaticLoadMoreO440a8e7.
  ///
  /// In en, this message translates to:
  /// **'Each load appends a large batch. Scroll to the bottom for automatic load-more, or trigger it manually.'**
  String
  get eachLoadAppendsALargeBatchScrollToTheBottomForAutomaticLoadMoreO440a8e7;

  /// No description provided for @rowsPerLoad.
  ///
  /// In en, this message translates to:
  /// **'Rows per load:'**
  String get rowsPerLoad;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load {batchSize}'**
  String load(Object batchSize);

  /// No description provided for @binOf.
  ///
  /// In en, this message translates to:
  /// **'Bin {index} of {itemsCount}'**
  String binOf(Object index, Object itemsCount);

  /// No description provided for @stillEditable.
  ///
  /// In en, this message translates to:
  /// **'Still editable'**
  String get stillEditable;

  /// No description provided for @committedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Committed transaction'**
  String get committedTransaction;

  /// No description provided for @noLongerActive.
  ///
  /// In en, this message translates to:
  /// **'No longer active'**
  String get noLongerActive;

  /// No description provided for @doubleClickAnEnumerationCellToEditItWithSuperSelectFormField.
  ///
  /// In en, this message translates to:
  /// **'Double-click an enumeration cell to edit it with SuperSelectFormField.'**
  String get doubleClickAnEnumerationCellToEditItWithSuperSelectFormField;

  /// No description provided for @changingWarehouseRebuildsTheBinSourcesForThatRow.
  ///
  /// In en, this message translates to:
  /// **'Changing Warehouse rebuilds the Bin sources for that row.'**
  String get changingWarehouseRebuildsTheBinSourcesForThatRow;

  /// No description provided for @searchAccount.
  ///
  /// In en, this message translates to:
  /// **'Search account'**
  String get searchAccount;

  /// No description provided for @pickAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Pick an account'**
  String get pickAnAccount;

  /// No description provided for @editableJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Editable journal entry'**
  String get editableJournalEntry;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @outOfBalance.
  ///
  /// In en, this message translates to:
  /// **'Out of balance'**
  String get outOfBalance;

  /// No description provided for @debitCredit.
  ///
  /// In en, this message translates to:
  /// **'Debit \${debit}   ·   Credit \${credit}'**
  String debitCredit(Object debit, Object credit);

  /// No description provided for @searchBins.
  ///
  /// In en, this message translates to:
  /// **'Search bins…'**
  String get searchBins;

  /// No description provided for @asyncComboFingerPrintRebuild.
  ///
  /// In en, this message translates to:
  /// **'Async combo (fingerPrint rebuild)'**
  String get asyncComboFingerPrintRebuild;

  /// No description provided for @doubleClickABinCellToSearchRemotelyChangeTheWarehouseAndTheBinLi990d954.
  ///
  /// In en, this message translates to:
  /// **'Double-click a Bin cell to search \"remotely\". Change the Warehouse and the Bin list rescopes.'**
  String
  get doubleClickABinCellToSearchRemotelyChangeTheWarehouseAndTheBinLi990d954;

  /// No description provided for @finalizedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Finalized transaction'**
  String get finalizedTransaction;

  /// No description provided for @filterState.
  ///
  /// In en, this message translates to:
  /// **'filterState: {json}'**
  String filterState(Object json);

  /// No description provided for @toggleMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle mode'**
  String get toggleMode;

  /// No description provided for @filterPosted.
  ///
  /// In en, this message translates to:
  /// **'Filter: Posted'**
  String get filterPosted;

  /// No description provided for @advancedAmountGreaterEqual500.
  ///
  /// In en, this message translates to:
  /// **'Advanced: amount ≥ 500'**
  String get advancedAmountGreaterEqual500;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @selectRowsZeroTwo.
  ///
  /// In en, this message translates to:
  /// **'Select rows 0–2'**
  String get selectRowsZeroTwo;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @filterJSON.
  ///
  /// In en, this message translates to:
  /// **'Filter JSON'**
  String get filterJSON;

  /// No description provided for @clearTable.
  ///
  /// In en, this message translates to:
  /// **'Clear table'**
  String get clearTable;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'🟢 Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'🟡 Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'🟠 High'**
  String get high;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'🔴 Critical'**
  String get critical;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @under5k.
  ///
  /// In en, this message translates to:
  /// **'Under \$5k'**
  String get under5k;

  /// No description provided for @message5k20k.
  ///
  /// In en, this message translates to:
  /// **'\$5k–\$20k'**
  String get message5k20k;

  /// No description provided for @over20k.
  ///
  /// In en, this message translates to:
  /// **'Over \$20k'**
  String get over20k;

  /// No description provided for @useTheColumnFilterRowTheAdvancedFilterButtonGutterHeaderOrPressRToReset.
  ///
  /// In en, this message translates to:
  /// **'Use the column filter row, the advanced-filter button (gutter header), or press \"R\" to reset.'**
  String
  get useTheColumnFilterRowTheAdvancedFilterButtonGutterHeaderOrPressRToReset;

  /// No description provided for @field.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get field;

  /// No description provided for @playgroundOneGridTwoModes.
  ///
  /// In en, this message translates to:
  /// **'Playground — one grid, two modes'**
  String get playgroundOneGridTwoModes;

  /// No description provided for @paging.
  ///
  /// In en, this message translates to:
  /// **'Paging'**
  String get paging;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get search;

  /// No description provided for @onHand41733d.
  ///
  /// In en, this message translates to:
  /// **'On Hand'**
  String get onHand41733d;

  /// No description provided for @pOSTDeltaTo.
  ///
  /// In en, this message translates to:
  /// **'POST delta → {delta}'**
  String pOSTDeltaTo(Object delta);

  /// No description provided for @editACellTabPastTheLastCellToAddARowOrRightClickToDeleteDirtyCel9f2a32d.
  ///
  /// In en, this message translates to:
  /// **'Edit a cell, Tab past the last cell to add a row, or right-click → Delete. Dirty cells show an accent corner. Save posts only the delta.'**
  String
  get editACellTabPastTheLastCellToAddARowOrRightClickToDeleteDirtyCel9f2a32d;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'{count} unsaved changes'**
  String unsavedChanges(Object count);

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get noChanges;

  /// No description provided for @revert.
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get revert;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @q1.
  ///
  /// In en, this message translates to:
  /// **'Q1'**
  String get q1;

  /// No description provided for @q2.
  ///
  /// In en, this message translates to:
  /// **'Q2'**
  String get q2;

  /// No description provided for @q3.
  ///
  /// In en, this message translates to:
  /// **'Q3'**
  String get q3;

  /// No description provided for @q4.
  ///
  /// In en, this message translates to:
  /// **'Q4'**
  String get q4;

  /// No description provided for @shiftDragABlockOfTheQuarterlyNumbersTheLiveSumAvgMinMaxAppearsIn8285e43.
  ///
  /// In en, this message translates to:
  /// **'Shift-drag a block of the quarterly numbers — the live Sum / Avg / Min / Max appears in the summary below.'**
  String
  get shiftDragABlockOfTheQuarterlyNumbersTheLiveSumAvgMinMaxAppearsIn8285e43;

  /// No description provided for @selectTwoOrMoreNumericCellsToSeeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Select two or more numeric cells to see statistics.'**
  String get selectTwoOrMoreNumericCellsToSeeStatistics;

  /// No description provided for @sUM.
  ///
  /// In en, this message translates to:
  /// **'SUM'**
  String get sUM;

  /// No description provided for @aVERAGE.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE'**
  String get aVERAGE;

  /// No description provided for @mIN.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get mIN;

  /// No description provided for @mAX.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get mAX;

  /// No description provided for @cOUNT.
  ///
  /// In en, this message translates to:
  /// **'COUNT'**
  String get cOUNT;

  /// No description provided for @searchExportReflectsTheFilteredView.
  ///
  /// In en, this message translates to:
  /// **'Search (export reflects the filtered view)…'**
  String get searchExportReflectsTheFilteredView;

  /// No description provided for @cSV.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get cSV;

  /// No description provided for @tSV.
  ///
  /// In en, this message translates to:
  /// **'TSV'**
  String get tSV;

  /// No description provided for @jSON.
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get jSON;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'{format} output'**
  String output(Object format);

  /// No description provided for @cSVCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'CSV copied to clipboard'**
  String get cSVCopiedToClipboard;

  /// No description provided for @cells.
  ///
  /// In en, this message translates to:
  /// **'Cells'**
  String get cells;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;

  /// No description provided for @rows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get rows;

  /// No description provided for @rawMaterial.
  ///
  /// In en, this message translates to:
  /// **'Raw Material'**
  String get rawMaterial;

  /// No description provided for @component.
  ///
  /// In en, this message translates to:
  /// **'Component'**
  String get component;

  /// No description provided for @finishedGood.
  ///
  /// In en, this message translates to:
  /// **'Finished Good'**
  String get finishedGood;

  /// No description provided for @consumable.
  ///
  /// In en, this message translates to:
  /// **'Consumable'**
  String get consumable;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @discontinued.
  ///
  /// In en, this message translates to:
  /// **'Discontinued'**
  String get discontinued;

  /// No description provided for @unitEach.
  ///
  /// In en, this message translates to:
  /// **'each'**
  String get unitEach;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'box'**
  String get unitBox;

  /// No description provided for @unitPallet.
  ///
  /// In en, this message translates to:
  /// **'pallet'**
  String get unitPallet;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitTonne.
  ///
  /// In en, this message translates to:
  /// **'tonne'**
  String get unitTonne;

  /// No description provided for @unitLitre.
  ///
  /// In en, this message translates to:
  /// **'litre'**
  String get unitLitre;

  /// No description provided for @unitMetre.
  ///
  /// In en, this message translates to:
  /// **'metre'**
  String get unitMetre;

  /// No description provided for @unitRoll.
  ///
  /// In en, this message translates to:
  /// **'roll'**
  String get unitRoll;

  /// No description provided for @unitSheet.
  ///
  /// In en, this message translates to:
  /// **'sheet'**
  String get unitSheet;
}

class _SuperTableExampleLocalizationDelegate
    extends LocalizationsDelegate<SuperTableExampleLocalization> {
  const _SuperTableExampleLocalizationDelegate();

  @override
  Future<SuperTableExampleLocalization> load(Locale locale) {
    return SynchronousFuture<SuperTableExampleLocalization>(
      lookupSuperTableExampleLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SuperTableExampleLocalizationDelegate old) => false;
}

SuperTableExampleLocalization lookupSuperTableExampleLocalization(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SuperTableExampleLocalizationAr();
    case 'en':
      return SuperTableExampleLocalizationEn();
  }

  throw FlutterError(
    'SuperTableExampleLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
