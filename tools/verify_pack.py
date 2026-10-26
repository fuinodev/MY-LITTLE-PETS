"""Validate local deliverables without changing the files."""
from pathlib import Path
import re, struct, json
ROOT=Path(__file__).resolve().parents[1]
base=ROOT/'game-system-overview'
errors=[];summary=[]
for folder in sorted(p for p in base.iterdir() if p.is_dir()):
    docs=list(folder.glob('*.md'));imgs=folder/'images'
    renders=list(imgs.glob('*-render.png'));blends=list(imgs.glob('*.blend'))
    if not docs or not (imgs/'README.md').exists():errors.append(str(folder)+' missing context')
    if len(renders)!=1 or len(blends)!=1:errors.append(str(folder)+' missing scene/render')
    for p in renders:
        data=p.read_bytes()
        if data[:8]!=b'\x89PNG\r\n\x1a\n':errors.append(str(p)+' invalid PNG')
        else:
            w,h=struct.unpack('>II',data[16:24])
            if (w,h)!=(1600,1100):errors.append(str(p)+' unexpected dimensions')
    for p in blends:
        if p.stat().st_size<10000:errors.append(str(p)+' unexpectedly small Blender file')
    summary.append({'system':folder.name,'documents':len(docs),'renders':len(renders),'blend_scenes':len(blends)})
for md in ROOT.rglob('*.md'):
    if '.tools' in md.parts:continue
    for raw in re.findall(r'\]\(([^\n]+?)\)',md.read_text(encoding='utf-8')):
        raw=raw.strip('<>').replace('%20',' ')
        if '://' in raw or raw.startswith('#'):continue
        target=(md.parent/raw.split('#')[0]).resolve()
        if not target.exists():errors.append(f'{md.relative_to(ROOT)}: broken link {raw}')
assert sum([2,5,9,15,25,39,59,89,129,179,249,349])==1149
assert 1+sum(v-1 for v in [1.5,2.5,4,7,12,25])==47
report={'systems':summary,'errors':errors,'status':'PASS' if not errors else 'FAIL'}
(ROOT/'verification-report.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report,indent=2))
raise SystemExit(bool(errors))
