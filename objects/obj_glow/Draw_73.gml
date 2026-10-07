// obj_glow - Draw End: multiplicative night map, then key objects
// redrawn full-bright for readability.
// Runs after world drawing, before Draw GUI, so HUD/menus are untouched.
if (!global.darkness_enabled) exit;

// Glow texture half-size, read live: redraw spr_light at any canvas size
// and the pools still land exactly on their table radius.
var _half = sprite_get_width(spr_light) / 2;
if (_half < 1) _half = 1;

// Darkness: a room-sized night map. It starts at the ambient floor and
// each emitter ADDS light into it; the map then multiplies over the scene.
// Addition never clamps at the bottom and multiplication never kinks, so
// unlike subtract there is no contour edge anywhere in the falloff.
// Room-sized so world-space drawing stays correct under any camera.
// Runs on its own toggle; skipped in the menu.
if (global.darkness_enabled && room != rm_menu) {
    var _rw = room_width;
    var _rh = room_height;
    if (!surface_exists(dark_surf) || surface_get_width(dark_surf) != _rw || surface_get_height(dark_surf) != _rh) {
        if (surface_exists(dark_surf)) surface_free(dark_surf);
        dark_surf = surface_create(_rw, _rh);
    }
    if (surface_exists(dark_surf)) {
        surface_set_target(dark_surf);
        draw_clear_alpha(ambient_color, 1);
        gpu_set_blendmode(bm_add);
        for (var j = 0; j < array_length(emitters); j++) {
            var _d = emitters[j];
            var _t = instance_number(_d[0]);
            for (var k = 0; k < _t; k++) {
                var _lite = instance_find(_d[0], k);
                if (!_lite.visible) continue;
                var _da = _d[3];
                if (_d[4] > 0) {
                    var _dh = k * 2.1 + j;
                    _da = _da * (1.0 - _d[4] * 0.35 * (0.5 + 0.5 * sin(current_time * 0.004 + _dh)));
                }
                // Holes follow the instance's own fade: a materializing or
                // vanishing enemy punches a growing/shrinking hole, never a
                // full-strength pool with no visible source. (image_alpha is
                // 1 for everything not fading, so this is a no-op for them.)
                _da *= _lite.image_alpha;
                // Pools read a little wider than the table radius so the
                // darkness boundary stays soft falloff, not an edge.
                var _ds = _d[1] * 1.2 / _half;
                draw_sprite_ext(spr_light, 0, _lite.x, _lite.y + _d[5], _ds, _ds, 0, _d[2], _da);
            }
        }
        gpu_set_blendmode(bm_normal);
        surface_reset_target();
        // Multiply the night map over the scene: pools stay near full
        // brightness, darkness scales the art toward black (hue kept).
        gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
        draw_surface(dark_surf, 0, 0);
        gpu_set_blendmode(bm_normal);
    }
}

// Visibility pass: redraw every emitter instance at full art brightness
// over the darkness (same table: anything with a light hole stays readable).
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
