// obj_game - Draw GUI: horror HUD, pause, achievements, intro/outro screens
// Fonts: fnt_heading for titles, fnt_body for all body text and prompts.
// Colors: blood red titles, bone white body, dark grey hints on black panels.
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _blood = make_color_rgb(139, 0, 0);
var _bone = make_color_rgb(210, 200, 180);

// HUD only outside the menu (obj_menu draws its own screen in rm_menu).
if (state != "menu") {
// HP: animated spr_heart top-left. Full hearts beat, empty ones are dark and still.
var _heart_n = max(1, sprite_get_number(spr_heart));
var _heart_frame = (current_time div 100) mod _heart_n;
var _heart_scale = 56 / max(1, sprite_get_width(spr_heart));
var _heart_ox = sprite_get_xoffset(spr_heart) * _heart_scale;
var _heart_oy = sprite_get_yoffset(spr_heart) * _heart_scale;
for (var i = 0; i < global.max_hp; i++) {
    var _hx = 24 + i * 72;
    var _hy = 16;
    if (i < global.hp) {
        draw_sprite_ext(spr_heart, _heart_frame, _hx + _heart_ox + 2, _hy + _heart_oy + 2, _heart_scale, _heart_scale, 0, c_black, 0.8);
        draw_sprite_ext(spr_heart, _heart_frame, _hx + _heart_ox, _hy + _heart_oy, _heart_scale, _heart_scale, 0, c_white, 1);
    }
    else draw_sprite_ext(spr_heart, 0, _hx + _heart_ox, _hy + _heart_oy, _heart_scale, _heart_scale, 0, c_dkgray, 0.45);
}
// Top-right cluster: item sprites with labels on the left, [ESC] pause rightmost.
if (state == "play") {
    draw_set_font(fnt_body);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var _gap = 16;
    var _key_txt = "x" + string(global.has_key);
    var _key_w = string_width(_key_txt);
    var _key_s = 48 / max(1, sprite_get_height(spr_key));
    var _key_iw = sprite_get_width(spr_key) * _key_s;
    var _has_clue = (global.code_found != "");
    var _clue_txt = "[N]";
    var _clue_w = _has_clue ? string_width(_clue_txt) : 0;
    var _clue_s = 48 / max(1, sprite_get_height(spr_paper));
    var _clue_iw = _has_clue ? sprite_get_width(spr_paper) * _clue_s : 0;
    var _pause_txt = "[ESC] pause";
    var _pause_w = string_width(_pause_txt);
    var _row_h = 56;
    var _total = _key_iw + 8 + _key_w + _gap + (_has_clue ? (_clue_iw + 8 + _clue_w + _gap) : 0) + _pause_w;
    var _sx = _gw - 24 - _total;
    var _cy = 44;
    var _dx = _sx;
    draw_sprite_ext(spr_key, (current_time div 100) mod max(1, sprite_get_number(spr_key)), _dx + sprite_get_xoffset(spr_key) * _key_s, _cy - 24 + sprite_get_yoffset(spr_key) * _key_s, _key_s, _key_s, 0, c_white, 1);
    _dx += _key_iw + 8;
    draw_set_color(_bone);
    draw_text(_dx, _cy, _key_txt);
    _dx += _key_w + _gap;
    if (_has_clue) {
        draw_sprite_ext(spr_paper, 0, _dx + sprite_get_xoffset(spr_paper) * _clue_s, _cy - 24 + sprite_get_yoffset(spr_paper) * _clue_s, _clue_s, _clue_s, 0, c_white, 1);
        _dx += _clue_iw + 8;
        draw_set_color(_bone);
        draw_text(_dx, _cy, _clue_txt);
        _dx += _clue_w + _gap;
    }
    draw_set_color(c_dkgray);
    draw_text(_dx, _cy, _pause_txt);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
}


// Zoomed paper overlay: N toggles, code drawn ON the paper
if (global.note_open && global.code_found != "") {
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // Paper preview sprite, drawn as-is with no frame behind it
    var _ps = global.note_sprite;
    var _pw = sprite_get_width(_ps);
    var _ph = sprite_get_height(_ps);
    var _scale = min(3, max(1.5, _gh / (_ph * 4)));
    var _nx = _gw / 2;
    var _ny = _gh / 2 - 20;
    draw_sprite_ext(_ps, 0, _nx, _ny, _scale, _scale, 0, c_white, 1);

    // Code written on the paper in large digits, centered so it can be read.
    // fnt_digits holds digits only, so it is used for this digits-only string.
    draw_set_alpha(1);
    draw_set_font(fnt_digits);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _code = global.code_found;
    var _cs = 2;
    var _cw = string_width(_code) * _cs;
    var _chh = string_height(_code) * _cs;
    var _ccx = clamp(_nx, _nx - _pw * _scale / 2 + _cw / 2 + 12, _nx + _pw * _scale / 2 - _cw / 2 - 12);
    var _ccy = clamp(_ny - 6, _ny - _ph * _scale / 2 + _chh / 2 + 12, _ny + _ph * _scale / 2 - _chh / 2 - 12);
    draw_set_color(make_color_rgb(190, 175, 140));
    draw_text_transformed(_ccx + 2, _ccy + 2, _code, _cs, _cs, 0);
    draw_set_color(make_color_rgb(20, 12, 10));
    draw_text_transformed(_ccx, _ccy, _code, _cs, _cs, 0);
    draw_set_valign(fa_top);

    // Hint
    draw_set_font(fnt_body);
    draw_set_halign(fa_left);
    draw_set_color(c_dkgray);
    draw_text(_nx - 80, _ny + _ph * _scale / 2 + 16, "[N] put away");
    draw_set_color(c_white);
}

// Red flash on damage, no text. Flash alone is the signal.
if (global.damage_flash > 0) {
    draw_set_alpha(0.45);
    draw_set_color(c_red);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Achievement popup: slides down, holds, slides up. Title in heading font,
// short description in body font. Panel measured around both lines so the
// description always sits inside the rectangle.
if (global.ach_timer > 0) {
    var _ach_slide = 0;
    if (global.ach_timer > 160) _ach_slide = -100 * (global.ach_timer - 160) / 20;
    else if (global.ach_timer < 30) _ach_slide = -100 * (30 - global.ach_timer) / 30;
    draw_set_font(fnt_heading);
    var _ath = string_height(global.ach_title);
    var _atw = string_width(global.ach_title);
    draw_set_font(fnt_body);
    var _adh = string_height(global.ach_text);
    var _adw = string_width(global.ach_text);
    var _aphw = max(230, max(_atw, _adw) / 2 + 30);
    var _aph = 12 + _ath + 6 + _adh + 12;
    var _apx1 = _gw/2 - _aphw;
    var _apx2 = _gw/2 + _aphw;
    var _apy1 = 14 + _ach_slide;
    var _apy2 = _apy1 + _aph;
    draw_set_color(c_black);
    draw_rectangle(_apx1, _apy1, _apx2, _apy2, false);
    draw_set_color(_blood);
    draw_rectangle(_apx1, _apy1, _apx2, _apy2, true);
    draw_set_halign(fa_center);
    draw_set_font(fnt_heading);
    draw_set_color(c_black);
    draw_text(_gw/2 + 2, _apy1 + 12 + 2, global.ach_title);
    draw_set_color(c_red);
    draw_text(_gw/2, _apy1 + 12, global.ach_title);
    draw_set_font(fnt_body);
    draw_set_color(_bone);
    draw_text(_gw/2, _apy1 + 12 + _ath + 6, global.ach_text);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

// Text box area for story text. Centered, 500px wide.
var _tb_x = _gw/2 - 250;
var _tb_w = 500;
var _tb_sep = 22;

// Intro overlay
if (state == "intro") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    // Thin blood frame around the story box
    draw_set_color(_blood);
    draw_rectangle(_tb_x - 16, _gh/2 - 70, _tb_x + _tb_w + 16, _gh/2 + 90, true);
    var _li = min(intro_index, array_length(intro_lines)-1);
    var _full = intro_lines[_li];
    var _shown = string_copy(_full, 1, type_timer div type_speed);
    if (string_length(_shown) < string_length(_full) && (current_time div 500) mod 2 == 0) _shown += "_";
    // First line of each card is the chapter title
    var _is_title = (_li == 0) || (string_char_at(_full, 1) == "I" && string_copy(_full, 1, 4) == "II. ") || (string_copy(_full, 1, 5) == "III. ") || (string_copy(_full, 1, 4) == "THE ");
    if (intro_index == 0 && _li == 0) {
        draw_set_font(fnt_heading);
        draw_set_color(_blood);
        draw_text(_tb_x + 2, _gh/2 - 38, _shown);
        draw_set_color(c_black);
    } else {
        draw_set_font(fnt_body);
        draw_set_color(_bone);
        draw_text_ext(_tb_x, _gh/2 - 40, _shown, _tb_sep, _tb_w);
    }
    // Wrapped body for non-title cards (draw again correctly when not title card)
    if (!(_is_title && intro_index == 0 && _li == 0)) {
        draw_set_font(fnt_body);
        draw_set_color(_bone);
        draw_text_ext(_tb_x, _gh/2 - 40, _shown, _tb_sep, _tb_w);
    }
    draw_set_font(fnt_body);
    draw_set_color(c_dkgray);
    draw_text(_tb_x, _gh/2 + 60, "ENTER: continue (" + string(min(intro_index+1, array_length(intro_lines))) + "/" + string(array_length(intro_lines)) + ")");
    draw_set_color(c_white);
}
// Handoff beat: hold black while the single reveal fade finishes into gameplay.
if (state == "begin") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_color(c_white);
}
if (state == "dead") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_font(fnt_heading);
    draw_set_halign(fa_center);
    var _dead_title = "YOU DIED";
    var _dead_h = string_height(_dead_title);
    var _dead_y = _gh/2 - _dead_h / 2 - 14;
    draw_set_color(c_black);
    draw_text(_gw/2 + 2, _dead_y + 2, _dead_title);
    draw_set_color(c_red);
    draw_text(_gw/2, _dead_y, _dead_title);
    draw_set_font(fnt_body);
    var _retry = "Press R to retry";
    if (dead_cooldown > 0) draw_set_color(c_dkgray);
    else draw_set_color(_bone);
    draw_text(_gw/2, _dead_y + _dead_h + 16, _retry);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
if (state == "outro") {
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_font(fnt_body);
    draw_set_color(_bone);
    var _budget = outro_timer div type_speed;
    var _oy = _gh/2 - 40;
    for (var j = 0; j < array_length(outro_lines); j++) {
        var _llen = string_length(outro_lines[j]);
        var _take = clamp(_budget, 0, _llen);
        var _txt = string_copy(outro_lines[j], 1, _take);
        if (_take < _llen && _take == _budget && (current_time div 500) mod 2 == 0) _txt += "_";
        draw_text_ext(_tb_x, _oy, _txt, _tb_sep, _tb_w);
        var _h = (_take > 0) ? string_height_ext(_txt, _tb_sep, _tb_w) : _tb_sep;
        _oy += max(_tb_sep, _h);
        _budget -= _llen;
        if (_budget < 0) _budget = 0;
    }
    draw_set_color(c_dkgray);
    draw_text(_tb_x, _oy + 20, "Press R to return to menu");
    draw_set_color(c_white);
}

// Pause menu overlay. Dark panel sized to its content, blood red titles.
if (state == "pause") {
    draw_set_alpha(0.82);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
    var _px = _gw/2;
    draw_set_halign(fa_center);
    if (!pause_settings) {
        draw_set_font(fnt_heading);
        var _ptitle = "PAUSED";
        var _ptitle_h = string_height(_ptitle);
        draw_set_font(fnt_body);
        var _prow_step = string_height("Ag") + 12;
        var _phint = "W/S select  ENTER confirm  ESC resume";
        var _phint_h = string_height(_phint);
        var _p_top = _gh/2 - (_ptitle_h + 3 * _prow_step + _phint_h + 76) / 2;
        var _p_bot = _p_top + _ptitle_h + 20 + 3 * _prow_step + 16 + _phint_h + 24;
        draw_set_color(_blood);
        draw_rectangle(_px - 230, _p_top, _px + 230, _p_bot, true);
        draw_set_font(fnt_heading);
        draw_set_color(c_red);
        draw_text(_px, _p_top + 20, _ptitle);
        draw_set_font(fnt_body);
        for (var _p = 0; _p < array_length(pause_options); _p++) {
            var _py = _p_top + 20 + _ptitle_h + 20 + _p * _prow_step;
            if (_p == pause_selected) {
                draw_set_color(c_red);
                draw_text(_px, _py, "- " + pause_options[_p] + " -");
            } else {
                draw_set_color(_bone);
                draw_text(_px, _py, pause_options[_p]);
            }
        }
        draw_set_font(fnt_body);
        draw_set_color(c_dkgray);
        draw_text(_px, _p_bot - _phint_h - 20, _phint);
    } else {
        draw_set_font(fnt_heading);
        var _stitle = "SETTINGS";
        var _stitle_h = string_height(_stitle);
        draw_set_font(fnt_body);
        var _srow_step = string_height("Ag") + 10;
        var _shint = "ENTER or Left/Right adjusts  ESC back";
        var _shint_h = string_height(_shint);
        var _mrow = "Music: " + (global.music_on ? "ON" : "OFF");
        var _mvrow = "Music volume: " + string(floor(global.music_vol * 100)) + "%";
        var _srow = "Sound: " + (global.sfx_on ? "ON" : "OFF");
        var _svrow = "Sound volume: " + string(floor(global.sfx_vol * 100)) + "%";
        var _rows = [_mrow, _mvrow, _srow, _svrow, "Back"];
        var _s_top = _gh/2 - (_stitle_h + 5 * _srow_step + _shint_h + 76) / 2;
        var _s_bot = _s_top + _stitle_h + 20 + 5 * _srow_step + 16 + _shint_h + 24;
        draw_set_color(_blood);
        draw_rectangle(_px - 230, _s_top, _px + 230, _s_bot, true);
        draw_set_font(fnt_heading);
        draw_set_color(c_red);
        draw_text(_px, _s_top + 20, _stitle);
        draw_set_font(fnt_body);
        for (var _s = 0; _s < 5; _s++) {
            var _sy = _s_top + 20 + _stitle_h + 20 + _s * _srow_step;
            if (_s == pause_selected) {
                draw_set_color(c_red);
                draw_text(_px, _sy, "- " + _rows[_s] + " -");
            } else {
                draw_set_color(_bone);
                draw_text(_px, _sy, _rows[_s]);
            }
        }
        draw_set_font(fnt_body);
        draw_set_color(c_dkgray);
        draw_text(_px, _s_bot - _shint_h - 20, _shint);
    }
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    draw_set_font(-1);
}
