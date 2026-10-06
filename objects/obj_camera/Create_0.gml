/// @description Initialize the camera

// SET THE OBJECT TO FOLLOW
follow = obj_player;

// SET THE CAMERA SIZE
vw = 480;
vh = 360;

// CREATE THE CAMERA VIEW
camera_create_view (0, 0, vw, vh);

// PARALLAX BACKDROP CACHE (Step shifts BG_Far; -1 = room has no such layer).
// BG_Mid is intentionally world-locked like normal tiles (no offset).
// par_mid is reserved for later tuning.
layer_far = layer_get_id("BG_Far");
layer_mid = layer_get_id("BG_Mid");
// Trail factors per room (smaller = farther = slower). Sized so the
// 4096x1024 far art always covers the view (L3 is 4096x1422, rest 1366x768).
var _rm = room_get_name(room);
if (_rm == "rm_level_3") { par_far = 0.45; par_mid = 0.65; }
else { par_far = 0.25; par_mid = 0.5; }