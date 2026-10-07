// obj_menu - Draw GUI: horror title, tagline, options, controls, achievements.
// Fonts: fnt_heading for titles and options, fnt_body for story and hints.
// Row spacing is measured from the real font heights so tall display glyphs
// never overlap. Footer lines are unchanged, only pinned higher and clear.
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;
var _mid = _gh / 2;
var _blood = make_color_rgb(139, 0, 0);
var _bone = make_color_rgb(210, 200, 180);

// Dark backdrop with blood frame
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_color(_blood);
draw_rectangle(24, 24, _gw - 24, _gh - 24, true);

// Title zone: measure the display font so the subtitle clears the glyphs
draw_set_halign(fa_center);
draw_set_font(fnt_heading);
var _flick = ((current_time div 400) mod 8 == 0) ? c_red : _blood;
var _title_y = _mid - 190;
var _title_h = string_height("THE FARM");
draw_set_color(c_black);
draw_text(_cx + 2, _title_y + 2, "THE FARM");
draw_set_color(_flick);
draw_text(_cx, _title_y, "THE FARM");
draw_set_font(fnt_body);
draw_set_color(c_dkgray);
var _sub_y = _title_y + _title_h + 12;
draw_text(_cx, _sub_y, "Reese. The crash. The family.");

// Tagline zone: fixed top, measured height so options start below it
draw_set_halign(fa_left);
draw_set_font(fnt_body);
draw_set_color(_bone);
var _shown = string_copy(tagline, 1, tag_timer div tag_speed);
if (string_length(_shown) < string_length(tagline) && (current_time div 500) mod 2 == 0) _shown += "_";
var _tag_top = _sub_y + 26;
draw_text_ext(_cx - 250, _tag_top, _shown, 22, 500);
var _tag_h = string_height_ext(_shown, 22, 500);

// Options zone: display-font row height measured, footer kept clear above
draw_set_font(fnt_heading);
var _opt_step = string_height("- Ag -") + 12;
draw_set_font(fnt_body);
var _set_step = string_height("Ag") + 12;
var _foot_top = _gh - 162;
var _opt_top = max(_tag_top + _tag_h + 30, _mid - 60);
draw_set_halign(fa_center);
if (menu_achievements) {
    // One row per achievement: bone label if earned, grey ??? + hint if not.
    var _got = [ach_hidden1, ach_hidden2, ach_hidden3, ach_level];
    draw_set_font(fnt_body);
    for (var a = 0; a < 4; a++) {
        var _ay = _opt_top + a * _set_step;
        if (_got[a]) {
            draw_set_color(_bone);
            draw_text(_cx, _ay, ach_list[a][0]);
        } else {
            draw_set_color(c_dkgray);
            draw_text(_cx, _ay, "??? - " + ach_list[a][1]);
        }
    }
    draw_set_color(c_dkgray);
    draw_text(_cx, min(_opt_top + 4 * _set_step + 12, _foot_top - 30), "[ENTER/ESC] Back");
} else if (!menu_settings) {
    draw_set_font(fnt_heading);
    for (var i = 0; i < array_length(options); i++) {
        var _y = _opt_top + i * _opt_step;
        if (i == selected) {
            draw_set_color(c_red);
            draw_text(_cx, _y, "- " + options[i] + " -");
        } else {
            draw_set_color(_bone);
            draw_text(_cx, _y, options[i]);
        }
    }
} else {
    draw_set_font(fnt_body);
    var _rows = ["Music: " + (music_on ? "ON" : "OFF"), "Music volume: " + string(floor(music_vol * 100)) + "%", "Sound: " + (sfx_on ? "ON" : "OFF"), "Sound volume: " + string(floor(sfx_vol * 100)) + "%", "Back"];
    for (var k = 0; k < 5; k++) {
        var _ky = _opt_top + k * _set_step;
        if (k == selected) {
            draw_set_color(c_red);
            draw_text(_cx, _ky, "- " + _rows[k] + " -");
        } else {
            draw_set_color(_bone);
            draw_text(_cx, _ky, _rows[k]);
        }
    }
}
draw_set_color(c_white);

// Footer zone pinned well above the bottom edge. Same 3 lines verbatim.
if (!menu_achievements) {
    draw_set_halign(fa_left);
    draw_set_font(fnt_body);
    draw_set_color(c_dkgray);
    draw_text(_cx - 250, _gh - 162, "W/S or Up/Down: select   ENTER: confirm");
    draw_text(_cx - 250, _gh - 136, "In game: A/D move, SPACE jump, E interact, N note, ESC pause");
    var _got2 = (ach_hidden1 ? 1 : 0) + (ach_hidden2 ? 1 : 0) + (ach_hidden3 ? 1 : 0) + (ach_level ? 1 : 0);
    draw_text(_cx - 250, _gh - 110, "Achievements: " + string(_got2) + "/4");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
draw_set_font(-1);
