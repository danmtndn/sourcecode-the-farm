// obj_game - Step: intro/outro/pause flow, damage flash timer, achievement popup timer
// Timers freeze while paused so popups don't expire behind the pause panel.
if (state != "pause") {
    if (global.damage_flash > 0) global.damage_flash -= 1;
    if (global.ach_timer > 0) global.ach_timer -= 1;
}
// N toggles the zoomed paper view (only once a note has been found, while playing)
if (state == "play" && global.code_found != "" && keyboard_check_pressed(ord("N"))) {
    global.note_open = !global.note_open;
}
if (state != "play") global.note_open = false;

// Remember spawn for respawn (first player position in each room)
if (room != room_first && false) {} // placeholder
if (state == "play" && instance_exists(obj_player) && spawn_x == 128 && spawn_y == 128) {
    // keep initial spawn; rooms you build set player start manually
}

// New room (persistent object): swap in that level's intro card.
// rm_menu is handled by obj_menu, so just idle there instead of showing an intro.
if (room != loaded_room) {
    loaded_room = room;
    if (room_get_name(room) == "rm_menu") {
        state = "menu";
    } else {
        intro_lines = story_for_room(room);
        intro_index = 0;
        type_timer = 0;
        outro_timer = 0;
        state = "intro";
    }
}

// Typewriter tick for the current intro line.
if (state == "intro" && intro_index < array_length(intro_lines)) {
    var _len = string_length(intro_lines[intro_index]);
    if (type_timer < _len * type_speed) type_timer += 1;
}

if (state == "intro" && keyboard_check_pressed(vk_enter)) {
    var _cur_len = string_length(intro_lines[intro_index]);
    if (type_timer < _cur_len * type_speed) {
        // Still typing: complete the line instantly instead of skipping it.
        type_timer = _cur_len * type_speed;
    } else {
        intro_index += 1;
        type_timer = 0;
        if (intro_index >= array_length(intro_lines)) {
            state = "play";
            // capture spawn on start
            if (instance_exists(obj_player)) {
                spawn_x = obj_player.x;
                spawn_y = obj_player.y;
            }
        }
    }
}

// Typewriter tick for the outro (reveals line by line, see Draw).
if (state == "outro") outro_timer += 1;

// Pause menu: P opens it from play; P resumes; ESC steps back (submenu -> options -> play).
// ESC never opens pause so it keeps cancelling door-code typing without side effects.
if (state == "play" && keyboard_check_pressed(ord("P"))) {
    state = "pause";
    pause_selected = 0;
    pause_settings = false;
} else if (state == "pause") {
    if (keyboard_check_pressed(vk_escape)) {
        if (pause_settings) {
            pause_settings = false;
            pause_selected = 1; // land back on "Settings"
        } else state = "play";
    } else if (keyboard_check_pressed(ord("P"))) {
        state = "play";
    } else {
        var _rows = pause_settings ? 3 : array_length(pause_options);
        var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
        var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
        if (_up) pause_selected = (pause_selected - 1 + _rows) mod _rows;
        if (_down) pause_selected = (pause_selected + 1) mod _rows;
        var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
        var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
        var _confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        if (pause_settings) {
            // 0 Music toggle, 1 SFX toggle, 2 Back. Left/Right also flip toggles.
            if ((_confirm || _left || _right) && pause_selected == 0) toggle_music();
            else if ((_confirm || _left || _right) && pause_selected == 1) toggle_sfx();
            else if (_confirm && pause_selected == 2) {
                pause_settings = false;
                pause_selected = 1;
            }
        } else if (_confirm) {
            if (pause_selected == 0) state = "play"; // Resume
            else if (pause_selected == 1) {
                pause_settings = true; // Settings
                pause_selected = 0;
            } else if (pause_selected == 2) { // Quit to Menu
                global.hp = global.max_hp;
                global.has_key = 0;
                global.code_found = "";
                global.note_open = false;
                global.damage_flash = 0;
                pause_settings = false;
                pause_selected = 0;
                state = "menu";
                room_goto(room_first);
            }
        }
    }
}

if (state == "dead" && keyboard_check_pressed(ord("R"))) {
    global.hp = global.max_hp;
    global.has_key = 0;
    // keep code_found so player doesn't re-read paper after death? reset for simplicity
    // global.code_found = "";
    state = "play";
    room_restart();
}

if (state == "outro" && keyboard_check_pressed(ord("R"))) {
    global.hp = global.max_hp;
    global.has_key = 0;
    global.code_found = "";
    state = "intro";
    intro_index = 0;
    type_timer = 0;
    outro_timer = 0;
    room_goto(room_first);
}
