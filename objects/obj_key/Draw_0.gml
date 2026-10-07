// obj_key - Draw: quiet prompt above the sprite, only when the player is close
draw_self();
if (instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 72) {
        draw_set_font(fnt_body);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        var _t = "Key [E]";
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
