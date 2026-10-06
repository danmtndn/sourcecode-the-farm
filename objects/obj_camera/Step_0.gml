/// @description Control the camera

x += (follow.x - x) * 0.1;
y += (follow.y - y) * 0.1;

// SET THE CAMERA POSITION
var camx = x - (vw / 1.5);
var camy = y - (vh / 1.5);

camera_set_view_pos (view_camera[0], camx, camy);

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