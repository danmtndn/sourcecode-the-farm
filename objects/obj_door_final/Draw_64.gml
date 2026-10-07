// obj_door_final - Draw GUI: horror keypad hint while typing
if (typing && instance_exists(obj_game) && obj_game.state == "play") {
    var _gw = display_get_gui_width();
    var _blood = make_color_rgb(139, 0, 0);
    draw_set_color(c_black);
    draw_rectangle(_gw/2 - 170, 96, _gw/2 + 170, 166, false);
    draw_set_color(_blood);
    draw_rectangle(_gw/2 - 170, 96, _gw/2 + 170, 166, true);
    draw_set_font(fnt_body);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_text(_gw/2 - 150, 106, "Type code and press ENTER. ESC cancels.");
    draw_text(_gw/2 - 150, 130, "- " + keyboard_string + "_");
    draw_set_color(c_white);
    draw_set_font(-1);
}
