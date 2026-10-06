---
name: Kinetic Volt
colors:
  surface: '#f9f9f9'
  surface-dim: '#dadada'
  surface-bright: '#f9f9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f4'
  surface-container: '#eeeeee'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e2e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#4b4731'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f0f1f1'
  outline: '#7c775f'
  outline-variant: '#cdc7aa'
  surface-tint: '#6a5f00'
  primary: '#6a5f00'
  on-primary: '#ffffff'
  primary-container: '#ffe600'
  on-primary-container: '#726600'
  inverse-primary: '#dec800'
  secondary: '#735c00'
  on-secondary: '#ffffff'
  secondary-container: '#fed01b'
  on-secondary-container: '#6f5900'
  tertiary: '#006a6a'
  on-tertiary: '#ffffff'
  tertiary-container: '#00feff'
  on-tertiary-container: '#007272'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#fde400'
  primary-fixed-dim: '#dec800'
  on-primary-fixed: '#201c00'
  on-primary-fixed-variant: '#504700'
  secondary-fixed: '#ffe083'
  secondary-fixed-dim: '#eec200'
  on-secondary-fixed: '#231b00'
  on-secondary-fixed-variant: '#574500'
  tertiary-fixed: '#00fbfc'
  tertiary-fixed-dim: '#00dcdd'
  on-tertiary-fixed: '#002020'
  on-tertiary-fixed-variant: '#004f50'
  background: '#f9f9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e2e2e2'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '800'
    lineHeight: 38px
    letterSpacing: -0.025em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: -0.01em
  label-md:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.02em
  label-caps:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.25rem
---

## Brand & Style

This design system drives a sleek, high-precision mobile authentication and onboarding experience. Designed to transform mundane credential entry into an electrifying, modern ritual, the aesthetic fuses deep chromatic contrast with razor-sharp editorial restraint. The primary emotional register is confident, rapid, and secure—reassuring users through solid, grounded architecture while propelling them forward with decisive energetic visual cues.

The aesthetic philosophy bridges **High-Contrast Minimalism** and **Tactile Precision**:
- **Canvas Architecture:** Immersive, clean canvases minimize distraction and create dramatic depth for high-luminosity accents.
- **Kinetic Voltage:** Intense electric yellow accents serve strictly as functional triggers—commanding action, indicating focused attention, and validating input completion.
- **Physical Feel & Micro-Feedback:** Floating inputs, smooth pills, subtle neon halos, and crisp hairline strokes provide the tactile responsiveness of modern physical hardware.

## Colors

The palette operates on high-stakes contrast, stripping away decorative mid-tones to focus attention on input capture and primary decisions.

- **Primary Accent (`#FFE600` / `#FACC15`):** Hyper-saturated, electric yellow. Reserved exclusively for primary conversion buttons, persistent focus indicators, validation badges, and high-impact active states. 
- **Deep Base Neutrals (`#FFFFFF`, `#18181B`, `#27272A`):** `#FFFFFF` serves as the canvas floor. `#18181B` provides elevated container surfaces (cards, sheets), while `#27272A` delivers tactile borders and inactive field strokes.
- **Typography & High-Contrast Elements:** Crisp styling establishes clear, legible headlines and primary user-entered values.
- **Subordinate Neutrals (`#A1A1AA`, `#71717A`):** Cool slate mid-tones reserved for placeholder strings, secondary disclaimers, unselected tabs, and tertiary navigation.
- **Functional Semantic Alerts:** Validation success relies on high-contrast icons. Error states use an unmistakable punchy crimson (`#FF3B30`), paired directly with clean explanatory copy.

## Typography

The type system pairs the punchy, geometric balance of **Plus Jakarta Sans** for display anchors with the clinical, structural neutrality of **Inter** for data capture, forms, and micro-copy.

- **Display & Section Headers:** Plus Jakarta Sans delivers tight geometric curves with aggressive negative letter-spacing, providing brand charisma without sacrificing rapid scanning.
- **Forms & Authentication Entry:** Inter provides open counters, tall x-height, and neutral figures, ensuring verification codes (OTP), passwords, and phone numbers remain crystal-clear at every screen scale.
- **Labeling & Caps:** Floating input labels and status tags use `label-caps` in tabular uppercase with increased tracking to anchor high-density form fields without visual clutter.

## Layout & Spacing

Authentication experiences require deliberate vertical momentum and zero layout ambiguity. Layouts rely on a strictly controlled single-column fluid frame centered within a safe 4-column mobile grid, transitioning to a maximum 440px constrained card frame on tablet or desktop web contexts.

- **Vertical Rhythm:** Screen construction employs `space-xl` (36px) to partition logical clusters (e.g., header cluster vs. input fields vs. social alternatives), and `space-md` (16px) between sequential form inputs.
- **Touch-First Tap Targets:** All interactive controls maintain a baseline minimum height of 52px to 56px, buffered by `space-sm` (8px) internal micro-spacing to ensure error-free thumb-zone interaction on edge-to-edge mobile screens.
- **Keyboard Handling & Inset Offsets:** Screen margins conform strictly to dynamic virtual keyboard frames. Key CTA pill buttons pin securely above the active keyboard with `space-md` bottom margin offsets.

## Elevation & Depth

Visual hierarchy is maintained through layered surface containment, subtle edge highlights, and luminous focal glow, eliminating heavy dropshadows in favor of crisp layering.

- **Base Floor (`#FFFFFF`):** Zero-elevation backdrop.
- **Tier 1 Card Surface (`#18181B`):** Elevated modals, bottom sheets, and grouped authentication panels use a 1px solid hairline border (`#27272A`) to define boundaries against the base floor.
- **Input & Recessed Controls (`#121215`):** Inputs sink into card surfaces with a slightly darker fill, creating a carved, tactile appearance bordered by subtle outlines.
- **Active Focus Ring (The "Kinetic Halo"):** When an input field gains focus, its border transitions immediately to `#FFE600`, accompanied by a diffused, low-spread ambient glow: `0 0 0 1px #FFE600, 0 0 20px -2px rgba(255, 230, 0, 0.35)`.
- **Primary Pill Glow:** Action-ready primary buttons feature an under-glow matching the accent hue: `0 8px 24px -4px rgba(255, 230, 0, 0.35)`.

## Shapes

The shape architecture relies on an intentional contrast between structural card containers and tactile, fully rounded interactive pills.

- **Interactive Primary Elements:** All buttons, badges, chips, and segmented pills utilize continuous full curvature (`roundedness: 1` / soft style). This provides immediate visual signposting for actionable tap areas.
- **Containers & Sheet Surfaces:** Modal sheets, authentication card surfaces, and social-auth groupings utilize `rounded-2xl` (20px to 24px) to create smooth, polished boundaries.
- **Form Inputs:** Fields feature generous `rounded-xl` (14px to 16px) corners, sitting comfortably between structural sheets and fully pill-shaped trigger buttons.

## Components

### Primary Buttons
- **Style:** Full pill geometry (`rounded-full`), height 56px, filled with bright energetic yellow (`#FFE600`).
- **Typography:** Inter SemiBold (`label-lg`), colored in pitch black (`#09090B`).
- **Interaction:** Under-glow of `0 8px 24px -4px rgba(255, 230, 0, 0.35)`. Pressed state transitions fill to `#FACC15` with a scale down to `0.98`. Disabled state settles on `#27272A` surface with muted `#71717A` label.

### Secondary & Social Auth Buttons
- **Style:** 52px pill with `#18181B` surface and a 1px border of `#27272A`.
- **Typography:** Pure crisp white (`#FFFFFF`) with 20px monochrome icons (Apple, Google, Passkey) aligned left.
- **States:** Hover/Touch-down brightens stroke to `#71717A`.

### Floating Label Input Fields
- **Architecture:** 58px tall recessed box (`#121215`), 14px rounded corners, hairline 1px border (`#27272A`).
- **Floating Mechanism:** Idle placeholder sits centered at `body-md` in `#71717A`. Upon focus or data presence, the label scales to `label-caps` in `#FFE600` and floats into the upper padding (top: 8px).
- **Active State:** Border transitions to `#FFE600` with the signature kinetic yellow halo. Trailing utilities use minimalist 20px strokes in `#A1A1AA`.

### Verification Code (OTP) Slots
- **Structure:** 6 standalone 52px × 64px vertical rectangular slots with 12px corners.
- **Styling:** Recessed `#121215` fill. Active slot displays a 2px `#FFE600` perimeter border with an animated blinking yellow cursor line. Entered numbers render in Plus Jakarta Sans at 24px bold (`#FFFFFF`).

### Authentication Cards & Bottom Sheets
- **Geometry:** `rounded-2xl` (24px) for desktop/tablet cards; rounded top edges (28px) for mobile bottom sheets.
- **Surface:** `#18181B` with 1px border `#27272A`. Header includes a 36px wide × 4px tall grab handle pill in `#3F3F46` centered at the top rim.

### Checkboxes & Segmented Radio Switches
- **Checkboxes:** 20px rounded squares (6px radius) with `#27272A` outline. Checked state triggers an instant `#FFE600` fill with a sharp pitch-black check icon.
- **Biometric / Passkey Prompt Tile:** High-contrast contextual tile featuring a 44px pill container with `#FFE600` icon, crisp white title, slate subtitle, and right-facing minimalist chevron.