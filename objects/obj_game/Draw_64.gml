// obj_game - Draw GUI: HP hearts, red damage flash, achievements, intro/outro screens
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// HP: 3 hearts top-left (standard PC platformer)
draw_set_font(-1);
for (var i = 0; i < global.max_hp; i++) {
    var _x = 24 + i * 36;
    var _y = 24;
    if (i < global.hp) draw_set_color(c_red);
    else draw_set_color(c_dkgray);
    draw_circle(_x, _y, 12, false);
}
draw_set_color(c_white);
draw_text(24, 44, "Keys: " + string(global.has_key));
if (global.code_found != "") draw_text(24, 64, "Code: **** (found)");

// Paper contents popup so player can actually see the password
if (global.paper_timer > 0) {
    draw_set_color(c_black);
    draw_rectangle(_gw/2 - 180, _gh/2 - 70, _gw/2 + 180, _gh/2 + 10, false);
    draw_set_color(c_white);
    draw_rectangle(_gw/2 - 180, _gh/2 - 70, _gw/2 + 180, _gh/2 + 10, true);
    draw_text(_gw/2 - 160, _gh/2 - 60, "NOTE FOUND:");
    draw_text(_gw/2 - 160, _gh/2 - 36, global.paper_text);
    draw_text(_gw/2 - 160, _gh/2 - 12, "Memorize for final door [E to close]");
    if (keyboard_check_pressed(ord("E"))) global.paper_timer = 0;
}

// Red visual indicator on damage (contract requirement)
if (global.damage_flash > 0) {
    draw_set_alpha(0.45);
    draw_set_color(c_red);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(_gw/2 - 40, 80, "HURT!");
}

// Achievement popup
if (global.ach_timer > 0) {
    draw_set_color(c_yellow);
    draw_rectangle(_gw/2 - 200, 16, _gw/2 + 200, 48, false);
    draw_set_color(c_black);
    draw_text(_gw/2 - 180, 24, global.ach_text);
    draw_set_color(c_white);
}

// Intro / Dead / Outro overlays
if (state == "intro") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_color(c_white);
    draw_text(_gw/2 - 250, _gh/2 - 40, intro_lines[min(intro_index, array_length(intro_lines)-1)]);
    draw_text(_gw/2 - 250, _gh/2 + 20, "ENTER: continue (" + string(min(intro_index+1, array_length(intro_lines))) + "/" + string(array_length(intro_lines)) + ")");
}
if (state == "dead") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_color(c_red);
    draw_text(_gw/2 - 100, _gh/2 - 20, "YOU DIED");
    draw_set_color(c_white);
    draw_text(_gw/2 - 100, _gh/2 + 10, "Press R to retry");
}
if (state == "outro") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_color(c_white);
    for (var j = 0; j < array_length(outro_lines); j++) {
        draw_text(_gw/2 - 250, _gh/2 - 40 + j*24, outro_lines[j]);
    }
    draw_text(_gw/2 - 250, _gh/2 + 60, "Press R to restart");
}
