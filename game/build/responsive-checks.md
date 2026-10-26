# Responsive UI verification — 2026-10-26

Updated HUD and menus: 8px outer padding and column gaps; 44px compact / 48px regular menu buttons; fixed caption space and consistent row spacing. All seven buttons, including Settings, share one group. Touch devices use center-right placement. Menu panels fit the safe viewport and hide the HUD while open. Coins/sec stays above the balance; touch layouts avoid the default movement controls. Forest is an 18px top-edge label. DeviceSafeInsets respects device cutouts without the previous large top margin.

Checked in Studio: iPhone 7 landscape (666×374), portrait (374×666), iPad Pro M5 (1375×1032), laptop (1365×768), desktop (1919×1079). All seven button bounds passed on phone/tablet/laptop; countdown text fit all four sizes. Portrait Pets menu stayed within its viewport, with working responsive tab widths and scrolling content. Screenshot inspection covered phone, portrait menu, tablet, laptop and desktop. Console showed no runtime errors. Device simulator reset to default afterward.

Actual hardware performance and every individual menu interaction are not exhaustively tested.
