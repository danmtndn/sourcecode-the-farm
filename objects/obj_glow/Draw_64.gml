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
// Panic flash: red vignette pulsing with a heartbeat rhythm while sprinting.
// Skipped in menu/pause (no player, or frozen run): only live chases throb.
if (instance_exists(obj_player) && variable_instance_exists(obj_player.id, "running") && obj_player.running
&& (!instance_exists(obj_game) || obj_game.state == "play")) {
    var _panic = 0.3 + 0.25 * (0.6 * sin(current_time * 0.009) + 0.4 * sin(current_time * 0.023));
    draw_sprite_stretched_ext(spr_vignette_red, 0, -16, -16, _gw + 32, _gh + 32, make_colour_rgb(180, 20, 20), _panic);
}
