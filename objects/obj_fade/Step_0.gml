// obj_fade - Step: tick the fade, perform the room change at full black.
if (room != loaded_fade_room) {
    // Arrived somewhere new: fade back in from black.
    loaded_fade_room = room;
    fade_alpha = 1;
    fade_dir = -1;
    fade_busy = true;
    global.transition_lock = true;
}
if (restart_wait > 0) {
    restart_wait -= 1;
    if (restart_wait <= 0) fade_dir = -1;
} else if (fade_dir == 1) {
    fade_alpha = min(1, fade_alpha + fade_speed);
    if (fade_alpha >= 1) {
        var _a = fade_action;
        var _p = fade_param;
        fade_action = "";
        if (_a == "goto") {
            room_goto(_p);
            fade_dir = 0; // room change detector above starts the fade-in
        } else if (_a == "next") {
            room_goto_next();
            fade_dir = 0;
        } else if (_a == "first") {
            room_goto(room_first);
            fade_dir = 0;
        } else if (_a == "restart") {
            room_restart();
            restart_wait = 4; // same room, so no change to detect: brief hold, then in
        } else {
            fade_dir = -1;
        }
    }
} else if (fade_dir == -1) {
    fade_alpha = max(0, fade_alpha - fade_speed);
    if (fade_alpha <= 0) {
        fade_dir = 0;
        fade_busy = false;
        global.transition_lock = false;
    }
}
