import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/store_hierarchy.dart';
import '../../data/local/app_database.dart';
import '../../data/services/share_service.dart';

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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final aisleOptions = _aisleOptions(_selectedStore);
    if (!aisleOptions.contains(_selectedAisle) && aisleOptions.isNotEmpty) {
      _selectedAisle = aisleOptions.first;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.editItemTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: AppStrings.itemNameLabel,
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: AppStrings.itemQuantityLabel,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.remove_rounded),
                        onPressed: () => _stepQuantity(-1),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => _stepQuantity(1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: AppStrings.itemUnitLabel,
                    ),
                    items: _unitOptions()
                        .map(
                          (u) => DropdownMenuItem<String>(
                            value: u,
                            child: Text(u),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStore,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: AppStrings.itemStoreLabel,
              ),
              items: StoreHierarchy.storeOrder
                  .map(
                    (store) => DropdownMenuItem<String>(
                      value: store,
                      child: Text(store),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey<String>('aisle_$_selectedStore'),
              initialValue: aisleOptions.contains(_selectedAisle)
                  ? _selectedAisle
                  : (aisleOptions.isNotEmpty ? aisleOptions.first : null),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: AppStrings.itemAisleLabel,
              ),
              items: aisleOptions
                  .map(
                    (aisle) => DropdownMenuItem<String>(
                      value: aisle,
                      child: Text(aisle, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAisle = value);
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitSave,
              child: const Text(AppStrings.saveItemButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _confirmDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              label: Text(
                AppStrings.deleteItemButton,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
