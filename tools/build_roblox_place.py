"""Build a portable Roblox XML place from the checked-in Luau sources."""
from pathlib import Path
import xml.etree.ElementTree as E

root = Path(__file__).resolve().parents[1]
doc = E.Element('roblox', version='4')
for value in ('null', 'nil'):
    E.SubElement(doc, 'External').text = value

def item(parent, cls, name, source=None):
    obj = E.SubElement(parent, 'Item', {'class': cls})
    props = E.SubElement(obj, 'Properties')
    E.SubElement(props, 'string', name='Name').text = name
    if source:
        E.SubElement(props, 'ProtectedString', name='Source').text = (root / 'game' / source).read_text(encoding='utf-8-sig')
    return obj

item(doc, 'Workspace', 'Workspace')
shared = item(item(doc, 'ReplicatedStorage', 'ReplicatedStorage'), 'Folder', 'MyLittlePets')
for name in ('Config', 'BigNum', 'Assets', 'HUD'):
    item(shared, 'ModuleScript', name, name + '.luau')
item(shared, 'RemoteEvent', 'Action')
server = item(item(doc, 'ServerScriptService', 'ServerScriptService'), 'Folder', 'MyLittlePets')
for name in ('Profiles', 'GameService', 'World', 'RushService', 'WeatherService', 'ShopService', 'LeaderboardService'):
    item(server, 'ModuleScript', name, name + '.luau')
item(server, 'ModuleScript', 'Tests', 'tests/Tests.luau')
item(server, 'Script', 'GameServer', 'Server.luau')
client = item(item(item(doc, 'StarterPlayer', 'StarterPlayer'), 'StarterPlayerScripts', 'StarterPlayerScripts'), 'Folder', 'MyLittlePets')
item(client, 'LocalScript', 'GameClient', 'Client.luau')
item(doc, 'Lighting', 'Lighting')
out = root / 'game/build/MyLittlePets.rbxlx'
E.indent(doc)
E.ElementTree(doc).write(out, encoding='utf-8', xml_declaration=True)
E.parse(out)
print(f'Built {out} ({out.stat().st_size:,} bytes)')
