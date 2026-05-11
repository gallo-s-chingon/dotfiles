# Palette Refactor v2

Generated: 2026-05-11T03:02:16

This is a **review draft** (no existing configs overwritten).

## Decisions applied
- Removed `minty-lemon` from proposed set.
- Added `joker-vibe` (neon) and `gotham-lofi` (muted, no hyphen in variant label).
- Kept Dracula-Pro style token model (`fg/bg ladder + semantic hues`) for all themes.
- `tokyo-vibe` anchored to original Niteblossom background `#00041F`.
- `matrix-vibe` pushed more neon, with cyan shifted greener and deeper black-shaded greens for separation.

## Theme palettes (ANSI 16)

### tokyo-vibe
`[#0D1130, #FF4D9D, #3BEE8A, #FFC07A, #B79CFF, #FF82E6, #57E6FF, #FFEBF7, #2C3F90, #FF75B5, #67F5A4, #FFD0A0, #C8B3FF, #FFB3FF, #84F0FF, #FFFFFF]`

Tokens:
- `bg`: `#00041F`
- `fg`: `#FFEBF7`
- `cursor`: `#FFB3FF`
- `comment`: `#635D97`
- `selection`: `#2A2F58`
- `subtle`: `#1A1F45`
- `accent`: `#B79CFF`

### tokyo-lofi
`[#161A32, #D06F9C, #74BE95, #DDB48D, #AFA3D8, #D8A1D1, #77C4D3, #EFE4F3, #464D7A, #D98AAA, #8DCCA8, #E2C3A2, #BBB1E3, #E3BADC, #92D1DE, #FCFBFE]`

Tokens:
- `bg`: `#0A0D24`
- `fg`: `#EFE4F3`
- `cursor`: `#D8A1D1`
- `comment`: `#6E6993`
- `selection`: `#2A2E4C`
- `subtle`: `#1C2140`
- `accent`: `#AFA3D8`

### matrix-vibe
`[#071007, #14A44A, #00C95C, #2CEB76, #00B88F, #27F0A9, #4CFFE6, #D9FFE7, #102314, #22C35A, #1CE06E, #55F691, #16D4A5, #56FFC9, #7CFFF0, #F1FFF5]`

Tokens:
- `bg`: `#002C00`
- `fg`: `#D9FFE7`
- `cursor`: `#56FFC9`
- `comment`: `#2B5D3A`
- `selection`: `#10331A`
- `subtle`: `#0B2312`
- `accent`: `#1CE06E`

### matrix-lofi
`[#0A0D0A, #48915F, #5EB37E, #79C69B, #3F9A85, #77C6AB, #8CD4CF, #DAEFDF, #1B281D, #5CAA71, #7AC392, #94D1AB, #55AD9A, #8ED3BA, #A9E0DD, #EEFAF0]`

Tokens:
- `bg`: `#000C00`
- `fg`: `#DAEFDF`
- `cursor`: `#8ED3BA`
- `comment`: `#355744`
- `selection`: `#122217`
- `subtle`: `#0E1A12`
- `accent`: `#7AC392`

### joker-vibe
`[#14201E, #FF5A5F, #00D46A, #FFC14D, #4DB8FF, #C07BFF, #00F0FF, #ECFFFE, #2B4D48, #FF7B7F, #32F08A, #FFD177, #7CCFFF, #D39BFF, #68FFFF, #FFFFFF]`

Tokens:
- `bg`: `#0C1014`
- `fg`: `#ECFFFE`
- `cursor`: `#C07BFF`
- `comment`: `#416765`
- `selection`: `#1B2831`
- `subtle`: `#152028`
- `accent`: `#00F0FF`

### gotham-lofi
`[#1A2428, #B65D52, #4E9B86, #C39C5D, #4D7180, #8D90AA, #5E9BAF, #D6E9E6, #355864, #C27A56, #66AF9C, #D1AD71, #75A9B6, #6D7288, #A5D2CC, #F1FCFA]`

Tokens:
- `bg`: `#0C1014`
- `fg`: `#D6E9E6`
- `cursor`: `#5E9BAF`
- `comment`: `#5C757F`
- `selection`: `#1A242B`
- `subtle`: `#131A20`
- `accent`: `#8D90AA`

## Neovim detail/spec coverage
The draft `themes.v2.toml` includes per-theme values for all core Dracula-Pro palette keys used by `dracula_pro_base.vim`:
`fg, bglighter, bglight, bg, bgdark, bgdarker, comment, selection, subtle, cyan, green, orange, pink, purple, red, yellow`, plus terminal ANSI and semantic role tokens.

## Files
- `~/.config/colors/palette-refactor-v2.md`
- `~/.config/colors/themes.v2.toml`


## Matrix-vibe terminal tweak
- foreground/text set to `#28FE14`
- background set to `#002C00`
- contrast remains very high (~11.23:1), so readability is still strong while giving a classic phosphor terminal feel.
