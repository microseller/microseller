import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:micro_seller/core/l10n/app_localizations.dart';
import 'package:micro_seller/data/models/product.dart';
import 'package:micro_seller/data/services/isar_service.dart';
import 'package:micro_seller/features/orders/presentation/order_form_screen.dart';
import 'package:micro_seller/features/orders/presentation/order_tabs_screen.dart';
import 'package:micro_seller/features/orders/providers/quick_add_provider.dart';

import 'support/isar_core.dart';

/// Up to three new orders open at once, each keeping what was typed.
void main() {
  late Isar isar;

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(closeTestIsars);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async => isar = await openTestIsar('order_tabs'));
    final router = GoRouter(
      initialLocation: '/add',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('orders list')),
          routes: [GoRoute(path: 'add', builder: (_, _) => const OrderTabsScreen())],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => isar),
          quickAddProductsProvider.overrideWith((ref) async => <Product>[]),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await settle(tester);
  }

  Finder plus() => find.byTooltip('New order tab');

  testWidgets('one form, no tab row, until a second order is opened', (tester) async {
    await pump(tester);
    expect(find.byType(OrderFormScreen), findsOneWidget);
    expect(find.text('Order 1'), findsNothing);
    await tester.tap(plus());
    await settle(tester);
    expect(find.text('📦 1'), findsOneWidget);
    expect(find.text('Order 2'), findsOneWidget);
    // Only the open tab has a close button.
    expect(find.byTooltip('Close this order?'), findsOneWidget);
  });

  testWidgets('at most three, and the + is hidden', (tester) async {
    await pump(tester);
    await tester.tap(plus());
    await settle(tester);
    await tester.tap(plus());
    await settle(tester);
    // The open tab is named in full, the others by number.
    expect(find.text('Order 3'), findsOneWidget);
    expect(find.text('📦 1'), findsOneWidget);
    expect(find.text('📦 2'), findsOneWidget);
    expect(plus(), findsNothing);
    expect(find.byType(OrderFormScreen, skipOffstage: false), findsNWidgets(3));
  });

  testWidgets('switching tabs keeps each form alive', (tester) async {
    await pump(tester);
    final first = tester.state(find.byType(OrderFormScreen));
    await tester.tap(plus());
    await settle(tester);
    expect(tester.state(find.byType(OrderFormScreen)), isNot(same(first)));
    await tester.ensureVisible(find.text('📦 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('📦 1'));
    await settle(tester);
    expect(tester.state(find.byType(OrderFormScreen)), same(first));
  });

  testWidgets('closing a tab asks, then removes it', (tester) async {
    await pump(tester);
    await tester.tap(plus());
    await settle(tester);
    await tester.ensureVisible(find.byTooltip('Close this order?').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close this order?').last);
    await settle(tester);
    expect(find.text('What you entered in this tab will be lost.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Order 2'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Close this order?').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close this order?').last);
    await settle(tester);
    await tester.tap(find.text('Confirm'));
    await settle(tester);
    expect(find.text('📦 2'), findsNothing);
    expect(find.byType(OrderFormScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets('closing the middle tab keeps the third tab\'s order', (tester) async {
    await pump(tester);
    await tester.tap(plus());
    await settle(tester);
    await tester.tap(plus());
    await settle(tester);
    final third = tester.state(find.byType(OrderFormScreen)); // tab 3 is open
    await tester.ensureVisible(find.text('📦 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('📦 2'));
    await settle(tester);
    final second = tester.state(find.byType(OrderFormScreen));
    await tester.ensureVisible(find.byTooltip('Close this order?'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close this order?'));
    await settle(tester);
    await tester.tap(find.text('Confirm'));
    await settle(tester);
    // The old tab 3 is now "Order 2", with its own form, and it's open.
    expect(find.text('📦 3'), findsNothing);
    expect(find.text('Order 2'), findsOneWidget);
    expect(second.mounted, isFalse);
    expect(tester.state(find.byType(OrderFormScreen)), same(third));
  });
}
