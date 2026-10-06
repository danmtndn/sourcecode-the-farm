// obj_glow - Draw End: flat room darkness, then additive glows on top.
// Runs after world drawing, before Draw GUI, so HUD/menus are untouched.
if (!global.glow_enabled && !global.darkness_enabled) exit;

// Darkness: one flat translucent fill over the whole room; the pools of
// light come purely from the additive glows below. A flat fill has no
// gradient, no holes and no boundary, so no edge or square can ever come
// from this layer. Runs on its own toggle; skipped in the menu.
if (global.darkness_enabled && room != rm_menu) {
    draw_set_alpha(global.ambient_alpha);
    draw_set_color(ambient_color);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (global.glow_enabled) {
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(emitters); i++) {
    var _e = emitters[i];
    var _count = instance_number(_e[0]);
    for (var n = 0; n < _count; n++) {
        var _inst = instance_find(_e[0], n);
        if (!_inst.visible) continue;
        var _a = _e[3];
        if (_e[4] > 0) {
            var _ph = n * 2.1 + i;
            _a = _a * (1.0 - _e[4] * 0.35 * (0.5 + 0.5 * sin(current_time * 0.004 + _ph)));
        }
        var _sc = _e[1] / 128; // 256px gradient -> diameter = radius * 2
        draw_sprite_ext(spr_light, 0, _inst.x, _inst.y + _e[5], _sc, _sc, 0, _e[2], _a);
    }
}
gpu_set_blendmode(bm_normal);
}

// Visibility pass: redraw every emitter instance at full art brightness
// over the darkness+glow (same table: anything that glows stays readable).
// Copies current frame, flip, angle, blend and alpha, so animation,
// facing and any flashing carry over exactly.
for (var v = 0; v < array_length(emitters); v++) {
    var _vo = emitters[v];
    var _vc = instance_number(_vo[0]);
    for (var w = 0; w < _vc; w++) {
        var _vi = instance_find(_vo[0], w);
        if (!_vi.visible) continue;
        draw_sprite_ext(_vi.sprite_index, _vi.image_index, _vi.x, _vi.y, _vi.image_xscale, _vi.image_yscale, _vi.image_angle, _vi.image_blend, _vi.image_alpha);
    }
}
