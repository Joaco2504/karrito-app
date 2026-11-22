---
name: Electric Mercado
colors:
  surface: '#13121b'
  surface-dim: '#13121b'
  surface-bright: '#3a3842'
  surface-container-lowest: '#0e0d16'
  surface-container-low: '#1c1a24'
  surface-container: '#201e28'
  surface-container-high: '#2a2933'
  surface-container-highest: '#35343e'
  on-surface: '#e5e0ee'
  on-surface-variant: '#cbc3d7'
  inverse-surface: '#e5e0ee'
  inverse-on-surface: '#312f39'
  outline: '#958ea0'
  outline-variant: '#494454'
  surface-tint: '#d0bcff'
  primary: '#d0bcff'
  on-primary: '#3c0091'
  primary-container: '#a078ff'
  on-primary-container: '#340080'
  inverse-primary: '#6d3bd7'
  secondary: '#ffb4a1'
  on-secondary: '#611300'
  secondary-container: '#b22c02'
  on-secondary-container: '#ffcdc1'
  tertiary: '#abd600'
  on-tertiary: '#283500'
  tertiary-container: '#7c9c00'
  on-tertiary-container: '#222e00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#23005c'
  on-primary-fixed-variant: '#5516be'
  secondary-fixed: '#ffdbd2'
  secondary-fixed-dim: '#ffb4a1'
  on-secondary-fixed: '#3c0800'
  on-secondary-fixed-variant: '#881f00'
  tertiary-fixed: '#c3f400'
  tertiary-fixed-dim: '#abd600'
  on-tertiary-fixed: '#161e00'
  on-tertiary-fixed-variant: '#3c4d00'
  background: '#13121b'
  on-background: '#e5e0ee'
  surface-variant: '#35343e'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.04em
  display-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.03em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 34px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: 0em
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.015em
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.5rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style
The design system channels the sensory overload of a midnight street market synthesized through an ultra-modern digital lens. It merges deep AMOLED darkness with electric, high-chroma illumination—radiating vitality, speed, and street-smart commerce. Tailored for mobile-first, hyper-connected urban traders, consumers, and marketplace navigators who expect fluid interaction and instantaneous visual feedback.

The aesthetic philosophy is an intersection of **Tactile High-Contrast Cyber-Streetwear** and **Native Android Material 3 (Expressive)**:
- High-saturation neon accents pierce through velvety, deep purple-tinted night surfaces.
- Ambient luminescence replaces traditional grey drop shadows, making key transactional and discovery touchpoints feel charged and interactive.
- Tactile pill containers, deliberate micro-interactions, and punchy typography evoke street signage, digital receipts, and neon marquees.

## Colors
The palette leverages a four-tiered dark surface architecture infused with subtle violet undertones, preventing optical flattening and providing rich native depth for OLED displays.

### Role Allocation & Vibrancy Hierarchy
- **Surfaces & Grounds**:
  - `surface-base` (`#12111a`): Pure backdrop for navigation bars, full-screen canvasses, and root viewports.
  - `surface-container-low` (`#161422`): Recessed shelves, card groupings, and app bar backgrounds.
  - `surface-container` (`#1e1b29`): Default standard card surface, listing tiles, bottom sheets.
  - `surface-container-high` (`#252135`): Elevated floating dialogs, floating quick-actions, active filter pills.
- **Electric Accents**:
  - **Primary (Electric Violet - `#8b5cf6` / `#a855f7`)**: Expresses transactional power, checkout actions, identity badges, and high-frequency toggles.
  - **Secondary (Neon Papaya - `#ff6238`)**: Hot deals, limited-quantity countdowns, dynamic badges, cart counters, and alerts.
  - **Tertiary (Neon Lime - `#ccff00` / `#a3e635`)**: Positive price deltas, live status indicators, verification tags, and micro-affirmations.
- **Typography & Scrims**:
  - Text Primary: `#f8fafc` (high-contrast crisp white/slate).
  - Text Secondary: `#94a3b8` (muted street slate).
  - Text Tertiary / Disabled: `#64748b`.
  - Outline / Borders: `rgba(139, 92, 246, 0.2)` for active stroke highlights; `rgba(255, 255, 255, 0.08)` for subtle panel separators.

## Typography
The system juxtaposes the technical, hyper-stylized character of **Space Grotesk** with the ergonomic readability of **Plus Jakarta Sans**. 

- **Display & Headlines (Space Grotesk)**: Geometric, angled terminals evoke electronic marketplace displays, pricing boards, and dynamic ticker items. Use uppercase styling selectively for badges and tags using `label-sm`.
- **Body & Captions (Plus Jakarta Sans)**: Ensures instant clarity for product descriptions, seller reviews, inventory terms, and numerical specifications.
- **Scale Adaptation**: On mobile devices (<600dp), large hero headers shrink dynamically according to mobile-token definitions to retain structural density without awkward multi-line hyphenations.

## Layout & Spacing
Designed for native Material 3 view hierarchies with an emphasis on single-handed thumb-reach zones.

### Grid & Layout Structure
- **Mobile (<600dp)**: 4-column fluid layout with `0.75rem` (12dp) gutters and `1rem` (16dp) screen margins. Elements adhere strictly to vertical baseline rhythmic steps of 4dp and 8dp.
- **Tablet / Expanded Foldables (600dp - 1024dp)**: 8-column layout with `1rem` gutters and `1.5rem` margins; transforms single-column feeds into staggered visual masonry grids.
- **Desktop / Web Experience (>1024dp)**: 12-column layout centered with max width of 1280dp, `1.5rem` gutters, and auto margins.

### Vertical Density & Rhythm
Card internal padding adheres to `space-md` (16dp) for standard listings and `space-sm` (8dp) for compact market tickers. Touch targets strictly respect Android accessibility standards at a minimum bounding footprint of 48×48dp, even when visual pills are slimmer.

## Elevation & Depth
Depth avoids sterile neutral grey blurs in favor of chromatic nocturnal illumination and stepped tonal architecture.

### Tonal Tiers (Material 3 Surface Hierarchy)
Visual lift is achieved primarily through progressive brightening of violet-dark surfaces:
- **Level 0 (Canvas Base)**: `#12111a`
- **Level 1 (Docked Panels & Shelves)**: `#161422` with a 1px border of `rgba(255, 255, 255, 0.05)`
- **Level 2 (Cards & Listing Units)**: `#1e1b29`
- **Level 3 (Modal Sheets & Snackbars)**: `#252135`

### Neon Atmospheric Glows (Electric Halos)
Floating elements use soft, saturated glows instead of shadow falloffs:
- **Primary Glow**: `0px 10px 30px rgba(139, 92, 246, 0.28)` for primary pill CTA buttons and active cart floating bars.
- **Papaya Alert Glow**: `0px 8px 24px rgba(255, 98, 56, 0.35)` for flash promotions and live countdown triggers.
- **Lime Accent Glow**: `0px 4px 16px rgba(204, 255, 0, 0.22)` for instant checkout and confirmed status tags.

## Shapes
A definitive pill-shaped design language (`roundedness: 3`) brings tactile sleekness to the electric night atmosphere.

- **Extreme Pill Radii (Full 9999px / `rounded-full`)**: Applied to all interactive buttons, search bars, category selector chips, numeric tags, and input search capsules.
- **Compound Card Radii (`rounded-xl` / 2rem ~ 32dp)**: Product cards, merchant highlight sheets, and bottom navigation sheets use soft rounded contours that seamlessly balance the strict pill-shaped micro-elements housed within them.
- **Floating Modals & Bottom Sheets**: Top corners terminate in an ultra-smooth 2rem radius curve with a centered pill-shaped drag handle (32×4dp in `rgba(255, 255, 255, 0.2)`).

## Components

### Buttons
- **Primary Action (Electric Violet CTA)**: Pill container filled with `#8b5cf6`, crisp `#ffffff` text (`label-lg`), and neon violet halo on press. Active state shifts background to `#a855f7` with slight inward optical compression (scale: 0.98).
- **Flash / Urgent CTA (Papaya)**: Pill container filled with `#ff6238`, text in `#12111a`, paired with immediate visual emphasis.
- **Outlined / Ghost**: High-contrast pill outlined in `1.5px solid rgba(139, 92, 246, 0.5)` with transparent background and slate-white text.

### Chips & Filter Pills
- Fully rounded pills (`height: 36dp`).
- Unselected: Surface `#1e1b29` with `rgba(255, 255, 255, 0.08)` stroke and `#94a3b8` label.
- Selected: Tinted `#8b5cf6` at 15% opacity with `1.5px solid #8b5cf6` border and `#f8fafc` label; optional electric lime indicator dot.

### Cards & Marketplace Items
- Constructed using `surface-container` (`#1e1b29`) with `rounded-xl` (2rem) geometry and subtle top hairline border (`1px solid rgba(255, 255, 255, 0.06)`).
- Images clip inside the upper frame with an integrated 12% bottom dark gradient for smooth contrast falloff into product titles.
- Embedded pricing pill: Embedded in `#12111a` capsule displaying `#ccff00` numeric figures.

### Input Fields & Search Bars
- Pill search capsule (`height: 52dp`) with `#161422` fill and full pill bounds.
- Placeholder styled in `#64748b`; input text in high-contrast `#f8fafc`.
- Leading search icon in `#8b5cf6`; trailing clear/voice mic in `#ccff00`.
- Focused state activates a continuous `1.5px` border glow in `#8b5cf6`.

### Checkboxes, Radios & Switches
- **Switch**: M3 wide pill track (`#161422` unselected, `#8b5cf6` selected) with a `#ccff00` (Lime) thumb toggle in selected state to provide electric visual contrast.
- **Checkbox / Radio**: `#8b5cf6` boundary fill when marked, housing a solid white or pitch-black tick icon for maximum glyph sharpness.

### Marketplace-Specific: Live Bidding / Flash Bar
- Fixed bottom docked island pill (`margin: 1rem`) utilizing `surface-container-high` (`#252135`) with dual-neon indicators: pulsing `#ff6238` countdown badge on the left, paired with an instant "Swipe to Buy" violet capsule slider on the right.