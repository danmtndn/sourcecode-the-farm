// obj_enemy - Step: patrol until player in range, then chase. Touch = -1 HP.
// Uses custom hsp_enemy/vsp/move_dir only (no built-in hspeed/vspeed/direction).
if (!variable_instance_exists(id, "vsp")) vsp = 0;
if (!variable_instance_exists(id, "move_dir")) move_dir = 1;
if (!variable_instance_exists(id, "hsp_enemy")) hsp_enemy = 0;

// Freeze while paused (patrol would otherwise continue behind the pause panel).
if (instance_exists(obj_game) && obj_game.state == "pause") exit;

if (touch_cd > 0) touch_cd -= 1;
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
    var _dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (_dist < chase_range) _chasing = true;
}

if (_chasing) {
    move_dir = sign(obj_player.x - x);
    if (move_dir == 0) move_dir = 1;
    hsp_enemy = move_dir * chase_speed;
} else {
    hsp_enemy = move_dir * patrol_speed;
    if (x < patrol_left) move_dir = 1;
    if (x > patrol_right) move_dir = -1;
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
    var _stepped = false;
    if (_terrain_only) {
        var _er = 0;
        while (_er < slope_max && place_meeting(_nx, y - _er, obj_solid)) _er++;
        if (_er < slope_max && !place_meeting(_nx, y - _er, obj_solid)) {
            y -= _er;
            x = _nx;
            _stepped = true;
        }
    }
    if (!_stepped) { _hblocked = true; break; }
}
if (_hblocked) {
    hsp_enemy = 0;
    if (!_chasing) move_dir *= -1; // turn around on wall/box/door while patrolling
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

// Damage player on touch (with per-enemy cooldown + player invuln)
if (touch_cd <= 0 && instance_exists(obj_player) && place_meeting(x, y, obj_player)) {
    if (instance_exists(obj_game)) {
        obj_game.take_damage(1);
        touch_cd = 60;
        // Knock player away so they can flee (collision-safe so player never ends up inside a box/wall/closed door)
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
