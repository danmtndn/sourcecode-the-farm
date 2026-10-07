// obj_game - Create: global state, HP, inventory, achievements, intro/outro text
// obj_game - Create: global state, HP, inventory, achievements, intro/outro text
// EDIT THESE for your story. One intro card per level + one final outro.
// Shown as a typewriter (see Step/Draw). ENTER completes the line first, then advances.
intro_l1 = [
    "THE FARM",
    "You came back to the old farm after the letter...",
    "Find what was left behind. Don't let it catch you.",
    "Press ENTER to begin.  (A/D move, SPACE jump, E interact, P pause)"
];
intro_l2 = [
    "THE BARN",
    "The farmhouse gave up its key, but the barn stays shut.",
    "Something moves between the shelves. Keep a box between you and it.",
    "Press ENTER to begin."
];
intro_default = [
    "THE FARM",
    "Press ENTER to begin."
];
outro_lines = [
    "You unlocked the barn and escaped.",
    "But something still follows...",
    "THE END - Thanks for playing."
];

// Typewriter tuning: steps per revealed character (2 = ~30 chars/sec at 60fps).
type_speed = 2;

state = "intro"; // intro -> play -> pause -> dead / outro (plus menu in rm_menu)
intro_index = 0;
type_timer = 0;   // counts steps; visible chars = type_timer div type_speed
outro_timer = 0;

// Pause menu state. pause_settings=false shows Resume/Settings/Quit,
// true shows the Music/SFX toggles.
pause_selected = 0;
pause_settings = false;
pause_options = ["Resume", "Settings", "Quit to Menu"];

// Pick intro card for a room. EDIT: add a branch per level.
story_for_room = function(_rm) {
    var _nm = room_get_name(_rm);
    if (_nm == "rm_level_1") return intro_l1;
    if (_nm == "rm_level_2") return intro_l2;
    return intro_default;
};

intro_lines = story_for_room(room);
loaded_room = room;

if (!variable_global_exists("hp")) global.hp = 3;
global.max_hp = 3;
global.has_key = 0;          // keys for obj_door_key
global.code_found = "";      // set by obj_paper, e.g. "4821"
global.final_code = "4821";  // EDIT: code for final door
global.note_open = false;     // N toggles zoomed paper overlay
global.note_sprite = spr_player_walk; // EDIT: swap to your spr_paper_zoom when ready
global.damage_flash = 0;
global.ach_hidden1 = false; // L1 secret (see obj_hidden_item Step)
global.ach_hidden2 = false; // L2 secret
global.ach_hidden3 = false; // L3 secret (needs an obj_hidden_item in rm_level_3)
global.ach_level = false;
global.ach_timer = 0;
global.ach_text = "";

spawn_x = 128;
spawn_y = 128;
if (instance_exists(obj_player)) {
    spawn_x = obj_player.x;
    spawn_y = obj_player.y;
}

// Simple persistent save for achievements
ini_open("thefarm_save.ini");
if (ini_key_exists("ach", "hidden1")) global.ach_hidden1 = ini_read_real("ach", "hidden1", 0) > 0.5;
if (ini_key_exists("ach", "hidden2")) global.ach_hidden2 = ini_read_real("ach", "hidden2", 0) > 0.5;
if (ini_key_exists("ach", "hidden3")) global.ach_hidden3 = ini_read_real("ach", "hidden3", 0) > 0.5;
if (ini_key_exists("ach", "level")) global.ach_level = ini_read_real("ach", "level", 0) > 0.5;
ini_close();

// Audio ON/OFF settings, persisted. There are no sound assets in the project
// yet, so these are gates: route all future sounds through play_sfx() for
// effects and play_music() for looping tracks and the toggles apply.
if (!variable_global_exists("music_on")) global.music_on = true;
if (!variable_global_exists("sfx_on")) global.sfx_on = true;
ini_open("thefarm_save.ini");
if (ini_key_exists("settings", "music")) global.music_on = ini_read_real("settings", "music", 1) > 0.5;
if (ini_key_exists("settings", "sfx")) global.sfx_on = ini_read_real("settings", "sfx", 1) > 0.5;
ini_close();
music_track = -1; // currently looping track started via play_music(), if any

save_settings = function() {
    ini_open("thefarm_save.ini");
    ini_write_real("settings", "music", global.music_on ? 1 : 0);
    ini_write_real("settings", "sfx", global.sfx_on ? 1 : 0);
    ini_close();
};

toggle_music = function() {
    global.music_on = !global.music_on;
    if (!global.music_on && music_track != -1) {
        if (audio_is_playing(music_track)) audio_stop_sound(music_track);
        music_track = -1;
    }
    save_settings();
};

toggle_sfx = function() {
    global.sfx_on = !global.sfx_on;
    save_settings();
};

play_sfx = function(_snd) {
    if (!global.sfx_on) return -1;
    return audio_play_sound(_snd, 10, false);
};

play_music = function(_snd) {
    if (!global.music_on) return -1;
    if (music_track != -1 && audio_is_playing(music_track)) audio_stop_sound(music_track);
    music_track = audio_play_sound(_snd, 1, true);
    return music_track;
};

take_damage = function(_dmg) {
    if (global.hp <= 0) return;
    if (instance_exists(obj_player) && obj_player.invuln > 0) return;
    global.hp -= _dmg;
    global.damage_flash = 30; // frames of red overlay
    if (instance_exists(obj_player)) obj_player.invuln = 90;
    if (global.hp <= 0) {
        global.hp = 0;
        state = "dead";
    }
};

unlock_achievement = function(_id, _label) {
    if (_id == "hidden1" && !global.ach_hidden1) {
        global.ach_hidden1 = true;
        global.ach_text = "Achievement: " + _label;
        global.ach_timer = 180;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden1", 1);
        ini_close();
    }
    if (_id == "hidden2" && !global.ach_hidden2) {
        global.ach_hidden2 = true;
        global.ach_text = "Achievement: " + _label;
        global.ach_timer = 180;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden2", 1);
        ini_close();
    }
    if (_id == "hidden3" && !global.ach_hidden3) {
        global.ach_hidden3 = true;
        global.ach_text = "Achievement: " + _label;
        global.ach_timer = 180;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden3", 1);
        ini_close();
    }
    if (_id == "level" && !global.ach_level) {
        global.ach_level = true;
        global.ach_text = "Achievement: " + _label;
        global.ach_timer = 180;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "level", 1);
        ini_close();
    }
};
