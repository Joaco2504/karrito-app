---
name: karrito-ui-selectors
description: Estándar visual obligatorio de Karrito para menús desplegables, selectores y campos de formulario en Flutter y Next.js. Usar siempre al crear o editar pantallas con inputs, formularios o selectores de opciones.
---

# Estándar visual de selectores y campos de formulario en Karrito

Esta skill define las reglas obligatorias de diseño e interacción para todos los campos de texto, controles numéricos y menús desplegables de Karrito (en la app móvil Flutter desde Fase 2 y en el panel web Next.js desde Fase 4).

## 1. Etiquetas fijas arriba del campo
- **Prohibido usar etiquetas flotantes** (`floatingLabelBehavior` en Flutter o labels que cortan el borde superior en formularios web).
- Toda etiqueta va fija **arriba del campo**, en línea independiente, con una separación inferior de `6 px` respecto al borde del control.
- Tipografía de etiqueta: `13 px`, peso medio (`FontWeight.w500` / `font-medium`), en texto secundario:
  - Modo claro: `#6B6268`
  - Modo oscuro: `#A89DA4`
- Los textos visibles respetan `.agents/textos-app-es-ar.md` (voseo argentino, tipo oración, sin emojis).

## 2. Superficie, borde, radio y tamaño táctil
- Todo campo de texto, control numérico y selector debe tener un **fondo sólido diferenciado** del fondo de la pantalla y del fondo de tarjetas/modales:
  - Modo claro: fondo de campo `#F5F1EA` (contrasta con tarjeta/modal `#FFFFFF` y pantalla `#FAF7F2`).
  - Modo oscuro: fondo de campo `#2B2329` (contrasta con tarjeta/modal `#211B20` y pantalla `#141013`).
- Borde visible continuo de `1 px`:
  - Modo claro: `#E5DFD5`
  - Modo oscuro: `#362D33`
  - En foco: `1.5–1.6 px` con color primario (`#4E1A3D` claro / `#E08EC3` oscuro).
- Esquinas redondeadas de `14 px` (`BorderRadius.circular(14)` / `rounded-[14px]`).
- Altura mínima táctil de **`48 px`** en todos los inputs y selectores (y alinear controles contiguos en una fila a la misma altura de `48 px`).

## 3. Selectores de opciones en Flutter (`KarritoSelectorField`)
- **Prohibido usar menús emergentes nativos** (`DropdownButton`, `DropdownButtonFormField`, `PopupMenuButton`) para elegir opciones como `Localidad`, `Unidad`, `Comercio` o `Pasillo`.
- Usar siempre el componente reutilizable `KarritoSelectorField` (`karrito_app/lib/ui/widgets/karrito_selector_field.dart`):
  - Al tocarlo, abre un `ModalBottomSheet` con esquinas superiores redondeadas (`24 px`), drag handle visible, fondo sólido (`#FFFFFF` claro / `#211B20` oscuro) y título claro en tipo oración.
  - Lista opciones con área táctil cómoda (`>= 48 px` de alto, esquinas `12 px`).
  - La opción elegida se marca con fondo suave de completado y un **tilde verde** a la derecha (`#2B6E4E` en claro / `#5EC293` en oscuro).
  - Si un selector depende de otro (por ejemplo `Comercio` -> `Pasillo`), al cambiar el padre se actualiza automáticamente el hijo a su primera opción válida.

## 4. Interruptores (`SwitchThemeData`)
- Cuando un interruptor esté apagado (`false`), el riel debe mantenerse bien visible sobre tarjetas y modales:
  - Modo claro: riel `#EDE7DF`, borde visible `#D0C7BC`, círculo contraste alto (`#6B6268`).
  - Modo oscuro: riel `#2B2329`, borde visible `#4A3F46`, círculo contraste alto (`#D6CCD2`).
- Encendido (`true`): riel primario (`#4E1A3D` claro / `#E08EC3` oscuro) sin borde, círculo `#FFFFFF` claro / `#380D29` oscuro.

## 5. Referencia para Next.js + Tailwind (Fase 4)
- Mantener exactamente la misma anatomía: `<label>` fijo arriba (`text-[13px] font-medium`), trigger y inputs con `min-h-[48px] rounded-[14px] border` usando los mismos hex de Karrito y un popover/drawer estilizado con ícono check `#2B6E4E` / `#5EC293` en la opción activa (evitando `<select>` nativos sin estilo cuando la lista supere 3 opciones o requiera búsqueda).
