import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/monetization_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../data/models/procesar_lista_response.dart';
import '../../data/repositories/shopping_repository.dart';
import '../../data/services/ai_classifier_service.dart';
import '../../data/services/media_capture_service.dart';
import '../../data/services/share_service.dart';
import '../../domain/services/currency_formatter.dart';
import 'karrito_bounce_button.dart';
import 'karrito_selector_field.dart';

/// Clean vector chef-hat (toque) icon used on the wide "Recetas" bar and
/// inside the recipe importer sheet.
class KarritoChefHatIcon extends StatelessWidget {
  const KarritoChefHatIcon({this.size = 20, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onPrimary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ChefHatPainter(resolvedColor)),
    );
  }
}

class _ChefHatPainter extends CustomPainter {
  const _ChefHatPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.095).clamp(1.5, 2.6)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Puffy top cloud of chef toque
    final puff = Path()
      ..moveTo(w * 0.24, h * 0.57)
      ..cubicTo(w * 0.11, h * 0.56, w * 0.08, h * 0.34, w * 0.24, h * 0.30)
      ..cubicTo(w * 0.27, h * 0.13, w * 0.44, h * 0.09, w * 0.50, h * 0.16)
      ..cubicTo(w * 0.56, h * 0.09, w * 0.73, h * 0.13, w * 0.76, h * 0.30)
      ..cubicTo(w * 0.92, h * 0.34, w * 0.89, h * 0.56, w * 0.76, h * 0.57)
      ..lineTo(w * 0.76, h * 0.82)
      ..quadraticBezierTo(w * 0.76, h * 0.88, w * 0.70, h * 0.88)
      ..lineTo(w * 0.30, h * 0.88)
      ..quadraticBezierTo(w * 0.24, h * 0.88, w * 0.24, h * 0.82)
      ..close();

    canvas.drawPath(puff, stroke);

    // Hat band horizontal line
    canvas.drawLine(
      Offset(w * 0.25, h * 0.68),
      Offset(w * 0.75, h * 0.68),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChefHatPainter oldDelegate) =>
      oldDelegate.color != color;
}

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

typedef RecipeTextPreviewCallback =
    Future<List<ProcessedAiItem>> Function(String rawText);
typedef RecipeImagePreviewCallback =
    Future<List<ProcessedAiItem>> Function(
      EncodedImagePayload payload, {
      String? dishHint,
    });

class ImportRecipeResult {
  const ImportRecipeResult({
    required this.selectedItems,
    required this.sourceLabel,
  });

  final List<ProcessedAiItem> selectedItems;
  final String sourceLabel;
}

/// Interactive Pro recipe converter (`procesar-lista` with `is_recipe: true`):
/// Stage 1: type a dish/recipe or capture/upload a compressed photo (`<= 1024 px`).
/// Stage 2: review commercial Argentine packages + recipe notes with checkboxes
/// before saving selected items grouped by store & aisle.
class ImportRecipeSheet extends StatefulWidget {
  const ImportRecipeSheet({
    required this.mediaService,
    required this.onPreviewText,
    required this.onPreviewImage,
    super.key,
  });

  final MediaCaptureService mediaService;
  final RecipeTextPreviewCallback onPreviewText;
  final RecipeImagePreviewCallback onPreviewImage;

  static Future<ImportRecipeResult?> show({
    required BuildContext context,
    required MediaCaptureService mediaService,
    required RecipeTextPreviewCallback onPreviewText,
    required RecipeImagePreviewCallback onPreviewImage,
  }) {
    return showModalBottomSheet<ImportRecipeResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => ImportRecipeSheet(
        mediaService: mediaService,
        onPreviewText: onPreviewText,
        onPreviewImage: onPreviewImage,
      ),
    );
  }

  @override
  State<ImportRecipeSheet> createState() => _ImportRecipeSheetState();
}

class _ImportRecipeSheetState extends State<ImportRecipeSheet> {
  static const List<String> _quickExamples = <String>[
    'Flan casero para 6 personas',
    'Empanadas catamarqueñas',
    'Tarta de jamón y queso',
  ];

  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isAnalyzing = false;
  List<ProcessedAiItem>? _previewItems;
  Set<int> _selectedIndices = <int>{};
  String _sourceLabel = 'Receta importada';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorText = AppStrings.recipeEmptyError);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isAnalyzing = true;
      _errorText = null;
    });

    try {
      final items = await widget.onPreviewText(trimmed);
      if (!mounted) return;
      if (items.isEmpty) {
        setState(() {
          _isAnalyzing = false;
          _errorText = AppStrings.recipeNoItemsDetectedError;
        });
        return;
      }
      setState(() {
        _isAnalyzing = false;
        _previewItems = items;
        _selectedIndices = {for (var i = 0; i < items.length; i++) i};
        _sourceLabel = trimmed;
      });
    } on ShoppingActionException catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorText = e.message;
        });
      }
    } on AiClassifierException catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorText = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorText = AppStrings.genericProcessingError;
        });
      }
    }
  }

  Future<void> _analyzePhoto(ImageSource source) async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);

    EncodedImagePayload? payload;
    try {
      payload = await widget.mediaService.pickAndCompressImage(source);
    } on MediaGuardException catch (e) {
      if (mounted) {
        setState(() => _errorText = e.userMessage);
      }
      return;
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = AppStrings.genericProcessingError);
      }
      return;
    }

    if (payload == null || !mounted) return;

    setState(() {
      _isAnalyzing = true;
      _errorText = null;
    });

    try {
      final dishHint = _controller.text.trim();
      final items = await widget.onPreviewImage(
        payload,
        dishHint: dishHint.isEmpty ? null : dishHint,
      );
      if (!mounted) return;
      if (items.isEmpty) {
        setState(() {
          _isAnalyzing = false;
          _errorText = AppStrings.recipeNoItemsDetectedError;
        });
        return;
      }
      setState(() {
        _isAnalyzing = false;
        _previewItems = items;
        _selectedIndices = {for (var i = 0; i < items.length; i++) i};
        _sourceLabel = dishHint.isEmpty ? 'Receta desde foto' : dishHint;
      });
    } on ShoppingActionException catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorText = e.message;
        });
      }
    } on AiClassifierException catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorText = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorText = AppStrings.genericProcessingError;
        });
      }
    }
  }

  void _toggleIndex(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _toggleSelectAll() {
    final items = _previewItems;
    if (items == null) return;
    setState(() {
      if (_selectedIndices.length == items.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices = {for (var i = 0; i < items.length; i++) i};
      }
    });
  }

  void _confirmSelection() {
    final items = _previewItems;
    if (items == null || _selectedIndices.isEmpty) return;
    final selected = <ProcessedAiItem>[
      for (var i = 0; i < items.length; i++)
        if (_selectedIndices.contains(i)) items[i],
    ];
    Navigator.of(context).pop(
      ImportRecipeResult(selectedItems: selected, sourceLabel: _sourceLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final karritoColors = theme.extension<KarritoColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final previewItems = _previewItems;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: karritoColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: KarritoChefHatIcon(
                  size: 22,
                  color: karritoColors.onAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.importRecipeTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.importRecipeSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: karritoColors.textSecondary,
                        height: 1.32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isAnalyzing) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: karritoColors.fieldSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: karritoColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: karritoColors.accent),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.importRecipeAnalyzingLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (previewItems != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.importRecipePreviewHeading} (${_selectedIndices.length}/${previewItems.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _toggleSelectAll,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: karritoColors.accentSoft,
                  ),
                  child: Text(
                    _selectedIndices.length == previewItems.length
                        ? AppStrings.importRecipeClearAll
                        : AppStrings.importRecipeSelectAll,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: (MediaQuery.sizeOf(context).height * 0.44).clamp(
                  200.0,
                  380.0,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: previewItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = previewItems[index];
                  final isSelected = _selectedIndices.contains(index);
                  final packageLabel =
                      '${ShareService.formatQuantity(item.quantity)} ${item.unit}';
                  final note = item.recipeNote?.trim();

                  return Material(
                    color: isSelected
                        ? (isDark
                              ? karritoColors.aisleCardSurface
                              : karritoColors.fieldSurface)
                        : colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isSelected
                            ? karritoColors.accentSoft
                            : karritoColors.border,
                        width: isSelected ? 1.3 : 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _toggleIndex(index),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 10, 12, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: karritoColors.accent,
                              checkColor: karritoColors.onAccent,
                              onChanged: (_) => _toggleIndex(index),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.cleanName,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: colorScheme.onSurface,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                karritoColors.accentContainer,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            packageLabel,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: karritoColors
                                                      .onAccentContainer,
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${item.storeCategory} · ${item.aisleName}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: karritoColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (note != null && note.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: karritoColors.ctaContainer,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          'Receta: $note',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: karritoColors
                                                    .onCtaContainer,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _previewItems = null;
                        _selectedIndices.clear();
                      });
                    },
                    child: const Text(AppStrings.importRecipeBackToEdit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: KarritoBounceButton(
                    enabled: _selectedIndices.isNotEmpty,
                    child: FilledButton.icon(
                      onPressed: _selectedIndices.isEmpty
                          ? null
                          : _confirmSelection,
                      style: FilledButton.styleFrom(
                        backgroundColor: karritoColors.cta,
                        foregroundColor: karritoColors.onCta,
                      ),
                      icon: const Icon(
                        Icons.playlist_add_check_rounded,
                        size: 19,
                      ),
                      label: Text(
                        AppStrings.importRecipeAddSelected(
                          _selectedIndices.length,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const KarritoFieldLabel(AppStrings.importRecipeLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: AppStrings.importRecipeHint,
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _quickExamples.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    ActionChip(
                      backgroundColor: karritoColors.fieldSurface,
                      side: BorderSide(color: karritoColors.border),
                      shape: const StadiumBorder(),
                      label: Text(
                        _quickExamples[i],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _controller
                            ..text = _quickExamples[i]
                            ..selection = TextSelection.collapsed(
                              offset: _quickExamples[i].length,
                            );
                          _errorText = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'O subí la foto o captura de una receta',
              style: theme.textTheme.labelMedium?.copyWith(
                color: karritoColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _analyzePhoto(ImageSource.camera),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: karritoColors.fieldSurface,
                      side: BorderSide(color: karritoColors.border),
                    ),
                    icon: Icon(
                      Icons.photo_camera_outlined,
                      size: 18,
                      color: karritoColors.accentSoft,
                    ),
                    label: const Text(AppStrings.importRecipeCameraButton),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _analyzePhoto(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: karritoColors.fieldSurface,
                      side: BorderSide(color: karritoColors.border),
                    ),
                    icon: Icon(
                      Icons.photo_library_outlined,
                      size: 18,
                      color: karritoColors.accentSoft,
                    ),
                    label: const Text(AppStrings.importRecipeGalleryButton),
                  ),
                ),
              ],
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
                      onPressed: _analyzeText,
                      style: FilledButton.styleFrom(
                        backgroundColor: karritoColors.cta,
                        foregroundColor: karritoColors.onCta,
                      ),
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                      label: const Text(AppStrings.importRecipeSubmitButton),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
