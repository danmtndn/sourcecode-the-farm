// obj_player - Step: horizontal move + jump + collide + push + damage
// Uses custom hsp/vsp only (no built-in hspeed/vspeed/direction).
if (!variable_instance_exists(id, "hsp")) hsp = 0;
if (!variable_instance_exists(id, "vsp")) vsp = 0;

right_key = keyboard_check(ord("D")) || keyboard_check(vk_right);
left_key  = keyboard_check(ord("A")) || keyboard_check(vk_left);
jump_key_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_space);
interact_pressed = keyboard_check_pressed(ord("E"));

if (interact_cd > 0) interact_cd -= 1;
if (invuln > 0) invuln -= 1;

// Pause during intro / outro / death (obj_game controls state)
if (instance_exists(obj_game)) {
    if (obj_game.state != "play") {
        hsp = 0;
        vsp += grav;
        if (place_meeting(x, y + vsp, obj_solid)) {
            while (!place_meeting(x, y + sign(vsp), obj_solid)) y += sign(vsp);
            vsp = 0;
        }
        y += vsp;
        x += hsp;
        exit;
    }
}

var _move = (right_key ? 1 : 0) - (left_key ? 1 : 0);
if (_move != 0) face = _move;

hsp = _move * move_speed;
vsp += grav;

// Horizontal collide (walls + pushable boxes)
if (place_meeting(x + hsp, y, obj_solid)) {
    while (!place_meeting(x + sign(hsp), y, obj_solid)) x += sign(hsp);
    hsp = 0;
}

// Pushable: try to push box if moving into it and space beyond is free
var _box = instance_place(x + hsp, y, obj_pushable);
if (_box != noone && hsp != 0) {
    var _dir = sign(hsp);
    // Only push horizontally when player is roughly on same height and box can move
    if (!place_meeting(_box.x + _dir * 4, _box.y, obj_solid)
    && !place_meeting(_box.x + _dir * 4, _box.y, obj_pushable)) {
        _box.x += _dir * 3;
    } else {
        // Blocked: stop player
        if (place_meeting(x + hsp, y, obj_pushable)) hsp = 0;
    }
}

x += hsp;

// Vertical collide
if (place_meeting(x, y + vsp, obj_solid)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// Grounded jump
if (jump_key_pressed && place_meeting(x, y + 1, obj_solid)) {
    vsp = jump_speed;
}

// Fell out of room
if (y > room_height + 200) {
    if (instance_exists(obj_game)) {
        obj_game.take_damage(1);
        // Respawn at room start
        x = obj_game.spawn_x;
        y = obj_game.spawn_y;
        vsp = 0;
    }
}
