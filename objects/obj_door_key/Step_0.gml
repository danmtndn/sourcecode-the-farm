// obj_door_key - Step: E near door with key -> open (destroy)
if (!opened && instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 64
    && keyboard_check_pressed(ord("E"))) {
        if (global.has_key >= keys_needed) {
            global.has_key -= keys_needed;
            opened = true;
            instance_destroy(); // path is now open; add sound here later
        }
    }
}
