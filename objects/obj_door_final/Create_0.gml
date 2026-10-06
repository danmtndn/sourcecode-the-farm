// obj_door_final - Create: final door, needs CODE typed + ENTER
// Flow per your answer: key doors first, then code unlocks final door.
// Locked = frame 0 held (image_speed stays 0; Step advances it manually
// once unlocked so pause freezes the animation too).
opened = false;
typing = false;
door_anim_rate = 0.2; // frames per step while opening (~1s for 12 frames)
image_index = 0;
image_speed = 0;
