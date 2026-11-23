import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/monetization_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/services/media_capture_service.dart';
import '../../data/services/share_service.dart';
import '../../domain/services/currency_formatter.dart';
import 'karrito_bounce_button.dart';
import 'karrito_selector_field.dart';

/// Bottom sheet for Pro voice dictation (M4A/AAC 48 kbps, <= 60s, <= 500 KB).
class VoiceDictationSheet extends StatefulWidget {
  const VoiceDictationSheet({required this.mediaService, super.key});

  final MediaCaptureService mediaService;

  static Future<EncodedVoicePayload?> show({
    required BuildContext context,
    required MediaCaptureService mediaService,
  }) {
    return showModalBottomSheet<EncodedVoicePayload>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => VoiceDictationSheet(mediaService: mediaService),
    );
  }

  @override
  State<VoiceDictationSheet> createState() => _VoiceDictationSheetState();
}

class _VoiceDictationSheetState extends State<VoiceDictationSheet> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRecording = false;
  bool _isStopping = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording && !_isStopping) {
      unawaited(widget.mediaService.cancelVoiceRecording());
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await widget.mediaService.startVoiceRecording();
      if (!mounted) return;
      setState(() => _isRecording = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() => _elapsedSeconds++);
        if (_elapsedSeconds >= MonetizationConfig.maxVoiceDurationSeconds) {
          unawaited(_finishAndSend());
        }
      });
    } on MediaGuardException catch (e) {
      if (mounted) {
        setState(() => _errorText = e.userMessage);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorText =
              'No pudimos abrir el micrófono ahora. Revisá los permisos del teléfono e intentá de nuevo.',
        );
      }
    }
  }

  Future<void> _finishAndSend() async {
    if (_isStopping) return;
    _timer?.cancel();
    setState(() {
      _isStopping = true;
      _errorText = null;
    });

    try {
      final payload = await widget.mediaService.stopVoiceRecording(
        durationSeconds: _elapsedSeconds,
      );
      _isRecording = false;
      if (!mounted) return;
      if (payload == null) {
        setState(() {
          _isStopping = false;
          _errorText =
              'No detectamos audio en la grabación. Probá hablar más cerca del micrófono.';
        });
        return;
      }
      Navigator.of(context).pop(payload);
    } on MediaGuardException catch (e) {
      _isRecording = false;
      if (mounted) {
        setState(() {
          _isStopping = false;
          _errorText = e.userMessage;
        });
      }
    } catch (_) {
      _isRecording = false;
      if (mounted) {
        setState(() {
          _isStopping = false;
          _errorText =
              'No pudimos guardar ese dictado. Probá grabar de nuevo en unos segundos.';
        });
      }
    }
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    _isRecording = false;
    await widget.mediaService.cancelVoiceRecording();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatClock(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _errorText != null
                    ? theme.colorScheme.errorContainer
                    : karritoColors.ctaContainer,
                border: Border.all(
                  color: _errorText != null
                      ? theme.colorScheme.error
                      : karritoColors.cta,
                  width: 2,
                ),
              ),
              child: Icon(
                _errorText != null ? Icons.mic_off_rounded : Icons.mic_rounded,
                size: 34,
                color: _errorText != null
                    ? theme.colorScheme.error
                    : karritoColors.cta,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.voiceRecordingTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatClock(_elapsedSeconds)} / 01:00',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: karritoColors.accentSoft,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorText ?? AppStrings.voiceLimitHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _errorText != null
                  ? theme.colorScheme.error
                  : karritoColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isStopping ? null : _cancel,
                  child: const Text(AppStrings.cancelButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KarritoBounceButton(
                  enabled: _isRecording && !_isStopping,
                  child: FilledButton.icon(
                    onPressed: (_isRecording && !_isStopping)
                        ? _finishAndSend
                        : null,
                    icon: _isStopping
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: const Text(AppStrings.voiceStopAndSendButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet letting Pro users pick camera (paper list) or gallery
/// (WhatsApp screenshot) for `procesar-lista` OCR extraction.
class ScanPhotoSourceSheet {
  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final karritoColors = theme.extension<KarritoColors>()!;

        Widget buildTile({
          required IconData icon,
          required String title,
          required String subtitle,
          required ImageSource source,
        }) {
          return Material(
            color: karritoColors.fieldSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: karritoColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(sheetContext).pop(source),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: karritoColors.accentContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: karritoColors.accentSoft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: karritoColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: karritoColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppStrings.scanSourceTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              buildTile(
                icon: Icons.photo_camera_outlined,
                title: AppStrings.scanCameraOption,
                subtitle: AppStrings.scanCameraSubtitle,
                source: ImageSource.camera,
              ),
              const SizedBox(height: 10),
              buildTile(
                icon: Icons.photo_library_outlined,
                title: AppStrings.scanGalleryOption,
                subtitle: AppStrings.scanGallerySubtitle,
                source: ImageSource.gallery,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom sheet for Pro recipe / DIY project importer (`procesar-lista`).
class ImportRecipeSheet extends StatefulWidget {
  const ImportRecipeSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const ImportRecipeSheet(),
    );
  }

  @override
  State<ImportRecipeSheet> createState() => _ImportRecipeSheetState();
}

class _ImportRecipeSheetState extends State<ImportRecipeSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorText = AppStrings.recipeEmptyError);
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.importRecipeTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.importRecipeSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: karritoColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          const KarritoFieldLabel(AppStrings.importRecipeLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppStrings.importRecipeHint,
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancelButton),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: KarritoBounceButton(
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                    label: const Text(AppStrings.importRecipeSubmitButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick bottom sheet for annotating an item's price in ARS (Pro Cart Calculator).
class ItemPriceInputResult {
  const ItemPriceInputResult.set(this.price) : clear = false;
  const ItemPriceInputResult.clear() : price = null, clear = true;

  final double? price;
  final bool clear;
}

class ItemPriceInputSheet extends StatefulWidget {
  const ItemPriceInputSheet({required this.item, super.key});

  final ShoppingItemEntity item;

  static Future<ItemPriceInputResult?> show(
    BuildContext context,
    ShoppingItemEntity item,
  ) {
    return showModalBottomSheet<ItemPriceInputResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ItemPriceInputSheet(item: item),
    );
  }

  @override
  State<ItemPriceInputSheet> createState() => _ItemPriceInputSheetState();
}

class _ItemPriceInputSheetState extends State<ItemPriceInputSheet> {
  late final TextEditingController _controller;
  bool _isUnitPriceMode = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.price != null
          ? CurrencyFormatter.formatArs(
              widget.item.price!,
              includeSymbol: false,
            )
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _computedTotal() {
    final parsed = CurrencyFormatter.parseArs(_controller.text);
    if (parsed == null) return null;
    if (_isUnitPriceMode && widget.item.quantity > 0) {
      return double.parse((parsed * widget.item.quantity).toStringAsFixed(2));
    }
    return parsed;
  }

  void _save() {
    final total = _computedTotal();
    if (total == null) {
      setState(
        () => _errorText = 'Escribí un importe mayor a cero (ej: 3.800).',
      );
      return;
    }
    Navigator.of(context).pop(ItemPriceInputResult.set(total));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karritoColors = theme.extension<KarritoColors>()!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final previewTotal = _computedTotal();
    final qtyLabel =
        '${ShareService.formatQuantity(widget.item.quantity)} ${widget.item.unit}';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.cartPriceDialogTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.item.cleanName} ($qtyLabel)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: karritoColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          if (widget.item.quantity != 1.0) ...[
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text(AppStrings.cartTotalModeLabel),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text(AppStrings.cartUnitModeLabel),
                ),
              ],
              selected: <bool>{_isUnitPriceMode},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  setState(() => _isUnitPriceMode = selection.first);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          const KarritoFieldLabel(AppStrings.cartPriceLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: AppStrings.cartPriceHint,
              errorText: _errorText,
            ),
            onChanged: (_) => setState(() => _errorText = null),
            onSubmitted: (_) => _save(),
          ),
          if (_isUnitPriceMode && previewTotal != null) ...[
            const SizedBox(height: 8),
            Text(
              'Total calculado ($qtyLabel): ${CurrencyFormatter.formatArs(previewTotal)}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: karritoColors.accentSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.item.price != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const ItemPriceInputResult.clear()),
                    child: const Text(AppStrings.cartClearPriceButton),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: KarritoBounceButton(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text(AppStrings.saveShortButton),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
