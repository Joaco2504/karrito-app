---
name: karrito-ui-selectors
description: Estándar visual obligatorio de Karrito para menús desplegables, selectores y campos de formulario en Flutter y Next.js. Usar siempre al crear o editar pantallas con inputs, formularios o selectores de opciones.
---

# Estándar visual de selectores y campos de formulario en Karrito

Esta skill define las reglas obligatorias de diseño e interacción para todos los campos de texto, controles numéricos y menús desplegables de Karrito (en la app móvil Flutter y en el panel web Next.js), alineada con el sistema oficial **Electric Mercado** (`.agents/figma_ref/DESIGN.md`).

## 1. Etiquetas fijas arriba del campo
- **Prohibido usar etiquetas flotantes** (`floatingLabelBehavior` en Flutter o labels que cortan el borde superior en formularios web).
- Toda etiqueta va fija **arriba del campo**, en línea independiente, con una separación inferior de `6 px` respecto al borde del control.
- Tipografía de etiqueta: `13 px`, peso medio-seminegrita (`FontWeight.w600` / `font-semibold`), en texto secundario:
  - Modo claro: `#4A4454`
  - Modo oscuro: `#B9B0C9`
- Los textos visibles respetan `.agents/textos-app-es-ar.md` (voseo argentino, tipo oración, sin emojis).

## 2. Superficie, borde, radio y tamaño táctil (Electric Mercado)
- Todo campo de texto, control numérico y selector debe tener un **fondo sólido diferenciado** del fondo de la pantalla y del fondo de tarjetas/modales:
  - Modo claro: fondo base `#F9F8F6`, tarjeta/modal `#FFFFFF`, fondo de campo `#F2EFFB` (Tinted Lavender Oat), primario `#531CB3` (Deep Violet Berry), secundario/CTA `#FF6238` (Neon Papaya), terciario/fresco `#9AE600` (Electric Lime con texto `#13101E`).
  - Modo oscuro: fondo base `#0F0B1A`, tarjeta/modal `#1A1429`, fondo de campo `#251D38`, primario `#7438F5` (acento claro `#D1BCFF`), secundario/CTA `#FF6238` (texto `#13101E`), terciario/completado `#9AE600` (texto `#13101E`).
- Borde visible continuo de `1 px`:
  - Modo claro: `#D8D0E6`
  - Modo oscuro: `#352B4D`
  - En foco: `1.6 px` con color primario (`#531CB3` claro / `#9D6BFF` oscuro).
- Esquinas redondeadas de `16 px` (`BorderRadius.circular(16)` / `rounded-2xl`) en campos de formulario y píldora (`9999px`) en buscadores rápidos y botones principales.
- Altura mínima táctil de **`48 px`** en todos los inputs y selectores (y alinear controles contiguos en una fila a la misma altura).

## 3. Selectores de opciones en Flutter (`KarritoSelectorField`)
- **Prohibido usar menús emergentes nativos** (`DropdownButton`, `DropdownButtonFormField`, `PopupMenuButton`) para elegir opciones como `Localidad`, `Unidad`, `Comercio` o `Pasillo`.
- Usar siempre el componente reutilizable `KarritoSelectorField` (`karrito_app/lib/ui/widgets/karrito_selector_field.dart`):
  - Al tocarlo, abre un `ModalBottomSheet` con esquinas superiores redondeadas (`32 px`), drag handle visible, fondo sólido (`#FFFFFF` claro / `#1A1429` oscuro) y título claro en tipo oración.
  - Lista opciones con área táctil cómoda (`>= 48 px` de alto, esquinas `16 px`).
  - La opción elegida se marca con contenedor suave violeta/lima y un **tilde de alto contraste** a la derecha (`#315C00` en claro / `#9AE600` en oscuro).
  - Si un selector depende de otro (por ejemplo `Comercio` -> `Pasillo`), al cambiar el padre se actualiza automáticamente el hijo a su primera opción válida.

## 4. Interruptores (`SwitchThemeData`)
- Cuando un interruptor esté apagado (`false`), el riel debe mantenerse bien visible sobre tarjetas y modales:
  - Modo claro: riel `#E4DDF2`, borde visible `#BDB2D4`, círculo contraste alto (`#4A4454`).
  - Modo oscuro: riel `#251D38`, borde visible `#4E426E`, círculo contraste alto (`#E4DCF5`).
- Encendido (`true`): riel primario (`#531CB3` claro / `#7438F5` oscuro) sin borde, círculo `#FFFFFF`.

## 5. Referencia para Next.js + Tailwind (`karrito_admin`)
- Mantener exactamente la misma anatomía: `<label>` fijo arriba (`text-[13px] font-semibold`), trigger e inputs con `min-h-[48px] rounded-2xl border` usando los mismos tokens **Electric Mercado** (`#F9F8F6`/`#FFFFFF`/`#F2EFFB`/`#531CB3`/`#FF6238`/`#9AE600` en claro y `#0F0B1A`/`#1A1429`/`#251D38`/`#7438F5`/`#FF6238`/`#9AE600` en oscuro), tipografía `Plus Jakarta Sans`, tarjetas `rounded-3xl`, botones `rounded-full`, y popover estilizado con ícono check de alto contraste en la opción activa.
