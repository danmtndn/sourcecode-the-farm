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
        if (place_meeting(x, y + vsp, obj_solid)
        || place_meeting(x, y + vsp, obj_pushable)
        || place_meeting(x, y + vsp, obj_door_key)
        || place_meeting(x, y + vsp, obj_door_final)) {
            while (!place_meeting(x, y + sign(vsp), obj_solid)
            && !place_meeting(x, y + sign(vsp), obj_pushable)
            && !place_meeting(x, y + sign(vsp), obj_door_key)
            && !place_meeting(x, y + sign(vsp), obj_door_final)) y += sign(vsp);
            vsp = 0;
        }
        y += vsp;
        x += hsp;
        exit;
    }
}

var _move = (right_key ? 1 : 0) - (left_key ? 1 : 0);
if (_move != 0) {
	face = _move;
	image_xscale = face;
}

// Reset each step; set to true below only when a box is actually engaged.
// (Sprite is picked at the end of the step so this flag is always fresh.)
pushing = false;

hsp = _move * move_speed;
vsp += grav;

// Horizontal collide (walls + closed doors are solid)
if (place_meeting(x + hsp, y, obj_solid)
|| place_meeting(x + hsp, y, obj_door_key)
|| place_meeting(x + hsp, y, obj_door_final)) {
    while (!place_meeting(x + sign(hsp), y, obj_solid)
    && !place_meeting(x + sign(hsp), y, obj_door_key)
    && !place_meeting(x + sign(hsp), y, obj_door_final)) x += sign(hsp);
    hsp = 0;
}

// Pushable: pixel-step push so neither player nor box can tunnel/clip.
// Box is blocked by walls, other boxes, closed doors and the enemy (heavy, never pushed).
var _box = instance_place(x + hsp, y, obj_pushable);
if (_box != noone && hsp != 0) {
    pushing = true; // engaged with a box (even if it ends up blocked)
    var _push_dir = sign(hsp);
    var _steps = abs(hsp);
    var _moved = 0;
    for (var _i = 0; _i < _steps; _i++) {
        // Would box hit something at its next pixel? (checked from player scope;
        // masks are same placeholder sprite, so result matches box mask)
        var _box_blocked = false;
        if (place_meeting(_box.x + _push_dir, _box.y, obj_solid)) _box_blocked = true;
        if (! _box_blocked && place_meeting(_box.x + _push_dir, _box.y, obj_door_key)) _box_blocked = true;
        if (! _box_blocked && place_meeting(_box.x + _push_dir, _box.y, obj_door_final)) _box_blocked = true;
        if (!_box_blocked) {
            var _hit2 = instance_place(_box.x + _push_dir, _box.y, obj_pushable);
            if (_hit2 != noone && _hit2 != _box) _box_blocked = true;
        }
        // Never shove the box into the enemy (would embed enemy inside box).
        if (!_box_blocked && instance_exists(obj_enemy)) {
            var _hitE = instance_place(_box.x + _push_dir, _box.y, obj_enemy);
            if (_hitE != noone) _box_blocked = true;
        }
        // Would player hit a wall/door at ITS next pixel?
        if (!_box_blocked
        && (place_meeting(x + _push_dir, y, obj_solid)
        || place_meeting(x + _push_dir, y, obj_door_key)
        || place_meeting(x + _push_dir, y, obj_door_final))) {
            _box_blocked = true;
        }
        if (_box_blocked) break;
        _box.x += _push_dir;
        x += _push_dir;
        _moved += 1;
    }
    if (_moved < _steps) {
        // Blocked partway: snap player to contact edge and stop leftover motion
        while (!place_meeting(x + _push_dir, y, obj_pushable)
        && !place_meeting(x + _push_dir, y, obj_solid)
        && !place_meeting(x + _push_dir, y, obj_door_key)
        && !place_meeting(x + _push_dir, y, obj_door_final)
        && abs(x - _box.x) > 1) {
            x += _push_dir;
            if (abs(x) > room_width + 1000) break;
        }
    }
    hsp = 0; // horizontal motion already applied pixel-by-pixel above
}

x += hsp;

// Depenetration: if we somehow start overlapped with a box (box fell on us,
// respawn, room start), push out vertically first, then horizontally.
if (place_meeting(x, y, obj_pushable)) {
    var _up = 0;
    while (place_meeting(x, y, obj_pushable) && _up < 64) {
        if (!place_meeting(x, y - 1, obj_solid) && !place_meeting(x, y - 1, obj_pushable)) y -= 1;
        else break;
        _up += 1;
    }
    var _side = 0;
    while (place_meeting(x, y, obj_pushable) && _side < 64) {
        var _dir = (face != 0) ? -sign(face) : 1;
        if (_dir == 0) _dir = 1;
        if (!place_meeting(x + _dir, y, obj_solid) && !place_meeting(x + _dir, y, obj_pushable)) x += _dir;
        else break;
        _side += 1;
    }
}

// Vertical collide (stand on ground AND boxes AND closed door tops)
if (place_meeting(x, y + vsp, obj_solid)
|| place_meeting(x, y + vsp, obj_pushable)
|| place_meeting(x, y + vsp, obj_door_key)
|| place_meeting(x, y + vsp, obj_door_final)) {
    while (!place_meeting(x, y + sign(vsp), obj_solid)
    && !place_meeting(x, y + sign(vsp), obj_pushable)
    && !place_meeting(x, y + sign(vsp), obj_door_key)
    && !place_meeting(x, y + sign(vsp), obj_door_final)) {
        y += sign(vsp);
    }
    vsp = 0;
}
y += vsp;

// Grounded jump (from ground, box or closed door top)
if (jump_key_pressed && (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final))) {
    vsp = jump_speed;
}

// Animation: jump while airborne, push while shoving a box, walk/idle grounded.
// Evaluated after movement so `pushing` reflects this frame's actual push.
var _grounded_now = (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final));
var _want = spr_player_idle;
if (!_grounded_now) _want = spr_player_jump;
else if (pushing && _move != 0) _want = spr_player_push;
else if (_move != 0) _want = spr_player_walk;
if (sprite_index != _want) {
    sprite_index = _want;
    image_index = 0; // restart the new animation from its first frame
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
