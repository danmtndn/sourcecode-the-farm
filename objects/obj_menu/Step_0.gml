// obj_menu - Step: W/S or Up/Down to move, ENTER/SPACE to confirm, ESC backs out.
// Inputs are ignored while a black fade transition is running.
if (tag_timer < string_length(tagline) * tag_speed) tag_timer += 1;
if (variable_global_exists("transition_lock") && global.transition_lock) exit;

// Achievements view: static list, any confirm or ESC backs out.
if (menu_achievements) {
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_escape)) {
        menu_achievements = false;
        selected = 2; // land back on "Achievements"
        menu_blip(1);
    }
    exit;
}

var _rows = menu_settings ? 5 : array_length(options);
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
if (_up) selected = (selected - 1 + _rows) mod _rows;
if (_down) selected = (selected + 1) mod _rows;
if (_up || _down) menu_blip(1.2);

if (menu_settings && keyboard_check_pressed(vk_escape)) {
    menu_settings = false;
    selected = 1; // land back on "Settings"
    menu_blip(1);
} else {
    var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
    var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
    var _confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
    if (menu_settings) {
        // 0 Music ON/OFF, 1 Music volume, 2 Sound ON/OFF, 3 Sound volume, 4 Back.
        if ((_confirm || _left || _right) && selected == 0) {
            music_on = !music_on;
            save_audio();
            apply_menu_volumes();
            menu_blip(1);
        } else if ((_left || _right) && selected == 1) {
            music_vol = clamp(music_vol + (_right ? 0.1 : -0.1), 0, 1);
            save_audio();
            apply_menu_volumes();
            menu_blip(1);
        } else if (_confirm && selected == 1) {
            music_vol = (music_vol + 0.1 > 1) ? 0 : music_vol + 0.1;
            save_audio();
            apply_menu_volumes();
            menu_blip(1);
        } else if ((_confirm || _left || _right) && selected == 2) {
            sfx_on = !sfx_on;
            save_audio();
            menu_blip(1);
        } else if ((_left || _right) && selected == 3) {
            sfx_vol = clamp(sfx_vol + (_right ? 0.1 : -0.1), 0, 1);
            save_audio();
            menu_blip(1);
        } else if (_confirm && selected == 3) {
            sfx_vol = (sfx_vol + 0.1 > 1) ? 0 : sfx_vol + 0.1;
            save_audio();
            menu_blip(1);
        } else if (_confirm && selected == 4) {
            menu_settings = false;
            selected = 1;
            menu_blip(1);
        }
    } else if (_confirm) {
        if (selected == 0) {
            menu_blip(1);
            if (instance_exists(obj_fade)) {
                with (obj_fade) fade_start("goto", rm_level_1);
            } else room_goto(rm_level_1);
        }
        else if (selected == 1) {
            menu_settings = true;
            selected = 0;
            menu_blip(1);
        } else if (selected == 2) {
            menu_achievements = true;
            menu_blip(1);
        } else if (selected == 3) game_end();
    }
}
