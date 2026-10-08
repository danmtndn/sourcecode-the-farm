// obj_drawer - Step: E to open, spawn contents with a slight throw toward the player
if (!opened && instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 64
    && keyboard_check_pressed(ord("E"))) {
        opened = true;
        if (instance_exists(obj_game)) obj_game.sfx_vary(snd_item_drop, 1, 0.08);
        var _dir = sign(obj_player.x - x);
        if (_dir == 0) _dir = 1;
        var _spawn = noone;
        if (contains == "key") _spawn = instance_create_layer(x, y - 32, layer, obj_key);
        if (contains == "paper") _spawn = instance_create_layer(x, y - 32, layer, obj_paper);
        if (_spawn != noone) {
            // Slight pop-out: up + toward the player, settles nearby (see obj_key/obj_paper Step).
            _spawn.hsp = _dir * random_range(1.5, 2.5);
            _spawn.vsp = -6;
        }
    }
}
