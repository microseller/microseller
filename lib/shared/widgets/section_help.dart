import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_next/tabler_icons_next.dart' as tabler;
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/sidebar_items.dart';
import 'bottom_sheet_handle.dart';

/// The help a screen's ? button opens. Every text is a translation key built
/// from [prefix]: `<prefix>What`, `<prefix>When`, and for each id in
/// [controls] / [numbers] a name (`<prefix>Ctl<id>Name`, `<prefix>Num<id>Name`)
/// and a line (`<prefix>Ctl<id>`, `<prefix>Num<id>`); tips are
/// `<prefix>Tip1`…. A sub-screen ([hasTitle]) also has `<prefix>Title`; a
/// sidebar section's sheet is titled with its sidebar label.
class SectionHelp {
  const SectionHelp(
    this.prefix, {
    this.hasTitle = false,
    this.controls = const [],
    this.numbers = const [],
    this.tips = 0,
    this.related = const [],
  });

  final String prefix;
  final bool hasTitle;
  final List<String> controls;
  final List<String> numbers;
  final int tips;

  /// (sidebar section, line key): the sections this screen works with.
  final List<(String, String)> related;

  String get what => '${prefix}What';
  String get when => '${prefix}When';
  String get title => '${prefix}Title';
  String controlName(String id) => '${prefix}Ctl${id}Name';
  String control(String id) => '${prefix}Ctl$id';
  String numberName(String id) => '${prefix}Num${id}Name';
  String number(String id) => '${prefix}Num$id';
  String tip(int i) => '${prefix}Tip$i';

  /// Every translation key this help reads.
  List<String> get keys => [
        if (hasTitle) title,
        what,
        when,
        for (final id in controls) ...[controlName(id), control(id)],
        for (final id in numbers) ...[numberName(id), number(id)],
        for (var i = 1; i <= tips; i++) tip(i),
        for (final (_, key) in related) key,
      ];
}

const kSectionRoutes = {
  'dashboard': '/',
  'products': '/products',
  'orders': '/orders',
  'returns': '/returns',
  'customers': '/customers',
  'dues': '/dues',
  'inventory': '/inventory',
  'suppliers': '/suppliers',
  'expenses': '/expenses',
  'cash_register': '/cash-register',
  'categories': '/categories',
  'reports': '/reports',
  'scanner': '/scanner',
  'settings': '/settings',
  'goals': '/goals',
  'expiry': '/expiry',
  'promotions': '/promotions',
};

/// Help per screen: the sidebar sections (keyed by their sidebar key) and the
/// sub-screens (detail, form and settings screens, keyed by a screen id).
const kSectionHelp = {
  // ── Sidebar sections ──────────────────────────────────────────────────
  'dashboard': SectionHelp(
    'helpDashboard',
    controls: ['Range', 'Cards', 'Overdue', 'DueBook', 'Charts', 'LowStock', 'Targets'],
    numbers: ['Revenue', 'Profit', 'Orders', 'Receivable', 'Collected'],
    tips: 2,
    related: [
      ('orders', 'helpDashboardOrders'),
      ('dues', 'helpDashboardDues'),
      ('inventory', 'helpDashboardInventory'),
      ('reports', 'helpDashboardReports'),
    ],
  ),
  'products': SectionHelp(
    'helpProducts',
    controls: ['Search', 'Categories', 'View', 'Share', 'Badge', 'Add'],
    tips: 2,
    related: [
      ('categories', 'helpProductsCategories'),
      ('orders', 'helpProductsOrders'),
      ('inventory', 'helpProductsInventory'),
      ('suppliers', 'helpProductsSuppliers'),
    ],
  ),
  'orders': SectionHelp(
    'helpOrders',
    controls: ['Tabs', 'Card', 'LongPress', 'Export', 'Add'],
    tips: 2,
    related: [
      ('customers', 'helpOrdersCustomers'),
      ('products', 'helpOrdersProducts'),
      ('inventory', 'helpOrdersInventory'),
      ('dues', 'helpOrdersDues'),
      ('returns', 'helpOrdersReturns'),
    ],
  ),
  'returns': SectionHelp(
    'helpReturns',
    controls: ['Tabs', 'Add', 'Flow', 'Open'],
    tips: 1,
    related: [
      ('orders', 'helpReturnsOrders'),
      ('inventory', 'helpReturnsInventory'),
      ('dues', 'helpReturnsDues'),
    ],
  ),
  'customers': SectionHelp(
    'helpCustomers',
    controls: ['Search', 'DueBook', 'Tags', 'Open', 'Add'],
    numbers: ['Outstanding'],
    tips: 1,
    related: [
      ('orders', 'helpCustomersOrders'),
      ('dues', 'helpCustomersDues'),
    ],
  ),
  'dues': SectionHelp(
    'helpDues',
    controls: ['Sort', 'Filter', 'Collect', 'Remind', 'Call', 'Recalculate'],
    numbers: ['Total', 'Aging'],
    tips: 1,
    related: [
      ('orders', 'helpDuesOrders'),
      ('customers', 'helpDuesCustomers'),
      ('cash_register', 'helpDuesCashRegister'),
    ],
  ),
  'inventory': SectionHelp(
    'helpInventory',
    controls: ['Tabs', 'Sort', 'Category', 'Adjust', 'Types'],
    tips: 1,
    related: [
      ('products', 'helpInventoryProducts'),
      ('orders', 'helpInventoryOrders'),
      ('suppliers', 'helpInventorySuppliers'),
    ],
  ),
  'suppliers': SectionHelp(
    'helpSuppliers',
    controls: ['AllPurchases', 'NewPurchase', 'Add', 'Open'],
    numbers: ['Due'],
    tips: 1,
    related: [
      ('inventory', 'helpSuppliersInventory'),
      ('products', 'helpSuppliersProducts'),
      ('expenses', 'helpSuppliersExpenses'),
    ],
  ),
  'expenses': SectionHelp(
    'helpExpenses',
    controls: ['Summary', 'Categories', 'Export', 'Add', 'Delete'],
    tips: 1,
    related: [
      ('reports', 'helpExpensesReports'),
      ('dashboard', 'helpExpensesDashboard'),
    ],
  ),
  'cash_register': SectionHelp(
    'helpCashRegister',
    controls: ['Open', 'CashIn', 'CashOut', 'Close', 'History'],
    numbers: ['Expected', 'Actual', 'Difference'],
    tips: 1,
    related: [
      ('dues', 'helpCashRegisterDues'),
      ('expenses', 'helpCashRegisterExpenses'),
    ],
  ),
  'categories': SectionHelp(
    'helpCategories',
    controls: ['Add', 'Edit', 'Dozen', 'Delete'],
    related: [
      ('products', 'helpCategoriesProducts'),
      ('reports', 'helpCategoriesReports'),
    ],
  ),
  'reports': SectionHelp(
    'helpReports',
    controls: ['Range', 'Tabs', 'Export'],
    numbers: ['NetSales', 'Gross', 'Net', 'Tax', 'Receivable', 'Stock'],
    tips: 1,
    related: [
      ('orders', 'helpReportsOrders'),
      ('expenses', 'helpReportsExpenses'),
      ('dues', 'helpReportsDues'),
      ('suppliers', 'helpReportsSuppliers'),
    ],
  ),
  'scanner': SectionHelp(
    'helpScanner',
    controls: ['Scan', 'View', 'AddNew', 'Torch'],
    tips: 1,
    related: [('products', 'helpScannerProducts')],
  ),
  'settings': SectionHelp(
    'helpSettings',
    controls: ['Theme', 'Display', 'Shop', 'Security', 'Backup', 'Sidebar', 'Bin'],
    tips: 1,
  ),
  'goals': SectionHelp(
    'helpGoals',
    controls: ['Monthly', 'Product', 'Save', 'Dashboard'],
    tips: 1,
    related: [
      ('dashboard', 'helpGoalsDashboard'),
      ('reports', 'helpGoalsReports'),
      ('products', 'helpGoalsProducts'),
    ],
  ),
  'expiry': SectionHelp(
    'helpExpiry',
    controls: ['Expired', 'Soon', 'Open'],
    tips: 1,
    related: [
      ('products', 'helpExpiryProducts'),
      ('inventory', 'helpExpiryInventory'),
    ],
  ),
  'promotions': SectionHelp(
    'helpPromotions',
    controls: ['Add', 'Types', 'Share', 'Status', 'Edit'],
    related: [
      ('products', 'helpPromotionsProducts'),
      ('orders', 'helpPromotionsOrders'),
    ],
  ),

  // ── Sub-screens ───────────────────────────────────────────────────────
  'product_detail': SectionHelp(
    'helpProductDetail',
    hasTitle: true,
    controls: ['Adjust', 'Edit', 'Delete', 'Variants', 'Serials'],
    numbers: ['Margin', 'Stock'],
  ),
  'product_form': SectionHelp(
    'helpProductForm',
    hasTitle: true,
    controls: ['Photo', 'Prices', 'Code', 'Supplier', 'Unit', 'Variants', 'BulkSet', 'Serials', 'Expiry'],
    tips: 1,
  ),
  'catalog_share': SectionHelp(
    'helpCatalog',
    hasTitle: true,
    controls: ['Select', 'Options', 'Image', 'Pdf', 'Text'],
    tips: 1,
  ),
  'order_detail': SectionHelp(
    'helpOrderDetail',
    hasTitle: true,
    controls: ['Steps', 'Payment', 'Menu', 'Email', 'Delivery', 'Return', 'Returns', 'Cancel'],
    numbers: ['Due', 'Returned'],
    tips: 1,
  ),
  'order_form': SectionHelp(
    'helpOrderForm',
    hasTitle: true,
    controls: ['Tabs', 'Customer', 'Date', 'Items', 'Dozen', 'Pricing', 'Paid', 'Status', 'Recurring'],
    tips: 1,
  ),
  'create_return': SectionHelp(
    'helpCreateReturn',
    hasTitle: true,
    controls: ['Items', 'Reason', 'Refund', 'Serials', 'Submit'],
    tips: 2,
  ),
  'choose_return_order': SectionHelp(
    'helpChooseReturn',
    hasTitle: true,
    controls: ['Search', 'Order'],
    tips: 1,
  ),
  'customer_detail': SectionHelp(
    'helpCustomerDetail',
    hasTitle: true,
    controls: ['Collect', 'Remind', 'Statement', 'Payments', 'Orders', 'Chart'],
    numbers: ['Outstanding', 'Spent'],
  ),
  'customer_form': SectionHelp(
    'helpCustomerForm',
    hasTitle: true,
    controls: ['Phone', 'Email', 'Type', 'Address'],
  ),
  'supplier_detail': SectionHelp(
    'helpSupplierDetail',
    hasTitle: true,
    controls: ['NewPurchase', 'PayDue', 'Call', 'Products', 'Activity'],
    numbers: ['Due', 'Paid'],
  ),
  'supplier_form': SectionHelp(
    'helpSupplierForm',
    hasTitle: true,
    controls: ['Contact', 'Notes'],
  ),
  'purchase_list': SectionHelp(
    'helpPurchaseList',
    hasTitle: true,
    controls: ['Add', 'Open'],
    numbers: ['Due'],
  ),
  'purchase_form': SectionHelp(
    'helpPurchaseForm',
    hasTitle: true,
    controls: ['Supplier', 'Date', 'Products', 'Filter', 'Paid', 'Reference'],
    tips: 1,
  ),
  'purchase_detail': SectionHelp(
    'helpPurchaseDetail',
    hasTitle: true,
    controls: ['Pay', 'Delete'],
  ),
  'expense_form': SectionHelp(
    'helpExpenseForm',
    hasTitle: true,
    controls: ['Category', 'Date'],
  ),
  'stock_adjustment': SectionHelp(
    'helpStockAdjust',
    hasTitle: true,
    controls: ['Variation', 'Type', 'Qty', 'Date', 'Reason', 'Serials'],
  ),
  'sidebar_order': SectionHelp(
    'helpSidebarOrder',
    hasTitle: true,
    controls: ['Drag', 'Switch', 'Reset'],
  ),
  'recycle_bin': SectionHelp(
    'helpRecycleBin',
    hasTitle: true,
    controls: ['Restore', 'Forever', 'Empty'],
    tips: 1,
  ),
  'color_theme': SectionHelp(
    'helpColorTheme',
    hasTitle: true,
    controls: ['Presets', 'Phone', 'Mine', 'Create'],
    tips: 1,
  ),
  'color_theme_editor': SectionHelp(
    'helpThemeEditor',
    hasTitle: true,
    controls: ['Main', 'Text', 'Style', 'Accent', 'Preview'],
    tips: 1,
  ),
};

SidebarItem _item(String key) => sidebarItems.firstWhere((i) => i.key == key);

String _sheetTitle(BuildContext context, String section, SectionHelp help) =>
    help.hasTitle ? AppStrings.of(context).tr(help.title) : _item(section).label(context);

Future<void> showSectionHelp(BuildContext context, String section) {
  final help = kSectionHelp[section]!;
  return AppBottomSheet.show<void>(
    context,
    title: _sheetTitle(context, section, help),
    child: SectionHelpBody(help: help),
  );
}

class SectionHelpButton extends StatelessWidget {
  const SectionHelpButton(this.section, {super.key, this.color});

  final String section;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppStrings.of(context).helpAboutScreen,
      onPressed: () => showSectionHelp(context, section),
      icon: ThinIcon(tabler.HelpCircle.new, color: color),
    );
  }
}

/// The sheet's content, for one screen's [help].
class SectionHelpBody extends StatelessWidget {
  const SectionHelpBody({super.key, required this.help});

  final SectionHelp help;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final heading = theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);

    Widget section(String title, List<Widget> rows) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(title, style: heading),
            const SizedBox(height: 4),
            ...rows,
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(s.tr(help.what), style: theme.textTheme.bodyLarge),
        section(s.helpWhenToUse, [Text(s.tr(help.when))]),
        if (help.controls.isNotEmpty)
          section(s.helpOnThisScreen, [
            for (final id in help.controls)
              _HelpRow(name: s.tr(help.controlName(id)), text: s.tr(help.control(id))),
          ]),
        if (help.numbers.isNotEmpty)
          section(s.helpNumbersMean, [
            for (final id in help.numbers)
              _HelpRow(name: s.tr(help.numberName(id)), text: s.tr(help.number(id))),
          ]),
        if (help.tips > 0)
          section(s.helpTips, [
            for (var i = 1; i <= help.tips; i++) _TipRow(text: s.tr(help.tip(i))),
          ]),
        if (help.related.isNotEmpty)
          section(s.helpWorksWith, [
            for (final (key, text) in help.related) _RelatedSection(section: key, text: s.tr(text)),
          ]),
      ],
    );
  }
}

/// A named control or figure and one line on it.
class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThinIcon(tabler.Bulb.new, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _RelatedSection extends StatelessWidget {
  const _RelatedSection({required this.section, required this.text});

  final String section;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _item(section);
    final color = theme.brightness == Brightness.dark
        ? Color.lerp(item.color, Colors.white, 0.25)!
        : item.color;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.go(kSectionRoutes[section]!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThinIcon(item.icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label(context),
                      style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                  Text(text, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ThinIcon(tabler.ChevronRight.new, size: 18, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
