// obj_fade - Draw GUI End: fullscreen black at the current fade level.
// Drawn in GUI End so it sits above all world, HUD, menu and overlay drawing.
if (fade_alpha > 0) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    draw_set_alpha(clamp(fade_alpha, 0, 1));
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
