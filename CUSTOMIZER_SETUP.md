# R15 Customizer Studio Setup

This document explains how the customizer code is arranged in Roblox Studio and what the main scripts are responsible for.

The easiest and safest setup is to open `place/R15Customizer.rbxl` in Roblox Studio, run Rojo from this repository, and connect the Rojo Studio plugin. This project is a code overlay, so `src/` contains scripts while many non-code Studio objects, UI instances, folders, values, assets, and templates still live in the `.rbxl` place file.

## Studio Placement Map

Rojo maps this repository into Studio through `default.project.json`.

| Repo path | Roblox Studio location | Notes |
| --- | --- | --- |
| `src/ReplicatedStorage` | `ReplicatedStorage` | Shared modules used by server and client. |
| `src/ReplicatedStorage/Shared/Constants.lua` | `ReplicatedStorage > Shared > Constants` | ModuleScript containing shared IDs, limits, defaults, ranks, and timing values. |
| `src/ServerScriptService` | `ServerScriptService` | Server-only scripts and modules. |
| `src/ServerScriptService/Server/init.server.lua` | `ServerScriptService > Server` | Main server Script. This is the script usually referred to as `Server.lua`. |
| `src/ServerScriptService/Server/Modules` | `ServerScriptService > Server > Modules` | ModuleScripts required by `Server`, including `Customization`. |
| `src/ServerScriptService/Server/Modules/Customization.lua` | `ServerScriptService > Server > Modules > Customization` | Main customization ModuleScript. |
| `src/StarterGui` | `StarterGui` | Client UI scripts and customizer UI client logic. |

If you are placing the customizer manually in Studio instead of using Rojo, keep the same hierarchy and names. The names matter because the scripts use `WaitForChild()` and `require()` calls that expect these exact locations.

## Required Studio Objects

The extracted scripts depend on objects that are not all represented as source files. These should already exist if you start from `place/R15Customizer.rbxl`.

- `ReplicatedStorage > Shared > Constants`
- `ServerScriptService > Server`
- `ServerScriptService > Server > Modules`
- `ServerScriptService > Server > Modules > Customization`
- `ServerScriptService > Server > Modules > GroupVerification`
- `ServerScriptService > Server > ServerAssets`
- `ServerScriptService > Server > ServerAssets > Custom Accessory`
- `ServerScriptService > Server > ServerAssets > Overlay`
- `ServerScriptService > Server > Modules > Customization > Particles`
- `ServerScriptService > Server > Modules > Customization > CustomizingGui`
- `StarterGui > Main` and its existing customizer UI children

Do not rename these unless the code is updated everywhere that references them.

## Recommended Setup With Rojo

1. Open `place/R15Customizer.rbxl` in Roblox Studio.
2. Install Rojo 7.7.0 locally with `rokit install`.
3. Start the project server from this repository with `rojo serve`.
4. In Studio, connect the Rojo plugin to the running server.
5. Let Rojo sync the code into `ReplicatedStorage`, `ServerScriptService`, and `StarterGui`.
6. Test player join, opening the customizer, saving, loading, accessory editing, and respawning before publishing.

Because this is a code overlay, avoid building a brand-new place from only `src/`. The original `.rbxl` contains required non-code Instances.

## Manual Setup Checklist

If copying by hand into an existing place:

1. In `ReplicatedStorage`, create a `Folder` named `Shared`.
2. Put `Constants.lua` inside `ReplicatedStorage > Shared` as a ModuleScript named `Constants`.
3. In `ServerScriptService`, create the main Script named `Server`.
4. Paste `src/ServerScriptService/Server/init.server.lua` into `Server`.
5. Under `Server`, create a `Folder` named `Modules`.
6. Put `Customization.lua` under `Server > Modules` as a ModuleScript named `Customization`.
7. Put the other server modules from `src/ServerScriptService/Server/Modules` into that same `Modules` folder with their existing names.
8. Make sure `Server > ServerAssets` contains the required accessory templates, overlay texture, and other server-side assets from the original place.
9. Make sure `Customization > Particles` and `Customization > CustomizingGui` are present.
10. Copy the `StarterGui > Main` customizer UI and client scripts from the original place or from the Rojo-synced `src/StarterGui` layout.

## Major Scripts

### `Server.lua`

Studio location: `ServerScriptService > Server`

Repo source: `src/ServerScriptService/Server/init.server.lua`

This is the main server bootstrap. It creates the shared RemoteFunctions and RemoteEvents in `ReplicatedStorage`, loads the server modules, and routes client requests to the right module function.

Important responsibilities:

- Creates `ReplicatedStorage.Customization`, the RemoteFunction used by the client customizer UI.
- Creates `ReplicatedStorage.CustomizingEvent`, used to show or remove the in-world customizing indicator.
- Creates other shared remotes such as `Multiverse`, `PartyInvoke`, `ServerListUpdate`, `PropPlacerInvoke`, `DisplayRollEvent`, and `HeadRotationEvent`.
- Creates `ReplicatedStorage.Info`, a folder used for per-player info values.
- Requires modules from `Server > Modules`, including `Customization`, `Multiverse`, `PropsPlacer`, `Gamepass`, `Economy`, and others.
- Handles `Customization.OnServerInvoke` request routing. Request names such as `NameBio`, `Shirt`, `Pants`, `Face`, `Color`, `Height`, `AddAccessory`, `Save`, `Load`, `Skill`, and `Empowerment` are forwarded into `Customization.lua`.
- Calls `Customization.IndexPlayer(player)` when players join or when the server catches already-present players.

Treat this file as the server/client contract hub. If a client button invokes a customization request, this script is usually where that request name is routed.

### `Constants.lua`

Studio location: `ReplicatedStorage > Shared > Constants`

Repo source: `src/ReplicatedStorage/Shared/Constants.lua`

This ModuleScript is the shared configuration table. Server and client code can require it from `ReplicatedStorage.Shared.Constants` so limits and IDs stay consistent.

It currently contains:

- Group IDs and permission group IDs.
- Place IDs for customization and lobby routing.
- Save slot, prop, height, accessory, and accessory distance limits.
- Default body type and body proportion values.
- Multiverse refresh and timeout values.
- Messaging keys.
- Minimum account age.
- Permission rank names and rank numbers.

Use this file when a value is meant to be shared across systems. Be careful changing DataStore-related limits or permission ranks because those affect live behavior.

### `Customization.lua`

Studio location: `ServerScriptService > Server > Modules > Customization`

Repo source: `src/ServerScriptService/Server/Modules/Customization.lua`

This is the main server-side customizer module. It handles player customization requests after `Server.lua` receives them from the client.

Important responsibilities:

- Loads and saves character slot data through DataStores including `CharacterSaves11`, `CharacterSaves12`, `SlotNames`, `OutfitIDs`, `AccessoryIDs`, and `Tutorial`.
- Reads shared configuration from `ReplicatedStorage.Shared.Constants`.
- Uses `Server > ServerAssets > Custom Accessory` as the template for custom accessory creation and conversion.
- Uses `Server > ServerAssets > Overlay` for accessory color/overlay behavior.
- Uses `Customization > Particles` when applying particle effects to accessories.
- Handles body appearance changes such as name/bio, shirt, pants, face, body color, accessory color, particle color, height, body scale, and proportions.
- Handles accessory operations such as add, blank accessory, delete, copy, mirror, weld, mesh ID, texture, material, transparency, position, size, rotation, particles, and accessory history restore.
- Handles save/load workflows, legacy data loading, outfit IDs, accessory IDs, tutorial status, skills, and empowerment fields.
- Runs `Customization.IndexPlayer(player)` to cache player slot names, legacy data, and normalize accessories when the player's character spawns.
- Listens to `CustomizingEvent` to add or remove the `CustomizingGui` marker on a player's character.

This script is trusted server code. Keep validation, save/load logic, and DataStore writes on the server side.

## Runtime Flow

1. Player joins the game.
2. `Server.lua` loads modules and calls `Customization.IndexPlayer(player)`.
3. `Customization.lua` prepares player caches, loads slot names and legacy data, and normalizes character accessories.
4. The client UI invokes `ReplicatedStorage.Customization` with a request name.
5. `Server.lua` receives the request and forwards it to the matching method in `Customization.lua`.
6. `Customization.lua` applies the change, saves or loads data when needed, and returns the result to the client.

## Things To Be Careful With

- Do not rename RemoteFunctions, RemoteEvents, folders, ModuleScripts, or UI objects without updating every reference.
- Do not change DataStore names unless you are intentionally migrating existing player data.
- Do not move validation from `Customization.lua` to the client.
- Do not delete `ServerAssets`, `Particles`, or existing UI templates just because they are not represented as `.lua` files.
- Test in Roblox Studio with API Services enabled when checking DataStore behavior.
