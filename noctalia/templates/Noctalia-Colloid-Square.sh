#!/bin/bash
# Noctalia Template — Colloid-Square-Dark GTK Theme
# Dynamically recolors the Colloid GTK theme based on wallpaper colors.
#
# Noctalia renders this template with Mustache variables and executes
# the output via post_hook.

set -euo pipefail

# ── Colors from Noctalia ──────────────────────────────────────────────
PRIMARY="{{colors.primary.default.hex}}"
ON_PRIMARY="{{colors.on_primary.default.hex}}"
SURFACE="{{colors.surface.default.hex}}"
ON_SURFACE="{{colors.on_surface.default.hex}}"
SURFACE_CONTAINER="{{colors.surface_container.default.hex}}"
SURFACE_CONTAINER_LOW="{{colors.surface_container_low.default.hex}}"
SURFACE_CONTAINER_HIGH="{{colors.surface_container_high.default.hex}}"
SURFACE_CONTAINER_LOWEST="{{colors.surface_container_lowest.default.hex}}"
OUTLINE_VARIANT="{{colors.outline_variant.default.hex}}"
ERROR="{{colors.error.default.hex}}"
ON_ERROR="{{colors.on_error.default.hex}}"
SECONDARY="{{colors.secondary.default.hex}}"
ON_SECONDARY="{{colors.on_secondary.default.hex}}"
TERTIARY="{{colors.tertiary.default.hex}}"
ON_TERTIARY="{{colors.on_tertiary.default.hex}}"
INVERSE_SURFACE="{{colors.inverse_surface.default.hex}}"
INVERSE_ON_SURFACE="{{colors.inverse_on_surface.default.hex}}"
SHADOW="{{colors.shadow.default.hex}}"
PRIMARY_CONTAINER="{{colors.primary_container.default.hex}}"
ON_PRIMARY_CONTAINER="{{colors.on_primary_container.default.hex}}"
SECONDARY_CONTAINER="{{colors.secondary_container.default.hex}}"
ON_SECONDARY_CONTAINER="{{colors.on_secondary_container.default.hex}}"
ON_SURFACE_VARIANT="{{colors.on_surface_variant.default.hex}}"
MODE="{{mode}}"

# ── Paths ─────────────────────────────────────────────────────────────
THEME_DIR="$HOME/.themes/Colloid-Square-Dark"
GTK3_CSS="$THEME_DIR/gtk-3.0/gtk.css"
GTK3_DARK="$THEME_DIR/gtk-3.0/gtk-dark.css"
GTK4_CSS="$THEME_DIR/gtk-4.0/gtk.css"
GTK4_DARK="$THEME_DIR/gtk-4.0/gtk-dark.css"
GTK3_BASE="$THEME_DIR/gtk-3.0/gtk.css.base"
GTK3_DARK_BASE="$THEME_DIR/gtk-3.0/gtk-dark.css.base"
GTK4_BASE="$THEME_DIR/gtk-4.0/gtk.css.base"
GTK4_DARK_BASE="$THEME_DIR/gtk-4.0/gtk-dark.css.base"
GTK3_USER_NOCTALIA="$HOME/.config/gtk-3.0/noctalia.css"
GTK4_USER_NOCTALIA="$HOME/.config/gtk-4.0/noctalia.css"
GTK3_USER_CSS="$HOME/.config/gtk-3.0/gtk.css"
GTK4_USER_CSS="$HOME/.config/gtk-4.0/gtk.css"
STATE_FILE="$HOME/.cache/noctalia/colloid-accent-state"
DECORATION_LAYOUT=":minimize,maximize,close"
# Match the specificity of Colloid's GTK4 window-control reset rules.
GTK4_CONTROL='windowcontrols > button:not(.raised):not(.suggested-action):not(.destructive-action):not(.opaque)'

# Colloid's default colors
DEFAULT_ACCENT="#5b9bf8"
DEFAULT_ACCENT_RGB="91, 155, 248"
DEFAULT_BG="#0F0F0F"
DEFAULT_HEADER_BG="#030303"
DEFAULT_PANEL_BG="#121212"

# ── Helper: hex to RGB ───────────────────────────────────────────────
hex_to_rgb() {
    local hex="${1#\#}"
    printf "%d, %d, %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

mkdir -p "$(dirname "$STATE_FILE")" "$(dirname "$GTK3_USER_CSS")" "$(dirname "$GTK4_USER_CSS")"

NEW_ACCENT_RGB="$(hex_to_rgb "$PRIMARY")"
NEW_FOREGROUND_RGB="$(hex_to_rgb "$ON_SURFACE")"

# Match the square SVG controls used by Halley, with the current palette.
for gtk_version in 3.0 4.0; do
    for control in minimize maximize close; do
        case "$control" in
            minimize) control_color="$PRIMARY" ;;
            maximize) control_color="$SECONDARY" ;;
            close) control_color="$ERROR" ;;
        esac
        cat > "$THEME_DIR/gtk-$gtk_version/assets/noctalia-halley-$control.svg" << SVGEOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16">
  <rect x="4" y="4" width="8" height="8" fill="$control_color" />
</svg>
SVGEOF
    done
done

# ── 1. GTK3: Replace hardcoded accent & background colors in theme CSS
for css_file in "$GTK3_CSS" "$GTK3_DARK"; do
    base_file="${css_file}.base"
    if [[ -f "$base_file" ]]; then
        cp "$base_file" "$css_file"
    fi

    # Replace hex accent color
    sed -i "s/${DEFAULT_ACCENT}/${PRIMARY}/gi" "$css_file"
    sed -i "s/rgba(${DEFAULT_ACCENT_RGB}/rgba(${NEW_ACCENT_RGB}/g" "$css_file"
    sed -i "s/#315486/${PRIMARY_CONTAINER}/gi" "$css_file"
    sed -i "s/#8cb9fa/${SECONDARY}/gi" "$css_file"
    sed -i "s/#5bd3f8/${TERTIARY}/gi" "$css_file"

    # Replace hardcoded dark background colors with Noctalia surface palette
    sed -i "s/${DEFAULT_BG}/${SURFACE}/gi" "$css_file"
    sed -i "s/${DEFAULT_HEADER_BG}/${SURFACE_CONTAINER}/gi" "$css_file"
    sed -i "s/${DEFAULT_PANEL_BG}/${SURFACE_CONTAINER_LOW}/gi" "$css_file"
    sed -i "s/#FFFFFF/${ON_SURFACE}/gi" "$css_file"
    sed -i "s/rgba(255, 255, 255/rgba(${NEW_FOREGROUND_RGB}/g" "$css_file"

    # Override @define-color in theme CSS
    sed -i "s/@define-color theme_selected_bg_color .*;/@define-color theme_selected_bg_color ${PRIMARY};/" "$css_file"
    sed -i "s/@define-color theme_unfocused_selected_bg_color .*;/@define-color theme_unfocused_selected_bg_color ${PRIMARY};/" "$css_file"
    sed -i "s/@define-color theme_bg_color .*;/@define-color theme_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_fg_color .*;/@define-color theme_fg_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_base_color .*;/@define-color theme_base_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_text_color .*;/@define-color theme_text_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_selected_fg_color .*;/@define-color theme_selected_fg_color ${ON_PRIMARY};/" "$css_file"
    sed -i "s/@define-color theme_unfocused_selected_fg_color .*;/@define-color theme_unfocused_selected_fg_color ${ON_PRIMARY};/" "$css_file"
    sed -i "s/@define-color theme_unfocused_fg_color .*;/@define-color theme_unfocused_fg_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_unfocused_text_color .*;/@define-color theme_unfocused_text_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_unfocused_bg_color .*;/@define-color theme_unfocused_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color theme_unfocused_base_color .*;/@define-color theme_unfocused_base_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color insensitive_bg_color .*;/@define-color insensitive_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color insensitive_base_color .*;/@define-color insensitive_base_color ${SURFACE_CONTAINER_LOW};/" "$css_file"
    sed -i "s/@define-color borders .*;/@define-color borders ${OUTLINE_VARIANT};/" "$css_file"
    sed -i "s/@define-color unfocused_borders .*;/@define-color unfocused_borders ${OUTLINE_VARIANT};/" "$css_file"
    sed -i "s/@define-color warning_color .*;/@define-color warning_color ${TERTIARY};/" "$css_file"
    sed -i "s/@define-color error_color .*;/@define-color error_color ${ERROR};/" "$css_file"
    sed -i "s/@define-color success_color .*;/@define-color success_color ${SECONDARY};/" "$css_file"
    sed -i "s/@define-color wm_bg .*;/@define-color wm_bg ${SURFACE_CONTAINER};/" "$css_file"
    sed -i "s/@define-color wm_unfocused_bg .*;/@define-color wm_unfocused_bg ${SURFACE};/" "$css_file"
    sed -i "s/@define-color wm_border .*;/@define-color wm_border ${OUTLINE_VARIANT};/" "$css_file"
    sed -i "s/@define-color content_view_bg .*;/@define-color content_view_bg ${SURFACE};/" "$css_file"
    sed -i "s/@define-color text_view_bg .*;/@define-color text_view_bg ${SURFACE};/" "$css_file"

    # Ensure border-radius stays 0
    sed -i -E 's/border-radius:[^;]+;/border-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-top-left-radius:[^;]+;/border-top-left-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-top-right-radius:[^;]+;/border-top-right-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-bottom-left-radius:[^;]+;/border-bottom-left-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-bottom-right-radius:[^;]+;/border-bottom-right-radius: 0px;/g' "$css_file"
    sed -i -E 's/-gtk-outline-radius:[^;]+;/-gtk-outline-radius: 0px;/g' "$css_file"
done

# ── 2. GTK3: User-level noctalia.css override ────────────────────────
cat > "$GTK3_USER_NOCTALIA" << CSSEOF
/*
 * Noctalia GTK3 Color Overrides for Colloid-Square-Dark
 * Generated by Noctalia's Template Processor
 */

@define-color theme_selected_bg_color   ${PRIMARY};
@define-color theme_selected_fg_color   ${ON_PRIMARY};
@define-color accent_color              ${PRIMARY};
@define-color accent_bg_color           ${PRIMARY};
@define-color accent_fg_color           ${ON_PRIMARY};

@define-color theme_bg_color            ${SURFACE};
@define-color theme_fg_color            ${ON_SURFACE};
@define-color theme_base_color          ${SURFACE};
@define-color theme_text_color          ${ON_SURFACE};

@define-color theme_tooltip_bg_color    ${INVERSE_SURFACE};
@define-color theme_tooltip_fg_color    ${INVERSE_ON_SURFACE};

@define-color menu_bg_color             ${SURFACE_CONTAINER};
@define-color menu_fg_color             ${ON_SURFACE};
@define-color menuitem_hover_bg_color   ${SURFACE_CONTAINER_HIGH};

@define-color headerbar_bg_color        ${SURFACE};
@define-color headerbar_fg_color        ${ON_SURFACE};

@define-color borders                   ${OUTLINE_VARIANT};
@define-color theme_unfocused_border_color ${OUTLINE_VARIANT};

@define-color error_color               ${ERROR};
@define-color warning_color             ${TERTIARY};
@define-color success_color             ${SECONDARY};

* {
  -gtk-icon-style: regular;
}

window, .background, .view, textview text, iconview {
  background-color: @theme_bg_color;
  color: @theme_fg_color;
}

/* GTK apps that retain CSD need visible, opaque Halley-matching chrome. */
headerbar, .titlebar,
headerbar:backdrop, .titlebar:backdrop {
  background-color: @headerbar_bg_color;
  background-image: none;
  color: @headerbar_fg_color;
  border-bottom: 2px solid @accent_bg_color;
  border-radius: 0;
  box-shadow: none;
  opacity: 1;
}

headerbar.default-decoration,
.titlebar.default-decoration {
  min-height: 28px;
  padding: 0 8px;
}

headerbar .title, .titlebar .title {
  color: @headerbar_fg_color;
  font-size: 10pt;
  font-weight: normal;
}

headerbar button:not(.suggested-action):not(.destructive-action),
.titlebar button:not(.suggested-action):not(.destructive-action) {
  color: @headerbar_fg_color;
}

headerbar button.titlebutton,
.titlebar button.titlebutton {
  min-height: 16px;
  min-width: 16px;
  padding: 6px;
  margin: 0;
  border: none;
  border-radius: 0;
  background-color: transparent;
  background-position: center;
  background-repeat: no-repeat;
  background-size: 16px 16px;
  box-shadow: none;
  opacity: 1;
  animation: none;
  transition: background-color 75ms ease-out;
}

/* Replace only the glyphs; the buttons remain visible and clickable. */
headerbar button.titlebutton image,
.titlebar button.titlebutton image {
  opacity: 0;
}

headerbar button.titlebutton.minimize,
.titlebar button.titlebutton.minimize {
  background-image: url("file://$THEME_DIR/gtk-3.0/assets/noctalia-halley-minimize.svg");
}

headerbar button.titlebutton.maximize,
.titlebar button.titlebutton.maximize {
  background-image: url("file://$THEME_DIR/gtk-3.0/assets/noctalia-halley-maximize.svg");
}

headerbar button.titlebutton.close,
.titlebar button.titlebutton.close {
  background-image: url("file://$THEME_DIR/gtk-3.0/assets/noctalia-halley-close.svg");
}

headerbar button.titlebutton:hover,
.titlebar button.titlebutton:hover {
  background-color: alpha(@accent_bg_color, 0.12);
}

headerbar button.titlebutton:active,
.titlebar button.titlebutton:active {
  background-color: alpha(@accent_bg_color, 0.2);
}

window.csd decoration,
window.solid-csd decoration {
  margin: 0;
  border-radius: 0;
  box-shadow: none;
}

menubar, .menubar {
  background-color: ${SURFACE_CONTAINER};
  color: @theme_fg_color;
}

toolbar, .toolbar {
  background-color: @theme_bg_color;
  color: @theme_fg_color;
}

.sidebar, stacksidebar list {
  background-color: ${SURFACE_CONTAINER_LOW};
}

row:selected, .view:selected {
  background-color: ${SECONDARY_CONTAINER};
  color: ${ON_SECONDARY_CONTAINER};
}

selection, *:selected {
  background-color: @theme_selected_bg_color;
  color: @theme_selected_fg_color;
}

button.suggested-action {
  background-color: @accent_bg_color;
  color: @accent_fg_color;
}

button.destructive-action {
  background-color: ${ERROR};
  color: ${ON_ERROR};
}

tooltip {
  background-color: @theme_tooltip_bg_color;
  color: @theme_tooltip_fg_color;
  border-radius: 0px;
}
CSSEOF

# Keep the installed theme complete, as well as the user-level override.
for css_file in "$GTK3_CSS" "$GTK3_DARK"; do
    cat "$GTK3_USER_NOCTALIA" >> "$css_file"
done
if [[ ! -f "$GTK3_USER_CSS" ]] || ! grep -qF '@import url("noctalia.css");' "$GTK3_USER_CSS"; then
    printf '\n@import url("noctalia.css");\n' >> "$GTK3_USER_CSS"
fi

# ── 3. GTK4: Rebuild user CSS ────────────────────────────────────────
for css_file in "$GTK4_CSS" "$GTK4_DARK"; do
    base_file="${css_file}.base"
    if [[ -f "$base_file" ]]; then
        cp "$base_file" "$css_file"
    fi

    # Replace @define-color accent and surface values
    sed -i "s/@define-color accent_bg_color .*;/@define-color accent_bg_color ${PRIMARY};/" "$css_file"
    sed -i "s/@define-color accent_fg_color .*;/@define-color accent_fg_color ${ON_PRIMARY};/" "$css_file"
    sed -i "s/@define-color accent_color .*;/@define-color accent_color ${PRIMARY};/" "$css_file"
    sed -i "s/@define-color destructive_bg_color .*;/@define-color destructive_bg_color ${ERROR};/" "$css_file"
    sed -i "s/@define-color destructive_fg_color .*;/@define-color destructive_fg_color ${ON_ERROR};/" "$css_file"
    sed -i "s/@define-color destructive_color .*;/@define-color destructive_color ${ERROR};/" "$css_file"
    sed -i "s/@define-color success_bg_color .*;/@define-color success_bg_color ${SECONDARY};/" "$css_file"
    sed -i "s/@define-color success_fg_color .*;/@define-color success_fg_color ${ON_SECONDARY};/" "$css_file"
    sed -i "s/@define-color success_color .*;/@define-color success_color ${SECONDARY};/" "$css_file"
    sed -i "s/@define-color warning_bg_color .*;/@define-color warning_bg_color ${TERTIARY};/" "$css_file"
    sed -i "s/@define-color warning_fg_color .*;/@define-color warning_fg_color ${ON_TERTIARY};/" "$css_file"
    sed -i "s/@define-color warning_color .*;/@define-color warning_color ${TERTIARY};/" "$css_file"
    sed -i "s/@define-color error_bg_color .*;/@define-color error_bg_color ${ERROR};/" "$css_file"
    sed -i "s/@define-color error_fg_color .*;/@define-color error_fg_color ${ON_ERROR};/" "$css_file"
    sed -i "s/@define-color error_color .*;/@define-color error_color ${ERROR};/" "$css_file"
    sed -i "s/@define-color window_bg_color .*;/@define-color window_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color window_fg_color .*;/@define-color window_fg_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color view_bg_color .*;/@define-color view_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color view_fg_color .*;/@define-color view_fg_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color headerbar_bg_color .*;/@define-color headerbar_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color headerbar_fg_color .*;/@define-color headerbar_fg_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color headerbar_border_color .*;/@define-color headerbar_border_color ${OUTLINE_VARIANT};/" "$css_file"
    sed -i "s/@define-color headerbar_backdrop_color .*;/@define-color headerbar_backdrop_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color sidebar_bg_color .*;/@define-color sidebar_bg_color ${SURFACE_CONTAINER_LOW};/" "$css_file"
    sed -i "s/@define-color sidebar_fg_color .*;/@define-color sidebar_fg_color ${ON_SURFACE};/" "$css_file"
    sed -i "s/@define-color sidebar_backdrop_color .*;/@define-color sidebar_backdrop_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color sidebar_border_color .*;/@define-color sidebar_border_color ${OUTLINE_VARIANT};/" "$css_file"
    sed -i "s/@define-color secondary_sidebar_bg_color .*;/@define-color secondary_sidebar_bg_color ${SURFACE};/" "$css_file"
    sed -i "s/@define-color secondary_sidebar_fg_color .*;/@define-color secondary_sidebar_fg_color ${ON_SURFACE};/" "$css_file"

    # Replace hardcoded colors in GTK4
    sed -i "s/${DEFAULT_ACCENT}/${PRIMARY}/gi" "$css_file"
    sed -i "s/rgba(${DEFAULT_ACCENT_RGB}/rgba(${NEW_ACCENT_RGB}/g" "$css_file"
    sed -i "s/${DEFAULT_BG}/${SURFACE}/gi" "$css_file"
    sed -i "s/${DEFAULT_HEADER_BG}/${SURFACE_CONTAINER}/gi" "$css_file"

    # Ensure border-radius stays 0
    sed -i -E 's/border-radius:[^;]+;/border-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-top-left-radius:[^;]+;/border-top-left-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-top-right-radius:[^;]+;/border-top-right-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-bottom-left-radius:[^;]+;/border-bottom-left-radius: 0px;/g' "$css_file"
    sed -i -E 's/border-bottom-right-radius:[^;]+;/border-bottom-right-radius: 0px;/g' "$css_file"
done

# ── 4. GTK4: Generate noctalia.css ───────────────────────────────────
cat > "$GTK4_USER_NOCTALIA" << CSSEOF
/*
 * Noctalia GTK4 Color Overrides for Colloid-Square-Dark
 * Generated by Noctalia's Template Processor
 */

@define-color accent_color          ${PRIMARY};
@define-color accent_bg_color       ${PRIMARY};
@define-color accent_fg_color       ${ON_PRIMARY};

@define-color destructive_color     ${ERROR};
@define-color destructive_bg_color  ${ERROR};
@define-color destructive_fg_color  ${ON_ERROR};
@define-color error_color           ${ERROR};
@define-color error_bg_color        ${ERROR};
@define-color error_fg_color        ${ON_ERROR};

@define-color success_color         ${SECONDARY};
@define-color success_bg_color      ${SECONDARY};
@define-color success_fg_color      ${ON_SECONDARY};
@define-color warning_color         ${TERTIARY};
@define-color warning_bg_color      ${TERTIARY};
@define-color warning_fg_color      ${ON_TERTIARY};

@define-color window_bg_color       ${SURFACE};
@define-color window_fg_color       ${ON_SURFACE};

@define-color view_bg_color         ${SURFACE_CONTAINER_LOWEST};
@define-color view_fg_color         ${ON_SURFACE};

@define-color headerbar_bg_color        ${SURFACE};
@define-color headerbar_fg_color        ${ON_SURFACE};
@define-color headerbar_border_color    ${OUTLINE_VARIANT};
@define-color headerbar_backdrop_color  ${SURFACE};
@define-color headerbar_shade_color     ${SHADOW}26;

@define-color card_bg_color         ${SURFACE_CONTAINER_LOW};
@define-color card_fg_color         ${ON_SURFACE};
@define-color card_shade_color      ${SHADOW}18;

@define-color dialog_bg_color       ${SURFACE_CONTAINER_HIGH};
@define-color dialog_fg_color       ${ON_SURFACE};

@define-color popover_bg_color      ${SURFACE_CONTAINER};
@define-color popover_fg_color      ${ON_SURFACE};
@define-color popover_shade_color   ${SHADOW}18;

@define-color sidebar_bg_color          ${SURFACE_CONTAINER_LOW};
@define-color sidebar_fg_color          ${ON_SURFACE};
@define-color sidebar_border_color      ${OUTLINE_VARIANT};
@define-color sidebar_backdrop_color    ${SURFACE};
@define-color sidebar_shade_color       ${SHADOW}14;

@define-color shade_color           ${SHADOW}1A;
@define-color scrollbar_outline_color ${OUTLINE_VARIANT};
@define-color thumbnail_bg_color    ${SURFACE_CONTAINER};
@define-color thumbnail_fg_color    ${ON_SURFACE_VARIANT};

@define-color borders               ${OUTLINE_VARIANT};

window.background:not(.osd) headerbar,
window.background:not(.osd) .titlebar,
window.background:not(.osd) headerbar:backdrop,
window.background:not(.osd) .titlebar:backdrop {
  background-color: @headerbar_bg_color;
  background-image: none;
  color: @headerbar_fg_color;
  border-bottom: 2px solid @accent_bg_color;
  border-radius: 0;
  box-shadow: none;
  opacity: 1;
}

window.background:not(.osd) headerbar.default-decoration,
window.background:not(.osd) .titlebar.default-decoration {
  min-height: 28px;
  padding: 0 8px;
}

window.background:not(.osd) headerbar.default-decoration > windowhandle > box {
  padding: 0;
}

headerbar > windowhandle,
headerbar:backdrop > windowhandle {
  filter: none;
}

headerbar .title, .titlebar .title {
  color: @headerbar_fg_color;
  font-size: 10pt;
  font-weight: normal;
}

headerbar button.titlebutton,
windowcontrols button,
windowhandle button.titlebutton,
$GTK4_CONTROL.minimize,
$GTK4_CONTROL.maximize,
$GTK4_CONTROL.close,
$GTK4_CONTROL.minimize:backdrop,
$GTK4_CONTROL.maximize:backdrop,
$GTK4_CONTROL.close:backdrop {
  min-height: 16px;
  min-width: 16px;
  padding: 6px;
  margin: 0;
  border: none;
  border-radius: 0;
  background-color: transparent;
  background-position: center;
  background-repeat: no-repeat;
  background-size: 16px 16px;
  box-shadow: none;
  opacity: 1;
  animation: none;
  transition: background-color 75ms ease-out;
}

headerbar button.titlebutton image,
windowcontrols button image,
windowhandle button.titlebutton image {
  opacity: 0;
}

headerbar button.titlebutton.minimize,
$GTK4_CONTROL.minimize,
windowhandle button.titlebutton.minimize {
  background-image: url("file://$THEME_DIR/gtk-4.0/assets/noctalia-halley-minimize.svg");
}

headerbar button.titlebutton.maximize,
$GTK4_CONTROL.maximize,
windowhandle button.titlebutton.maximize {
  background-image: url("file://$THEME_DIR/gtk-4.0/assets/noctalia-halley-maximize.svg");
}

headerbar button.titlebutton.close,
$GTK4_CONTROL.close,
windowhandle button.titlebutton.close {
  background-image: url("file://$THEME_DIR/gtk-4.0/assets/noctalia-halley-close.svg");
}

headerbar button.titlebutton:hover,
$GTK4_CONTROL.minimize:hover,
$GTK4_CONTROL.maximize:hover,
$GTK4_CONTROL.close:hover,
windowhandle button.titlebutton:hover {
  background-color: alpha(@accent_bg_color, 0.12);
}

headerbar button.titlebutton:active,
$GTK4_CONTROL.minimize:active,
$GTK4_CONTROL.maximize:active,
$GTK4_CONTROL.close:active,
windowhandle button.titlebutton:active {
  background-color: alpha(@accent_bg_color, 0.2);
}

.suggested-action {
  background-color: @accent_bg_color;
  color: @accent_fg_color;
}

headerbar .selection-mode-bar {
  background-color: ${PRIMARY_CONTAINER};
  color: ${ON_PRIMARY_CONTAINER};
}

row:hover {
  background-color: ${SURFACE_CONTAINER_HIGH};
}
row:selected {
  background-color: ${SECONDARY_CONTAINER};
  color: ${ON_SECONDARY_CONTAINER};
}

switch:checked {
  background-color: @accent_bg_color;
}
switch:checked slider {
  background-color: @accent_fg_color;
}

progressbar progress {
  background-color: @accent_bg_color;
}

tooltip {
  background-color: ${INVERSE_SURFACE};
  color: ${INVERSE_ON_SURFACE};
  border-radius: 0px;
  padding: 4px 8px;
}
CSSEOF

# ── 5. GTK4: Apply the full Colloid theme in both light and dark modes
for css_file in "$GTK4_CSS" "$GTK4_DARK"; do
    cat "$GTK4_USER_NOCTALIA" >> "$css_file"
done

# nwg-look may symlink gtk.css to GTK4_CSS. Writing an import or copying the
# file through that link would overwrite the theme or copy it onto itself.
if [[ ! "$GTK4_CSS" -ef "$GTK4_USER_CSS" && ! "$GTK4_DARK" -ef "$GTK4_USER_CSS" ]]; then
    cat > "$GTK4_USER_CSS" << CSSEOF
@import url("file://$GTK4_CSS");
CSSEOF
fi

# ── 6. Save current state ───────────────────────────────────────────
echo "$PRIMARY" > "$STATE_FILE"
echo "$NEW_ACCENT_RGB" >> "$STATE_FILE"

# ── 7. Force GTK theme persistence & refresh ──────────────────────
chmod 644 "$HOME/.config/gtk-3.0/settings.ini" 2>/dev/null || true
chmod 644 "$HOME/.config/gtk-4.0/settings.ini" 2>/dev/null || true

THEME_NAME="Colloid-Square-Dark"
[[ "$MODE" == "dark" ]] && PREFER_DARK=1 || PREFER_DARK=0

set_gtk_setting() {
    local settings_file="$1" key="$2" value="$3"
    if [[ ! -f "$settings_file" ]]; then
        printf '[Settings]\n' > "$settings_file"
    fi
    if grep -q "^$key=" "$settings_file"; then
        sed -i "s|^$key=.*|$key=$value|" "$settings_file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$settings_file"
    fi
}

for gtk_version in 3.0 4.0; do
    settings_file="$HOME/.config/gtk-$gtk_version/settings.ini"
    set_gtk_setting "$settings_file" gtk-theme-name "$THEME_NAME"
    set_gtk_setting "$settings_file" gtk-application-prefer-dark-theme "$PREFER_DARK"
    set_gtk_setting "$settings_file" gtk-decoration-layout "$DECORATION_LAYOUT"
done

if [[ -f "$HOME/.gtkrc-2.0" ]]; then
    sed -i -E "s|^gtk-theme-name[[:space:]]*=.*|gtk-theme-name = \"$THEME_NAME\"|" "$HOME/.gtkrc-2.0"
fi

if [[ -f "$HOME/.config/xsettingsd/xsettingsd.conf" ]]; then
    sed -i "s/Net\/ThemeName .*/Net\/ThemeName \"$THEME_NAME\"/" "$HOME/.config/xsettingsd/xsettingsd.conf"
    if grep -q '^Gtk/DecorationLayout ' "$HOME/.config/xsettingsd/xsettingsd.conf"; then
        sed -i "s|^Gtk/DecorationLayout .*|Gtk/DecorationLayout \"$DECORATION_LAYOUT\"|" "$HOME/.config/xsettingsd/xsettingsd.conf"
    else
        printf 'Gtk/DecorationLayout "%s"\n' "$DECORATION_LAYOUT" >> "$HOME/.config/xsettingsd/xsettingsd.conf"
    fi
    pkill -HUP xsettingsd 2>/dev/null || true
fi

# Reload theme via gsettings toggle
CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
if [[ "$CURRENT_THEME" == "$THEME_NAME" ]]; then
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" 2>/dev/null || true
    sleep 0.15
fi
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences button-layout "$DECORATION_LAYOUT" 2>/dev/null || true

echo "[Noctalia-Colloid] Applied theme $THEME_NAME (mode: $MODE, accent: ${PRIMARY}, surface: ${SURFACE})"
