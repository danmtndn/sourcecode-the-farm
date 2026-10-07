// obj_door_final - Draw: strong pulsing halo so it pops, then sprite + prompt.
if (!opened) {
    var _pulse = 0.15 + 0.07 * (0.5 + 0.5 * sin(current_time / 300));
    var _gs = 0.9;
    var _gx = (bbox_left + bbox_right) / 2;
    var _gy = (bbox_top + bbox_bottom) / 2;
    var _hlx = _gx + (sprite_get_xoffset(spr_light) - sprite_get_width(spr_light) / 2) * _gs;
    var _hly = _gy + (sprite_get_yoffset(spr_light) - sprite_get_height(spr_light) / 2) * _gs;
    gpu_set_blendmode(bm_add);
    draw_set_alpha(_pulse);
    draw_sprite_ext(spr_light, 0, _hlx, _hly, _gs, _gs, 0, c_white, 1);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
draw_self();
if (!opened && instance_exists(obj_game) && obj_game.state == "play") {
    var _near = instance_exists(obj_player) && point_distance(x, y, obj_player.x, obj_player.y) < 110;
    if (typing || _near) {
        draw_set_font(fnt_body);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        var _t = "";
        if (global.code_found == "") _t = "Locked. Find note.";
        else if (!typing) _t = "Open [E]";
        else _t = "Code: " + keyboard_string + "_";
        var _top = bbox_top;
        var _ccx = (bbox_left + bbox_right) / 2;
        var _tw = string_width(_t);
        var _th = string_height(_t);
        draw_set_alpha(0.65);
        draw_set_color(c_black);
        draw_rectangle(_ccx - _tw / 2 - 6, _top - _th - 14, _ccx + _tw / 2 + 6, _top - 8, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(_ccx, _top - _th - 12, _t);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
    }
}
