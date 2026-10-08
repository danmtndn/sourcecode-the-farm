// obj_hidden_item - Step: secret pickup needs E like other items, no autopickup
// (hidden1/2/3). Every level's secret is its own achievement.
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (point_distance(x, y, obj_player.x, obj_player.y) < 48 && keyboard_check_pressed(ord("E"))) {
        // EDIT labels per level (keep in sync with the menu list in obj_menu).
        var _aid = "hidden1";
        var _alabel = "Farmhouse Secret";
        var _rm = room_get_name(room);
        if (_rm == "rm_level_2") { _aid = "hidden2"; _alabel = "Barn Loft Secret"; }
        else if (_rm == "rm_level_3") { _aid = "hidden3"; _alabel = "Cellar Secret"; }
        obj_game.unlock_achievement(_aid, _alabel);
        obj_game.sfx_vary(snd_pickup, 1, 0.08);
        instance_destroy();
    }
}
