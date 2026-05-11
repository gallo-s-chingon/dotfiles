# Palette Refactor Proposal

Generated: 2026-05-11T02:02:03

## Recommended format
- **Use TOML** instead of JSON for hand-editing readability and comments.
- Keep one canonical `palette` per theme, and have `lualine`/`render_markdown` reference token names (not raw hex).
- Keep `ansi[0..15]` as an ordered array for terminal compatibility.
- Enforce paired consistency: `colorN` and `colorN_bg` should map to same token unless intentionally overridden.

## Proposed schema (token-based)

```toml
[themes.tokyo-vibe.meta]
name = "Tokyo Vibe"
base = "dark"

[themes.tokyo-vibe.palette]
# fixed array for ANSI consumers (kitty, terminal)
ansi = ["#1A1B2A", "#FF5C8A", "#68E38A", "#FFCA7A", "#A99CFF", "#FF9BE9", "#67E8F9", "#F4EFFF", "#3B3F61", "#FF7FA4", "#8AF2A5", "#FFD99B", "#C0B6FF", "#FFB8F1", "#8EF1FF", "#FFFFFF"]

# semantic tokens (single source of truth)
bg = "#1A1B2A"
fg = "#F4EFFF"
cursor = "#FFB8F1"
comment = "#3B3F61"
error = "#FF5C8A"
warn = "#FFCA7A"
info = "#67E8F9"
hint = "#68E38A"
accent = "#A99CFF"

[themes.tokyo-vibe.derived]
# sections should reference palette keys, not hardcoded hex
lualine_normal_a_bg = "accent"
render_markdown_color1_bg = "comment"
```

## Darcula/Dracula-Pro style 'math' to reuse
1. **Surface ladder**: 5 neutral steps (`bgdarker -> bgdark -> bg -> bglight -> bglighter`) with small, constant luminance delta.
2. **Role hues**: fixed semantic lanes (`error red`, `warn orange`, `info cyan`, `hint green`, `accent purple/pink`).
3. **Two intensity bands** per hue: normal + bright for ANSI 1-7 / 9-15.
4. **Contrast floor**: keep text/background contrast >= ~4.5:1 for body text.

## Existing themes (current ANSI arrays)

### gotham
`[#0C6014, #C23127, #2AA889, #EDB443, #195466, #888CA6, #33859E, #D3EBE9, #245361, #D26937, #2AA889, #EDB443, #599CAB, #4E5166, #99D1CE, #F0FFFC]`

### gotham-nu
`[#A09030, #FF7676, #939393, #4F5B66, #B2B2B2, #A88A1F, #D1D1D1, #FFFFFF, #9F9F9F, #FF7676, #939393, #4F5B66, #B2B2B2, #A88A1F, #D1D1D1, #FFFFFF]`

### joker-gotham
`[#1CC0C4, #C23127, #2DCC82, #EDB443, #195466, #8B75D9, #94407A, #D3EBE9, #245361, #D26937, #00CC68, #EDB443, #599CAB, #94407A, #2BAFCC, #F0FFFC]`

### joker-nu
`[#006000, #FF7676, #2DCC82, #4F5B66, #B2B2B2, #8B75D9, #94407A, #FFFFFF, #FFFFFF, #FF7676, #00CC68, #4F5B66, #B2B2B2, #94407A, #2BAFCC, #FFFFFF]`

### matrix-light
`[#005000, #0F7A37, #026072, #00E65C, #03D1C9, #39FF88, #04F9F8, #D8FFD8, #009900, #0F7A37, #026072, #00E65C, #03D1C9, #39FF88, #04F9F8, #D8FFD8]`

### minty-lemon
`[#000000, #0260C2, #04D1F9, #04F9F8, #37F499, #4FE0FC, #81F8BF, #EBFAFA, #4FFCED, #026072, #04D1F9, #04F9F8, #37F499, #4FE0FC, #81F8BF, #EBFAFA]`

### niteblossom
`[#00441F, #E8336C, #22DA6E, #FFB46E, #A99CFF, #EB73BF, #6ADCEA, #EACFE3, #303F9F, #FF7596, #22DA6E, #FFBAB8, #A99CFF, #FFB3FF, #6ADCEA, #FFEBF7]`

## New/renamed theme proposals

### tokyo-vibe
`[#1A1B2A, #FF5C8A, #68E38A, #FFCA7A, #A99CFF, #FF9BE9, #67E8F9, #F4EFFF, #3B3F61, #FF7FA4, #8AF2A5, #FFD99B, #C0B6FF, #FFB8F1, #8EF1FF, #FFFFFF]`

### tokyo-lofi
`[#1B1C24, #DC7A96, #7EC893, #E2C292, #B5ADE9, #E9ACDC, #82CFD9, #F2EEFB, #414356, #E396AC, #9CDBAC, #E9D2AC, #C8C1EF, #EFC3E6, #A2DEE6, #FCFCFC]`

### matrix-vibe
`[#0A120A, #2FAF57, #43D37A, #62E29A, #1FBF9A, #5EE4B6, #76EFE7, #D6F8DE, #18301C, #44C768, #63DF8C, #82E8A8, #39CEAD, #7AECC3, #99F5EF, #EEFFF1]`

### matrix-lofi
`[#0A0D0A, #48915F, #5EB37E, #79C69B, #3F9A85, #77C6AB, #8CD4CF, #DAEFDF, #1B281D, #5CAA71, #7AC392, #94D1AB, #55AD9A, #8ED3BA, #A9E0DD, #EEFAF0]`

## Notes
- Rename `niteblossom` -> `tokyo-vibe` (vibrant) and add `tokyo-lofi` (muted).
- Replace `matrix-light` with dual set: `matrix-vibe` + `matrix-lofi` to preserve separation between comments/text/warnings without neon bleed.
- After visual review, we can auto-generate updated `colors.json` (or `themes.toml`) without touching your live theme switcher yet.
