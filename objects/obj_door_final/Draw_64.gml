// obj_door_final - Draw GUI: keypad hint while typing
if (typing && instance_exists(obj_game) && obj_game.state == "play") {
    var _gw = display_get_gui_width();
    draw_set_color(c_black);
    draw_rectangle(_gw/2 - 160, 100, _gw/2 + 160, 160, false);
    draw_set_color(c_white);
    draw_text(_gw/2 - 140, 110, "Type code + ENTER. ESC cancels.");
    draw_text(_gw/2 - 140, 130, ">" + keyboard_string);
}
