// obj_exit - Step: touch to unlock level achievement + next room or outro
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (place_meeting(x, y, obj_player)) {
        obj_game.unlock_achievement("level", "Level unlocked!");
        // If last room -> outro, else next room
        if (room == room_last) {
            obj_game.state = "outro";
        } else {
            room_goto_next();
        }
    }
}
