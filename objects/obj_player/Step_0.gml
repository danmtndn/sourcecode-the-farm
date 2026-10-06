// obj_player - Step: horizontal move + jump + collide + push + damage
// Uses custom hsp/vsp only (no built-in hspeed/vspeed/direction).
if (!variable_instance_exists(id, "hsp")) hsp = 0;
if (!variable_instance_exists(id, "vsp")) vsp = 0;

// Hard freeze while paused: no gravity, motion, or cooldown timers.
// (The intro/outro/death branch below intentionally still settles.)
if (instance_exists(obj_game) && obj_game.state == "pause") exit;

right_key = keyboard_check(ord("D")) || keyboard_check(vk_right);
left_key  = keyboard_check(ord("A")) || keyboard_check(vk_left);
jump_key_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_space);
interact_pressed = keyboard_check_pressed(ord("E"));

if (interact_cd > 0) interact_cd -= 1;
if (invuln > 0) invuln -= 1;

// Settle during intro / outro / death (pause freezes above; obj_game controls state)
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

// Grounded state before moving (drives the slope-down snap later).
var _was_grounded = (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final));

// Horizontal collide (walls + closed doors are solid), with slope-up
// assist: step onto ramps and low lips within reach instead of stopping.
// (slope_max lives in Create; doors are far taller, so they still block.)
if (place_meeting(x + hsp, y, obj_solid)
|| place_meeting(x + hsp, y, obj_door_key)
|| place_meeting(x + hsp, y, obj_door_final)) {
    var _rise = 0;
    while (_rise < slope_max
    && (place_meeting(x + hsp, y - _rise, obj_solid)
    || place_meeting(x + hsp, y - _rise, obj_door_key)
    || place_meeting(x + hsp, y - _rise, obj_door_final))) _rise++;
    // Climb only onto a fully free cell (never rise into an overhanging box).
    if (_rise < slope_max
    && !place_meeting(x + hsp, y - _rise, obj_solid)
    && !place_meeting(x + hsp, y - _rise, obj_door_key)
    && !place_meeting(x + hsp, y - _rise, obj_door_final)
    && !place_meeting(x + hsp, y - _rise, obj_pushable)) {
        y -= _rise; // climb; x += hsp below carries us forward
    } else {
        while (!place_meeting(x + sign(hsp), y, obj_solid)
        && !place_meeting(x + sign(hsp), y, obj_door_key)
        && !place_meeting(x + sign(hsp), y, obj_door_final)) x += sign(hsp);
        hsp = 0;
    }
}

// Pushable: pixel-step push so neither player nor box can tunnel/clip.
// Box is blocked by walls, other boxes, closed doors and the enemy (heavy, never pushed).
// NOTE: box-destination tests run with the BOX mask (ours is narrower), so
// boxes stop exactly at contact instead of sinking ~12px into things.
var _box = instance_place(x + hsp, y, obj_pushable);
if (_box != noone && hsp != 0) {
    pushing = true; // engaged with a box (even if it ends up blocked)
    var _push_dir = sign(hsp);
    var _steps = abs(hsp);
    var _moved = 0;
    var _keep_mask = mask_index;
    for (var _i = 0; _i < _steps; _i++) {
        // Destination tests with the BOX mask (48px sprite), not our
        // narrower 23px body, so edges register exactly.
        mask_index = spr_pushable;
        var _solid_hit = place_meeting(_box.x + _push_dir, _box.y, obj_solid);
        var _door_hit = place_meeting(_box.x + _push_dir, _box.y, obj_door_key)
            || place_meeting(_box.x + _push_dir, _box.y, obj_door_final);
        var _foe_hit = instance_exists(obj_enemy)
            && instance_place(_box.x + _push_dir, _box.y, obj_enemy) != noone;
        mask_index = _keep_mask;
        // Other-box overlap via exact extents. (instance_place returns a
        // single match, so a neighbor hiding behind _box itself would slip
        // through — and boxes may be scaled, so each side is measured.)
        // Sprite is 48px, bottom-center origin: 24*sx each side, 48*sy tall.
        var _box_hit = false;
        var _bcount = instance_number(obj_pushable);
        for (var _bix = 0; _bix < _bcount; _bix++) {
            var _btest = instance_find(obj_pushable, _bix);
            if (_btest == _box) continue;
            var _tx = _box.x + _push_dir;
            if (_tx - 24 * _box.image_xscale < _btest.x + 24 * _btest.image_xscale
            && _tx + 24 * _box.image_xscale > _btest.x - 24 * _btest.image_xscale
            && _box.y - 48 * _box.image_yscale < _btest.y
            && _box.y > _btest.y - 48 * _btest.image_yscale) { _box_hit = true; break; }
        }
        // Player path with the PLAYER mask.
        var _player_hit = place_meeting(x + _push_dir, y, obj_solid)
            || place_meeting(x + _push_dir, y, obj_door_key)
            || place_meeting(x + _push_dir, y, obj_door_final);
        if (!_solid_hit && !_door_hit && !_foe_hit && !_box_hit && !_player_hit) {
            _box.x += _push_dir;
            x += _push_dir;
            _moved += 1;
            continue;
        }
        // Blocked: slope assist — step the box up terrain ramps, but only on
        // solid-only contact with the player path free (never climb boxes,
        // doors, foes, and never drag the player into a wall).
        if (!_solid_hit || _door_hit || _box_hit || _foe_hit || _player_hit) break;
        var _brise = 0;
        mask_index = spr_pushable;
        while (_brise < slope_max && place_meeting(_box.x + _push_dir, _box.y - _brise, obj_solid)) _brise++;
        mask_index = _keep_mask;
        if (_brise <= 0 || _brise >= slope_max) break;
        // Raised cell must be free of EVERYTHING: re-verify terrain there,
        // plus an extents check so a stack waiting above stops the climb
        // instead of letting the box rise into it.
        var _ux = _box.x + _push_dir;
        var _uy = _box.y - _brise;
        mask_index = spr_pushable;
        var _up_clear = !place_meeting(_ux, _uy, obj_solid)
            && !place_meeting(_ux, _uy, obj_door_key)
            && !place_meeting(_ux, _uy, obj_door_final)
            && (!instance_exists(obj_enemy) || instance_place(_ux, _uy, obj_enemy) == noone);
        mask_index = _keep_mask;
        var _up_box = false;
        for (var _bux = 0; _bux < _bcount; _bux++) {
            var _bup = instance_find(obj_pushable, _bux);
            if (_bup == _box) continue;
            if (_ux - 24 * _box.image_xscale < _bup.x + 24 * _bup.image_xscale
            && _ux + 24 * _box.image_xscale > _bup.x - 24 * _bup.image_xscale
            && _uy - 48 * _box.image_yscale < _bup.y
            && _uy > _bup.y - 48 * _bup.image_yscale) { _up_box = true; break; }
        }
        if (!_up_clear || _up_box) break;
        _box.x += _push_dir;
        _box.y -= _brise;
        x += _push_dir;
        _moved += 1;
    }
    mask_index = _keep_mask; // safety: never leave the step on the box mask
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

// Slope-down snap: stay glued descending ramps so grounding (and jump)
// never flickers. Only when grounded before, falling now (not jumping),
// and actually moving — a real fall past slope_max keeps falling.
if (_was_grounded && vsp >= 0 && _move != 0
&& !place_meeting(x, y + 1, obj_solid)
&& !place_meeting(x, y + 1, obj_pushable)
&& !place_meeting(x, y + 1, obj_door_key)
&& !place_meeting(x, y + 1, obj_door_final)) {
    var _drop = 0;
    while (_drop < slope_max
    && !place_meeting(x, y + _drop + 1, obj_solid)
    && !place_meeting(x, y + _drop + 1, obj_pushable)
    && !place_meeting(x, y + _drop + 1, obj_door_key)
    && !place_meeting(x, y + _drop + 1, obj_door_final)) _drop++;
    if (_drop < slope_max) {
        y += _drop;
        vsp = 0;
    }
}

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
