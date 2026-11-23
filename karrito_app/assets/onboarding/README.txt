KARRITO — IMÁGENES DEL ONBOARDING (assets/onboarding/)
======================================================

Esta carpeta contiene las 3 imágenes visuales que se muestran en los pasos
de bienvenida (OnboardingScreen) de Karrito:

  - step_1.png  -> Paso 1: "Volcá todo mezclado" (entrada rápida / pegado)
  - step_2.png  -> Paso 2: "Separá por comercio y pasillo" (agrupación inteligente)
  - step_3.png  -> Paso 3: "Tachá en el súper sin señal" (modo offline en góndola)

Cómo reemplazarlas
------------------
El diseñador puede reemplazar cualquiera de estos 3 archivos por capturas de
pantalla reales de la app o fotografías de personas usando Karrito en el
supermercado, manteniendo exactamente el mismo nombre de archivo (`step_1.png`,
`step_2.png`, `step_3.png`).

Recomendaciones técnicas
------------------------
- Formato: PNG o WebP optimizado (recomendado PNG liviano <= 150 KB cada una
  para mantener el APK liviano).
- Relación de aspecto sugerida: 16:9 o 16:10 horizontal (por ejemplo 800 x 460 px
  o 960 x 540 px). La app las recorta automáticamente con `BoxFit.cover` dentro
  de un marco con bordes redondeados de 24 px y sombra suave.
- Fallback automático: si algún archivo falta o no puede decodificarse, Karrito
  muestra automáticamente la ilustración vectorial interactiva original sin
  errores ni espacios vacíos.
