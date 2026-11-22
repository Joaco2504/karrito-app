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
  - Modo oscuro: `#CBC3D7`
- Los textos visibles respetan `.agents/textos-app-es-ar.md` (voseo argentino, tipo oración, sin emojis).

## 2. Superficie, borde, radio y tamaño táctil (Electric Mercado 1 & 2)
- Todo campo de texto, control numérico y selector debe tener un **fondo sólido diferenciado** del fondo de la pantalla y del fondo de tarjetas/modales:
  - Modo claro (`electric_mercado_1/DESIGN.md`): fondo base `#FDF7FF`, tarjeta/modal `#FFFFFF`, contenedor pasillo `#F8F1FF`, fondo de campo `#F2EBFF`, primario `#531CB3` (Deep Violet Berry; profundo `#3A008C`), secundario/CTA `#FF6238` (Neon Papaya, contenedor `#FFDBD2`, texto `#FFFFFF`), terciario/fresco `#ABF926` (Electric Lime con texto `#111F00`, tinta legible `#314D00`).
  - Modo oscuro AMOLED (`electric_mercado_2/DESIGN.md`): fondo base `#12111A`, contenedor pasillo `#161422`, tarjeta/modal `#1E1B29`, fondo de campo `#252135`, primario `#8B5CF6` (Electric Violet, acento claro `#D0BCFF`, focus `#A078FF`), secundario/CTA `#FF6238` (texto `#FFFFFF`, acento suave `#FFB4A1`), terciario/completado `#CCFF00` (Neon Lime con texto `#161E00`, tinta `#ABD600`).
- Borde visible continuo de `1 px`:
  - Modo claro: `#CBC3D6`
  - Modo oscuro: `#494454`
  - En foco: `1.6 px` con color primario (`#531CB3` claro / `#A078FF` oscuro).
- Esquinas redondeadas de `16–18 px` (`BorderRadius.circular(18)` / `rounded-2xl`) en campos de formulario y píldora (`9999px`) en buscadores rápidos y botones principales.
- Altura mínima táctil de **`48 px`** en todos los inputs y selectores (y alinear controles contiguos en una fila a la misma altura).

## 3. Selectores de opciones en Flutter (`KarritoSelectorField`)
- **Prohibido usar menús emergentes nativos** (`DropdownButton`, `DropdownButtonFormField`, `PopupMenuButton`) para elegir opciones como `Localidad`, `Unidad`, `Comercio` o `Pasillo`.
- Usar siempre el componente reutilizable `KarritoSelectorField` (`karrito_app/lib/ui/widgets/karrito_selector_field.dart`):
  - Al tocarlo, abre un `ModalBottomSheet` con esquinas superiores redondeadas (`32 px`), drag handle visible, fondo sólido (`#FFFFFF` claro / `#1E1B29` oscuro) y título claro en tipo oración.
  - Lista opciones con área táctil cómoda (`>= 48 px` de alto, esquinas `16 px`).
  - La opción elegida se marca con contenedor suave lima y un **tilde de alto contraste** a la derecha (`#314D00` en claro / `#CCFF00` en oscuro).
  - Si un selector depende de otro (por ejemplo `Comercio` -> `Pasillo`), al cambiar el padre se actualiza automáticamente el hijo a su primera opción válida.

## 4. Interruptores (`SwitchThemeData`)
- Cuando un interruptor esté apagado (`false`), el riel debe mantenerse bien visible sobre tarjetas y modales:
  - Modo claro: riel `#E6DFF4`, borde visible `#CBC3D6`, círculo contraste alto (`#4A4454`).
  - Modo oscuro: riel `#161422`, borde visible `#494454`, círculo contraste alto (`#E5E0EE`).
- Encendido (`true`): riel primario (`#531CB3` claro con círculo `#FFFFFF`; `#8B5CF6` oscuro con círculo `#CCFF00`) sin borde.

## 5. Referencia para Next.js + Tailwind (`karrito_admin`)
- Mantener exactamente la misma anatomía: `<label>` fijo arriba (`text-[13px] font-semibold`), trigger e inputs con `min-h-[48px] rounded-2xl border` usando los mismos tokens **Electric Mercado 1 & 2** (`#FDF7FF`/`#FFFFFF`/`#F2EBFF`/`#531CB3`/`#FF6238`/`#ABF926` en claro y `#12111A`/`#1E1B29`/`#252135`/`#8B5CF6`/`#FF6238`/`#CCFF00` en oscuro), tipografía `Space Grotesk` (títulos) + `Plus Jakarta Sans` (cuerpo), tarjetas `rounded-3xl`, botones `rounded-full`, y popover estilizado con ícono check de alto contraste en la opción activa.
