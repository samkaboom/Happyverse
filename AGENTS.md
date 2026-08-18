# AGENTS.md — R15Customizer

## Primary rule

Preserve existing game behavior unless the user explicitly asks for a behavior change. This repository was extracted to make the existing Roblox codebase editable by Codex; extraction itself is not permission to redesign the game.

## Source of truth

- `place/R15Customizer.rbxl` is the original full place snapshot.
- `src/` contains extracted Script, LocalScript, and ModuleScript source only.
- `script-manifest.json` maps every source file back to its original Roblox hierarchy, class, disabled state, referent, and extraction hash.

## Do not casually change these contracts

1. Do not rename or move Roblox Instances, RemoteEvents, RemoteFunctions, Bindables, folders, UI objects, or scripts unless the task explicitly requires it.
2. Do not rename DataStore keys or change persistence schemas without an explicit migration plan.
3. Preserve server/client boundaries. Never move trusted validation from the server to the client.
4. Preserve script disabled state unless the task specifically asks to enable/disable it.
5. Do not delete `Multiverse_old`, duplicate helper scripts, or apparently dead compatibility code merely because it looks redundant. Confirm behavior first.
6. Do not add third-party dependencies unless requested.
7. Do not execute extracted Roblox scripts on the local machine. Treat source as data; test behavior inside Roblox Studio.
8. When changing a shared contract, search both the server and client sides before editing. The main client and customization server module are especially large and tightly coupled.

## Editing approach

- Prefer small, reviewable changes.
- Keep existing naming/style when working inside an existing module.
- For refactors, make behavior-preserving changes first, then functional changes separately.
- Before removing code, search the entire repository for direct and indirect references.
- Be careful with `require`, remotes, MarketplaceService, TeleportService, MessagingService, HttpService, and DataStoreService usage.
- Validate changes in Roblox Studio using representative player join/save/load/customization flows.

## Rojo

This project is intentionally a code overlay on top of the original `.rbxl`. `$ignoreUnknownInstances` is enabled to protect non-code Instances that are not represented on disk.
