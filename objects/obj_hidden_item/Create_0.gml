// obj_hidden_item - Create: art matches the level (item1/2/3 for L1/2/3).
// Non-persistent, so Create-time assignment is exact. Labels stay in Step.
var _rmh = room_get_name(room);
if (_rmh == "rm_level_1") sprite_index = spr_hidden_item1;
else if (_rmh == "rm_level_2") sprite_index = spr_hidden_item2;
else sprite_index = spr_hidden_item3;
