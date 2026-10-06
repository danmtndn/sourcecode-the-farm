// obj_game - Draw GUI: HUD, pause menu, achievements, intro/outro screens
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_font(-1);
// HUD only outside the menu (obj_menu draws its own screen in rm_menu).
if (state != "menu") {
// HP: 3 hearts top-left (standard PC platformer)
for (var i = 0; i < global.max_hp; i++) {
    var _x = 24 + i * 36;
    var _y = 24;
    if (i < global.hp) draw_set_color(c_red);
    else draw_set_color(c_dkgray);
    draw_circle(_x, _y, 12, false);
}
draw_set_color(c_white);
draw_text(24, 44, "Keys: " + string(global.has_key));
if (global.code_found != "") draw_text(24, 64, "Code found [N view]");
if (state == "play") {
    draw_set_color(c_dkgray);
    draw_set_halign(fa_right);
    draw_text(_gw - 24, 20, "P: pause");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
}

// Zoomed paper overlay: N toggles, code drawn ON the paper
if (global.note_open && global.code_found != "") {
    // Slightly transparent black to emphasize the paper
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // Zoomed paper (placeholder sprite; user swaps global.note_sprite later)
    var _ps = global.note_sprite;
    var _pw = sprite_get_width(_ps);
    var _ph = sprite_get_height(_ps);
    var _scale = min(3, max(1.5, _gh / (_ph * 4)));
    draw_sprite_ext(_ps, 0, _gw/2, _gh/2 - 20, _scale, _scale, 0, c_white, 1);

    // Code written on the paper
    draw_set_color(c_black);
    draw_text(_gw/2 - 80, _gh/2 - 20, global.code_found);

    // Hint
    draw_set_color(c_dkgray);
    draw_text(_gw/2 - 80, _gh/2 + _ph * _scale / 2 + 16, "[N] close note");
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

// Text box area for story text. EDIT these to move/resize the box (centered, 500px wide).
var _tb_x = _gw/2 - 250;
var _tb_w = 500;
var _tb_sep = 22;

// Intro / Dead / Outro overlays
if (state == "intro") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_color(c_white);
    var _li = min(intro_index, array_length(intro_lines)-1);
    var _full = intro_lines[_li];
    var _shown = string_copy(_full, 1, type_timer div type_speed);
    // Blinking cursor while the line is still typing.
    if (string_length(_shown) < string_length(_full) && (current_time div 500) mod 2 == 0) _shown += "_";
    // Wrapped inside the text box so long lines break instead of running off-screen.
    draw_text_ext(_tb_x, _gh/2 - 40, _shown, _tb_sep, _tb_w);
    draw_text(_tb_x, _gh/2 + 60, "ENTER: continue (" + string(min(intro_index+1, array_length(intro_lines))) + "/" + string(array_length(intro_lines)) + ")");
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
    // Sequential typewriter: line j starts once earlier lines are fully revealed.
    // Each line wraps inside the text box; y advances by the wrapped height.
    var _budget = outro_timer div type_speed;
    var _oy = _gh/2 - 40;
    for (var j = 0; j < array_length(outro_lines); j++) {
        var _llen = string_length(outro_lines[j]);
        var _take = clamp(_budget, 0, _llen);
        var _txt = string_copy(outro_lines[j], 1, _take);
        if (_take < _llen && _take == _budget && (current_time div 500) mod 2 == 0) _txt += "_";
        draw_text_ext(_tb_x, _oy, _txt, _tb_sep, _tb_w);
        // Advance past the wrapped block (empty yet-unrevealed lines still take one row).
        var _h = (_take > 0) ? string_height_ext(_txt, _tb_sep, _tb_w) : _tb_sep;
        _oy += max(_tb_sep, _h);
        _budget -= _llen;
        if (_budget < 0) _budget = 0;
    }
    draw_text(_tb_x, _oy + 20, "Press R to return to menu");
}

// Pause menu overlay (game world frozen behind it, see Step).
if (state == "pause") {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    var _px = _gw/2;
    draw_set_halign(fa_center);
    if (!pause_settings) {
        draw_set_color(c_yellow);
        draw_text(_px, _gh/2 - 90, "PAUSED");
        for (var _p = 0; _p < array_length(pause_options); _p++) {
            var _py = _gh/2 - 40 + _p * 32;
            if (_p == pause_selected) {
                draw_set_color(c_yellow);
                draw_text(_px, _py, "> " + pause_options[_p] + " <");
            } else {
                draw_set_color(c_ltgray);
                draw_text(_px, _py, pause_options[_p]);
            }
        }
        draw_set_color(c_dkgray);
        draw_text(_px, _gh/2 + 80, "W/S select  ENTER confirm  P/ESC resume");
    } else {
        draw_set_color(c_yellow);
        draw_text(_px, _gh/2 - 90, "SETTINGS");
        var _mrow = "Music: " + (global.music_on ? "ON" : "OFF");
        var _srow = "Sound Effects: " + (global.sfx_on ? "ON" : "OFF");
        var _rows = [_mrow, _srow, "Back"];
        for (var _s = 0; _s < 3; _s++) {
            var _sy = _gh/2 - 40 + _s * 32;
            if (_s == pause_selected) {
                draw_set_color(c_yellow);
                draw_text(_px, _sy, "> " + _rows[_s] + " <");
            } else {
                draw_set_color(c_ltgray);
                draw_text(_px, _sy, _rows[_s]);
            }
        }
        draw_set_color(c_dkgray);
        draw_text(_px, _gh/2 + 80, "ENTER or Left/Right toggles  ESC back");
    }
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
