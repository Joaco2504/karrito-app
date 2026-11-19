/// Visible UI strings in Argentine Spanish (es-AR, Catamarca tone).
/// Rules enforced per `.agents/textos-app-es-ar.md`:
/// - Always voseo (vos, tenés, podés, elegí, tocá, escribí).
/// - Sentence-case headings.
/// - No emojis in UI copy, buttons, or system messages.
/// - Errors state what happened, why, and the concrete action to take.
class AppStrings {
  AppStrings._();

  static const String appName = 'Karrito';

  // Onboarding
  static const String onboardingHeadline = 'Armá tu compra por pasillo';
  static const String onboardingSubtitle =
      'Elegí tu localidad para empezar. Después podés cambiarla en Ajustes.';
  static const String cityLabel = 'Localidad';
  static const String onboardingCard1Title = 'Cargá todo junto';
  static const String onboardingCard1Body =
      'Escribí o pegá lo que necesitás en un renglón, aunque mezcles comida con cosas de ferretería.';
  static const String onboardingCard2Title = 'Separá por comercio';
  static const String onboardingCard2Body =
      'Karrito agrupa cada producto en su rubro y lo ordena según los pasillos habituales.';
  static const String onboardingCard3Title = 'Tachá en la góndola';
  static const String onboardingCard3Body =
      'Tocá un ítem para marcarlo como listo. Si algo quedó mal ubicado, mantenelo apretado y corregilo.';
  static const String startShoppingButton = 'Empezar lista';
  static const String saveGuideButton = 'Volver a la app';

  // Main shopping screen
  static const String listSelectorTooltip = 'Elegir lista';
  static const String newListTitle = 'Nueva lista';
  static const String newListHint = 'Ej: Asado del domingo';
  static const String renameListTitle = 'Renombrar lista';
  static const String createListButton = 'Crear lista';
  static const String saveListButton = 'Guardar nombre';
  static const String deleteListButton = 'Borrar lista';
  static const String maxListsReached =
      'Ya tenés 3 listas activas. Borrá una para crear otra nueva.';
  static const String cannotDeleteLastList =
      'Necesitás al menos una lista activa. Creá otra antes de borrar esta.';
  static String deleteListConfirmBody(String title) =>
      'Se va a borrar "$title" junto con todos sus productos guardados.';

  static const String inputHint =
      'Escribí o pegá lo que te falta (ej: 2 kg de papa, leche, 10 tornillos)';
  static const String addItemsButton = 'Agregar';
  static const String processingItemsLabel = 'Ordenando tu lista...';

  static const String wakelockOnTooltip = 'Pantalla encendida activada';
  static const String wakelockOffTooltip = 'Mantener pantalla encendida';
  static const String shareListTooltip = 'Compartir lista';
  static const String settingsTooltip = 'Abrir ajustes';

  // Connection & pending AI banner
  static const String offlineBannerTitle = 'Estás sin señal';
  static const String offlineBannerBody =
      'Lo que cargues queda guardado en el teléfono. Cuando vuelva internet se ordena solo.';
  static String pendingAiBanner(int count) => count == 1
      ? 'Tenés 1 producto guardado sin conexión listo para ordenar.'
      : 'Tenés $count productos guardados sin conexión listos para ordenar.';
  static const String reprocessNowButton = 'Ordenar ahora';
  static const String retryingPendingLabel = 'Ordenando pendientes...';

  // Empty state & list sections
  static const String emptyListTitle = 'Tu lista todavía está vacía';
  static const String emptyListBody =
      'Escribí arriba lo que necesitás comprar, por ejemplo "pan, lavandina y foco led", y tocá Agregar.';
  static String pendingCountBadge(int pending, int total) => '$pending/$total';
  static const String allCheckedInStore =
      'Ya tachaste todo lo de este comercio.';
  static const String pendingOfflineBadge = 'Sin señal';

  // Item actions & edit sheet
  static const String editItemTitle = 'Editar producto';
  static const String itemNameLabel = 'Producto';
  static const String itemQuantityLabel = 'Cantidad';
  static const String itemUnitLabel = 'Unidad';
  static const String itemStoreLabel = 'Comercio';
  static const String itemAisleLabel = 'Pasillo';
  static const String saveItemButton = 'Guardar cambios';
  static const String deleteItemButton = 'Quitar de la lista';
  static String deleteItemConfirmBody(String name) =>
      'Se va a quitar "$name" de esta lista.';
  static const String cancelButton = 'Cancelar';
  static const String deleteButton = 'Borrar';

  // Share formatting
  static const String shareEmptyListError =
      'Tu lista no tiene productos pendientes para compartir. Agregá algo o destachá un ítem.';
  static const String shareHeader = 'Lista de compras - Karrito';
  static const String shareRemainingCheckedNote =
      'Solo se incluyeron los productos que faltan comprar.';

  // Errors & feedback
  static const String emptyInputError =
      'Escribí al menos un producto arriba para poder agregarlo a la lista.';
  static const String invalidItemNameError =
      'El nombre del producto no puede quedar vacío. Escribí cómo querés llamarlo.';
  static const String invalidListNameError =
      'Escribí un nombre corto para identificar la lista.';
  static const String localSavedNotice =
      'Listo, sumado desde tus productos frecuentes.';
  static String addedItemsNotice(int total, {int? fromLocal}) {
    if (fromLocal != null && fromLocal == total) {
      return total == 1
          ? 'Producto agregado al instante desde tu historial.'
          : 'Agregamos $total productos al instante desde tu historial.';
    }
    return total == 1
        ? 'Agregamos 1 producto a tu lista.'
        : 'Agregamos $total productos a tu lista.';
  }

  static const String savedOfflineNotice =
      'No hay señal ahora. Lo guardamos en el teléfono bajo "Sin clasificar (sin señal)" para ordenarlo cuando vuelva internet.';
  static const String reprocessSuccessNotice =
      'Listo, ordenamos los productos que estaban esperando señal.';
  static const String wakelockEnabledNotice =
      'Pantalla encendida activada para la compra.';
  static const String wakelockDisabledNotice =
      'Pantalla encendida desactivada.';

  static const String dailyLimitError =
      'Alcanzaste las 5 cargas con IA de hoy en el plan gratuito. Los productos que ya cargaste antes siguen entrando al instante, o podés probar de nuevo mañana.';
  static const String networkFallbackError =
      'No pudimos conectarnos con el servidor en este momento. Guardamos tus productos en el teléfono para no perderlos.';
  static const String genericProcessingError =
      'No pudimos ordenar esa carga ahora. Probá separarla por comas o revisá tu conexión e intentá de nuevo.';

  // Settings screen
  static const String settingsTitle = 'Ajustes';
  static const String settingsGeneralSection = 'Preferencias';
  static const String settingsAppearanceLabel = 'Tema de la app';
  static const String themeSystemLabel = 'Según el teléfono';
  static const String themeLightLabel = 'Claro';
  static const String themeDarkLabel = 'Oscuro';
  static const String settingsKeepScreenOnTitle = 'Mantener pantalla encendida';
  static const String settingsKeepScreenOnSubtitle =
      'Evita que el teléfono se bloquee mientras recorrés las góndolas.';
  static const String settingsGuideTitle = 'Guía inicial';
  static const String settingsGuideSubtitle =
      'Volvé a ver cómo cargar y ordenar productos.';
  static const String settingsViewGuideButton = 'Ver guía';

  // FAQ
  static const String faqSectionTitle = 'Preguntas frecuentes';
  static const List<({String question, String answer})>
  faqEntries = <({String question, String answer})>[
    (
      question: '¿Funciona si me quedo sin señal en el súper?',
      answer:
          'Sí. Todas tus listas y productos están guardados en el teléfono. Podés tachar, editar y agregar productos conocidos sin conexión. Si escribís algo nuevo sin internet, queda guardado en "Sin clasificar (sin señal)" y se ordena solo apenas recuperás señal.',
    ),
    (
      question: '¿Cómo aprende Karrito mis correcciones?',
      answer:
          'Cada vez que movés un producto a otro pasillo o comercio desde el menú de edición, la app recuerda tu preferencia. La próxima vez que lo cargues va directo adonde vos elegiste, sin gastar consultas.',
    ),
    (
      question: '¿Por qué a veces no usa el límite diario?',
      answer:
          'Cuando escribís productos simples separados por comas que ya cargaste antes, Karrito los reconoce desde la memoria local del teléfono y los agrega en el acto.',
    ),
    (
      question: '¿Cómo mantengo la pantalla prendida mientras compro?',
      answer:
          'Tocá el ícono de pantalla arriba en tu lista o activalo acá en Ajustes. Así no tenés que desbloquear el teléfono en cada pasillo.',
    ),
  ];
}
