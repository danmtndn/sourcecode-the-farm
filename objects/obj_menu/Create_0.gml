// obj_menu - Create: main menu state. No dependencies (obj_game doesn't exist yet).
// EDIT the option labels / tagline for your story.
options = ["Start Game", "Settings", "Achievements", "Quit"];
selected = 0;
menu_settings = false; // false = main options, true = Music/SFX toggles
menu_achievements = false; // true = achievements list (view-only, any key backs out)
tagline = "He swerved to avoid the dead animal... and the farm took him in.";
tag_timer = 0;
tag_speed = 2; // steps per revealed character, matches obj_game typewriter

// Show saved achievements, same ini file obj_game uses.
ach_hidden1 = false;
ach_hidden2 = false;
ach_hidden3 = false;
ach_level = false;
// Achievement list: [label, locked hint]. Labels MUST match obj_game /
// obj_hidden_item or the menu names something the popup never awards.
ach_list = [
    ["Farmhouse Secret", "Find the Level 1 secret"],
    ["Barn Loft Secret", "Find the Level 2 secret"],
    ["Cellar Secret", "Find the Level 3 secret"],
    ["Level unlocked!", "Escape a level"],
];
// Audio toggles live here too so the menu works before obj_game exists.
music_on = true;
sfx_on = true;
music_vol = 0.8;
sfx_vol = 0.8;
master_vol = 1.0;
ini_open("thefarm_save.ini");
if (ini_key_exists("ach", "hidden1")) ach_hidden1 = ini_read_real("ach", "hidden1", 0) > 0.5;
if (ini_key_exists("ach", "hidden2")) ach_hidden2 = ini_read_real("ach", "hidden2", 0) > 0.5;
if (ini_key_exists("ach", "hidden3")) ach_hidden3 = ini_read_real("ach", "hidden3", 0) > 0.5;
if (ini_key_exists("ach", "level")) ach_level = ini_read_real("ach", "level", 0) > 0.5;
if (ini_key_exists("settings", "music")) music_on = ini_read_real("settings", "music", 1) > 0.5;
if (ini_key_exists("settings", "sfx")) sfx_on = ini_read_real("settings", "sfx", 1) > 0.5;
if (ini_key_exists("settings", "music_vol")) music_vol = clamp(ini_read_real("settings", "music_vol", 0.8), 0, 1);
if (ini_key_exists("settings", "sfx_vol")) sfx_vol = clamp(ini_read_real("settings", "sfx_vol", 0.8), 0, 1);
if (ini_key_exists("settings", "master_vol")) master_vol = clamp(ini_read_real("settings", "master_vol", 1), 0, 1);
ini_close();

save_audio = function() {
    ini_open("thefarm_save.ini");
    ini_write_real("settings", "music", music_on ? 1 : 0);
    ini_write_real("settings", "sfx", sfx_on ? 1 : 0);
    ini_write_real("settings", "music_vol", music_vol);
    ini_write_real("settings", "sfx_vol", sfx_vol);
    ini_close();
};

// Live BGM gain for this room's sliders and toggles (obj_game owns the rest).
apply_menu_volumes = function() {
    if (!variable_global_exists("bgm_track")) global.bgm_track = -1;
    if (global.bgm_track != -1 && audio_is_playing(global.bgm_track)) {
        audio_sound_gain(global.bgm_track, music_on ? music_vol * master_vol : 0, 0);
    } else if (music_on) {
        global.bgm_track = audio_play_sound(msc_background, 1, true);
        audio_sound_gain(global.bgm_track, music_vol * master_vol, 0);
    } else global.bgm_track = -1;
};
// Local menu blip with pitch wobble (obj_game does not exist in this room).
menu_blip = function(_base) {
    if (_base == undefined) _base = 1;
    if (!sfx_on) return -1;
    var _id = audio_play_sound(snd_menu, 10, false);
    audio_sound_pitch(_id, random_range(_base - 0.06, _base + 0.06));
    audio_sound_gain(_id, sfx_vol * master_vol, 0);
    return _id;
};

// Boot the endless background loop (obj_game adopts the handle in levels).
apply_menu_volumes();
