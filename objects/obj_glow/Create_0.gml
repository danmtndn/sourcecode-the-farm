// obj_glow - Create: flat room darkness + additive glow per emitter.
// PERSISTENT: place ONE instance in rm_menu only; it survives room changes.
// One fullscreen quad plus a few sprite draws per frame: cheapest possible.
//
// To make an object glow, add a row below:
//   [object, radius_px, color, alpha, flicker, y_offset]
// flicker 0 = steady glow, higher = stronger pulse. y_offset lifts the glow
// above feet-origin sprites. Toggle everything with global.glow_enabled.
if (!variable_global_exists("glow_enabled")) global.glow_enabled = true;
// Vignette: one stretched texture over the GUI, also nearly free.
// Strength is baked into the texture; this scales it (1 = as authored, 0 = off).
if (!variable_global_exists("vignette_enabled")) global.vignette_enabled = true;
if (!variable_global_exists("vignette_alpha")) global.vignette_alpha = 1;
// Darkness: flat room-wide dimming (see Draw End); light pools come
// purely from the additive glows below. ambient_alpha near 1 = darker.
// Toggle with global.darkness_enabled.
if (!variable_global_exists("darkness_enabled")) global.darkness_enabled = true;
if (!variable_global_exists("ambient_alpha")) global.ambient_alpha = 0.8;
ambient_color = make_colour_rgb(5, 5, 14);

emitters = [
    [obj_player,      130, make_colour_rgb(255, 190, 120), 0.45, 0.00, -24],
    [obj_enemy,       100, c_red,                          0.55, 0.30, -24],
    [obj_key,          60, c_yellow,                       0.60, 0.00,  -8],
    [obj_paper,        60, make_colour_rgb(200, 220, 255), 0.60, 0.00,  -8],
    [obj_exit,         90, c_lime,                         0.55, 0.30, -24],
    [obj_hidden_item,  60, c_aqua,                         0.55, 0.00,  -8],
];
