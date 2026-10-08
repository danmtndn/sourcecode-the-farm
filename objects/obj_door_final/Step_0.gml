// obj_door_final - Step: E to type code; correct code -> animate open,
// finished -> passable open door (never destroyed, never loops).
if (!instance_exists(obj_player) || obj_game.state != "play") exit;

if (!opened) {
    image_index = 0; // locked: hold the shut frame
    var _near = point_distance(x, y, obj_player.x, obj_player.y) < 80;

    if (_near && keyboard_check_pressed(ord("E")) && global.code_found != "") {
        typing = !typing;
        keyboard_string = "";
    }

    if (typing) {
        // Numbers only: strip anything that isn't 0-9 and cap to code length.
        var _raw = keyboard_string;
        var _clean = "";
        for (var _i = 1; _i <= string_length(_raw); _i++) {
            var _o = ord(string_char_at(_raw, _i));
            if (_o >= 48 && _o <= 57) _clean += chr(_o);
        }
        var _maxlen = max(1, string_length(global.level_code));
        if (string_length(_clean) > _maxlen) _clean = string_copy(_clean, 1, _maxlen);
        keyboard_string = _clean;
        if (keyboard_check_pressed(vk_enter)) {
            if (keyboard_string == global.level_code) {
                opened = true;
                typing = false; // animation below takes over; still solid until it ends
                if (instance_exists(obj_game)) obj_game.sfx_vary(snd_door, 1, 0.08);
            } else {
                keyboard_string = ""; // wrong, retry
            }
        }
        if (keyboard_check_pressed(vk_escape)) typing = false;
        if (!_near) typing = false;
    }
} else {
    image_index += door_anim_rate;
    if (image_index >= image_number - 1) {
        image_index = image_number - 1;
        instance_change(obj_door_open, false); // persists, passable, holds frame
    }
}
