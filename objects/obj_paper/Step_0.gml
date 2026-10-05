// obj_paper - Step: E to read, show contents popup, store code
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 56
    && keyboard_check_pressed(ord("E"))) {
        global.code_found = paper_code;
        global.paper_text = paper_code;
        global.paper_timer = 360; // 6 seconds to read/memorize
        instance_destroy();
    }
}
