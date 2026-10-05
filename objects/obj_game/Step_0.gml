// obj_game - Step: intro/outro flow, damage flash timer, achievement popup timer
if (global.damage_flash > 0) global.damage_flash -= 1;
if (global.ach_timer > 0) global.ach_timer -= 1;
if (global.paper_timer > 0) global.paper_timer -= 1;

// Remember spawn for respawn (first player position in each room)
if (room != room_first && false) {} // placeholder
if (state == "play" && instance_exists(obj_player) && spawn_x == 128 && spawn_y == 128) {
    // keep initial spawn; rooms you build set player start manually
}

if (state == "intro" && keyboard_check_pressed(vk_enter)) {
    intro_index += 1;
    if (intro_index >= array_length(intro_lines)) {
        state = "play";
        // capture spawn on start
        if (instance_exists(obj_player)) {
            spawn_x = obj_player.x;
            spawn_y = obj_player.y;
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
    room_goto(room_first);
}
