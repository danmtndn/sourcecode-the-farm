// obj_paper - Step: E to read -> stores code, opens the note overlay
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 56
    && keyboard_check_pressed(ord("E"))) {
        global.code_found = paper_code;
        global.note_open = true; // show zoomed paper immediately
        instance_destroy();
    }
}
