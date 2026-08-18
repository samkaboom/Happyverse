# R15Customizer — Codex/Rojo Code Workspace

This repository was extracted from `place/R15Customizer.rbxl` for filesystem-based editing with Codex and Rojo.

## What was extracted

- **67 scripts total**: 9 Scripts, 29 LocalScripts, 29 ModuleScripts
- **25,598 lines** of Luau/Lua source (830,103 UTF-8 bytes)
- Original Roblox hierarchy and script classes are recorded in `script-manifest.json`.
- Disabled script state is preserved with Rojo `.meta.json` files.
- No script source was refactored or behaviorally changed during extraction.

## Rojo version

This workspace is pinned to **Rojo 7.7.0** through `rokit.toml`.

Use:

```powershell
rokit install
rojo -V
rojo serve
```

The Roblox Studio Rojo plugin should also be **7.7.0** before connecting.

## Important: this is a code overlay, not a full filesystem recreation of the place

The original place contains thousands of non-code Instances (UI, models, values, etc.). Those remain in `place/R15Customizer.rbxl` and are intentionally **not** duplicated into `src/`.

`default.project.json` is configured with `$ignoreUnknownInstances: true` so Rojo can overlay the extracted scripts onto the existing place without deleting the non-code content that Codex does not manage.

### Recommended workflow

1. Keep `place/R15Customizer.rbxl` as your known-good place backup.
2. Open that place in Roblox Studio.
3. Install/run Rojo 7 and start `rojo serve` from this repository.
4. Connect the Rojo Studio plugin to the project.
5. Let Codex edit the files under `src/`.
6. Test in Studio before publishing.

Do **not** treat `rojo build` from this code-only overlay as a complete replacement for the original place; the non-code game content lives in the `.rbxl`.

## Codex context

Read these first:

- `AGENTS.md` — editing rules and invariants
- `docs/CODEBASE.md` — high-level architecture and risky integration points
- `docs/SCRIPT_INVENTORY.md` — every extracted script and its original Roblox path
- `script-manifest.json` — machine-readable path/class/hash mapping

## Largest scripts

- `StarterGui/Main/Client` — 8,785 lines
- `ServerScriptService/Server/Modules/Customization` — 3,478 lines
- `ServerScriptService/ProfileService` — 2,417 lines
- `ServerScriptService/Server/Modules/Multiverse` — 1,584 lines
- `ServerScriptService/Server/Modules/Multiverse_old` — 1,063 lines
- `StarterGui/Main/Client/PropPlacer` — 907 lines
- `ServerScriptService/Server` — 713 lines
- `ServerScriptService/Server/Modules/AdManager` — 571 lines
- `StarterGui/Main/GeneralSettings/Freecam/FreecamScript` — 532 lines
- `StarterGui/Main/Client/Color` — 422 lines

## Verification

Every extracted source file has a SHA-256 hash in `script-manifest.json`. These hashes are based on the source decoded directly from the binary place file.
