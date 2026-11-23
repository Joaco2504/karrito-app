import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/services/currency_formatter.dart';
import '../../providers/shopping_providers.dart';
import '../widgets/karrito_asset_icon.dart';
import '../widgets/karrito_bounce_button.dart';
import '../widgets/karrito_selector_field.dart';

/// Monthly shopping expense tracker for Pro users following
/// `.agents/figma_ref/8._calculadora_de_changuito_pro_1` & `2`.
class MonthlyExpensesScreen extends ConsumerWidget {
  const MonthlyExpensesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const MonthlyExpensesScreen()),
    );
  }

  Future<void> _showBudgetSheet(
    BuildContext context,
    WidgetRef ref,
    double? currentBudget,
  ) async {
    final textController = TextEditingController(
      text: currentBudget != null
          ? CurrencyFormatter.formatArs(currentBudget, includeSymbol: false)
          : '',
    );
    final result = await showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.cartAdjustBudgetButton,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const KarritoFieldLabel(AppStrings.cartMonthlyBudgetLabel),
              const SizedBox(height: 6),
              TextField(
                controller: textController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  hintText: 'Ej: 150.000',
                ),
                onSubmitted: (_) {
                  final parsed = CurrencyFormatter.parseArs(
                    textController.text,
                  );
                  Navigator.of(sheetContext).pop(parsed ?? -1);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(-1.0),
                      child: const Text('Quitar tope'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final parsed = CurrencyFormatter.parseArs(
                          textController.text,
                        );
                        Navigator.of(sheetContext).pop(parsed ?? -1.0);
                      },
                      child: const Text(AppStrings.saveShortButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    textController.dispose();

    if (result == null) return;
    await ref
        .read(shoppingControllerProvider.notifier)
        .setMonthlyBudget(result < 0 ? null : result);
  }

  String _formatDateAr(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year.toString();
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history =
        ref.watch(expenseHistoryProvider).value ??
        const <ExpenseHistoryEntity>[];
    final prefs = ref.watch(preferencesProvider).value;
    final budget = prefs?.monthlyBudgetArs;

    final now = DateTime.now();
    final currentMonthEntries = history.where((e) {
      final d = e.recordedAt.toLocal();
      return d.year == now.year && d.month == now.month;
    }).toList();

    final monthTotal = currentMonthEntries.fold<double>(
      0.0,
      (sum, e) => sum + e.totalAmount,
    );
    final byStore = <String, double>{};
    for (final entry in currentMonthEntries) {
      byStore[entry.storeCategory] =
          (byStore[entry.storeCategory] ?? 0.0) + entry.totalAmount;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;

    final ratio = (budget != null && budget > 0)
        ? (monthTotal / budget).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (budget != null && budget > 0)
        ? budget - monthTotal
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.cartMonthlyHistoryTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              children: [
                // Budget Live Tracker Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: karritoColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: karritoColors.shadowTint,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GASTOS DE ESTE MES',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: karritoColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatArs(monthTotal),
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                    ),
                                    if (budget != null && budget > 0)
                                      Text(
                                        '/ ${CurrencyFormatter.formatArs(budget)}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  karritoColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          KarritoBounceButton(
                            child: TextButton.icon(
                              onPressed: () =>
                                  _showBudgetSheet(context, ref, budget),
                              style: TextButton.styleFrom(
                                backgroundColor: karritoColors.fieldSurface,
                                foregroundColor: karritoColors.accentSoft,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              icon: const Icon(Icons.tune_rounded, size: 16),
                              label: const Text(
                                AppStrings.cartAdjustBudgetButton,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (budget != null && budget > 0) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: karritoColors.fieldSurface,
                            color: remaining != null && remaining < 0
                                ? colorScheme.error
                                : karritoColors.cta,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: karritoColors.fieldSurface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  remaining! >= 0
                                      ? 'Te quedan ${CurrencyFormatter.formatArs(remaining)} para no pasarte'
                                      : 'Superaste tu tope por ${CurrencyFormatter.formatArs(remaining.abs())}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: remaining >= 0
                                        ? karritoColors.cta
                                        : colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(ratio * 100).round()}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: karritoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                if (byStore.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: byStore.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: karritoColors.fieldSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: karritoColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            KarritoAssetIcon.store(entry.key, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${entry.key}: ${CurrencyFormatter.formatArs(entry.value)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 18),
                if (history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: karritoColors.aisleCardSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: karritoColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 38,
                          color: karritoColors.accentSoft,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.cartHistoryEmptyTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.cartHistoryEmptyBody,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: karritoColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final entry in history)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: karritoColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: karritoColors.fieldSurface,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: KarritoAssetIcon.store(
                                entry.storeCategory,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.storeCategory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${entry.listTitle} · ${_formatDateAr(entry.recordedAt)} · ${entry.itemCount} ${entry.itemCount == 1 ? 'ítem' : 'ítems'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: karritoColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.formatArs(
                                    entry.totalAmount,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: karritoColors.accentSoft,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => ref
                                      .read(shoppingControllerProvider.notifier)
                                      .deleteExpenseRecord(entry.id),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Quitar',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(color: colorScheme.error),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
