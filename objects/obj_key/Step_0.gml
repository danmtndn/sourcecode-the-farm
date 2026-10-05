// obj_key - Step: E to pick up, +1 key
if (instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 48
    && keyboard_check_pressed(ord("E"))) {
        global.has_key += 1;
        instance_destroy();
    }
}
