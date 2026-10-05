// obj_hidden_item - Step: secret pickup -> hidden achievement
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (place_meeting(x, y, obj_player) || (point_distance(x, y, obj_player.x, obj_player.y) < 40 && keyboard_check_pressed(ord("E")))) {
        obj_game.unlock_achievement("hidden", "Hidden item found!");
        instance_destroy();
    }
}
