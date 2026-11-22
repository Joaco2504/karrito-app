import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/services/share_service.dart';
import 'karrito_bounce_button.dart';
import 'karrito_selector_field.dart';

class EditItemResult {
  const EditItemResult.save({
    required this.cleanName,
    required this.quantity,
    required this.unit,
    required this.storeCategory,
    required this.aisleName,
  }) : isDelete = false;

  const EditItemResult.delete()
    : cleanName = '',
      quantity = 0,
      unit = '',
      storeCategory = '',
      aisleName = '',
      isDelete = true;

  final bool isDelete;
  final String cleanName;
  final double quantity;
  final String unit;
  final String storeCategory;
  final String aisleName;
}

class EditItemBottomSheet extends StatefulWidget {
  const EditItemBottomSheet({required this.item, super.key});

  final ShoppingItemEntity item;

  static Future<EditItemResult?> show(
    BuildContext context,
    ShoppingItemEntity item,
  ) {
    return showModalBottomSheet<EditItemResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => EditItemBottomSheet(item: item),
    );
  }

  @override
  State<EditItemBottomSheet> createState() => _EditItemBottomSheetState();
}

class _EditItemBottomSheetState extends State<EditItemBottomSheet> {
  static const List<String> _quickUnits = <String>[
    'u',
    'kg',
    'g',
    'l',
    'paquete',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late String _selectedUnit;
  late String _selectedStore;
  late String _selectedAisle;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.cleanName);
    _qtyController = TextEditingController(
      text: ShareService.formatQuantity(widget.item.quantity),
    );
    _selectedUnit = widget.item.unit;
    _selectedStore = StoreHierarchy.normalizeStore(widget.item.storeCategory);
    _selectedAisle = widget.item.aisleName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  List<String> _unitOptions() {
    final set = <String>{...StoreHierarchy.commonUnits, _selectedUnit};
    return set.toList();
  }

  List<String> _aisleOptions(String store) {
    final defaults = StoreHierarchy.storeAisles[store] ?? const <String>[];
    final set = <String>{...defaults};
    if (defaults.contains(_selectedAisle) || _selectedAisle.isNotEmpty) {
      if (_selectedStore == store) {
        set.add(_selectedAisle);
      }
    }
    return set.toList();
  }

  void _stepQuantity(double delta) {
    final current =
        double.tryParse(_qtyController.text.replaceAll(',', '.')) ?? 1.0;
    final next = (current + delta).clamp(0.25, 999.0);
    _qtyController.text = ShareService.formatQuantity(next);
  }

  void _submitSave() {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        _nameError = AppStrings.invalidItemNameError;
      });
      return;
    }

    final parsedQty =
        double.tryParse(_qtyController.text.trim().replaceAll(',', '.')) ?? 1.0;
    final safeQty = parsedQty > 0 ? parsedQty : 1.0;

    Navigator.of(context).pop(
      EditItemResult.save(
        cleanName: trimmedName,
        quantity: safeQty,
        unit: _selectedUnit,
        storeCategory: _selectedStore,
        aisleName: _selectedAisle,
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppStrings.deleteItemButton),
          content: Text(
            AppStrings.deleteItemConfirmBody(widget.item.cleanName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppStrings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: const Text(AppStrings.deleteButton),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const EditItemResult.delete());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final aisleOptions = _aisleOptions(_selectedStore);
    if (!aisleOptions.contains(_selectedAisle) && aisleOptions.isNotEmpty) {
      _selectedAisle = aisleOptions.first;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 22 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.editItemTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const KarritoFieldLabel(AppStrings.itemNameLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.itemNameHint,
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const KarritoFieldLabel(AppStrings.itemQuantityLabel),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: karritoColors.fieldSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: karritoColors.border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'Restar cantidad',
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme.surface,
                                  foregroundColor: colorScheme.onSurface,
                                ),
                                icon: const Icon(
                                  Icons.remove_rounded,
                                  size: 20,
                                ),
                                onPressed: () => _stepQuantity(-1),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _qtyController,
                                textAlign: TextAlign.center,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                  color: colorScheme.onSurface,
                                ),
                                decoration: const InputDecoration(
                                  filled: false,
                                  isDense: true,
                                  constraints: BoxConstraints(minHeight: 44),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: 'Sumar cantidad',
                                style: IconButton.styleFrom(
                                  backgroundColor: karritoColors.accent,
                                  foregroundColor: karritoColors.onAccent,
                                ),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                onPressed: () => _stepQuantity(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: KarritoSelectorField<String>(
                    label: AppStrings.itemUnitLabel,
                    sheetTitle: AppStrings.selectUnitTitle,
                    value: _selectedUnit,
                    options: _unitOptions(),
                    onChanged: (value) {
                      setState(() => _selectedUnit = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickUnits.map((unit) {
                final active = _selectedUnit == unit;
                return ChoiceChip(
                  label: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? karritoColors.onAccent
                          : karritoColors.textSecondary,
                    ),
                  ),
                  selected: active,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: karritoColors.fieldSurface,
                  selectedColor: karritoColors.accent,
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: active ? karritoColors.accent : karritoColors.border,
                  ),
                  onSelected: (_) => setState(() => _selectedUnit = unit),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            KarritoSelectorField<String>(
              label: AppStrings.itemStoreLabel,
              sheetTitle: AppStrings.selectStoreTitle,
              value: _selectedStore,
              options: StoreHierarchy.storeOrder,
              onChanged: (value) {
                final newAisles =
                    StoreHierarchy.storeAisles[value] ?? const <String>[];
                setState(() {
                  _selectedStore = value;
                  _selectedAisle = newAisles.isNotEmpty
                      ? newAisles.first
                      : 'Varios';
                });
              },
            ),
            const SizedBox(height: 14),
            KarritoSelectorField<String>(
              label: AppStrings.itemAisleLabel,
              sheetTitle: AppStrings.selectAisleTitle,
              value: aisleOptions.contains(_selectedAisle)
                  ? _selectedAisle
                  : (aisleOptions.isNotEmpty ? aisleOptions.first : 'Varios'),
              options: aisleOptions,
              onChanged: (value) {
                setState(() => _selectedAisle = value);
              },
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: KarritoBounceButton(
                    child: OutlinedButton(
                      onPressed: _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: colorScheme.errorContainer.withValues(
                          alpha: 0.45,
                        ),
                        side: BorderSide(
                          color: karritoColors.softDestructive.withValues(
                            alpha: 0.4,
                          ),
                          width: 1,
                        ),
                        foregroundColor: karritoColors.softDestructive,
                      ),
                      child: const Text(
                        AppStrings.removeShortButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KarritoBounceButton(
                    child: FilledButton(
                      onPressed: _submitSave,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        AppStrings.saveShortButton,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
