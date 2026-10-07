// obj_exit - Step: touch to unlock level achievement + next room or outro
if (variable_global_exists("transition_lock") && global.transition_lock) exit;
if (instance_exists(obj_player) && obj_game.state == "play") {
    if (place_meeting(x, y, obj_player)) {
        obj_game.unlock_achievement("level", "Level unlocked!");
        // If last room -> outro, else next room via black fade
        if (room == room_last) {
            obj_game.state = "outro";
        } else if (instance_exists(obj_fade)) {
            with (obj_fade) fade_start("next", 0);
        } else {
            room_goto_next();
        }
    }
}
