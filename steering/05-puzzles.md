# Puzzles: Drawer / Paper / Key / Doors

Flow: key doors first, code unlocks final door.

- `obj_drawer`: Create `contains="paper"|"key"|"nothing"; opened=false`. Step: E within 64px -> `opened=true`, `instance_create_layer(x,y-32,layer,obj_key|obj_paper)`. EDIT `contains` per instance via Creation Code.
- `obj_paper`: Create `paper_code="4821"` (must match `global.final_code`). Step: E within 56px -> `global.code_found=paper_code; global.paper_text=paper_code; global.paper_timer=360; instance_destroy()`.
- `obj_key`: Step: E within 48px -> `global.has_key+=1; instance_destroy()`.
- `obj_door_key`: Create `keys_needed=1`. Step: E within 64px and `global.has_key>=keys_needed` -> `global.has_key-=keys_needed; instance_destroy()`.
- `obj_door_final`: Create `opened=false; typing=false`. Step: near 80px + E + `global.code_found!=""` toggles `typing`, clears `keyboard_string`. While typing: ENTER compares `keyboard_string==global.final_code` -> destroy on match else clear retry. ESC or walk away cancels. Draw shows `FINAL DOOR [E]` / `CODE: xxx_`. Draw GUI shows keypad box.
- To change code: edit `obj_game.final_code` AND matching `obj_paper.paper_code`.
