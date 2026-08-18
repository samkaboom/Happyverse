# Codebase Overview

## Extraction summary

- Roblox place Instances: **8,171**
- Extracted scripts: **67**
- Script source lines: **25,598**
- Script distribution: 9 server Scripts / 29 LocalScripts / 29 ModuleScripts
- Script-bearing services: ReplicatedStorage (3), ServerScriptService (29), StarterGui (35)

## Main code centers

The largest client entry point is `StarterGui/Main/Client` (8,785 lines). The largest customization server module is `ServerScriptService/Server/Modules/Customization` (3,478 lines). Treat changes that cross these two areas as client/server contract changes and search both sides before modifying remote behavior.

Other large modules include `ProfileService`, `Multiverse`, `Multiverse_old`, `PropPlacer`, `Economy`, and the server bootstrap `Server`.

## Roblox services referenced in source

- `ReplicatedStorage` — referenced through `GetService` 27 time(s)
- `UserInputService` — referenced through `GetService` 20 time(s)
- `RunService` — referenced through `GetService` 19 time(s)
- `MarketplaceService` — referenced through `GetService` 14 time(s)
- `DataStoreService` — referenced through `GetService` 9 time(s)
- `Players` — referenced through `GetService` 6 time(s)
- `TweenService` — referenced through `GetService` 6 time(s)
- `HttpService` — referenced through `GetService` 5 time(s)
- `TeleportService` — referenced through `GetService` 5 time(s)
- `TextService` — referenced through `GetService` 4 time(s)
- `ReplicatedFirst` — referenced through `GetService` 4 time(s)
- `StarterGui` — referenced through `GetService` 4 time(s)
- `MessagingService` — referenced through `GetService` 2 time(s)
- `InsertService` — referenced through `GetService` 1 time(s)
- `ContextActionService` — referenced through `GetService` 1 time(s)
- `Workspace` — referenced through `GetService` 1 time(s)

## Persistence identifiers found by static scan

These strings are existing persistence contracts. Do not rename them casually.

- `PlayerDesignation`
- `ServerOccupied`
- `Follows`
- `SlotSave`
- `____PS`
- `CharacterSaves11`
- `CharacterSaves12`
- `SlotNames`
- `OutfitIDs`
- `AccessoryIDs`
- `Tutorial`
- `XP`
- `FilterMode`
- `SuperReservedServerAccessCodes`
- `ReservedServerAccessCodes`
- `PropSave`
- `PurchaseHistory`

## Exact duplicate source groups

The extraction found **6 exact duplicate groups**. They are documented because they may be intentional copies; no deduplication was performed.

- `ServerScriptService/Server/Modules/Multiverse/Global Message/Script` ↔ `ServerScriptService/Server/Modules/Multiverse_old/Global Message/Script`
- `ServerScriptService/Server/Modules/Multiverse/ServerBufferCleaner` ↔ `ServerScriptService/Server/Modules/Multiverse_old/ServerBufferCleaner`
- `ServerScriptService/dont add if you have existing ProfileService` ↔ `StarterGui/Main/Client/LookAt`
- `StarterGui/Main/Client/BodyColor/Drag` ↔ `StarterGui/Main/Client/Color/Drag` ↔ `StarterGui/Main/Client/ParticleColor/Drag`
- `StarterGui/Main/Customization/InfoBox/Bin/Powers/EmpowermentCustomEntry/Description/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry1/Description/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry2/Description/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry3/Description/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry4/Description/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry5/Description/TextFitter`
- `StarterGui/Main/Customization/InfoBox/Bin/Powers/EmpowermentCustomEntry/Title/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry1/Title/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry2/Title/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry3/Title/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry4/Title/TextFitter` ↔ `StarterGui/Main/Customization/InfoBox/Bin/Powers/SkillCustomEntry5/Title/TextFitter`

## Areas requiring extra care

- DataStore/ProfileService persistence and save compatibility
- RemoteEvent/RemoteFunction validation and client/server expectations
- Teleport and reserved-server logic in the Multiverse modules
- Marketplace/gamepass purchase handling
- UI hierarchy dependencies in `StarterGui/Main`
- Disabled scripts that may be templates, examples, or event-only code

This document is static context only; it does not claim that every referenced service or duplicate block is currently active at runtime.
