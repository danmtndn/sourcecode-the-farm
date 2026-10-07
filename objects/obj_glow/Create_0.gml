// obj_glow - Create: multiplicative night map (one surface, added lights).
// PERSISTENT: place ONE instance in rm_menu only; it survives room changes.
// One room-sized surface plus a few sprite draws per frame: cheap.
//
// To give an object a pool of light, add a row below:
//   [object, radius_px, color, alpha, flicker, y_offset]
// flicker 0 = steady hole, higher = stronger pulse. y_offset lifts the hole
// above feet-origin sprites.
// Vignette: one stretched texture over the GUI, also nearly free.
// Strength is baked into the texture; this scales it (1 = as authored, 0 = off).
if (!variable_global_exists("vignette_enabled")) global.vignette_enabled = true;
if (!variable_global_exists("vignette_alpha")) global.vignette_alpha = 1;
// Darkness: multiplicative night map (see Draw End). The map starts at
// ambient_color and lights add into it, then it multiplies over the scene.
// Set the night depth directly here: darker color = darker night.
// (global.ambient_alpha is retired; it belonged to the old subtract math.)
// Toggle with global.darkness_enabled.
if (!variable_global_exists("darkness_enabled")) global.darkness_enabled = true;
ambient_color = make_colour_rgb(30, 30, 42);
dark_surf = -1;

emitters = [
    [obj_drawer,      130, make_colour_rgb(255, 190, 120), 0.45, 0.00, -24],
	//[obj_pushable,      130, make_colour_rgb(255, 190, 120), 0.45, 0.00, -24],
	[obj_door_key,      130, make_colour_rgb(255, 190, 120), 0.45, 0.00, -24],
	[obj_door_final,      130, make_colour_rgb(255, 190, 120), 0.45, 0.00, -24],
    [obj_enemy,       100, c_red,                          0.55, 0.30, -24],
    [obj_key,          60, c_yellow,                       0.60, 0.00,  -8],
    [obj_paper,        60, make_colour_rgb(200, 220, 255), 0.60, 0.00,  -8],
    [obj_exit,         90, c_lime,                         0.55, 0.30, -24],
    [obj_hidden_item,  60, c_aqua,                         0.55, 0.00,  -8],
	[obj_player,      130, make_colour_rgb(255, 190, 120), 0.45, 0.00, -24],
];
