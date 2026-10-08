// obj_game - Create: global state, HP, inventory, achievements, intro/outro text
// Singleton: persistent AND placed in every level room, so without this guard
// the controller would stack duplicates (double HUD, double intro input, the
// handoff fighting itself). The newcomer yields before touching any globals.
if (instance_number(obj_game) > 1) { instance_destroy(); exit; }
// Draw above the vignette: obj_game was born on a deep room layer while
// obj_glow was born at depth 0, so without this the fullscreen vignette
// composites over the HUD (darkest exactly in the HUD corners).
depth = -100;
// Story: Reese crashes near a remote farm, is drugged and locked in a cell,
// then must escape the underground by finding keys and clues while hiding
// from the family. No weapons in this game. Edit text below to change story.
intro_l1 = [
    "THE FARM - I. THE CRASH",
    "Driving home on an isolated road, Reese swerves to avoid a dead animal and crashes off a bridge.",
    "No signal. No passing cars. Only lights in the distance: a remote farmhouse.",
    "The family takes him in. Warm dinner. Kind smiles. Then his vision blurs...",
    "Press ENTER to begin. (A/D move, SPACE jump, E interact, N note, ESC pause)",
    "They are waiting. Find a way out."
];
intro_l2 = [
    "II. THE CELL",
    "Reese wakes in a dark cell. Hours blur into days. Whispers behind the walls.",
    "He watches and listens until one captor makes a mistake. A door left unlatched.",
    "Now the underground spreads before him. Find keys. Find clues. Stay quiet. Hide.",
    "Press ENTER to continue.",
    "They are waiting. Find a way out."
];
intro_l3 = [
    "III. THE SLAUGHTERHOUSE",
    "Below the barn the air turns to iron and rot. Hooks. Chains. Ledgers of names.",
    "The family does not farm animals. The carcass on the road was bait. A trap.",
    "Unlock the final exit. Do not let them hear you.",
    "Press ENTER to descend.",
    "They are waiting. Find a way out."
];
intro_default = [
    "THE FARM",
    "Press ENTER to begin."
];
outro_lines = [
    "The final lock clicks. Cold night air. Reese runs and does not look back.",
    "Behind him the farm lights go out one by one. The road is empty.",
    "Somewhere an engine starts. The trap is reset for the next traveler.",
    "THE END - Thanks for playing."
];

// Typewriter tuning: steps per revealed character (2 = ~30 chars/sec at 60fps).
type_speed = 2;

state = "intro"; // intro -> begin -> play -> pause -> dead / outro (plus menu in rm_menu)
intro_index = 0;
type_timer = 0;   // counts steps; visible chars = type_timer div type_speed
outro_timer = 0;
dead_cooldown = 0; // counts down on the death screen before R retry is accepted

// Pause menu state. pause_settings=false shows Resume/Settings/Quit,
// true shows the Music/SFX toggles.
pause_selected = 0;
pause_settings = false;
pause_options = ["Resume", "Settings", "Quit to Menu"];

// Pick intro card for a room. One card per level.
story_for_room = function(_rm) {
    var _nm = room_get_name(_rm);
    if (_nm == "rm_level_1") return intro_l1;
    if (_nm == "rm_level_2") return intro_l2;
    if (_nm == "rm_level_3") return intro_l3;
    return intro_default;
};

intro_lines = story_for_room(room);
loaded_room = room;

// Fresh RNG so level codes differ every launch (singleton: Create runs once).
randomize();

// Level code: fresh random digits every entry. Length escalates per level:
// rm_level_1 = 4, rm_level_2 = 6, rm_level_3 = 8. Digits only so fnt_digits
// always covers them. First digit never zero for a clean keypad readout.
gen_level_code = function() {
    var _len = 4;
    var _nm = room_get_name(room);
    if (_nm == "rm_level_2") _len = 6;
    else if (_nm == "rm_level_3") _len = 8;
    var _c = string(irandom_range(1, 9));
    for (var i = 1; i < _len; i++) _c += string(irandom(9));
    global.level_code = _c;
};

// Full inventory wipe: keys and clue. Runs on every new level and on death.
reset_level_items = function() {
    global.has_key = 0;
    global.code_found = "";
    global.note_open = false;
    global.damage_flash = 0;
};
reset_level_items();
gen_level_code();

if (!variable_global_exists("hp")) global.hp = 3;
global.max_hp = 3;
global.has_key = 0;          // keys for obj_door_key, reset every level
global.code_found = "";      // set by obj_paper from the level code
// NOTE: no level_code init here: gen_level_code() above already set it,
// and a blank init would wipe the fresh code (papers would carry "").
global.note_open = false;     // N toggles zoomed paper overlay
global.note_sprite = spr_paper_preview; // EDIT: swap to your spr_paper_zoom when ready
global.damage_flash = 0;
global.ach_hidden1 = false; // L1 secret (see obj_hidden_item Step)
global.ach_hidden2 = false; // L2 secret
global.ach_hidden3 = false; // L3 secret (needs an obj_hidden_item in rm_level_3)
global.ach_level = false;
global.ach_timer = 0;
global.ach_title = "";
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

// Audio settings, persisted. No sound assets in the project yet, so these are
// gates plus volume levels: route all future sounds through play_sfx() for
// effects and play_music() for looping tracks.
if (!variable_global_exists("music_on")) global.music_on = true;
if (!variable_global_exists("sfx_on")) global.sfx_on = true;
if (!variable_global_exists("music_vol")) global.music_vol = 0.8;
if (!variable_global_exists("sfx_vol")) global.sfx_vol = 0.8;
if (!variable_global_exists("master_vol")) global.master_vol = 1.0;
ini_open("thefarm_save.ini");
if (ini_key_exists("settings", "music")) global.music_on = ini_read_real("settings", "music", 1) > 0.5;
if (ini_key_exists("settings", "sfx")) global.sfx_on = ini_read_real("settings", "sfx", 1) > 0.5;
if (ini_key_exists("settings", "music_vol")) global.music_vol = clamp(ini_read_real("settings", "music_vol", 0.8), 0, 1);
if (ini_key_exists("settings", "sfx_vol")) global.sfx_vol = clamp(ini_read_real("settings", "sfx_vol", 0.8), 0, 1);
if (ini_key_exists("settings", "master_vol")) global.master_vol = clamp(ini_read_real("settings", "master_vol", 1), 0, 1);
ini_close();
music_track = -1; // currently looping track started via play_music(), if any
if (!variable_global_exists("bgm_track")) global.bgm_track = -1; // msc_background loop handle
heart_track = -1; // msc_heartbeat loop handle (second loop beside BGM)
heart_target = 0; // heartbeat chase fraction 0/1; gain = target * music_vol * master
walk_track = -1; // msc_walk loop handle (player walking ambience)
run_track = -1; // msc_run loop handle (player running music)
move_target = 0; // movement music: 0 idle, 1 walk, 2 run

save_settings = function() {
    ini_open("thefarm_save.ini");
    ini_write_real("settings", "music", global.music_on ? 1 : 0);
    ini_write_real("settings", "sfx", global.sfx_on ? 1 : 0);
    ini_write_real("settings", "music_vol", global.music_vol);
    ini_write_real("settings", "sfx_vol", global.sfx_vol);
    ini_write_real("settings", "master_vol", global.master_vol);
    ini_close();
};

apply_audio_volumes = function() {
    // Master gain plus per-loop gains. One-shots need nothing (gain is set
    // at play time). Safe to call with no assets loaded.
    var _m = global.master_vol;
    if (audio_group_is_loaded(audiogroup_default)) {
        audio_group_set_gain(audiogroup_default, _m, 0);
    }
    if (music_track != -1) {
        audio_sound_gain(music_track, global.music_on ? global.music_vol * _m : 0, 0);
    }
    if (variable_global_exists("bgm_track") && global.bgm_track != -1) {
        if (audio_is_playing(global.bgm_track)) {
            audio_sound_gain(global.bgm_track, global.music_on ? global.music_vol * _m : 0, 0);
        } else global.bgm_track = -1;
    }
    if (heart_track != -1) {
        if (audio_is_playing(heart_track)) {
            var _hm = global.music_on ? global.music_vol : 0;
            audio_sound_gain(heart_track, heart_target * _hm * _m, 0);
        } else heart_track = -1;
    }
    if (walk_track != -1) {
        if (audio_is_playing(walk_track)) {
            var _wm = global.music_on ? global.music_vol : 0;
            audio_sound_gain(walk_track, (move_target == 1 ? _wm : 0) * _m, 0);
        } else walk_track = -1;
    }
    if (run_track != -1) {
        if (audio_is_playing(run_track)) {
            var _rm = global.music_on ? global.music_vol : 0;
            audio_sound_gain(run_track, (move_target == 2 ? _rm : 0) * _m, 0);
        } else run_track = -1;
    }
};

set_music_vol = function(_v) {
    global.music_vol = clamp(_v, 0, 1);
    apply_audio_volumes();
    save_settings();
};

set_sfx_vol = function(_v) {
    global.sfx_vol = clamp(_v, 0, 1);
    save_settings();
};

set_master_vol = function(_v) {
    global.master_vol = clamp(_v, 0, 1);
    apply_audio_volumes();
    save_settings();
};

toggle_music = function() {
    global.music_on = !global.music_on;
    if (!global.music_on && music_track != -1) {
        if (audio_is_playing(music_track)) audio_stop_sound(music_track);
        music_track = -1;
    }
    if (global.music_on) start_bgm();
    apply_audio_volumes();
    save_settings();
};

toggle_sfx = function() {
    global.sfx_on = !global.sfx_on;
    save_settings();
};

play_sfx = function(_snd, _pitch) {
    if (!global.sfx_on) return -1;
    if (_pitch == undefined) _pitch = 1;
    var _id = audio_play_sound(_snd, 10, false);
    audio_sound_pitch(_id, _pitch);
    audio_sound_gain(_id, global.sfx_vol * global.master_vol, 0);
    return _id;
};

// Pitch-varied one-shot for repetitive sounds (pickups, drops, menu, hurt).
sfx_vary = function(_snd, _base, _spread) {
    if (_base == undefined) _base = 1;
    if (_spread == undefined) _spread = 0.08;
    return play_sfx(_snd, random_range(_base - _spread, _base + _spread));
};

// Endless background music. Starts once (menu boot or direct level launch),
// keeps looping across rooms; muting is done via gain, never stopping it.
start_bgm = function() {
    if (!variable_global_exists("bgm_track")) global.bgm_track = -1;
    if (global.bgm_track == -1 || !audio_is_playing(global.bgm_track)) {
        global.bgm_track = -1;
        if (global.music_on) {
            global.bgm_track = audio_play_sound(msc_background, 1, true);
            audio_sound_gain(global.bgm_track, global.music_vol * global.master_vol, 0);
        }
    } else {
        audio_sound_gain(global.bgm_track, global.music_on ? global.music_vol * global.master_vol : 0, 0);
    }
};

play_music = function(_snd) {
    if (!global.music_on) return -1;
    if (music_track != -1 && audio_is_playing(music_track)) audio_stop_sound(music_track);
    music_track = audio_play_sound(_snd, 1, true);
    audio_sound_gain(music_track, global.music_vol * global.master_vol, 0);
    return music_track;
};

stop_music = function() {
    if (music_track != -1) {
        if (audio_is_playing(music_track)) audio_stop_sound(music_track);
        music_track = -1;
    }
};

stop_all_sfx = function() {
    audio_stop_all();
    music_track = -1;
    heart_track = -1;
    walk_track = -1;
    run_track = -1;
    if (variable_global_exists("bgm_track")) global.bgm_track = -1;
};

take_damage = function(_dmg) {
    if (variable_global_exists("transition_lock") && global.transition_lock) return;
    if (global.hp <= 0) return;
    if (instance_exists(obj_player) && obj_player.invuln > 0) return;
    global.hp -= _dmg;
    global.damage_flash = 30; // frames of red overlay
    sfx_vary(snd_hurt, 1, 0.05);
    // I-frames match the enemy attack cycle: windup 18 + recover 12 + 10 buffer.
    // Enemy touch_cd is 60, so any re-windup strikes after these expire: every
    // connected completed swing damages, broken-contact swings still whiff.
    if (instance_exists(obj_player)) obj_player.invuln = 40;
    if (global.hp <= 0) {
        global.hp = 0;
        state = "dead";
        dead_cooldown = 60; // steps before R retry is accepted
    }
};

unlock_achievement = function(_id, _label) {
    var _newly = false;    if (_id == "hidden1" && !global.ach_hidden1) {
        global.ach_hidden1 = true;
        global.ach_title = "SECRET FOUND";
        global.ach_text = _label;
        global.ach_timer = 180;
        _newly = true;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden1", 1);
        ini_close();
    }
    if (_id == "hidden2" && !global.ach_hidden2) {
        global.ach_hidden2 = true;
        global.ach_title = "SECRET FOUND";
        global.ach_text = _label;
        global.ach_timer = 180;
        _newly = true;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden2", 1);
        ini_close();
    }
    if (_id == "hidden3" && !global.ach_hidden3) {
        global.ach_hidden3 = true;
        global.ach_title = "SECRET FOUND";
        global.ach_text = _label;
        global.ach_timer = 180;
        _newly = true;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden3", 1);
        ini_close();
    }
    if (_id == "level" && !global.ach_level) {
        global.ach_level = true;
        global.ach_title = "LEVEL CLEAR";
        global.ach_text = _label;
        global.ach_timer = 180;
        _newly = true;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "level", 1);
        ini_close();
    }
    if (_newly) play_sfx(snd_notification, 1);
};

// Boot the endless background loop (no-op if the menu already started it).
start_bgm();
