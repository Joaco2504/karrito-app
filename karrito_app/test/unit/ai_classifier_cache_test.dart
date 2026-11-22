import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:karrito_app/data/models/procesar_lista_response.dart';
import 'package:karrito_app/data/services/ai_classifier_service.dart';
import 'package:karrito_app/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthService implements AuthService {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Session? get currentSession => null;

  @override
  String? get currentUserId => 'test-uid';

  @override
  bool get isAnonymous => true;

  @override
  String? get currentEmail => null;

  @override
  String? get currentPhotoUrl => null;

  @override
  String? get currentDisplayName => null;

  @override
  Stream<AuthState> get onAuthStateChange => _controller.stream;

  @override
  Future<bool> ensureSignedInSilently() async => true;

  @override
  Future<GoogleLinkOutcome?> linkOrSignInWithGoogle() async => null;

  @override
  Future<void> signOutToGuest() async {}

  void dispose() => _controller.close();
}

void main() {
  test(
    'AiResponseCache returns cached response within 30-min TTL, expires after 30 min, and evicts LRU entries',
    () {
      var now = DateTime.utc(2026, 11, 22, 12, 0, 0);
      final cache = AiResponseCache(
        maxEntries: 2,
        ttl: const Duration(minutes: 30),
        clock: () => now,
      );

      const respA = ProcesarListaResponse(
        items: <ProcessedAiItem>[
          ProcessedAiItem(
            cleanName: 'Papa',
            quantity: 2,
            unit: 'kg',
            storeCategory: 'Supermercado',
            aisleName: 'Verdulería y Frutería',
          ),
        ],
      );
      const respB = ProcesarListaResponse(
        items: <ProcessedAiItem>[
          ProcessedAiItem(
            cleanName: 'Leche',
            quantity: 1,
            unit: 'l',
            storeCategory: 'Supermercado',
            aisleName: 'Lácteos y Refrigerados',
          ),
        ],
      );
      const respC = ProcesarListaResponse(
        items: <ProcessedAiItem>[
          ProcessedAiItem(
            cleanName: 'Pan',
            quantity: 1,
            unit: 'kg',
            storeCategory: 'Supermercado',
            aisleName: 'Panadería',
          ),
        ],
      );

      cache.put('2 kg de Papá', respA);
      cache.put('1 l de leche', respB);

      // Normalized hit promotes A as most recently used.
      expect(cache.get('  2 KG de papa  '), same(respA));

      // Inserting C evicts B (least recently used), keeping A and C.
      cache.put('1 kg pan', respC);
      expect(cache.get('1 l de leche'), isNull);
      expect(cache.get('2 kg de papa'), same(respA));
      expect(cache.get('1 kg pan'), same(respC));

      // Advance clock past 30 minutes -> expired!
      now = now.add(const Duration(minutes: 31));
      expect(cache.get('2 kg de papa'), isNull);
    },
  );

  test(
    'SupabaseAiClassifierService avoids duplicate Edge Function calls for identical blocks within 30 minutes',
    () async {
      var now = DateTime.utc(2026, 11, 22, 12, 0, 0);
      final auth = _FakeAuthService();
      addTearDown(auth.dispose);

      var remoteCalls = 0;
      final service = SupabaseAiClassifierService(
        client: null,
        authService: auth,
        cache: AiResponseCache(clock: () => now),
        invoker: (text) async {
          remoteCalls++;
          return <String, dynamic>{
            'items': <Map<String, dynamic>>[
              <String, dynamic>{
                'clean_name': 'Fideos',
                'quantity': 2,
                'unit': 'paquete',
                'store_category': 'Supermercado',
                'aisle_name': 'Almacén',
              },
            ],
          };
        },
      );

      final first = await service.classifyText('2 paquetes de fideos');
      final second = await service.classifyText('  2  paquetes de FIDEOS ');

      expect(remoteCalls, 1);
      expect(first.items.single.cleanName, 'Fideos');
      expect(second.items.single.cleanName, 'Fideos');

      // After 31 minutes, cache expires and triggers a fresh invocation.
      now = now.add(const Duration(minutes: 31));
      await service.classifyText('2 paquetes de fideos');
      expect(remoteCalls, 2);
    },
  );
}
