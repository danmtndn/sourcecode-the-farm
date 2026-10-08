// obj_game - Step: intro/outro/pause flow, damage flash timer, achievement popup timer
// Timers freeze while paused so popups don't expire behind the pause panel.
if (state != "pause") {
    if (global.damage_flash > 0) global.damage_flash -= 1;
    if (global.ach_timer > 0) global.ach_timer -= 1;
}
// Transition lock and door-typing flag shared by all inputs below.
var _locked = variable_global_exists("transition_lock") && global.transition_lock;
var _typing_now = false;
if (instance_exists(obj_door_final)) {
    with (obj_door_final) {
        if (typing) other._typing_now = true;
    }
}
// N toggles the zoomed paper view (only once a note has been found, while playing)
if (state == "play" && !_locked && global.code_found != "" && keyboard_check_pressed(ord("N"))) {
    global.note_open = !global.note_open;
}
if (state != "play") global.note_open = false;

// Remember spawn for respawn (first player position in each room)
if (room != room_first && false) {} // placeholder
if (state == "play" && instance_exists(obj_player) && spawn_x == 128 && spawn_y == 128) {
    // keep initial spawn; rooms you build set player start manually
}

// New room (persistent object): menu idles, ending plays the outro,
// levels get a fresh intro card, code and empty hands.
if (room != loaded_room) {
    loaded_room = room;
    if (room_get_name(room) == "rm_menu") {
        state = "menu";
    } else if (room_get_name(room) == "rm_ending") {
        outro_timer = 0;
        state = "outro";
    } else {
        intro_lines = story_for_room(room);
        intro_index = 0;
        type_timer = 0;
        outro_timer = 0;
        // New level, new code: fresh random digits plus empty hands.
        reset_level_items();
        gen_level_code();
        state = "intro";
    }
}

// Typewriter tick for the current intro line.
if (state == "intro" && intro_index < array_length(intro_lines)) {
    var _len = string_length(intro_lines[intro_index]);
    if (type_timer < _len * type_speed) type_timer += 1;
}

if (state == "intro" && !_locked && keyboard_check_pressed(vk_enter)) {
    var _cur_len = string_length(intro_lines[intro_index]);
    var _fader_idle = !instance_exists(obj_fade) || !obj_fade.is_fading();
    if (type_timer < _cur_len * type_speed) {
        // Still typing: complete the line instantly instead of skipping it.
        type_timer = _cur_len * type_speed;
    } else if (_fader_idle) {
        intro_index += 1;
        type_timer = 0;
        if (intro_index >= array_length(intro_lines)) {
            // Story handoff: the card screen is already black, so reveal
            // gameplay with a single fade-in. No fade-out, no second dip.
            state = "begin";
            if (instance_exists(obj_fade)) {
                with (obj_fade) fade_reveal();
            } else {
                state = "play";
            }
            // capture spawn on start
            if (instance_exists(obj_player)) {
                spawn_x = obj_player.x;
                spawn_y = obj_player.y;
            }
        }
    }
    // else: entry fade still running -> hold the last card, press ENTER again.
}

// Handoff beat: hold black until the fade dip finishes, then play.
if (state == "begin") {
    var _still_fading = instance_exists(obj_fade) && obj_fade.is_fading();
    if (!_still_fading) state = "play";
}

// Typewriter tick for the outro (reveals line by line, see Draw).
if (state == "outro") outro_timer += 1;

// Pause menu: ESC opens it from play (P works too); ESC/P resumes; ESC steps
// back (submenu -> options -> play). ESC never opens pause while typing a
// door code so it keeps cancelling the keypad without side effects.
if (state == "play" && !_locked && !_typing_now && (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P")))) {
    state = "pause";
    pause_selected = 0;
    pause_settings = false;
} else if (state == "pause" && !_locked) {
    if (keyboard_check_pressed(vk_escape)) {
        if (pause_settings) {
            pause_settings = false;
            pause_selected = 1; // land back on "Settings"
        } else state = "play";
    } else if (keyboard_check_pressed(ord("P"))) {
        state = "play";
    } else {
        var _rows = pause_settings ? 5 : array_length(pause_options);
        var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
        var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
        if (_up) pause_selected = (pause_selected - 1 + _rows) mod _rows;
        if (_down) pause_selected = (pause_selected + 1) mod _rows;
        var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
        var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
        var _confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        if (pause_settings) {
            // 0 Music ON/OFF, 1 Music volume, 2 Sound ON/OFF, 3 Sound volume, 4 Back.
            // Left/Right and A/D adjust volumes. ENTER/SPACE toggles or backs out.
            if (pause_selected == 0 && (_confirm || _left || _right)) toggle_music();
            else if (pause_selected == 1 && (_left || _right)) {
                var _d = _right ? 0.1 : -0.1;
                set_music_vol(global.music_vol + _d);
            } else if (pause_selected == 1 && _confirm) set_music_vol(global.music_vol + 0.1 > 1 ? 0 : global.music_vol + 0.1);
            else if (pause_selected == 2 && (_confirm || _left || _right)) toggle_sfx();
            else if (pause_selected == 3 && (_left || _right)) {
                var _d2 = _right ? 0.1 : -0.1;
                set_sfx_vol(global.sfx_vol + _d2);
            } else if (pause_selected == 3 && _confirm) set_sfx_vol(global.sfx_vol + 0.1 > 1 ? 0 : global.sfx_vol + 0.1);
            else if (_confirm && pause_selected == 4) {
                pause_settings = false;
                pause_selected = 1;
            }
        } else if (_confirm) {
            if (pause_selected == 0) state = "play"; // Resume
            else if (pause_selected == 1) {
                pause_settings = true; // Settings
                pause_selected = 0;
            } else if (pause_selected == 2) { // Quit to Menu via black fade
                global.hp = global.max_hp;
                global.has_key = 0;
                global.code_found = "";
                global.note_open = false;
                global.damage_flash = 0;
                pause_settings = false;
                pause_selected = 0;
                state = "menu";
                if (instance_exists(obj_fade)) {
                    with (obj_fade) fade_start("first", 0);
                } else room_goto(room_first);
            }
        }
    }
}

if (state == "dead") {
    // Hold the death screen briefly so it can be read before R works.
    if (dead_cooldown > 0) dead_cooldown -= 1;
    else if (!_locked && keyboard_check_pressed(ord("R"))) {
    global.hp = global.max_hp;
    // Death wipes the full inventory: keys and clue. Re-read the paper.
    reset_level_items();
    state = "play";
    if (instance_exists(obj_fade)) {
        with (obj_fade) fade_start("restart", 0);
    } else room_restart();
    }
}

if (state == "outro" && !_locked && keyboard_check_pressed(ord("R"))) {
    global.hp = global.max_hp;
    global.has_key = 0;
    global.code_found = "";
    state = "intro";
    intro_index = 0;
    type_timer = 0;
    outro_timer = 0;
    if (instance_exists(obj_fade)) {
        with (obj_fade) fade_start("first", 0);
    } else room_goto(room_first);
}
