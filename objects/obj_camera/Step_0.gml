/// @description Control the camera

x += (follow.x - x) * 0.1;
y += (follow.y - y) * 0.1;

// SET THE CAMERA POSITION
var camx = x - (vw / 1.5);
var camy = y - (vh / 1.5);

camera_set_view_pos (view_camera[0], camx, camy);