# Rebuilding the reference pack

These scripts create documentation and real Blender scenes; they do not implement Roblox gameplay.

1. Run `python tools/build_context.py` to rebuild context documents and copy supplied reference images.
2. Run `.tools/blender-4.5.15-windows-x64/blender.exe --background --python tools/render_samples.py` from the project root to rebuild all seven scenes and PNG renders.
3. Run `python tools/verify_pack.py` to verify document links, file presence, render dimensions, and balance arithmetic.
4. Run Blender with `--background --python tools/audit_blender.py` to open each saved scene and verify camera, lighting, geometry, and ten numbered arena boxes.

The portable runtime comes from [Blender's official release directory](https://download.blender.org/release/Blender4.5/). It stays local under `.tools`; an installed Blender 4.5 or later can run the same scripts. Rendering uses Cycles, 24 samples, denoising, an orthographic camera, and 1600 × 1100 PNG output. Materials are procedural and require no external textures.

Every scene is a sample diorama/blockout. Before Roblox production, separate reusable assets, decide scale in studs, simplify collision, set pivots, test materials and mobile performance, and export selected meshes through the chosen Studio import pipeline. The `.blend` scenes retain editable geometry and text rather than baked reference images.
