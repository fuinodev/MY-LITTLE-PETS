from pathlib import Path
import shutil, re, json

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'game-system-overview'
SYSTEMS = [
('Pet Collection & Progression System','petcollection&progression.md','pet-image.png','pet-progression'),
('World & Biome Progression System','world-biome-progression.md','forest-sample.png','forest-world'),
('Treasure Farming & Economy System','treasure-farming-economy.md','forest-sample.png','treasure-farming'),
('Egg Spinning & Pet Index System','egg-spinning-pet-index.md','assets.png','egg-plaza'),
('Mini-Field & Egg Rush PvP System','mini-field-egg-rush-pvp.md','egg-rush.png','egg-rush'),
('Weather Events & Mutation System','weather-events-mutations.md','pet-image.png','weather-mutations'),
('Robux Shop & Permanent Upgrade System','robux-shop-permanent-upgrades.md','assets.png','upgrade-shop'),
]

CONTENT = {
'World & Biome Progression System': '''## Purpose and player journey

The world is one connected linear route. The Forest launches first, followed by River, Desert, Ice, and Volcanic updates. Players farm coins, buy the next sector gate, and discover stronger treasure without losing pets or permanent account upgrades.

## Forest layout

The hub contains the spawn, Giant Egg Spin Plaza, shop, leaderboards, Pet Index access, and the Mini-Field entrance. Five farming sectors follow in order: Forest Entrance (free), Green Clearing, Deep Woods, Ancient Grove, and Forest Gateway. Place the River Coming Soon gateway after sector five. The arena is a separate competition space, never a sixth farming sector.

Use broad grassy paths, low-poly trees, stepped cliff walls, wooden fencing, warm lanterns, and readable signs. Keep sight lines clear so players can find gates and treasure on mobile. Decorative trees and rocks are not destructible farming targets.

## Gate interaction

1. Approach a locked gate to see its sector name, coin price, and prerequisite.
2. Request an unlock through a clearly labeled button.
3. The server verifies the previous sector, balance, and active profile.
4. Deduct the price and grant the unlock in one profile transaction.
5. Open the gate for that player and save the result; retries cannot charge twice.

Locked gates remain authoritative even if the client hides a barrier or teleports. Farming checks the player's unlocked sectors rather than trusting character position alone. Existing unlocks remain available after respawn and rejoin.

## Expansion rules

River uses bridges, water, and pearl treasure; Desert uses dunes and ruins; Ice uses glaciers and crystals; Volcanic uses lava and obsidian. Each biome adds 30 standard pets and its own cosmetic coin design, all contributing to one shared Coins balance. Proposed pet origin multipliers are Forest 1, River 2, Desert 4, Ice 8, and Volcanic 16; they apply to pet origin, not the ground currently occupied.

## Interface, persistence, and services

Show the current sector, next gate price, available coins, and locked reason. Unreleased content displays Coming Soon without a purchase button. Save unlocked sector IDs and last safe spawn. WorldService owns gate permissions; EconomyService performs debits; PlayerDataService saves; a client controller handles signs and visual gates. Keep configuration IDs independent from display names.

## Suggested playtest defaults

New proposed values, not previously approved balance: gates cost 2M, 20M, 200M, and 2B coins. Start testing with three equipped Common pets as an attainable early team, while granting only one starter pet. Measure time to each unlock with free and upgraded accounts before publishing prices. Preserve the sequential gate rule even when a purchase makes farming very fast.

## Acceptance checks

- A new account can enter only the free sector.
- Double requests unlock once and spend once.
- Insufficient funds, missing prerequisites, and unreleased biomes reject cleanly.
- Rejoining restores unlocks and a valid spawn.
- Egg Rush return restores the player's safe world location.
- Every future biome preserves previously owned pets and multipliers.

## Art deliverables

Build reusable cliff, grass, fence, lantern, tree, gate, and sign modules. The sample Blender scene demonstrates the five-sector route and River gateway; it is an editable blockout, not the finished Roblox map. The supplied forest reference says Beach Area at the far end; production must use River instead.
''',
'Treasure Farming & Economy System': '''## Purpose and boundaries

Equipped cube pets automatically farm coin piles, giant hoards, and treasure chests in unlocked sectors. This system owns target durability, coin payout, replenishment, and numeric formatting. Scenery remains intact. All biomes use the same Coins wallet despite different coin art.

## Farming calculation

For each equipped pet, compute rate = base rarity income × origin-biome factor × variant factor × combined mutation factor × (1 + 0.01 × (level - 1)) × permanent account factor. Add pet rates to obtain the team's nominal coins per second. Huge strength is a separately configured factor and defaults to 1 until approved. Never apply origin scaling twice if a stored base value already includes it.

Normal Forest Level 1 base rates are Common 10K, Uncommon 50K, Rare 250K, Epic 1M, Legendary 5M, Mythic 25M, Eternal 125M, Heroic 600M, Divine 1.7B, and EXCLUSIVE 20B per second. Variant factors are Normal 1, Silver 3, Gold 7, Diamond 15, and Rainbow 30.

## Target lifecycle and payout contract

Proposed prototype contract: durability is measured in coin-work units. Each server tick removes min(team rate × elapsed time, remaining durability) from a target and credits that exact amount as coins. A target therefore has a fixed maximum total payout equal to its initial durability. This avoids granting both periodic income and a second full chest reward on depletion. Award XP only for validated active work.

Multiple teams share one target's remaining work; apportion a tick's remaining durability by requested work so the last tick never overpays. Keep fractional progress internally, credit whole coins, and retain the fractional remainder per player. Pets choose a reachable target in range in an unlocked sector; after depletion select another target or idle. No target means no farming payout.

## Prototype target configuration

For Forest Entrance, start with small pile 100K work / 3-second respawn, large pile 500K / 5 seconds, hoard 2M / 8 seconds, and wooden chest 10M / 12 seconds. Later sector target work scales provisionally by 10 per sector. These are playtest proposals. Tune target density and replenishment so powerful teams have useful targets without infinite instant payout loops. A one-hit pet still earns only the remaining target value.

## Economy sinks and presentation

Coin sinks are egg spins, sequential sector gates, and proposed food purchases. Do not charge coins for permanent cosmetic bat claims. Display K, M, B, T, Qa and larger suffixes with consistent rounding; keep the exact balance available in a detail view. Nominal team rate is potential farming output, while earned coins reflect real available target work.

Use an explicit large-number representation for balances and rates before values exceed exact integer precision. Persist a versioned decimal-string or mantissa/exponent format rather than silently truncating large values. Rounding on screen must never determine affordability. Cap elapsed time for farming ticks to prevent a long pause from becoming unbounded income; offline income is outside the current design.

## Leaderboards

The supplied board references show global and current-server rankings with coins/sec and Coins columns. Rank by server-calculated nominal team rate, with a stable user-ID tiebreaker. Show cached data and update timestamps. Prototype refresh targets are 30 seconds globally and 5 seconds locally; these are display goals, not guarantees. Throttle writes and show an unavailable state when ranking storage fails. Never let board errors block farming.

## Data and implementation ownership

Treasure definitions store target ID, sector, initial work, respawn delay, and visual model. TreasureService owns target state; FarmingService owns assignment and tick allocation; EconomyService owns balance changes; leaderboard and visual controllers consume sanitized snapshots. Save wallet and persistent progression, not each short-lived target. Validate distance, equipment ownership, sector access, and target life state server-side.

## Acceptance checks

- A 10K/sec starter earns 10K from one second of valid work.
- A 100K target pays at most 100K total across all contributors.
- Depleted targets shrink, disappear, and respawn without duplicate payouts.
- Pet swaps, mutations, and purchases update rate once.
- Teleporting into a locked sector never authorizes farming there.
- Extremely large values retain affordability and display correctly.

## Art deliverables

Create small and large leaf-engraved gold piles, a giant hoard, wooden chest, and golden chest. Keep collision simple and use staged scale changes rather than complex destruction. The Blender sample presents reusable treasure and cube pets on a forest diorama.
''',
'Egg Spinning & Pet Index System': '''## Purpose and collection rules

Coin egg spins supply biome pets. The Pet Index permanently records species discovery and unlocks cosmetic bat skins when a rarity collection is complete. Each biome has exactly 30 species: 5 Common, 5 Uncommon, 4 Rare, 4 Epic, 3 Legendary, 3 Mythic, 2 Eternal, 2 Heroic, and 2 Divine. Five planned biomes total 150 standard species. EXCLUSIVE uses a separate collection and never appears in ordinary coin spins or normal Egg Rush.

## Plaza and spin flow

Arrange giant themed egg pedestals in a semicircle with the selected egg prominent. Display the coin price, available species, individual probabilities, and inventory capacity before purchase. A pedestal is a product presentation, not a new rarity. The reference art's Secret label is decorative legacy concept text; production uses Eternal, Heroic, and Divine within the nine standard rarities.

On request, the server checks biome access, profile state, capacity, balance, and cooldown. It reserves inventory capacity, debits coins, rolls once using configured server weights, creates a uniquely identified pet, records discovery, and commits the result before sending the reveal. A request ID returns the same outcome on retry. Reveal animation must not determine rewards. Failed transactions leave the balance and inventory unchanged.

## Proposed Forest egg configuration

Use one Forest collection pool initially, with additional pedestal designs available for later distinct pools. Prototype price: 250K coins per spin. Proposed rarity probabilities: Common 45%, Uncommon 30%, Rare 15%, Epic 7%, Legendary 2%, Mythic 0.8%, Eternal 0.15%, Heroic 0.05%, Divine 0%. These total 100%; split each rarity's weight equally among its species unless explicitly configured otherwise. Divine remains tied to the separate daily-limited opportunity. Its daily entry rules, odds, and cap require an explicit product decision before that opportunity can ship. These are new playtest defaults, not approved production odds.

## Index interface

Provide Forest, River, Desert, Ice, and Volcanic tabs, with unreleased collections marked Coming Soon. Show at least seven compact tiles per desktop row and a responsive grid on smaller screens. Tiles run continuously from Common through Divine without rarity heading rows. Use full rarity-colored backgrounds and a silhouette for undiscovered species. Pair color with names and lock icons for readability.

Discovery is species-based: obtaining another variant, duplicate, Huge size, or mutation does not count as another species. Discovery survives deleting or otherwise losing an owned pet. The collection counter reads discovered / 30, never total inventory size. EXCLUSIVE tiles live in a separate rainbow-themed tab.

## Bat reward contract

Completing all species of a rarity unlocks one permanent biome rarity bat: Forest Common requires 5/5, Uncommon 5/5, Rare 4/4, Epic 4/4, Legendary 3/3, Mythic 3/3, Eternal 2/2, Heroic 2/2, and Divine 2/2. Recompute eligibility on discoveries and profile migration; grant each bat once. The Bat Skin Inventory previews owned skins and saves the selected cosmetic. All skins use identical combat stats.

## Persistence and service integration

Save species discoveries, bat unlock IDs, selected skin, and spin transaction results alongside inventory and wallet. EggService uses EconomyService and PetService; IndexService derives completion; BatSkinService grants cosmetics. Definition validation must reject unknown species, negative weights, wrong biome counts, and pools containing EXCLUSIVE. Expose actual configured probabilities to the interface rather than maintaining a separate hand-written odds display.

## Acceptance checks

- Every biome definition has 30 unique species with the required distribution.
- A full inventory prevents spending and rolling.
- Duplicate requests cannot spend twice or grant two pets.
- A new species updates discovery and any completed reward once.
- Removing a pet never removes its Index discovery or bat reward.
- Standard spins cannot yield EXCLUSIVE or bypass the Divine daily system.

## Art deliverables

Create Forest egg shell, pedestal, rarity trim, central clover egg, nine rarity tile treatments, 30 species thumbnails and silhouettes, and nine cosmetic bat models. The local asset sheet guides plaza materials; the bat sheet guides all nine reward appearances. The Blender sample is a plaza blockout with nine standard rarity pedestals.
''',
'Mini-Field & Egg Rush PvP System': '''## Purpose and fixed fairness rules

Egg Rush is an optional competition every 20 minutes in a rectangular Mini-Field. Players start together and race to ten egg boxes in one straight row. Bats knock opponents backward. All players use identical speed, range, cooldown, hitbox, and knockback regardless of pets, purchases, or bat skin. No EXCLUSIVE rewards come from normal Egg Rush.

## Event lifecycle

Use server states Idle → Registration → Teleporting → Countdown → Running → Results → Returning → Idle. A proposed registration lasts 30 seconds, followed by the required five-second countdown, a maximum 60-second race, and a five-second results display. These timing defaults extend the approved 20-minute cadence for playtesting. Missed rounds do not queue multiple events after server downtime.

Save each entrant's safe return location and current movement settings. Lock entrants behind a starting barrier during countdown. Enable combat only when Running begins. End when all boxes are claimed or the timer expires. Restore world movement rules and return entrants safely even after death, reset, or early exit. Cancel an empty registration without consuming player resources.

## Proposed egg claim mechanic

Use instant claim for the sample implementation: a player within six studs holds an interaction for 0.75 seconds. Taking a valid hit or leaving the radius interrupts the hold. The server atomically grants the first completed valid claim, locks the box, and creates a persistent pending egg reward. Maximum one box per player per round; extra entrants may finish without a reward. Box assignment is determined by server completion order, never client timestamps. Unclaimed boxes expire at round end.

Pending rewards reserve a claim even if inventory is full and can be opened later from a reward inbox. Convert each pending egg into its configured standard biome pet using a unique round/box claim key. Retries and reconnects must not duplicate rewards. Carry-to-safe-zone mechanics are outside this proposed baseline.

## Prototype combat specification

Use uniform speed 16 studs/second, range 6 studs, swing cooldown 0.8 seconds, and a short equal knockback impulse as playtest values. Validate attacker/target participation, state, distance, facing, and cooldown on the server. Limit repeated hits with a proposed 0.5-second victim grace period. Cosmetic meshes never define the hitbox. Bats do not deal health damage and cannot hit spectators or players in the main world.

Disable rarity movement bonuses and farming pet effects in the arena. Farming multipliers, Lucky Boosters, Huge size, variants, and mutations have no influence on combat or claim speed. Restore the highest equipped rarity's world speed on return rather than assuming every player had the same original speed.

## Arena and interface

Build an unobstructed grass rectangle, fenced boundaries, a full-width start line, readable box numbers 1–10, and a spectator edge outside combat bounds. Space spawn slots fairly across the same line. Show the next event timer, optional Join button, countdown, boxes remaining, claim progress, and result. The supplied concept image omits one physical box and skips numbering; the Blender sample and implementation must contain exactly ten.

## Rewards and persistence

Use a separately configured standard-pet reward pool; any Divine reward must obey the approved daily-limited rule. Until that rule is approved, exclude Divine from the prototype pool along with EXCLUSIVE. Arena rewards do not require the winner to unlock a future biome: keep the launch reward pool Forest-only. Weekly Admin Abuse summons are a separate event with distinct configuration.

## Acceptance checks

- Ten boxes spawn with unique consecutive numbers.
- Countdown prevents movement and premature claims.
- Two simultaneous claims award one persistent reward.
- Purchases and every cosmetic bat produce identical PvP behavior.
- Full inventory, disconnect, reset, and event cancellation preserve rewards and restore safe state.
- Invalid swing and claim requests cannot affect nonparticipants.

## Art deliverables

Create arena boundary modules, starting stripe, ten numbered egg boxes, equal-footprint cosmetic bats, countdown overlay, and reward reveal. The Blender sample provides the actual ten-box arena layout, with a separate bat reference sheet for appearance.
''',
'Weather Events & Mutation System': '''## Purpose and permanent outcomes

Random weather exposes equipped pets to direct-hit mutation rolls. Standing in a weather event alone never grants a mutation. Successful mutations are permanent per pet, distinct mutations can accumulate, and duplicates are forbidden. Weather changes farming appearance and output without influencing Egg Rush fairness.

## Event definitions

Rainy produces Soaked at 1.5×, Snowstorm produces Frozen at 2.5×, Thunderstorm produces Thunderstruck at 4×, Rage produces Enraged at 7×, Meteor Shower produces Celestial at 12×, and Aurora produces Astral at 25×. Keep a stable mutation ID separate from its display name. Preserve these approved individual factors.

## Proposed scheduler and strike model

For the sample, schedule one two-minute weather event after a random 8–12 minute clear interval. Pick weather with provisional weights Rainy 40, Snowstorm 25, Thunderstorm 18, Rage 10, Meteor Shower 5, and Aurora 2 out of 100. Do not overlap weather events. These timing and frequency values are playtest proposals.

During an event, every ten seconds choose up to three eligible equipped pets per server, uniformly without replacement. Produce a visible effect that directly contacts each chosen pet, then roll mutation success on the server. Eligibility requires a loaded owner profile, an active pet in an unlocked world sector, and absence of that mutation. Pets in the Mini-Field, inventory, or another server are excluded. Limit a pet to one roll per strike ID; visual replay never repeats the roll.

## Success and booster rules

Use a provisional base chance of 5% per qualifying direct hit. Basic, Super, and Ultra Lucky add 5, 15, and 25 percentage points respectively for five minutes, yielding 10%, 20%, and 30% with the sample base. Clamp success to 100%. Only one booster is active; reject activation while another remains active. Consume a booster and record its end time atomically. Proposed timer semantics use an absolute UTC expiry that continues while offline; show this before activation.

Boosters do not create strikes, change event frequency, guarantee mutations, or affect egg odds or PvP. Only a qualifying pet owned by the boosted player receives the chance bonus.

## Proposed stacking decision

For the sample use additive bonus stacking: combined factor = 1 + sum(individual factor - 1). Soaked plus Frozen gives 3×, not 3.75×. All six distinct mutations give 47×. Permit all six types and no duplicates. This is a new balancing proposal resolving an earlier open question, not an approved rule. Use one shared configurable formula in the pet detail UI and farming calculation so playtests can change it safely.

## Visual and audio behavior

Give each weather a readable sky tint, lightweight ambient particles, strike cue, and a success notification naming the pet and mutation. Soaked uses droplets; Frozen uses frost; Thunderstruck uses sparks; Enraged uses ember accents; Celestial uses star fragments; Astral uses soft aurora ribbons. Preserve the cube silhouette and rarity identity beneath overlays. Support reduced effects and avoid rapid full-screen flashes. A failed strike remains visually distinct from a successful permanent mutation.

## Persistence and ownership

WeatherService owns scheduling and strike IDs. MutationService checks eligibility and grants permanent IDs through PetService. BoosterService stores inventory and expiry. Save the mutation list, booster counts, expiry, and grant transaction IDs. Recompute income from definitions after mutation grant; never compound a previously multiplied cached income. Late event messages cannot mutate an unequipped or transferred pet.

## Acceptance checks

- Ambient rain without a direct hit grants nothing.
- A failed roll leaves the pet unchanged.
- Replaying a strike or receiving the same mutation cannot duplicate its bonus.
- Six mutations produce 47× under the proposed additive rule.
- A booster expires correctly after reconnect and cannot overlap another.
- Egg Rush pets receive no strikes or combat advantage.

## Art deliverables

Produce six restrained mutation overlays, six weather cues, strike effects, booster bottle icons, and success/failure notifications. The pet reference sheet establishes mutation colors. The Blender sample shows six cubic pets with distinct weather treatments; procedural effects illustrate appearance rather than a runtime particle implementation.
''',
'Robux Shop & Permanent Upgrade System': '''## Purpose and permanent entitlements

The shop offers sequential permanent farming upgrades, premium EXCLUSIVE pets, and mutation Lucky Boosters. Farming upgrades belong to the account, never expire, survive future biomes, and never require repurchasing an owned tier. No shop product improves Egg Rush speed, knockback, hitbox, range, cooldown, or claim speed.

## Approved target price ladder

Start at 1× for free. Sequential tier multiplier / target Robux price pairs are 2× / 2, 4× / 5, 8× / 9, 16× / 15, 32× / 25, 64× / 39, 128× / 59, 256× / 89, 512× / 129, 1,024× / 179, 2,048× / 249, and 4,096× / 349. The full target ladder totals 1,149 Robux, matching the master overview. These are design target prices, not a claim that products are configured or published.

Always show current multiplier, next multiplier, exact available platform price, permanence, and a clear purchase button. The next tier doubles the current multiplier; it is a replacement factor rather than an additional independent bonus. Buying 4× after 2× results in 4× total, not 8×.

## Future expansion

Forest launch caps available tiers at 4,096×. Planned later caps are River 16,384×, Desert 65,536×, Ice 262,144×, and Volcanic 1,048,576×. Each expansion adds sequential doublings. Prices for tiers beyond launch remain a product decision; keep unreleased tiers informational and unpurchasable. Old entitlements carry forward unchanged.

## Receipt and entitlement contract

Use a centralized server purchase adapter; bind configured platform product IDs to explicit entitlement grants. The client purchase prompt is never evidence of payment. Validate the actual server receipt or entitlement ownership before granting. Record receipt IDs alongside the grant transaction and make fulfillment idempotent so retries cannot duplicate consumables or pets.

For sequential upgrades, configure permanent ownership products per tier and reconcile owned tiers on join. The UI only offers the next tier. Never consume a paid valid entitlement because an earlier ownership check arrived late: reconcile the highest verified permanent tier and log ordering anomalies. For repeatable pets and boosters, use receipt-based consumable fulfillment and a persistent pending-grant record if inventory cannot accept a reward. A shop failure must preserve the player's current tier and all existing purchases.

## Lucky Boosters

Basic, Super, and Ultra Lucky last five minutes and add proposed bonuses of 5, 15, and 25 percentage points to a qualifying mutation roll. Only one is active at a time. The shop must state that a direct weather hit is required and success is not guaranteed. Pricing is not approved; display Coming Soon in sample UI rather than invented purchase prices. The Weather system owns activation and expiry semantics.

## EXCLUSIVE and special events

EXCLUSIVE has a Forest reference base of 20B/sec and animated rainbow presentation. It is separate from the 30-pet biome index and never enters ordinary egg pools. Premium species, prices, variant rules, and Huge availability are not approved. Weekly Admin Abuse summons use a separate free event configuration and announcement; exact schedule and odds remain a release gate. Sample art may show an EXCLUSIVE preview without suggesting it is purchasable now.

## Interface and failure states

Separate Permanent Upgrades, Premium Pets, and Boosters. Show owned/current state, pending purchase, completed fulfillment, cancelled prompt, unavailable product, and retryable service error. Disable duplicate purchase requests while pending. The selected bat skin is never a paid combat tier. Preserve price localization and live product metadata rather than treating concept art numbers as a checkout authority.

## Data and acceptance checks

Save verified tier ownership, receipt/grant IDs, booster inventory, premium pet UIDs, and pending grants. Test repeated receipts, reconnect during purchase, delayed ownership reconciliation, unavailable profile, full inventory, cancelled prompt, and future tier rollout. A confirmed grant must survive rejoin; an unconfirmed client prompt must grant nothing. Check that the 12 launch target prices sum to 1,149 and all multiplier values equal powers of two.

## Art deliverables

Create a forest wooden shop kiosk, blue-and-white awning, upgrade badge, potion previews, premium pet display, and clear owned/current indicators. The Blender sample includes a kiosk, booster bottles, and upgrade display. Final checkout prices come from verified configured products rather than image text.
'''
}

COMMON = '''## Specification status and dependencies

This is a development context document, not a claim of implemented Roblox gameplay. Rules inherited from the master concept remain the baseline. Any section labeled proposed or prototype is a concrete playtest recommendation and must be balanced before release. Unapproved monetization, Divine access, Huge acquisition, and future content remain explicitly gated.

All permanent changes are server-authoritative and saved in a versioned player profile. Failed profile loads must block spending and grants rather than overwrite real progress with defaults. Use bounded retries, session ownership, idempotent transaction IDs, and migration checks. Clients handle presentation and submit requests, never final rewards or balances.
'''

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')

links=[]
for i,(folder,filename,reference,slug) in enumerate(SYSTEMS,1):
    d=BASE/folder
    images=d/'images'
    images.mkdir(exist_ok=True)
    shutil.copy2(ROOT/'asset-images'/reference, images/'reference.png')
    if 'Index' in folder or 'PvP' in folder:
        shutil.copy2(ROOT/'asset-images/bat-sample.png', images/'bat-reference.png')
    if 'Economy' in folder or 'Spinning' in folder:
        shutil.copy2(ROOT/'asset-images/leaderboard-looklike.png', images/'leaderboard-reference.png')
    visual=f'''## Local images and editable Blender sample

![Primary art reference](images/reference.png)

![Actual Blender sample render](images/{slug}-render.png)

The render is generated from [the editable Blender scene](images/{slug}.blend). See [image context](images/README.md) for art intent, reference limitations, and reproduction instructions.
'''
    if i==1:
        old=(d/filename).read_text(encoding='utf-8')
        old=re.sub(r'^\[.*?\]\(https://images\.openai\.com/.*?\)\s*$', '', old, flags=re.M)
        old=re.sub(r'^\[devforum\.roblox\.com\].*$', '', old, flags=re.M)
        if '## Local images and editable Blender sample' not in old:
            old += '\n'+COMMON+'\n'+visual+'''
## Proposed prototype decisions supplement

Start with three equipment slots and 200 inventory slots, with one free Level 1 Normal Common Forest Fox granted exactly once. Add the starter species to discovery. Use XP-to-next-level = 100 × current level, reset within-level XP on each level-up, carry overflow forward, and cap at Level 100. Reaching 100 requires 495,000 cumulative XP. Grant one XP per second of validated active farming per equipped working pet, independent of payout multipliers.

Proposed food coin prices are Apple 100K, Fish 500K, Golden Fruit 2.5M, and Mystic Treat 10M, for the existing 100 / 500 / 2,500 / 10,000 XP values. Reject feeding a capped pet before consuming food. Use additive mutation bonuses and a maximum of six distinct types as described in the Weather specification. Huge remains visually supported with a default strength factor of 1 until acquisition and strength are approved. Variants remain modeled attributes; do not expose an unapproved paid variant-conversion flow.

### Proposed 30-species Forest roster

These names are new art direction proposals, not approved character assets. Common: Forest Fox, Meadow Bunny, Acorn Mouse, Moss Chick, Twig Pup. Uncommon: Leaf Cat, Clover Deer, Fern Frog, Sprout Owl, Hedgehog Scout. Rare: Azure Jay, Crystal Badger, Riverbank Otter, Sapphire Squirrel. Epic: Mystic Owl, Mooncap Cat, Orchid Moth, Rune Wolf. Legendary: Amber Griffin, Suncrest Lion, Ancient Stag. Mythic: Ember Imp, Crimson Drake, Thorn Phoenix. Eternal: Twilight Lynx, Void Raven. Heroic: Halo Hound, Pearl Pegasus. Divine: Golden Dragon, Crowned Seraph. Every design retains a dominant cube-shaped body. Store stable species IDs independently from names.

### Cross-system precedence

The starter and standard collection exclude EXCLUSIVE. Divine acquisition stays behind its separate daily-limited opportunity until its limits are approved. Use the shared farming rate formula and mutation policy, rather than multiplying cached values repeatedly. Main-world rarity speed bonuses are disabled in Egg Rush. Complete Index rewards from permanent species discoveries, not the number of currently owned pets.
'''
        write(d/filename,old)
    else:
        write(d/filename,f'# MY LITTLE PETS\n\n## System {i} — {folder}\n\n'+COMMON+'\n'+CONTENT[folder]+'\n'+visual)
    write(images/'README.md',f'''# {folder} — image context

`reference.png` is a local copy of the supplied `{reference}`. It is visual direction, not a screenshot of completed gameplay. Original files remain in `/asset-images`.

`{slug}-render.png` is an actual Blender render of the sample scene. `{slug}.blend` is the corresponding editable scene containing named objects, materials, camera, and lights. These are sample/blockout assets; they are not imported Roblox models or a finished game.

Read [system context](../{filename.replace(' ', '%20')}) for behavior, balance proposals, art requirements, and acceptance checks. The Blender scene is generated by `tools/render_samples.py` at the project root. Run Blender in background mode with that script to regenerate all seven scene/render pairs. No external textures are required.

Production corrections to reference art: use nine standard rarities through Divine, with EXCLUSIVE separate; Secret is not an approved rarity. The final Forest gate leads to River, not Beach. Egg Rush requires exactly ten boxes numbered 1–10. Embedded reference percentages and prices are illustrative and do not configure gameplay.
''')
    links.append(f'- [System {i}: {folder}](<{folder}/{filename}>)')

write(BASE/'README.md','# Game system development context\n\n'+ '\n'.join(links)+'''\n
Each folder contains its system Markdown specification and an `images` folder with reference art, an actual Blender render, an editable `.blend` sample, and an image-context README. Start with the original master overview, then read each detailed system document. New numeric defaults are labeled as proposals; no document claims the Roblox implementation is complete.
''')
write(ROOT/'asset-images/README.md','''# Supplied asset reference images

- `pet-image.png`: mandatory cube pet silhouette, rarity presentation, variants, levels, mutation examples, Huge proportions, and inventory direction.
- `forest-sample.png`: linear forest farming route, cliffs, trees, coin piles, and chests. Replace the reference Beach Area gateway with River Coming Soon.
- `egg-rush.png`: Mini-Field framing and start line. The image has missing/inconsistent box numbering; build exactly ten boxes numbered 1–10.
- `bat-sample.png`: nine permanent Forest rarity collection rewards. Every skin is cosmetic and uses identical combat parameters.
- `assets.png`: modular plaza, egg pedestals, shop, fences, trees, and leaderboard styling. Secret is not an approved rarity.
- `leaderboard-looklike.png`: global/server board placement and coin-rate presentation. Embedded names, amounts, odds, and update text are illustrative.

These supplied PNGs are concept references, not editable 3D models or evidence of working gameplay. Actual Blender samples and renders are in each corresponding system's `images` folder. Preserve these originals when revising production art.
''')
master=ROOT/'mylittlepets-overview.md'
text=master.read_text(encoding='utf-8')
text=re.sub(r'^\[.*?\]\(httpsimages\.openai\.com.*?\)\s*$', '', text, flags=re.M)
if '## Detailed system documents and local assets' not in text:
    text+='\n\n## Detailed system documents and local assets\n\nSee [all seven system specifications](game-system-overview/README.md) and [the supplied asset context](asset-images/README.md). Each system includes local reference art, an editable Blender sample, an actual render, and an images README. New playtest values in detailed documents are proposals. The launch price ladder sums to 1,149 Robux.\n\n![Pet visual standard](asset-images/pet-image.png)\n\n![Forest route reference](asset-images/forest-sample.png)\n\n![Forest cosmetic bats](asset-images/bat-sample.png)\n\n![Egg Rush arena reference](asset-images/egg-rush.png)\n\n![Plaza and shop modules](asset-images/assets.png)\n\n![Leaderboard visual reference](asset-images/leaderboard-looklike.png)\n'
write(master,text)
write(ROOT/'README.md','''# My Little Pets — development reference pack

Start with the [master concept](mylittlepets-overview.md), then read the [seven system specifications](game-system-overview/README.md). Each system has complete development context, art requirements, prototype decisions, acceptance checks, and an `images` folder with its own context Markdown.

Supplied concept images remain in [asset-images](asset-images/README.md). Actual sample renders and editable Blender scenes live beside their relevant specification. They demonstrate art and layout; this repository does not yet contain a working Roblox game.

Regenerate documentation with `python tools/build_context.py`. Regenerate scenes and renders with Blender background mode and `tools/render_samples.py`. Use the local portable Blender runtime under `.tools` if present, or an installed Blender 4.5+. Scripts use only built-in Python/Blender features and no downloaded art dependencies.
''')
print('Created context for',len(SYSTEMS),'systems')
