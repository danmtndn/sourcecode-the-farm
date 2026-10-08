// obj_door_key - Step: E with key -> animate open; finished -> passable
// open door (never destroyed, never loops: holds the last frame).
if (!instance_exists(obj_player) || obj_game.state != "play") exit;
if (!opened) {
    image_index = 0; // locked: hold the shut frame
    if (point_distance(x, y, obj_player.x, obj_player.y) < 64
    && keyboard_check_pressed(ord("E"))) {
        if (global.has_key >= keys_needed) {
            global.has_key -= keys_needed;
            opened = true; // animation below takes over; still solid until it ends
            if (instance_exists(obj_game)) obj_game.sfx_vary(snd_door, 1, 0.08);
        }
    }
} else {
    image_index += door_anim_rate;
    if (image_index >= image_number - 1) {
        image_index = image_number - 1;
        instance_change(obj_door_open, false); // persists, passable, holds frame
    }
}
