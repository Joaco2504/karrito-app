import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/store_visuals.dart';
import '../../data/local/app_database.dart';
import '../../data/services/share_service.dart';
import '../../domain/services/currency_formatter.dart';
import 'karrito_asset_icon.dart';
import 'karrito_bounce_button.dart';
import 'karrito_selector_field.dart';

class EditItemResult {
  const EditItemResult.save({
    required this.cleanName,
    required this.quantity,
    required this.unit,
    required this.storeCategory,
    required this.aisleName,
    this.price,
    this.updatePrice = false,
  }) : isDelete = false;

  const EditItemResult.delete()
    : cleanName = '',
      quantity = 0,
      unit = '',
      storeCategory = '',
      aisleName = '',
      price = null,
      updatePrice = false,
      isDelete = true;

  final bool isDelete;
  final String cleanName;
  final double quantity;
  final String unit;
  final String storeCategory;
  final String aisleName;
  final double? price;
  final bool updatePrice;
}

class EditItemBottomSheet extends StatefulWidget {
  const EditItemBottomSheet({
    required this.item,
    this.showPriceField = false,
    super.key,
  });

  final ShoppingItemEntity item;
  final bool showPriceField;

  static Future<EditItemResult?> show(
    BuildContext context,
    ShoppingItemEntity item, {
    bool showPriceField = false,
  }) {
    return showModalBottomSheet<EditItemResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) =>
          EditItemBottomSheet(item: item, showPriceField: showPriceField),
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
  late final TextEditingController _priceController;
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
    _priceController = TextEditingController(
      text: widget.item.price != null
          ? CurrencyFormatter.formatArs(
              widget.item.price!,
              includeSymbol: false,
            )
          : '',
    );
    _selectedUnit = widget.item.unit;
    _selectedStore = StoreHierarchy.normalizeStore(widget.item.storeCategory);
    _selectedAisle = widget.item.aisleName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
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
    final parsedPrice = widget.showPriceField
        ? CurrencyFormatter.parseArs(_priceController.text)
        : null;

    Navigator.of(context).pop(
      EditItemResult.save(
        cleanName: trimmedName,
        quantity: safeQty,
        unit: _selectedUnit,
        storeCategory: _selectedStore,
        aisleName: _selectedAisle,
        price: parsedPrice,
        updatePrice: widget.showPriceField,
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
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final aisleOptions = _aisleOptions(_selectedStore);
    if (!aisleOptions.contains(_selectedAisle) && aisleOptions.isNotEmpty) {
      _selectedAisle = aisleOptions.first;
    }

    final storeVisual = StoreVisuals.forStore(_selectedStore);
    final aisleVisual = StoreVisuals.forAisle(_selectedAisle);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 2, 20, 18 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: karritoColors.accentContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 21,
                    color: karritoColors.accentSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.editItemTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        AppStrings.editItemSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: karritoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.cancelButton,
                  style: IconButton.styleFrom(
                    backgroundColor: karritoColors.fieldSurface,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: karritoColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const KarritoFieldLabel(AppStrings.itemNameLabel),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.itemNameHint,
                        errorText: _nameError,
                        suffixIcon: _nameController.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Limpiar',
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: karritoColors.textSecondary,
                                ),
                                onPressed: () {
                                  _nameController.clear();
                                  setState(() => _nameError = null);
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        setState(() {
                          if (_nameError != null) _nameError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const KarritoFieldLabel(
                                AppStrings.itemQuantityLabel,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
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
                                          foregroundColor:
                                              colorScheme.onSurface,
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
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
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
                                          constraints: BoxConstraints(
                                            minHeight: 44,
                                          ),
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
                                          foregroundColor:
                                              karritoColors.onAccent,
                                        ),
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          size: 20,
                                        ),
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _quickUnits.map((unit) {
                        final active = _selectedUnit == unit;
                        return ChoiceChip(
                          avatar: active
                              ? Icon(
                                  Icons.scale_rounded,
                                  size: 14,
                                  color: karritoColors.onAccent,
                                )
                              : null,
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
                            color: active
                                ? karritoColors.accent
                                : karritoColors.border,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedUnit = unit),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    KarritoSelectorField<String>(
                      label: AppStrings.itemStoreLabel,
                      sheetTitle: AppStrings.selectStoreTitle,
                      leadingWidget: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: storeVisual.color.withValues(
                            alpha: isDark ? 0.22 : 0.16,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: KarritoAssetIcon.store(
                            _selectedStore,
                            size: 16,
                            color: storeVisual.color,
                          ),
                        ),
                      ),
                      value: _selectedStore,
                      options: StoreHierarchy.storeOrder,
                      onChanged: (value) {
                        final newAisles =
                            StoreHierarchy.storeAisles[value] ??
                            const <String>[];
                        setState(() {
                          _selectedStore = value;
                          _selectedAisle = newAisles.isNotEmpty
                              ? newAisles.first
                              : 'Varios';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    KarritoSelectorField<String>(
                      label: AppStrings.itemAisleLabel,
                      sheetTitle: AppStrings.selectAisleTitle,
                      leadingWidget: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: aisleVisual.color.withValues(
                            alpha: isDark ? 0.22 : 0.16,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: KarritoAssetIcon.aisle(
                            _selectedAisle,
                            size: 16,
                            color: aisleVisual.color,
                          ),
                        ),
                      ),
                      value: aisleOptions.contains(_selectedAisle)
                          ? _selectedAisle
                          : (aisleOptions.isNotEmpty
                                ? aisleOptions.first
                                : 'Varios'),
                      options: aisleOptions,
                      onChanged: (value) {
                        setState(() => _selectedAisle = value);
                      },
                    ),
                    if (widget.showPriceField) ...[
                      const SizedBox(height: 12),
                      const KarritoFieldLabel(AppStrings.cartPriceLabel),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          hintText: AppStrings.cartPriceHint,
                          suffixIcon: _priceController.text.isNotEmpty
                              ? IconButton(
                                  tooltip: AppStrings.cartClearPriceButton,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: karritoColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    _priceController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: karritoColors.ctaContainer.withValues(
                          alpha: isDark ? 0.75 : 0.85,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: karritoColors.cta.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: karritoColors.cta,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.editItemLearnTip,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: karritoColors.onCtaContainer,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: KarritoBounceButton(
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: colorScheme.errorContainer.withValues(
                          alpha: isDark ? 0.65 : 0.55,
                        ),
                        side: BorderSide(
                          color: karritoColors.softDestructive.withValues(
                            alpha: 0.4,
                          ),
                          width: 1,
                        ),
                        foregroundColor: karritoColors.softDestructive,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text(
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
                  flex: 7,
                  child: KarritoBounceButton(
                    child: FilledButton.icon(
                      onPressed: _submitSave,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 19),
                      label: const Text(
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
