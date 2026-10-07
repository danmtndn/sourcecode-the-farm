# Lighting: Darkness + Glow Holes + Vignette (`obj_glow`, persistent)

Draw End (world space, after everything, before Draw GUI) + Draw GUI.
Skipped in menu. Toggles: `global.darkness_enabled`, `vignette_enabled`,
`vignette_alpha` (=1). No shaders, no per-pixel code anywhere.

## Night map (`Draw_73.gml`)
- One room-sized surface (rebuilt only on size change/loss): filled with
  `ambient_color` (default night floor, tune brightness there), then each
  emitter ADDS its gradient in, then the map MULTIPLIES over the scene
  (`bm_dest_colour/bm_zero`). Add-then-multiply never clamps at the bottom,
  so falloff has no contour edge (the old subtract version did — do not
  revert to subtract).
- `emitters` table rows: `[object, radius_px, color, alpha, flicker, yoff]`
  (player/enemy/pickups/drawers/doors). Hole radius reads 1.2x glow radius
  for a soft boundary. Each hole's alpha follows its instance's
  `image_alpha`, so spawn fades punch growing holes (no light without source).
- `spr_light` gradient MUST stay centered with a zero rim, and draw scale
  derives live from `sprite_get_width/2` — redrawing the art at any canvas
  size keeps pools landing exactly on their table radius.

## Glow, visibility, vignette
- Additive per-emitter glows were reverted (kept: holes + visibility pass).
- Visibility pass redraws every emitter instance full-bright over the dark
  (current frame/flip/angle/blend/alpha copied), so characters stay readable.
- Vignette (`Draw_64.gml`): `spr_vignette` stretched 16px past every screen
  edge (overscan hides texture-page seams), scaled by `vignette_alpha`.
- Perf: one surface fill + ~a dozen sprite draws + one composite per frame.
  If frames dip, first suspect is engine layer FX (`_effect_glow` on room
  layers), never this controller.
