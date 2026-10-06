// obj_glow - Draw End: draws each emitter's glow additively over the world.
// Runs after world drawing, before Draw GUI, so HUD/menus are untouched.
if (!global.glow_enabled) exit;
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
