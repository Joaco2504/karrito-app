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
  static const String onboardingCard1Title = 'Volcá todo mezclado';
  static const String onboardingCard1Body =
      'Escribí o pegá lo que necesitás en un renglón, aunque juntes comida, remedios y tornillos.';
  static const String onboardingCard1Example =
      '2 kg de papa, leche, 10 tornillos, ibuprofeno';
  static const String onboardingCard2Title = 'Separá por comercio y pasillo';
  static const String onboardingCard2Body =
      'Karrito agrupa cada producto en su rubro y lo ordena según los pasillos reales de tu local.';
  static const String onboardingCard2Example =
      'Supermercado: Verdulería y Lácteos  ·  Ferretería: Fijaciones';
  static const String onboardingCard3Title = 'Tachá en el súper sin señal';
  static const String onboardingCard3Body =
      'Tus listas quedan guardadas en el teléfono. Tachá en la góndola aunque se corte internet y sincronizá al volver.';
  static const String onboardingCard3Example =
      'Funciona offline con pantalla siempre encendida';
  static const String onboardingNextButton = 'Siguiente';
  static const String onboardingBackButton = 'Anterior';
  static const String onboardingSkipButton = 'Saltar';
  static const String startShoppingButton = 'Empezar a armar mi lista';
  static const String onboardingGoogleButton =
      'Ingresar con mi cuenta de Google';
  static const String saveGuideButton = 'Volver a la app';
  static const String onboardingFooterNote =
      'Podés entrar directo como invitado o sincronizar tus listas con Google.';

  // Main shopping screen
  static const String listSelectorTooltip = 'Elegir lista';
  static const String switchToLightTooltip = 'Cambiar a modo claro';
  static const String switchToDarkTooltip = 'Cambiar a modo oscuro';
  static const String newListTitle = 'Nueva lista';
  static const String newListHint = 'Ej: Asado del domingo';
  static const String renameListTitle = 'Renombrar lista';
  static const String createListButton = 'Crear lista';
  static const String saveListButton = 'Guardar nombre';
  static const String deleteListButton = 'Borrar lista';
  static const String maxListsReached =
      'Ya tenés 3 listas propias activas. Borrá una para crear otra nueva.';
  static String maxListsReachedForLimit(int limit) =>
      'Ya llegaste al tope de $limit listas propias de tu plan. Borrá una o pasate a un plan superior para sumar más.';
  static const String cannotDeleteLastList =
      'Necesitás al menos una lista activa. Creá otra antes de borrar esta.';
  static String deleteListConfirmBody(String title) =>
      'Se va a borrar "$title" junto con todos sus productos guardados.';
  static String leaveSharedListConfirmBody(String title) =>
      'Vas a salir de la lista compartida "$title". Podés volver a entrar después con el código.';

  static const String inputHint =
      'Escribí o pegá lo que te falta (ej: 2 kg de papa, leche, 10 tornillos)';
  static const String addItemsButton = 'Agregar';
  static const String frequentButton = 'Frecuentes';
  static const String reorderAislesButton = 'Ordenar pasillos';
  static const String processingItemsLabel = 'Ordenando tu lista...';

  static const String wakelockOnTooltip = 'Pantalla encendida activada';
  static const String wakelockOffTooltip = 'Mantener pantalla encendida';
  static const String shareListTooltip = 'Compartir lista';
  static const String settingsTooltip = 'Abrir ajustes';
  static const String profileMenuTooltip = 'Abrir menú de perfil';

  // Profile menu & Guide/FAQ
  static const String profileMenuTitle = 'Tu perfil';
  static const String profileAvatarPickerLabel = 'Elegí tu avatar';
  static const String profileGooglePhotoLabel = 'Foto de Google';
  static const String profilePreferencesOption = 'Preferencias';
  static const String profilePreferencesSubtitle =
      'Tema, localidad, sonido, vibración y respaldo.';
  static const String profileGuideFaqOption =
      'Guía básica y preguntas frecuentes';
  static const String profileGuideFaqSubtitle =
      'Tutorial paso a paso y respuestas rápidas sobre Karrito.';
  static const String profileSignOutOption = 'Cerrar sesión';
  static const String profileSignOutSubtitle =
      'Pasás a modo invitado sin borrar tus listas guardadas.';
  static const String profileSignInGoogleOption = 'Ingresar con Google';
  static const String profileSignInGoogleSubtitle =
      'Respaldá y sincronizá tus listas en la nube.';
  static const String signedOutNotice =
      'Cerraste sesión. Seguís en modo invitado con todas tus listas guardadas en este teléfono.';
  static const String guideFaqTitle = 'Guía básica y preguntas frecuentes';
  static const String guideTutorialSectionTitle = 'Cómo aprovechar Karrito';

  // Aisle reordering
  static const String reorderAislesTitle = 'Ordenar pasillos';
  static String reorderAislesSubtitle(String store) =>
      'Arrastrá los pasillos de $store en el orden en que recorrés tu local.';
  static const String reorderResetButton = 'Orden habitual';
  static const String reorderMovingBadge = 'Moviendo';
  static const String reorderNoItemsBadge = 'Sin ítems';
  static String reorderInListBadge(int count) => '$count en lista';
  static const String reorderTipTitle = 'Recorrido por comercio';
  static const String reorderTipBody =
      'Karrito recuerda este orden por separado para cada comercio sin mezclar tus locales.';
  static const String saveOrderButton = 'Guardar orden';
  static String reorderSuccessNotice(String store) =>
      'Guardamos tu orden de pasillos para $store.';

  // Frequent items sheet
  static const String frequentItemsTitle = 'Productos frecuentes';
  static const String frequentItemsSubtitle =
      'Sumá tus compras habituales en un toque sin gastar consultas.';
  static const String frequentSearchLabel = 'Buscar producto frecuente';
  static const String frequentSearchHint =
      'Escribí para filtrar tu lista habitual';
  static const String frequentEmptyTitle =
      'Todavía no tenés productos frecuentes';
  static const String frequentEmptyBody =
      'Cada producto que cargues se guarda acá para sumarlo después sin gastar consultas.';
  static const String frequentNoMatches =
      'No encontramos productos frecuentes con ese nombre.';
  static const String removeFrequentTooltip = 'Quitar de frecuentes';
  static String addedFromFrequentNotice(String name) =>
      'Sumamos "$name" desde tus frecuentes.';
  static const String frequentAddedBadge = 'Agregado';
  static const String frequentDoneButton = 'Listo, volver a la lista';
  static String frequentSessionCount(int count) =>
      count == 1 ? '1 agregado' : '$count agregados';
  static const String doneButton = 'Listo';

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
  static const String liveListBadge = 'En vivo';

  // Item actions & edit sheet
  static const String editItemTitle = 'Editar producto';
  static const String itemNameLabel = 'Producto';
  static const String itemNameHint = 'Ej: Papa negra';
  static const String itemQuantityLabel = 'Cantidad';
  static const String itemUnitLabel = 'Unidad';
  static const String itemStoreLabel = 'Comercio';
  static const String itemAisleLabel = 'Pasillo';
  static const String selectCityTitle = 'Elegí tu localidad';
  static const String selectUnitTitle = 'Elegí la unidad';
  static const String selectStoreTitle = 'Elegí el comercio';
  static const String selectAisleTitle = 'Elegí el pasillo';
  static const String saveShortButton = 'Guardar';
  static const String removeShortButton = 'Quitar';
  static const String saveItemButton = 'Guardar cambios';
  static const String deleteItemButton = 'Quitar de la lista';
  static String deleteItemConfirmBody(String name) =>
      'Se va a quitar "$name" de esta lista.';
  static const String cancelButton = 'Cancelar';
  static const String deleteButton = 'Borrar';

  // Share formatting & collaborative live lists
  static const String shareEmptyListError =
      'Tu lista no tiene productos pendientes para compartir. Agregá algo o destachá un ítem.';
  static const String shareHeader = 'Lista de compras - Karrito';
  static const String shareRemainingCheckedNote =
      'Solo se incluyeron los productos que faltan comprar.';
  static const String shareOptionsTitle = 'Compartir y colaborar';
  static const String shareAsTextOption = 'Enviar lista por WhatsApp';
  static const String shareAsTextSubtitle =
      'Manda los productos pendientes agrupados por comercio y pasillo.';
  static const String shareLiveOption = 'Compartir lista en vivo';
  static const String shareLiveSubtitle =
      'Generá un código de 6 caracteres y un QR para tachar juntos al instante.';
  static const String shareJoinOption = 'Unirme a una lista';
  static const String shareJoinSubtitle =
      'Ingresá un código de 6 caracteres o escaneá el QR de otra persona.';
  static const String joinWithCodeButton = 'Unirme a una lista';
  static const String joinSheetTitle = 'Unirme a una lista';
  static const String joinCodeLabel = 'Código de 6 caracteres';
  static const String joinCodeHint = 'Ej: K7M4P9';
  static const String joinSubmitButton = 'Unirme';
  static const String scanQrButton = 'Escanear código QR';
  static const String qrScannerTitle = 'Escanear código QR';
  static const String qrScannerHint =
      'Apuntá la cámara al código QR de la lista compartida.';
  static const String qrScannerInvalidCode =
      'Ese código QR no corresponde a una lista de Karrito. Probá con otro QR o escribí el código a mano.';
  static const String qrScannerPermissionError =
      'No pudimos abrir la cámara. Habilitá el permiso de cámara en tu teléfono o ingresá el código de 6 caracteres a mano.';
  static const String qrScannerTorchTooltip = 'Encender o apagar linterna';
  static const String liveQrCaption =
      'Escaneá este QR desde Karrito para unirte al instante';
  static const String invalidShareCodeError =
      'Escribí un código válido de 6 letras o números para unirte a la lista.';
  static const String liveOfflineError =
      'No tenés conexión a internet ahora. Probá de nuevo cuando vuelva la señal para usar listas en vivo.';
  static const String liveShareTitle = 'Lista compartida en vivo';
  static const String liveShareSubtitle =
      'Mostrá este QR o pasale el código a quien haga las compras con vos para tachar productos al instante.';
  static const String shareCodeLabel = 'Código para compartir';
  static const String copyCodeButton = 'Copiar código';
  static const String codeCopiedNotice = 'Código copiado para compartir.';
  static const String sendInviteButton = 'Enviar por WhatsApp';
  static const String proLiveSheetTitle = 'Listas en vivo en el plan Pro';
  static const String proLiveSheetBody =
      'Crear listas colaborativas en vivo con código compartido forma parte del plan Pro (\$ 3 USD por mes). Igual podés unirte gratis a la lista de otra persona si te pasan un código.';
  static const String proLiveUnderstandButton = 'Entendido';
  static String liveJoinedNotice(String title) =>
      'Te uniste a "$title". Ya podés ver y tachar productos en vivo.';
  static String liveInviteMessage(String title, String code) =>
      'Sumate a mi lista "$title" en vivo en Karrito. Entrá a Tus listas -> Unirme con código e ingresá: $code';
  static const String guestShareSuggestionTitle = 'Respaldá tus listas';
  static const String guestShareSuggestionBody =
      'Estás usando modo invitado. Si vinculás tu cuenta de Google en Ajustes no perdés tus listas ni tu orden de pasillos si cambiás de teléfono.';
  static const String goToSettingsButton = 'Ir a Ajustes';

  // Google account & cloud sync
  static const String cloudBackupSection = 'Cuenta y respaldo';
  static const String guestAccountTitle = 'Modo invitado';
  static const String guestAccountSubtitle =
      'Vinculá tu Google para guardar tus listas, pasillos y frecuentes en la nube y recuperarlos en otro celular.';
  static const String linkedAccountTitle = 'Cuenta vinculada con Google';
  static const String linkGoogleButton = 'Vincular con Google';
  static const String linkingGoogleLabel = 'Vinculando cuenta...';
  static const String syncNowButton = 'Sincronizar ahora';
  static const String syncingNowLabel = 'Sincronizando...';
  static const String googleLinkedNotice =
      'Cuenta vinculada. Ya respaldamos tus listas, pasillos y frecuentes.';
  static const String googleLinkedSyncPendingNotice =
      'Cuenta vinculada con Google. Tocá Sincronizar ahora cuando mejore la señal para subir el respaldo.';
  static const String googleOfflineError =
      'No pudimos vincular tu cuenta porque no hay conexión a internet. Probá cuando vuelva la señal.';
  static const String googleTokenError =
      'No pudimos completar la verificación con Google. Probá de nuevo en unos segundos.';
  static const String syncCompletedNotice =
      'Sincronización completa con tu cuenta.';
  static const String syncFailedError =
      'No pudimos sincronizar ahora. Tus cambios siguen seguros en el teléfono y se suben cuando mejore la señal.';
  static String syncFailedWithRef(String? refCode) {
    final trimmed = refCode?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return syncFailedError;
    }
    return '$syncFailedError (Ref: $trimmed)';
  }

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
  static const String settingsAppearanceSection = 'Apariencia y pantalla';
  static const String settingsLocationSection = 'Localidad';
  static const String settingsShoppingSection = 'Preferencias de compra';
  static const String settingsGeneralSection = 'Preferencias';
  static const String settingsAppearanceLabel = 'Tema de la app';
  static const String themeSystemLabel = 'Sistema';
  static const String themeLightLabel = 'Claro';
  static const String themeDarkLabel = 'Oscuro';
  static const String settingsKeepScreenOnTitle = 'Mantener pantalla encendida';
  static const String settingsKeepScreenOnSubtitle =
      'Evita que el teléfono se bloquee mientras recorrés las góndolas.';
  static const String settingsSoundOnCheckTitle = 'Sonido al tachar';
  static const String settingsSoundOnCheckSubtitle =
      'Reproduce un pulso corto y limpio cuando tachás un producto.';
  static const String settingsVibrationOnCheckTitle = 'Vibración al tachar';
  static const String settingsVibrationOnCheckSubtitle =
      'Acompaña cada producto tachado con una vibración breve.';
  static const String settingsActiveBadge = 'Activo';
  static const String settingsLocalBadge = 'Local';
  static const String settingsNoBackupBadge = 'Sin respaldo';
  static const String settingsBackedUpBadge = 'Respaldada';
  static const String settingsCityHelper =
      'Usamos tu localidad para adaptar la experiencia a los comercios de tu zona.';
  static const String settingsGuideTitle = 'Guía inicial';
  static const String settingsGuideSubtitle =
      'Volvé a ver cómo cargar y ordenar productos.';
  static const String settingsViewGuideButton = 'Ver guía';
  static const String settingsFooterNote =
      'Karrito · Pensado para hacer las compras sin vueltas.';
  static const String editItemSubtitle = 'Corregí cantidad, comercio o pasillo';
  static const String editItemLearnTip =
      'Si cambiás el comercio o el pasillo, Karrito lo recuerda para tu próxima compra.';

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
      question: '¿Para qué sirve vincular mi cuenta de Google?',
      answer:
          'Si vinculás tu Google en Ajustes, tus listas, pasillos ordenados y productos frecuentes se sincronizan con la nube. Así no perdés nada si cambiás de celular.',
    ),
    (
      question: '¿Puedo unirme gratis a una lista compartida en vivo?',
      answer:
          'Sí. Si otra persona con plan Pro comparte un código de 6 caracteres, podés tocar "Unirme a una lista" desde Compartir o el selector de listas y tachar productos en vivo con cuenta gratuita o en modo invitado.',
    ),
  ];

  // Phase 5: Local ads cascade & interstitial
  static const String sponsoredLocalBadge = 'Comercio local auspiciado';
  static const String regionalOfferBadge = 'Oferta regional';
  static String adSkipIn(int seconds) => 'Saltar en ${seconds}s';
  static const String adCloseButton = 'Cerrar';
  static const String adOpenOfferCta = 'Ver oferta del comercio';
  static const String adWhatsAppCta = 'Pedir por WhatsApp al comercio';
  static const String adMapsCta = 'Cómo llegar con Google Maps';
  static const String adUpsellTitle = '¿Querés comprar sin anuncios?';
  static const String adUpsellSubtitle =
      'Pasate a Karrito Básico o Pro desde \$ 2 USD/mes.';
  static const String adViewPlansButton = 'Ver planes';

  // Phase 5: Subscriptions & PlansScreen (monthly only, no annual option)
  static const String plansTitle = 'Planes y suscripciones';
  static const String plansSubtitle =
      'Elegí el plan mensual que mejor se adapte a tus compras.';
  static const String profilePlansOption = 'Planes y suscripciones';
  static const String profilePlansSubtitle =
      'Quitá anuncios y desbloqueá voz, fotos, recetas y calculadora.';
  static const String planFreeName = 'Plan Gratis';
  static const String planBasicName = 'Plan Básico';
  static const String planProName = 'Plan Pro';
  static const String planMostChosenBadge = 'Más elegido';
  static const String planCurrentBadge = 'Tu plan actual';
  static const String planActiveOnDevice = 'Activo en este dispositivo';
  static const String chooseBasicButton = 'Elegir Plan Básico';
  static const String chooseProButton = 'Elegir Plan Pro';
  static const String restorePurchasesButton = 'Restaurar compras';
  static const String plansUpgradeButton = 'Subir de plan';
  static const String plansTrustNote =
      'Cobro mensual administrado desde Google Play Store. Sin plan anual ni cargos ocultos; podés cancelar cuando quieras.';

  // Phase 5: Pro features (Voice, Photo/Screenshot, Recipes/Projects, Cart Calculator)
  static const String voiceInputTooltip = 'Dictar lista por voz';
  static const String voiceRecordingTitle = 'Escuchando tu dictado...';
  static const String voiceStopAndSendButton = 'Enviar dictado';
  static const String voiceLimitHint = 'Máximo 60 segundos · audio M4A liviano';
  static const String scanPhotoTooltip = 'Escanear foto o captura';
  static const String scanSourceTitle = 'Escanear lista con foto';
  static const String scanCameraOption = 'Sacar foto a lista en papel';
  static const String scanCameraSubtitle =
      'Ideal para notas escritas a mano o listas en la heladera.';
  static const String scanGalleryOption =
      'Elegir captura de WhatsApp o galería';
  static const String scanGallerySubtitle =
      'Seleccioná una captura de pantalla o foto guardada.';
  static const String proMediaOfflineError =
      'Necesitás conexión a internet para procesar audios, fotos o recetas con IA. Probá de nuevo cuando vuelva la señal.';
  static const String importRecipeButton = 'Receta';
  static const String importRecipeTitle = 'Importar receta o proyecto';
  static const String importRecipeSubtitle =
      'Pegá los ingredientes de una comida o los materiales de un arreglo y Karrito los agrupa por comercio.';
  static const String importRecipeLabel = 'Receta o lista de materiales';
  static const String importRecipeHint =
      'Ej: Para empanadas catamarqueñas: 1 kg carne picada, 1 kg cebolla, comino, pimentón, 2 docenas tapas...';
  static const String importRecipeSubmitButton = 'Importar a la lista';
  static const String recipeEmptyError =
      'Pegá el texto de una receta o proyecto para poder extraer los productos.';

  // Phase 5: Cart price calculator & monthly expenses
  static const String cartPriceLabel = 'Precio en ARS (opcional)';
  static const String cartPriceHint = 'Ej: 3.800';
  static const String cartPutPriceButton = 'Precio';
  static const String cartPriceDialogTitle = 'Anotar precio';
  static const String cartTotalModeLabel = 'Precio total del ítem';
  static const String cartUnitModeLabel = 'Por unidad (multiplica cantidad)';
  static const String cartClearPriceButton = 'Quitar precio';
  static const String cartStoreSubtotalLabel = 'Comercio actual';
  static const String cartTotalLabel = 'Total carrito';
  static const String cartCloseAndSaveButton = 'Cerrar compra y guardar gasto';
  static const String cartMonthlyHistoryButton = 'Gastos del mes';
  static const String cartMonthlyHistoryTitle = 'Gastos del mes';
  static const String cartMonthlyBudgetLabel = 'Presupuesto mensual (ARS)';
  static const String cartAdjustBudgetButton = 'Ajustar tope';
  static const String cartNoPricesToSaveError =
      'Anotá el precio en al menos un producto para guardar el gasto de esta compra.';
  static String cartExpenseSavedNotice(String totalLabel) =>
      'Compra cerrada. Guardamos $totalLabel en tus gastos del mes.';
  static const String cartHistoryEmptyTitle =
      'Todavía no guardaste compras este mes';
  static const String cartHistoryEmptyBody =
      'Anotá los precios mientras comprás y tocá "Cerrar compra y guardar gasto" para llevar el control mensual.';

  // Phase 5: Account & privacy deletion (Google Play requirement)
  static const String accountPrivacySection = 'Cuenta y privacidad';
  static const String deleteAccountButton = 'Eliminar mi cuenta y mis datos';
  static const String deleteAccountSubtitle =
      'Borra permanentemente tu perfil en la nube, tus listas, pasillos, frecuentes e historial en este teléfono.';
  static const String deleteAccountDialogTitle = 'Eliminar cuenta y datos';
  static const String deleteAccountDialogBody =
      'Se van a borrar de forma permanente tu cuenta, tus listas, tus pasillos personalizados, tus productos frecuentes y tu historial de gastos, tanto en la nube como en este teléfono. Esta acción no se puede deshacer.';
  static const String deleteAccountConfirmButton = 'Sí, eliminar todo';
  static const String deletingAccountLabel = 'Eliminando cuenta...';
  static const String accountDeletedNotice =
      'Eliminamos tu cuenta y tus datos. Seguís en modo invitado con una lista nueva.';
}
