// obj_drawer - Step: E to open, spawn contents
if (!opened && instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 64
    && keyboard_check_pressed(ord("E"))) {
        opened = true;
        if (contains == "key") instance_create_layer(x, y - 32, layer, obj_key);
        if (contains == "paper") instance_create_layer(x, y - 32, layer, obj_paper);
    }
}
