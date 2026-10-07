// obj_menu - Draw GUI: title, tagline typewriter, options, controls, achievements.
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;

draw_set_font(-1);

// Title (centered)
draw_set_halign(fa_center);
draw_set_color(c_yellow);
draw_text(_cx, _gh/2 - 140, "THE FARM");
draw_set_color(c_white);

// Tagline typewriter in a 500px box (left-aligned, matches obj_game story style)
draw_set_halign(fa_left);
var _shown = string_copy(tagline, 1, tag_timer div tag_speed);
if (string_length(_shown) < string_length(tagline) && (current_time div 500) mod 2 == 0) _shown += "_";
draw_text_ext(_cx - 250, _gh/2 - 100, _shown, 22, 500);

// Options (centered). Settings mode shows toggles, achievements mode a list.
draw_set_halign(fa_center);
if (menu_achievements) {
    // One row per achievement: gold label if earned, grey ??? + hint if not.
    var _got = [ach_hidden1, ach_hidden2, ach_hidden3, ach_level];
    for (var a = 0; a < 4; a++) {
        var _ay = _gh/2 - 52 + a * 28;
        if (_got[a]) {
            draw_set_color(c_yellow);
            draw_text(_cx, _ay, ach_list[a][0]);
        } else {
            draw_set_color(c_dkgray);
            draw_text(_cx, _ay, "??? - " + ach_list[a][1]);
        }
    }
    draw_set_color(c_dkgray);
    draw_text(_cx, _gh/2 + 80, "[ENTER/ESC] Back");
} else if (!menu_settings) {
    for (var i = 0; i < array_length(options); i++) {
        var _y = _gh/2 - 20 + i * 32;
        if (i == selected) {
            draw_set_color(c_yellow);
            draw_text(_cx, _y, "> " + options[i] + " <");
        } else {
            draw_set_color(c_ltgray);
            draw_text(_cx, _y, options[i]);
        }
    }
} else {
    var _rows = ["Music: " + (music_on ? "ON" : "OFF"), "Sound Effects: " + (sfx_on ? "ON" : "OFF"), "Back"];
    for (var k = 0; k < 3; k++) {
        var _ky = _gh/2 - 20 + k * 32;
        if (k == selected) {
            draw_set_color(c_yellow);
            draw_text(_cx, _ky, "> " + _rows[k] + " <");
        } else {
            draw_set_color(c_ltgray);
            draw_text(_cx, _ky, _rows[k]);
        }
    }
}
draw_set_color(c_white);

// Controls + achievements footer (left-aligned box; hidden while the
// achievements list is up since it carries its own Back hint).
if (!menu_achievements) {
    draw_set_halign(fa_left);
    draw_text(_cx - 250, _gh/2 + 80, "W/S or Up/Down: select   ENTER: confirm");
    draw_text(_cx - 250, _gh/2 + 104, "In game: A/D move, SPACE jump, E interact, N note, P pause");
    var _got = (ach_hidden1 ? 1 : 0) + (ach_hidden2 ? 1 : 0) + (ach_hidden3 ? 1 : 0) + (ach_level ? 1 : 0);
    draw_set_color(c_dkgray);
    draw_text(_cx - 250, _gh/2 + 132, "Achievements: " + string(_got) + "/4");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
