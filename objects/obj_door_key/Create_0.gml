// obj_door_key - Create: normal locked door, needs 1 key
// Locked = frame 0 held (image_speed stays 0; Step advances it manually
// once unlocked so pause freezes the animation too).
keys_needed = 1;
opened = false;
door_anim_rate = 0.2; // frames per step while opening (~1s for 12 frames)
image_index = 0;
image_speed = 0;
