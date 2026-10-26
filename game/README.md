# Game implementation

## Run
Open `build/MyLittlePets.rbxlx` in Roblox Studio and press Play. The scripts construct the Forest and UI. The current build is also installed in the connected Studio place. Rebuild the XML place from repository sources using `python tools/build_roblox_place.py`.

## Sources
- Config: approved economy, rarity, species and release gates.
- BigNum: exact unsigned decimal arithmetic for large balances.
- Assets and World: native cube pets, mutation accessories, bats, eggs, Forest sectors, shop, boards and arena.
- HUD and Client: screenshot-inspired simulator buttons, responsive menus, 3D inventory previews and effects.
- Profiles and GameService: session locking, transactional profile changes, inventory, hatching, food, gates and farming.
- RushService and WeatherService: scheduled events, fair arena rules, durable claims and mutation selection.
- ShopService and LeaderboardService: verified platform ownership/receipts and cloud ranking adapters.
- Server: authoritative actions, world startup and service scheduling.
- tests/Tests: opt-in integration suite. Set Workspace attribute MLP_RunTests to true in Studio before Play to run it. Keep it false for ordinary play.

## Validation and limits
All 18 integration checks passed on 2026-10-26. Test results are saved in `build/test-report.json`. Tests include complete arena countdown, hold-to-claim, duplicate rejection and safe return. Final Studio console showed no runtime errors during the checked session.

StudioUseDataStore is false: progress is intentionally temporary in Studio. Published cloud saving, multi-client contention, real receipts, device performance and global ranking accuracy still need live-environment validation. Never enable sales with placeholder IDs. No publishing was performed.

Future biomes and unspecified Divine, weekly EXCLUSIVE, premium, Huge and variant acquisition policies remain Coming Soon. Existing code supports variant and mutation math without inventing acquisition policy. Original Blender samples are preserved; the playable art is generated native geometry rather than a production mesh conversion.

The reference for the new button style is `reference/ui-buttons-reference.png`. The HUD uses original code-drawn icons and real game counters.
