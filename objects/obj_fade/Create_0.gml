// obj_fade - Create: black fade transitions for all room changes.
// Persistent, placed once in rm_menu. Other objects call fade_start() instead
// of room_goto / room_goto_next / room_restart directly.
fade_alpha = 0;
fade_dir = 0; // 0 idle, 1 fading out, -1 fading in
fade_speed = 1 / 30; // ~0.5s each way at 60fps
fade_action = "";
fade_param = 0;
fade_busy = false;
restart_wait = 0;
loaded_fade_room = room;
if (!variable_global_exists("transition_lock")) global.transition_lock = false;

// Queue a black fade into a room change. action: "goto", "next", "first", "restart".
fade_start = function(_action, _param) {
    if (fade_busy) return false;
    fade_busy = true;
    global.transition_lock = true;
    fade_action = _action;
    fade_param = _param;
    fade_dir = 1;
    return true;
};

// Reveal from black with no preceding fade-out. For handoffs off screens
// that are already black (story cards): one single fade into the next state.
fade_reveal = function() {
    if (fade_busy) return false;
    fade_busy = true;
    global.transition_lock = true;
    fade_action = "";
    fade_alpha = 1;
    fade_dir = -1;
    return true;
};

is_fading = function() {
    return fade_busy;
};
