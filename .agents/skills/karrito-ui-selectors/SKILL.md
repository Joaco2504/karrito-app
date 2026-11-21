---
name: karrito-ui-selectors
description: Estándar visual obligatorio de Karrito para menús desplegables, selectores y campos de formulario en Flutter y Next.js. Usar siempre al crear o editar pantallas con inputs, formularios o selectores de opciones.
---

# Estándar visual de selectores y campos de formulario en Karrito

Esta skill define las reglas obligatorias de diseño e interacción para todos los campos de texto, controles numéricos y menús desplegables de Karrito (en la app móvil Flutter y en el panel web Next.js), siguiendo la paleta oficial **60-30-10**.

## 1. Etiquetas fijas arriba del campo
- **Prohibido usar etiquetas flotantes** (`floatingLabelBehavior` en Flutter o labels que cortan el borde superior en formularios web).
- Toda etiqueta va fija **arriba del campo**, en línea independiente, con una separación inferior de `6 px` respecto al borde del control.
- Tipografía de etiqueta: `13 px`, peso medio (`FontWeight.w500` / `font-medium`), en texto secundario:
  - Modo claro: `#5B5449`
  - Modo oscuro: `#B5C2DF`
- Los textos visibles respetan `.agents/textos-app-es-ar.md` (voseo argentino, tipo oración, sin emojis).

## 2. Superficie, borde, radio y tamaño táctil (Paleta 60-30-10)
- Todo campo de texto, control numérico y selector debe tener un **fondo sólido diferenciado** del fondo de la pantalla y del fondo de tarjetas/modales:
  - Modo claro: pantalla 60% `#EEE3CC`, tarjeta/modal `#FFFFFF`, fondo de campo `#F8F2E6`, tinta/primario 30% `#151515`, acento 10% `#00C2B5` (con texto `#151515`).
  - Modo oscuro: pantalla 60% `#13285A`, tarjeta/modal `#1B3573`, fondo de campo `#22418A`, tinta/secundario 30% `#ECE6DC`, acento 10% `#FF5A12` (con texto `#13285A` en negrita para contraste AA).
- Borde visible continuo de `1 px`:
  - Modo claro: `#D8CCB4`
  - Modo oscuro: `#2E4E99`
  - En foco: `1.5–1.6 px` con color de acento (`#00C2B5` claro / `#FF5A12` oscuro).
- Esquinas redondeadas de `14 px` (`BorderRadius.circular(14)` / `rounded-[14px]`).
- Altura mínima táctil de **`48 px`** en todos los inputs y selectores (y alinear controles contiguos en una fila a la misma altura de `48 px`).

## 3. Selectores de opciones en Flutter (`KarritoSelectorField`)
- **Prohibido usar menús emergentes nativos** (`DropdownButton`, `DropdownButtonFormField`, `PopupMenuButton`) para elegir opciones como `Localidad`, `Unidad`, `Comercio` o `Pasillo`.
- Usar siempre el componente reutilizable `KarritoSelectorField` (`karrito_app/lib/ui/widgets/karrito_selector_field.dart`):
  - Al tocarlo, abre un `ModalBottomSheet` con esquinas superiores redondeadas (`24 px`), drag handle visible, fondo sólido (`#FFFFFF` claro / `#1B3573` oscuro) y título claro en tipo oración.
  - Lista opciones con área táctil cómoda (`>= 48 px` de alto, esquinas `14 px`).
  - La opción elegida se marca con fondo suave de completado y un **tilde verde** a la derecha (`#1E8E6E` en claro / `#38D39F` en oscuro).
  - Si un selector depende de otro (por ejemplo `Comercio` -> `Pasillo`), al cambiar el padre se actualiza automáticamente el hijo a su primera opción válida.

## 4. Interruptores (`SwitchThemeData`)
- Cuando un interruptor esté apagado (`false`), el riel debe mantenerse bien visible sobre tarjetas y modales:
  - Modo claro: riel `#E4D8C1`, borde visible `#C6B79B`, círculo contraste alto (`#5B5449`).
  - Modo oscuro: riel `#22418A`, borde visible `#4163B5`, círculo contraste alto (`#ECE6DC`).
- Encendido (`true`): riel de acento (`#00C2B5` claro / `#FF5A12` oscuro) sin borde, círculo `#151515` claro / `#13285A` oscuro.

## 5. Referencia para Next.js + Tailwind (`karrito_admin`)
- Mantener exactamente la misma anatomía: `<label>` fijo arriba (`text-[13px] font-medium`), trigger e inputs con `min-h-[48px] rounded-[14px] border` usando los mismos hex 60-30-10 de Karrito (`#EEE3CC`/`#151515`/`#00C2B5` en claro y `#13285A`/`#ECE6DC`/`#FF5A12` en oscuro) y un popover estilizado con ícono check `#1E8E6E` / `#38D39F` en la opción activa (evitando `<select>` nativos sin estilo cuando la lista supere 3 opciones o requiera búsqueda).
