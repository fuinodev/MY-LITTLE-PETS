# My Little Pets — playable Forest build

Open `game/build/MyLittlePets.rbxlx` in Roblox Studio and press Play. The game creates its world at startup. The connected Studio place also has the current scripts installed.

The HUD follows the supplied screenshot: outlined colorful icon buttons, a top coin counter, right-side shortcuts, and Boosts. Image buttons open Pets, Shop, Index, Food, Bats, Guide, and Settings. Farming rate is plain text above Boosts. Pets has Equipped and All pets tabs, with Egg Rush rewards inside All pets; there is no Inbox button or top pet counter.

Implemented: five Forest sectors, 30 collectible species, exact integer balances, shared treasure farming, hatching, pet equipment and food, collection rewards, ten-box Egg Rush with durable inbox claims, six weather mutations, cloud profile/session handling, leaderboard adapters, and verified-purchase handlers. Cube pets, eggs, bats, treasure, shop, arena and UI icons are editable native Roblox objects built from code, informed by the supplied artwork.

Studio uses temporary session progress by default. Live DataStore persistence, concurrent multiplayer behavior, purchase receipts and global rankings require published-environment testing. Real sales remain disabled until valid product/pass IDs are configured. Future biomes, Divine access, weekly EXCLUSIVE events, premium pet offers, and Huge/variant acquisition remain gated where the design documents leave decisions open. These are not completed production features.

Validation: 18 Studio integration checks passed on 2026-10-26, covering arithmetic, economy, collection, equipment, mutations, rewards, and the complete Egg Rush lifecycle. This is a playable development build, not a production release certification.

Sources are under `game/`. Rebuild the portable place with `python tools/build_roblox_place.py`. Read `game/README.md` for module details. Original design documents and reference images remain in place.
