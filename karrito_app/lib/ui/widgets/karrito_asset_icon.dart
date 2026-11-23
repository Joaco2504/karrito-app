import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/store_visuals.dart';

/// Kind of domain icon resolved by [KarritoAssetIcon].
enum KarritoAssetIconKind { store, aisle }

/// Caches the bundled Flutter [AssetManifest] keys so [KarritoAssetIcon] and
/// [KarritoBrandLogo] only attempt `Image.asset(...)` when a designer PNG is
/// actually present in the bundle — zero exceptions or console warnings when
/// falling back to vector Material icons.
class KarritoAssetRegistry {
  KarritoAssetRegistry._();

  static Set<String>? _knownAssets;
  static Future<void>? _pendingLoad;
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static bool hasAsset(String assetPath) {
    final cached = _knownAssets;
    if (cached != null) {
      return cached.contains(assetPath);
    }
    unawaited(warmUp());
    return false;
  }

  static Future<void> warmUp([AssetBundle? bundle]) {
    if (_knownAssets != null) return Future<void>.value();
    return _pendingLoad ??= _load(bundle ?? rootBundle);
  }

  static Future<void> _load(AssetBundle bundle) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(bundle);
      _knownAssets = manifest.listAssets().toSet();
    } catch (_) {
      _knownAssets = <String>{};
    } finally {
      _pendingLoad = null;
      revision.value++;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _knownAssets = null;
    _pendingLoad = null;
    revision.value++;
  }

  @visibleForTesting
  static void setKnownAssetsForTest(Set<String> assets) {
    _knownAssets = Set<String>.from(assets);
    _pendingLoad = null;
    revision.value++;
  }
}

/// Loads a custom PNG icon from `assets/icons/stores/<slug>.png` or
/// `assets/icons/aisles/<slug>.png`, falling back cleanly to the semantic
/// Material vector icon from [StoreVisuals] whenever the PNG has not been
/// added yet.
class KarritoAssetIcon extends StatelessWidget {
  const KarritoAssetIcon.store(
    this.label, {
    super.key,
    this.size = 20,
    this.color,
    this.fallbackIcon,
  }) : kind = KarritoAssetIconKind.store;

  const KarritoAssetIcon.aisle(
    this.label, {
    super.key,
    this.size = 20,
    this.color,
    this.fallbackIcon,
  }) : kind = KarritoAssetIconKind.aisle;

  final String label;
  final KarritoAssetIconKind kind;
  final double size;
  final Color? color;
  final IconData? fallbackIcon;

  /// Converts any Spanish store or aisle label into a lowercase ASCII filename
  /// slug matching `assets/icons/stores/<slug>.png` or `assets/icons/aisles/<slug>.png`.
  static String slugify(String raw) {
    const accents = 'áéíóúüñÁÉÍÓÚÜÑ';
    const plain = 'aeiouunAEIOUUN';
    final buffer = StringBuffer();
    for (final rune in raw.trim().runes) {
      final ch = String.fromCharCode(rune);
      final idx = accents.indexOf(ch);
      buffer.write(idx >= 0 ? plain[idx] : ch);
    }
    return buffer
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String assetPathFor(KarritoAssetIconKind kind, String label) {
    final folder = kind == KarritoAssetIconKind.store ? 'stores' : 'aisles';
    return 'assets/icons/$folder/${slugify(label)}.png';
  }

  @override
  Widget build(BuildContext context) {
    final visual = kind == KarritoAssetIconKind.store
        ? StoreVisuals.forStore(label)
        : StoreVisuals.forAisle(label);
    final effectiveIcon = fallbackIcon ?? visual.icon;
    final effectiveColor = color ?? visual.color;
    final path = assetPathFor(kind, label);

    Widget buildFallback() =>
        Icon(effectiveIcon, size: size, color: effectiveColor);

    return ValueListenableBuilder<int>(
      valueListenable: KarritoAssetRegistry.revision,
      builder: (context, _, _) {
        if (!KarritoAssetRegistry.hasAsset(path)) {
          return buildFallback();
        }
        return Image.asset(
          path,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          semanticLabel: label,
          errorBuilder: (_, _, _) => buildFallback(),
        );
      },
    );
  }
}

/// Renders the horizontal Karrito brand logo in the top-left of the AppBar:
/// loads `assets/brand/logo_light.png` (light theme) or
/// `assets/brand/logo_dark.png` (dark theme) if bundled, and falls back
/// seamlessly to the Electric Mercado icon + "Karrito" wordmark.
class KarritoBrandLogo extends StatelessWidget {
  const KarritoBrandLogo({super.key, this.height = 30});

  final double height;

  static const String lightAssetPath = 'assets/brand/logo_light.png';
  static const String darkAssetPath = 'assets/brand/logo_dark.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final assetPath = isDark ? darkAssetPath : lightAssetPath;

    Widget buildFallback() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF8B5CF6), Color(0xFF531CB3)]
                    : const [Color(0xFF531CB3), Color(0xFF3A008C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              size: height * 0.58,
              color: isDark
                  ? (theme.extension<KarritoColors>()?.lime ??
                        const Color(0xFFCCFF00))
                  : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Karrito',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
            ),
          ),
        ],
      );
    }

    return ValueListenableBuilder<int>(
      valueListenable: KarritoAssetRegistry.revision,
      builder: (context, _, _) {
        if (!KarritoAssetRegistry.hasAsset(assetPath)) {
          return buildFallback();
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: height,
            maxWidth: height * 4.2,
          ),
          child: Image.asset(
            assetPath,
            height: height,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            filterQuality: FilterQuality.medium,
            semanticLabel: 'Karrito',
            errorBuilder: (_, _, _) => buildFallback(),
          ),
        );
      },
    );
  }
}
