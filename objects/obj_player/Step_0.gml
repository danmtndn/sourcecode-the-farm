// obj_player - Step: horizontal move + jump + collide + push + damage
// Uses custom hsp/vsp only (no built-in hspeed/vspeed/direction).
if (!variable_instance_exists(id, "hsp")) hsp = 0;
if (!variable_instance_exists(id, "vsp")) vsp = 0;
// Self-heal anim state if Create didn't run first (stale build): reading
// an unset instance var crashes the step, same pattern as hsp/vsp above.
if (!variable_instance_exists(id, "grounded_prev")) grounded_prev = true;
if (!variable_instance_exists(id, "land_timer")) land_timer = 0;
if (!variable_instance_exists(id, "air_timer")) air_timer = 0;

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

// Chase sense: sprint while any enemy actively hunts us (aggro latched,
// or inside its rectangular vision). Read-only: never writes enemies.
if (!variable_instance_exists(id, "running")) running = false;
if (!variable_instance_exists(id, "calm_timer")) calm_timer = 0;
if (!variable_instance_exists(id, "being_chased")) being_chased = false;
if (!variable_instance_exists(id, "walk_speed")) walk_speed = 3;
if (!variable_instance_exists(id, "run_speed")) run_speed = 4.5;
being_chased = false;
if (instance_exists(obj_enemy) && instance_exists(obj_game) && obj_game.state == "play") {
    var _ec = instance_number(obj_enemy);
    for (var _ei = 0; _ei < _ec; _ei++) {
        var _en = instance_find(obj_enemy, _ei);
        if (_en.aggro || (abs(x - _en.x) < _en.chase_range && abs(y - _en.y) < _en.chase_range / 2)) {
            being_chased = true;
            break;
        }
    }
}
if (being_chased) calm_timer = 45; // stay sprinting briefly after danger passes
else if (calm_timer > 0) calm_timer -= 1;
running = (being_chased || calm_timer > 0);
move_speed = running ? run_speed : walk_speed;
hsp = _move * move_speed;
vsp += grav;

// Jump wind-up: a started timer crouches locked in place, then launches.
// Committed even if you drift off an edge mid-windup (input-buffer feel).
var _fired = false;
if (anticipate_timer > 0) {
    anticipate_timer -= 1;
    hsp = 0; // planted feet while winding up (also skips the push block)
    if (anticipate_timer <= 0) {
        vsp = jump_speed;
        _fired = true;
    }
}

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
    hsp *= 0.5; // pushing pace: half movespeed (walk 1.5, run ~2.25)
    var _push_dir = sign(hsp);
    // Total push distance may be fractional: whole pixels plus one
    // fractional remainder substep, so speed stays exact (no overshoot).
    var _ptotal = abs(hsp);
    var _pfull = floor(_ptotal);
    var _prem = _ptotal - _pfull;
    var _moved = 0;
    var _keep_mask = mask_index;
    for (var _i = 0; _i < _pfull + (_prem > 0 ? 1 : 0); _i++) {
        var _plen = (_prem > 0 && _i == _pfull) ? _prem : 1.0;
        var _step = _push_dir * _plen;
        // Destination tests with the BOX mask (48px sprite), not our
        // narrower 23px body, so edges register exactly.
        mask_index = spr_pushable;
        var _solid_hit = place_meeting(_box.x + _step, _box.y, obj_solid);
        var _door_hit = place_meeting(_box.x + _step, _box.y, obj_door_key)
            || place_meeting(_box.x + _step, _box.y, obj_door_final);
        var _foe_hit = instance_exists(obj_enemy)
            && instance_place(_box.x + _step, _box.y, obj_enemy) != noone;
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
            var _tx = _box.x + _step;
            if (_tx - 24 * _box.image_xscale < _btest.x + 24 * _btest.image_xscale
            && _tx + 24 * _box.image_xscale > _btest.x - 24 * _btest.image_xscale
            && _box.y - 48 * _box.image_yscale < _btest.y
            && _box.y > _btest.y - 48 * _btest.image_yscale) { _box_hit = true; break; }
        }
        // Player path with the PLAYER mask.
        var _player_hit = place_meeting(x + _step, y, obj_solid)
            || place_meeting(x + _step, y, obj_door_key)
            || place_meeting(x + _step, y, obj_door_final);
        if (!_solid_hit && !_door_hit && !_foe_hit && !_box_hit && !_player_hit) {
            _box.x += _step;
            x += _step;
            _moved += _plen;
            continue;
        }
        // Blocked: slope assist — step the box up terrain ramps, but only on
        // solid-only contact with the player path free (never climb boxes,
        // doors, foes, and never drag the player into a wall).
        if (!_solid_hit || _door_hit || _box_hit || _foe_hit || _player_hit) break;
        var _brise = 0;
        mask_index = spr_pushable;
        while (_brise < slope_max && place_meeting(_box.x + _step, _box.y - _brise, obj_solid)) _brise++;
        mask_index = _keep_mask;
        if (_brise <= 0 || _brise >= slope_max) break;
        // Raised cell must be free of EVERYTHING: re-verify terrain there,
        // plus an extents check so a stack waiting above stops the climb
        // instead of letting the box rise into it.
        var _ux = _box.x + _step;
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
        _box.x += _step;
        _box.y -= _brise;
        x += _step;
        _moved += _plen;
    }
    mask_index = _keep_mask; // safety: never leave the step on the box mask
    if (_moved < _ptotal) {
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

// Grounded jump (from ground, box or closed door top): press starts the
// wind-up instead of launching instantly (max() keeps a 0-step tune working).
if (jump_key_pressed && anticipate_timer <= 0
&& (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final))) {
    anticipate_timer = max(1, anticipate_steps);
}

// Animation: phased jump (0-1 rise, 2-9 air, 10-11 land), push, walk, idle.
// Evaluated after movement so `pushing` reflects this frame's actual push.
// Frames are driven manually so each phase syncs to physics, not wall clock.
var _grounded_now = (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final));
var _took_off = (grounded_prev && !_grounded_now);
var _landed = (!grounded_prev && _grounded_now);
grounded = _grounded_now; // publish for outside readers (walk ambience)
if (!_grounded_now) air_timer += 1;
if (_landed) {
    if (air_timer > 6) land_timer = 10; // real jump: play the landing beat
    air_timer = 0; // tiny step-downs don't trigger it
}
if (land_timer > 0) land_timer -= 1;
// Landing/air indices relative to strip length (strip: 2 ready + air + 2
// land), so trimming or extending frames in the sprite editor can't break
// the mapping the way hardcoded 9/10/11 would.
var _air_end = image_number - 3; // last air frame, held on long falls
var _land_a = image_number - 2; // landing beat, first frame
var _land_b = image_number - 1; // landing beat, held crouch
var _want = spr_player_idle;
// Pressing into a closed door counts as pushing too (doors stay put;
// opened ones change object, so anything still here blocks).
var _door_push = (_move != 0
    && (instance_place(x + sign(_move), y, obj_door_key) != noone
    || instance_place(x + sign(_move), y, obj_door_final) != noone));
if (!_grounded_now) _want = spr_player_jump;
else if ((pushing || _door_push) && _move != 0) _want = spr_player_push;
else if (anticipate_timer > 0 || _fired) _want = spr_player_jump;
else if (land_timer > 0) _want = spr_player_jump;
else if (running && _move != 0) _want = spr_player_run;
else if (_move != 0) _want = spr_player_walk;
if (sprite_index != _want) {
    sprite_index = _want;
    image_index = 0;
}
// Takeoff frame from physics, not input timing (the press already expired
// by the time gravity shows us airborne): jumped = crouch, walked off = air.
// Takeoff: a real launch keeps its wind-up crouch (only restart the strip
// when coming from later frames); walking off an edge starts airborne.
if (_took_off) {
    if (vsp < 0) { if (image_index > 2) image_index = 0; }
    else image_index = 2;
}
if (_want == spr_player_jump) {
    if (!_grounded_now) {
        if (vsp < 0) image_index = min(image_index + rise_rate, 2); // rise: crouch to air
        else if (image_index < _air_end) image_index = min(image_index + 0.3, _air_end); // fall: hold last air
    } else if (anticipate_timer > 0 || _fired) {
        // Wind-up crouch: progress 0->1 across the timer, hold at launch.
        image_index = min((anticipate_steps - anticipate_timer) / max(1, anticipate_steps), 1);
        if (_fired) image_index = 1;
    } else if (land_timer > 0) {
        if (image_index < _land_a) image_index = _land_a;
        else image_index = min(image_index + 0.25, _land_b); // landing beat, hold crouch
    }
}
grounded_prev = _grounded_now;

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
