// obj_menu - Create: main menu state. No dependencies (obj_game doesn't exist yet).
// EDIT the option labels / tagline for your story.
options = ["Start Game", "Settings", "Achievements", "Quit"];
selected = 0;
menu_settings = false; // false = main options, true = Music/SFX toggles
menu_achievements = false; // true = achievements list (view-only, any key backs out)
tagline = "You came back to the old farm after the letter...";
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
ini_open("thefarm_save.ini");
if (ini_key_exists("ach", "hidden1")) ach_hidden1 = ini_read_real("ach", "hidden1", 0) > 0.5;
if (ini_key_exists("ach", "hidden2")) ach_hidden2 = ini_read_real("ach", "hidden2", 0) > 0.5;
if (ini_key_exists("ach", "hidden3")) ach_hidden3 = ini_read_real("ach", "hidden3", 0) > 0.5;
if (ini_key_exists("ach", "level")) ach_level = ini_read_real("ach", "level", 0) > 0.5;
if (ini_key_exists("settings", "music")) music_on = ini_read_real("settings", "music", 1) > 0.5;
if (ini_key_exists("settings", "sfx")) sfx_on = ini_read_real("settings", "sfx", 1) > 0.5;
ini_close();

save_audio = function() {
    ini_open("thefarm_save.ini");
    ini_write_real("settings", "music", music_on ? 1 : 0);
    ini_write_real("settings", "sfx", sfx_on ? 1 : 0);
    ini_close();
};
