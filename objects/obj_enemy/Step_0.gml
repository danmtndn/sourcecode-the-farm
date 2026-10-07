// obj_enemy - Step: patrol until player in range, then chase. Touch = -1 HP.
// Uses custom hsp_enemy/vsp/move_dir only (no built-in hspeed/vspeed/direction).
if (!variable_instance_exists(id, "vsp")) vsp = 0;
if (!variable_instance_exists(id, "move_dir")) move_dir = 1;
if (!variable_instance_exists(id, "hsp_enemy")) hsp_enemy = 0;
if (!variable_instance_exists(id, "jump_cd")) jump_cd = 0;
if (!variable_instance_exists(id, "arrive_range")) arrive_range = 10;
if (!variable_instance_exists(id, "face_deadzone")) face_deadzone = 2;
if (!variable_instance_exists(id, "land_timer")) land_timer = 0;
if (!variable_instance_exists(id, "air_timer")) air_timer = 0;
if (!variable_instance_exists(id, "grounded_prev")) grounded_prev = true;
if (!variable_instance_exists(id, "jump_speed")) jump_speed = -10;

// Variant sprite set applies lazily: spawner assignment and Creation Code
// both run after Create, so pick up the set on first sight (and on change).
if (!variable_instance_exists(id, "applied_variant")) applied_variant = -1;
if (!variable_instance_exists(id, "variant")) variant = 0;
if (applied_variant != variant && variable_instance_exists(id, "apply_variant")) apply_variant();
// Freeze while paused (patrol would otherwise continue behind the pause panel).
if (instance_exists(obj_game) && obj_game.state == "pause") exit;
// Freeze mid-transition: AI must not act behind a black fade (unfair hits).
if (variable_global_exists("transition_lock") && global.transition_lock) exit;

// Spawn-state guards (self-heal if Create didn't run first).
if (!variable_instance_exists(id, "spawning")) spawning = false;
if (!variable_instance_exists(id, "despawning")) despawning = false;
if (!variable_instance_exists(id, "spawn_fade_in")) spawn_fade_in = 30;
if (!variable_instance_exists(id, "spawn_fade_out")) spawn_fade_out = 24;
if (!variable_instance_exists(id, "aggro")) aggro = false;
if (!variable_instance_exists(id, "attacking")) attacking = false;
if (!variable_instance_exists(id, "attack_t")) attack_t = 0;
if (!variable_instance_exists(id, "attack_hit_done")) attack_hit_done = false;
if (!variable_instance_exists(id, "attack_windup")) attack_windup = 18;
if (!variable_instance_exists(id, "attack_recover")) attack_recover = 12;
if (!variable_instance_exists(id, "aggro_grace")) aggro_grace = 180;
if (!variable_instance_exists(id, "aggro_timer")) aggro_timer = 0;

// Spawned by obj_spawner: fade in harmless, fade out to despawn.
if (spawning) {
    image_alpha = min(image_alpha + 1 / max(1, spawn_fade_in), 1);
    if (image_alpha >= 1) spawning = false; // active from now on
    exit; // frozen mid-materialize: no AI, gravity, or damage (fair)
}
if (despawning) {
    image_alpha -= 1 / max(1, spawn_fade_out);
    if (image_alpha <= 0) { instance_destroy(); exit; }
    exit; // frozen and harmless while vanishing
}

if (touch_cd > 0) touch_cd -= 1;
if (jump_cd > 0) jump_cd -= 1;
vsp += grav;

// Depenetration: a box pushed/fallen into us can leave us overlapped.
// Push out vertically first (up), then horizontally, so we never stay stuck inside a box/wall/door.
if (place_meeting(x, y, obj_pushable) || place_meeting(x, y, obj_solid) || place_meeting(x, y, obj_door_key) || place_meeting(x, y, obj_door_final)) {
    var _out = 0;
    while (place_meeting(x, y, obj_pushable) && _out < 64) {
        if (!place_meeting(x, y - 1, obj_solid) && !place_meeting(x, y - 1, obj_pushable)
        && !place_meeting(x, y - 1, obj_door_key) && !place_meeting(x, y - 1, obj_door_final)) y -= 1;
        else break;
        _out += 1;
    }
    _out = 0;
    while ((place_meeting(x, y, obj_pushable) || place_meeting(x, y, obj_solid)
    || place_meeting(x, y, obj_door_key) || place_meeting(x, y, obj_door_final)) && _out < 64) {
        var _edir = -sign(move_dir);
        if (_edir == 0) _edir = 1;
        if (!place_meeting(x + _edir, y, obj_solid) && !place_meeting(x + _edir, y, obj_pushable)
        && !place_meeting(x + _edir, y, obj_door_key) && !place_meeting(x + _edir, y, obj_door_final)) x += _edir;
        else if (!place_meeting(x - _edir, y, obj_solid) && !place_meeting(x - _edir, y, obj_pushable)
        && !place_meeting(x - _edir, y, obj_door_key) && !place_meeting(x - _edir, y, obj_door_final)) x -= _edir;
        else break;
        _out += 1;
    }
    // Still stuck (e.g. box dropped exactly on head): cancel velocity this frame.
    if (place_meeting(x, y, obj_pushable) || place_meeting(x, y, obj_solid)) {
        hsp_enemy = 0;
        vsp = 0;
    }
}

hsp_enemy = 0;
var _chasing = false;

if (instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play") {
    // Rectangular vision: wide horizontal, half as tall (not a circle).
    var _vdx = obj_player.x - x;
    var _vdy = obj_player.y - y;
    if (abs(_vdx) < chase_range && abs(_vdy) < chase_range / 2) _chasing = true;
}

// Aggro expires after losing sight: back to patrol/vision instead of
// hugging a wall forever. Refreshes every step the player stays visible.
if (aggro) {
    if (_chasing) aggro_timer = aggro_grace;
    else {
        aggro_timer -= 1;
        if (aggro_timer <= 0) aggro = false;
    }
}

var _idle_hold = false;
if (_chasing || aggro) { // spawner-spawned enemies chase from activation
    if (instance_exists(obj_player)) {
        var _pdx = obj_player.x - x;
        if (abs(_pdx) > face_deadzone) move_dir = sign(_pdx); // deadzone: facing never flickers
        if (abs(_pdx) <= arrive_range) {
            hsp_enemy = 0; // arrived: stand ground, idle below
            _idle_hold = true;
        } else hsp_enemy = move_dir * chase_speed;
    } else hsp_enemy = 0;
} else {
    hsp_enemy = move_dir * patrol_speed;
    if (x < patrol_left) move_dir = 1;
    if (x > patrol_right) move_dir = -1;
}

// Attack: telegraphed strike. Touch with cooldown ready STARTS the windup
// (no instant damage); the hit lands only if still touching at the end of
// it, so the player dodges by breaking contact. Frozen in place throughout.
if (!attacking && touch_cd <= 0 && instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play" && place_meeting(x, y, obj_player)) {
    attacking = true;
    attack_t = 0;
    attack_hit_done = false;
}
if (attacking) {
    hsp_enemy = 0; // planted feet: windup, strike, recover all stationary
    attack_t += 1;
    if (attack_t >= attack_windup && !attack_hit_done) {
        attack_hit_done = true;
        if (instance_exists(obj_player) && place_meeting(x, y, obj_player) && instance_exists(obj_game)) {
            obj_game.take_damage(1);
            touch_cd = 60;
            // Knock player away so they can flee (collision-safe placement).
            if (!variable_instance_exists(obj_player.id, "vsp")) obj_player.vsp = 0;
            obj_player.vsp = -8;
            var _kdx = sign(obj_player.x - x);
            if (_kdx == 0) _kdx = 1;
            for (var _k = 0; _k < 24; _k++) {
                if (!place_meeting(obj_player.x + _kdx, obj_player.y, obj_solid)
                && !place_meeting(obj_player.x + _kdx, obj_player.y, obj_pushable)
                && !place_meeting(obj_player.x + _kdx, obj_player.y, obj_door_key)
                && !place_meeting(obj_player.x + _kdx, obj_player.y, obj_door_final)) {
                    obj_player.x += _kdx;
                } else break;
            }
        }
    }
    if (attack_t >= attack_windup + attack_recover) attacking = false;
}

// Grounded state before moving (drives the slope-down snap later).
var _ewas_ground = (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final));

// Horizontal move, pixel-stepped (no tunneling) with slope-up assist:
// ramps are climbed when blocked by terrain only; boxes and closed doors
// always stop us (turn around while patrolling, hold while chasing).
var _hdir = sign(hsp_enemy);
var _hdist = abs(hsp_enemy);
var _hfull = floor(_hdist);
var _hrem = _hdist - _hfull;
var _hblocked = false;
for (var _hs = 0; _hs < _hfull + (_hrem > 0 ? 1 : 0); _hs++) {
    var _len = (_hrem > 0 && _hs == _hfull) ? _hrem : 1.0;
    var _nx = x + _hdir * _len;
    if (!place_meeting(_nx, y, obj_solid)
    && !place_meeting(_nx, y, obj_pushable)
    && !place_meeting(_nx, y, obj_door_key)
    && !place_meeting(_nx, y, obj_door_final)) {
        x = _nx;
        continue;
    }
    // Blocked: climb terrain-only slopes, else stop.
    var _terrain_only = place_meeting(_nx, y, obj_solid)
        && !place_meeting(_nx, y, obj_pushable)
        && !place_meeting(_nx, y, obj_door_key)
        && !place_meeting(_nx, y, obj_door_final);
    var _box_only = !_terrain_only && place_meeting(_nx, y, obj_pushable)
        && !place_meeting(_nx, y, obj_solid)
        && !place_meeting(_nx, y, obj_door_key)
        && !place_meeting(_nx, y, obj_door_final);
    var _stepped = false;
    if (_terrain_only) {
        var _er = 0;
        while (_er < slope_max && place_meeting(_nx, y - _er, obj_solid)) _er++;
        if (_er < slope_max && !place_meeting(_nx, y - _er, obj_solid)) {
            y -= _er;
            x = _nx;
            _stepped = true;
        }
    } else if (_chasing && _box_only) {
        // Chasing onto a lone box: step up to its top (single boxes never
        // stop us now; stacked pairs still barricade). Needs clear headroom.
        var _br = 0;
        while (_br < 56 && place_meeting(_nx, y - _br, obj_pushable)) _br++;
        if (_br < 56 && _br > 0
        && !place_meeting(_nx, y - _br, obj_solid)
        && !place_meeting(_nx, y - _br, obj_pushable)
        && !place_meeting(_nx, y - _br, obj_door_key)
        && !place_meeting(_nx, y - _br, obj_door_final)) {
            y -= _br;
            x = _nx;
            _stepped = true;
        }
    }
    if (!_stepped) { _hblocked = true; break; }
}
if (_hblocked) {
    hsp_enemy = 0;
    if (!_chasing) {
        // Turn around, unless boxed in on both sides (hold, don't jitter).
        var _back = -_hdir;
        if (_back == 0) _back = 1;
        if (place_meeting(x + _back, y, obj_solid)
        || place_meeting(x + _back, y, obj_pushable)
        || place_meeting(x + _back, y, obj_door_key)
        || place_meeting(x + _back, y, obj_door_final)) {
            // nowhere to turn to: hold still, facing stays put
        } else move_dir *= -1; // turn around on wall/box/door while patrolling
    } else if (_ewas_ground && jump_cd <= 0) {
        // Chasing and stuck: hop pushable boxes and low ledges, or jump for
        // a player above. Tall walls/doors still hold us (no bunny-hopping
        // pointlessly at them).
        var _boxwall = place_meeting(x + move_dir, y, obj_pushable);
        var _above = instance_exists(obj_player) && obj_player.y < y - 40;
        if (_boxwall || _above) {
            vsp = jump_speed;
            jump_cd = 40; // one hop attempt, then hold until cooldown clears
        }
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
    && !place_meeting(x, y + sign(vsp), obj_door_final)) y += sign(vsp);
    vsp = 0;
}
y += vsp;

// Slope-down snap: stay glued descending ramps instead of hopping.
if (_ewas_ground && vsp >= 0
&& !place_meeting(x, y + 1, obj_solid)
&& !place_meeting(x, y + 1, obj_pushable)
&& !place_meeting(x, y + 1, obj_door_key)
&& !place_meeting(x, y + 1, obj_door_final)) {
    var _edrop = 0;
    while (_edrop < slope_max
    && !place_meeting(x, y + _edrop + 1, obj_solid)
    && !place_meeting(x, y + _edrop + 1, obj_pushable)
    && !place_meeting(x, y + _edrop + 1, obj_door_key)
    && !place_meeting(x, y + _edrop + 1, obj_door_final)) _edrop++;
    if (_edrop < slope_max) {
        y += _edrop;
        vsp = 0;
    }
}

// Face walk direction (move_dir is always -1 or 1).
image_xscale = move_dir;

// Animation: phased jump (0-1 rise, air to air_end, last 2 land), run grounded.
// Frames driven manually so each phase syncs to physics (player's system:
// takeoff crouch, air frames while falling, landing beat after real air).
var _eground_now = (place_meeting(x, y + 1, obj_solid)
|| place_meeting(x, y + 1, obj_pushable)
|| place_meeting(x, y + 1, obj_door_key)
|| place_meeting(x, y + 1, obj_door_final));
var _etook_off = (grounded_prev && !_eground_now);
var _elanded = (!grounded_prev && _eground_now);
if (!_eground_now) air_timer += 1;
if (_elanded) {
    if (air_timer > 6) land_timer = 10; // real jump/fall: play the landing beat
    air_timer = 0; // tiny step-downs don't trigger it
}
if (land_timer > 0) land_timer -= 1;
var _e_air_end = image_number - 3; // last air frame, held on long falls
var _e_land_a = image_number - 2; // landing beat, first frame
var _e_land_b = image_number - 1; // landing beat, held crouch
var _ewant = spr_run;
if (attacking) _ewant = spr_attack;
else if (!_eground_now) _ewant = spr_jump;
else if (land_timer > 0) _ewant = spr_jump;
else if (_idle_hold) _ewant = spr_idle;
if (sprite_index != _ewant) {
    sprite_index = _ewant;
    image_index = 0;
}
// Takeoff frame from physics: jumped = crouch, walked off = airborne.
// (Skipped while attacking: the swing owns its frames, see below.)
if (_etook_off && !attacking) image_index = (vsp < 0) ? 0 : 2;
if (_ewant == spr_attack) {
    // Windup frames 0-2, strike/recover 3-4 (5-frame strip).
    if (attack_t < attack_windup) image_index = min(floor(attack_t / max(1, attack_windup) * 3), 2);
    else image_index = min(3 + floor((attack_t - attack_windup) / max(1, attack_recover) * 2), 4);
} else if (_ewant == spr_jump) {
    if (!_eground_now) {
        if (vsp < 0) image_index = min(image_index + 0.12, 2); // rise: crouch to air
        else if (image_index < _e_air_end) image_index = min(image_index + 0.3, _e_air_end); // fall: hold last air
    } else if (land_timer > 0) {
        if (image_index < _e_land_a) image_index = _e_land_a;
        else image_index = min(image_index + 0.25, _e_land_b); // landing beat, hold crouch
    }
}
grounded_prev = _eground_now;
