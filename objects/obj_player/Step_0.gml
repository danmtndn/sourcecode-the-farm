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

// Pushable: if walking into box and box can move, move box same amount.
// Else stop player at box edge.
var _box = instance_place(x + hsp, y, obj_pushable);
if (_box != noone && hsp != 0) {
    var _push_dir = sign(hsp);
    var _box_can_move = true;
    // Would box hit a wall at its destination? (checked from player scope;
    // masks are same placeholder sprite, so result matches box mask)
    if (place_meeting(_box.x + hsp, _box.y, obj_solid)) _box_can_move = false;
    // Would box hit another box?
    if (_box_can_move) {
        var _hit2 = instance_place(_box.x + hsp, _box.y, obj_pushable);
        if (_hit2 != noone && _hit2 != _box) _box_can_move = false;
    }
    if (_box_can_move) {
        _box.x += hsp; // same speed as player so they stay together
    } else {
        // Blocked: snap player to contact edge and stop
        while (!place_meeting(x + _push_dir, y, obj_pushable)
        && !place_meeting(x + _push_dir, y, obj_solid)
        && abs(x - _box.x) > 1) {
            x += _push_dir;
            if (abs(x) > room_width + 1000) break;
        }
        hsp = 0;
    }
}

x += hsp;

// Vertical collide (stand on both ground AND boxes so pushable works as platform)
if (place_meeting(x, y + vsp, obj_solid) || place_meeting(x, y + vsp, obj_pushable)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)
    && !place_meeting(x, y + sign(vsp), obj_pushable)) {
        y += sign(vsp);
    }
    vsp = 0;
}
y += vsp;

// Grounded jump (from ground or box)
if (jump_key_pressed && (place_meeting(x, y + 1, obj_solid) || place_meeting(x, y + 1, obj_pushable))) {
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
