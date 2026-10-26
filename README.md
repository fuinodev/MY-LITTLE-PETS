# My Little Pets — playable Forest build

Open `game/build/MyLittlePets.rbxlx` in Roblox Studio and press Play. The game creates its world at startup. The connected Studio place also has the current scripts installed.

The HUD follows the supplied screenshot: outlined colorful icon buttons, three top status bars, right-side shortcuts, and Boosts. Buttons open Pets, Shop, Index, Food, Bats, Inbox, Guide, and Settings. Status bars show actual coins, farming rate, and pet count.

Implemented: five Forest sectors, 30 collectible species, exact integer balances, shared treasure farming, hatching, pet equipment and food, collection rewards, ten-box Egg Rush with durable inbox claims, six weather mutations, cloud profile/session handling, leaderboard adapters, and verified-purchase handlers. Cube pets, eggs, bats, treasure, shop, arena and UI icons are editable native Roblox objects built from code, informed by the supplied artwork.

Studio uses temporary session progress by default. Live DataStore persistence, concurrent multiplayer behavior, purchase receipts and global rankings require published-environment testing. Real sales remain disabled until valid product/pass IDs are configured. Future biomes, Divine access, weekly EXCLUSIVE events, premium pet offers, and Huge/variant acquisition remain gated where the design documents leave decisions open. These are not completed production features.

Validation: 18 Studio integration checks passed on 2026-10-26, covering arithmetic, economy, collection, equipment, mutations, rewards, and the complete Egg Rush lifecycle. This is a playable development build, not a production release certification.

Sources are under `game/`. Rebuild the portable place with `python tools/build_roblox_place.py`. Read `game/README.md` for module details. Original design documents and reference images remain in place.
