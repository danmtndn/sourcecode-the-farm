// obj_glow - Draw GUI: fullscreen vignette, one stretched sprite draw.
// Runs after everything (including the HUD), stretched to the GUI size,
// so it always covers the screen exactly with no extra math.
if (!global.vignette_enabled) exit;
if (global.vignette_alpha <= 0) exit;
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
// Overscan by 16px on every side: any texture-page seam sampled at the
// sprite's UV border lands offscreen, so no square edge can show.
draw_sprite_stretched_ext(spr_vignette, 0, -16, -16, _gw + 32, _gh + 32, c_white, global.vignette_alpha);
