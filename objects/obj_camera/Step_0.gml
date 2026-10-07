/// @description Control the camera

x += (follow.x - x) * 0.1;
y += (follow.y - y) * 0.1;

// SET THE CAMERA POSITION
var camx = x - (vw / 1.5);
var camy = y - (vh / 1.5);

// Subtle handheld shake while sprinting: ephemeral offset on the APPLIED
// position only (never on x/y, so the smooth follow can't random-walk).
// Frozen outside play (menu/pause/intro) with everything else.
var _shx = 0;
var _shy = 0;
if (instance_exists(obj_player) && instance_exists(obj_game) && obj_game.state == "play"
&& variable_instance_exists(obj_player.id, "running") && obj_player.running) {
    _shx = random_range(-1.5, 1.5);
    _shy = random_range(-1.5, 1.5);
}
camera_set_view_pos (view_camera[0], camx + _shx, camy + _shy);

// PARALLAX: only the far backdrop trails the camera, so it drifts slower
// than the world (depth feel). BG_Mid stays world-locked like normal tiles.
// Offsets are absolute each step (no drift), and freeze on their own
// whenever the camera stops (pause/intro/death/menu).
if (layer_exists(layer_far)) {
    var _cx = camera_get_view_x(view_camera[0]);
    var _cy = camera_get_view_y(view_camera[0]);
    layer_x(layer_far, _cx * par_far);
    layer_y(layer_far, _cy * par_far);
}