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
    if (i < global.hp) draw_sprite_ext(spr_heart, _heart_frame, _hx + _heart_ox, _hy + _heart_oy, _heart_scale, _heart_scale, 0, c_white, 1);
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
    draw_set_alpha(0.55);
    draw_set_color(c_black);
    draw_rectangle(_sx - 8, _cy - _row_h / 2, _gw - 24 + 8, _cy + _row_h / 2, false);
    draw_set_alpha(1);
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

// World input prompts, drawn in GUI space above the room filter and night
// map (world-space pills sat underneath both and read as dimmed). Same
// texts and ranges as before, only the draw space moved. Pills keep a fixed
// GUI size so they stay readable at any camera zoom.
if (state == "play" && instance_exists(obj_player)) {
    var _cam = view_camera[0];
    var _vvx = 0;
    var _vvy = 0;
    var _vvw = room_width;
    var _vvh = room_height;
    if (_cam != -1 && camera_get_view_width(_cam) > 0 && camera_get_view_height(_cam) > 0) {
        _vvx = camera_get_view_x(_cam);
        _vvy = camera_get_view_y(_cam);
        _vvw = camera_get_view_width(_cam);
        _vvh = camera_get_view_height(_cam);
    }
    var _psx = _gw / max(1, _vvw);
    var _psy = _gh / max(1, _vvh);
    draw_set_font(fnt_body);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    // Key pickup
    var _nkey = instance_number(obj_key);
    for (var _ik = 0; _ik < _nkey; _ik++) {
        var _ok = instance_find(obj_key, _ik);
        if (!instance_exists(_ok)) continue;
        if (point_distance(_ok.x, _ok.y, obj_player.x, obj_player.y) >= 72) continue;
        var _p1x = (((_ok.bbox_left + _ok.bbox_right) / 2) - _vvx) * _psx;
        var _p1y = (_ok.bbox_top - _vvy) * _psy;
        var _t1 = "Key [E]";
        var _w1 = string_width(_t1);
        var _h1 = string_height(_t1);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_p1x - _w1 / 2 - 6, _p1y - _h1 - 14, _p1x + _w1 / 2 + 6, _p1y - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_p1x, _p1y - _h1 - 12, _t1);
    }
    // Paper note
    var _npa = instance_number(obj_paper);
    for (var _ip = 0; _ip < _npa; _ip++) {
        var _op = instance_find(obj_paper, _ip);
        if (!instance_exists(_op)) continue;
        if (point_distance(_op.x, _op.y, obj_player.x, obj_player.y) >= 72) continue;
        var _p2x = (((_op.bbox_left + _op.bbox_right) / 2) - _vvx) * _psx;
        var _p2y = (_op.bbox_top - _vvy) * _psy;
        var _t2 = "Read [E]";
        var _w2 = string_width(_t2);
        var _h2 = string_height(_t2);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_p2x - _w2 / 2 - 6, _p2y - _h2 - 14, _p2x + _w2 / 2 + 6, _p2y - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_p2x, _p2y - _h2 - 12, _t2);
    }
    // Hidden item
    var _nhi = instance_number(obj_hidden_item);
    for (var _ih = 0; _ih < _nhi; _ih++) {
        var _oh = instance_find(obj_hidden_item, _ih);
        if (!instance_exists(_oh)) continue;
        if (point_distance(_oh.x, _oh.y, obj_player.x, obj_player.y) >= 56) continue;
        var _p3x = (((_oh.bbox_left + _oh.bbox_right) / 2) - _vvx) * _psx;
        var _p3y = (_oh.bbox_top - _vvy) * _psy;
        var _t3 = "Take [E]";
        var _w3 = string_width(_t3);
        var _h3 = string_height(_t3);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_p3x - _w3 / 2 - 6, _p3y - _h3 - 14, _p3x + _w3 / 2 + 6, _p3y - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_p3x, _p3y - _h3 - 12, _t3);
    }
    // Drawer
    var _ndr = instance_number(obj_drawer);
    for (var _idr = 0; _idr < _ndr; _idr++) {
        var _od = instance_find(obj_drawer, _idr);
        if (!instance_exists(_od) || _od.opened) continue;
        if (point_distance(_od.x, _od.y, obj_player.x, obj_player.y) >= 80) continue;
        var _p4x = (((_od.bbox_left + _od.bbox_right) / 2) - _vvx) * _psx;
        var _p4y = (_od.bbox_top - _vvy) * _psy;
        var _t4 = "Open [E]";
        var _w4 = string_width(_t4);
        var _h4 = string_height(_t4);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_p4x - _w4 / 2 - 6, _p4y - _h4 - 14, _p4x + _w4 / 2 + 6, _p4y - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_p4x, _p4y - _h4 - 12, _t4);
    }
    // Key door
    var _ndk = instance_number(obj_door_key);
    for (var _ik2 = 0; _ik2 < _ndk; _ik2++) {
        var _ok2 = instance_find(obj_door_key, _ik2);
        if (!instance_exists(_ok2) || _ok2.opened) continue;
        if (point_distance(_ok2.x, _ok2.y, obj_player.x, obj_player.y) >= 96) continue;
        var _p5x = (((_ok2.bbox_left + _ok2.bbox_right) / 2) - _vvx) * _psx;
        var _p5y = (_ok2.bbox_top - _vvy) * _psy;
        var _t5 = (global.has_key > 0) ? "Open [E]" : "Locked. Need key.";
        var _w5 = string_width(_t5);
        var _h5 = string_height(_t5);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_p5x - _w5 / 2 - 6, _p5y - _h5 - 14, _p5x + _w5 / 2 + 6, _p5y - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_p5x, _p5y - _h5 - 12, _t5);
    }
    // Final door: halo plus contextual prompt
    var _ndf = instance_number(obj_door_final);
    for (var _ifd = 0; _ifd < _ndf; _ifd++) {
        var _of = instance_find(obj_door_final, _ifd);
        if (!instance_exists(_of) || _of.opened) continue;
        var _fgx = (((_of.bbox_left + _of.bbox_right) / 2) - _vvx) * _psx;
        var _fgy = (((_of.bbox_top + _of.bbox_bottom) / 2) - _vvy) * _psy;
        var _hsx = 0.9 * _psx;
        var _hsy = 0.9 * _psy;
        var _hlx = _fgx + (sprite_get_xoffset(spr_light) - sprite_get_width(spr_light) / 2) * _hsx;
        var _hly = _fgy + (sprite_get_yoffset(spr_light) - sprite_get_height(spr_light) / 2) * _hsy;
        var _pulse = 0.30 + 0.15 * (0.5 + 0.5 * sin(current_time / 300));
        gpu_set_blendmode(bm_add);
        draw_set_alpha(_pulse);
        draw_sprite_ext(spr_light, 0, _hlx, _hly, _hsx, _hsy, 0, c_white, 1);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
        var _near = point_distance(_of.x, _of.y, obj_player.x, obj_player.y) < 110;
        if (_of.typing || _near) {
            var _t6 = "";
            if (global.code_found == "") _t6 = "Locked. Find note.";
            else if (!_of.typing) _t6 = "Open [E]";
            else _t6 = "Code: " + keyboard_string + "_";
            var _ftop = (_of.bbox_top - _vvy) * _psy;
            var _w6 = string_width(_t6);
            var _h6 = string_height(_t6);
            draw_set_alpha(0.65);
            draw_set_color(c_black);
            draw_rectangle(_fgx - _w6 / 2 - 6, _ftop - _h6 - 14, _fgx + _w6 / 2 + 6, _ftop - 8, false);
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_text(_fgx, _ftop - _h6 - 12, _t6);
        }
    }
    // Exit
    var _nex = instance_number(obj_exit);
    for (var _iex = 0; _iex < _nex; _iex++) {
        var _oe = instance_find(obj_exit, _iex);
        if (!instance_exists(_oe)) continue;
        if (point_distance(_oe.x, _oe.y, obj_player.x, obj_player.y) >= 80) continue;
        var _p7x = (((_oe.bbox_left + _oe.bbox_right) / 2) - _vvx) * _psx;
        var _p7y = (_oe.bbox_top - _vvy) * _psy;
        var _t7 = "Escape";
        var _w7 = string_width(_t7);
        var _h7 = string_height(_t7);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_p7x - _w7 / 2 - 6, _p7y - _h7 - 14, _p7x + _w7 / 2 + 6, _p7y - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_p7x, _p7y - _h7 - 12, _t7);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
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
// short description in body font.
if (global.ach_timer > 0) {
    var _ach_slide = 0;
    if (global.ach_timer > 160) _ach_slide = -100 * (global.ach_timer - 160) / 20;
    else if (global.ach_timer < 30) _ach_slide = -100 * (30 - global.ach_timer) / 30;
    var _apx1 = _gw/2 - 230;
    var _apx2 = _gw/2 + 230;
    var _apy1 = 14 + _ach_slide;
    var _apy2 = 100 + _ach_slide;
    draw_set_color(c_black);
    draw_rectangle(_apx1, _apy1, _apx2, _apy2, false);
    draw_set_color(_blood);
    draw_rectangle(_apx1, _apy1, _apx2, _apy2, true);
    draw_set_halign(fa_center);
    draw_set_font(fnt_heading);
    var _atitle_h = string_height(global.ach_title);
    draw_set_color(c_black);
    draw_text(_gw/2 + 2, _apy1 + 12, global.ach_title);
    draw_set_color(c_red);
    draw_text(_gw/2, _apy1 + 10, global.ach_title);
    draw_set_font(fnt_body);
    draw_set_color(_bone);
    draw_text(_gw/2, _apy1 + 12 + _atitle_h + 6, global.ach_text);
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
