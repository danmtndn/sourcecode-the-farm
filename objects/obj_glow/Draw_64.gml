// obj_glow - Draw GUI: fullscreen vignette, one stretched sprite draw.
// Runs after everything (including the HUD), stretched to the GUI size,
// so it always covers the screen exactly with no extra math.
if (!global.vignette_enabled) exit;
if (global.vignette_alpha <= 0) exit;
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
draw_sprite_stretched_ext(spr_vignette, 0, 0, 0, _gw, _gh, c_white, global.vignette_alpha);
