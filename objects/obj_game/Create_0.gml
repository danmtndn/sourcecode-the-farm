// obj_game - Create: global state, HP, inventory, achievements, intro/outro text
// EDIT THESE for your story. User chose Intro/outro only.
intro_lines = [
    "THE FARM",
    "You came back to the old farm after the letter...",
    "Find what was left behind. Don't let it catch you.",
    "Press ENTER to begin.  (A/D move, SPACE jump, E interact)"
];
outro_lines = [
    "You unlocked the barn and escaped.",
    "But something still follows...",
    "THE END - Thanks for playing."
];

state = "intro"; // intro -> play -> dead / outro
intro_index = 0;

if (!variable_global_exists("hp")) global.hp = 3;
global.max_hp = 3;
global.has_key = 0;          // keys for obj_door_key
global.code_found = "";      // set by obj_paper, e.g. "4821"
global.final_code = "4821";  // EDIT: code for final door
global.damage_flash = 0;
global.ach_hidden = false;
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
if (ini_key_exists("ach", "hidden")) global.ach_hidden = ini_read_real("ach", "hidden", 0) > 0.5;
if (ini_key_exists("ach", "level")) global.ach_level = ini_read_real("ach", "level", 0) > 0.5;
ini_close();

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
    if (_id == "hidden" && !global.ach_hidden) {
        global.ach_hidden = true;
        global.ach_text = "Achievement: " + _label;
        global.ach_timer = 180;
        ini_open("thefarm_save.ini");
        ini_write_real("ach", "hidden", 1);
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
