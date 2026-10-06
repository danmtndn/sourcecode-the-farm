// obj_menu - Step: W/S or Up/Down to move, ENTER/SPACE to confirm, ESC backs out.
if (tag_timer < string_length(tagline) * tag_speed) tag_timer += 1;

var _rows = menu_settings ? 3 : array_length(options);
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
if (_up) selected = (selected - 1 + _rows) mod _rows;
if (_down) selected = (selected + 1) mod _rows;

if (menu_settings && keyboard_check_pressed(vk_escape)) {
    menu_settings = false;
    selected = 1; // land back on "Settings"
} else {
    var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
    var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
    var _confirm = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
    if (menu_settings) {
        // 0 Music toggle, 1 SFX toggle, 2 Back. Left/Right also flip toggles.
        if ((_confirm || _left || _right) && selected == 0) {
            music_on = !music_on;
            save_audio();
        } else if ((_confirm || _left || _right) && selected == 1) {
            sfx_on = !sfx_on;
            save_audio();
        } else if (_confirm && selected == 2) {
            menu_settings = false;
            selected = 1;
        }
    } else if (_confirm) {
        if (selected == 0) room_goto(rm_level_3);
        else if (selected == 1) {
            menu_settings = true;
            selected = 0;
        } else if (selected == 2) game_end();
    }
}
