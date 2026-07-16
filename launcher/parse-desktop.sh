#!/usr/bin/env python3
import os, json, re, sys

ICON_CACHE = {}

def resolve_icon(name):
    if not name:
        return ""
    if name in ICON_CACHE:
        return ICON_CACHE[name]
    if name.startswith("/"):
        if os.path.isfile(name):
            ICON_CACHE[name] = name
            return name
        ICON_CACHE[name] = ""
        return ""

    bases = [
        "/usr/share/icons/hicolor",
        "/usr/share/icons/Adwaita",
        "/usr/share/icons/breeze",
        "/usr/share/icons/breeze-dark",
        "/usr/share/icons/Papirus",
        "/usr/share/icons/Tela",
        os.path.expanduser("~/.local/share/icons/hicolor"),
    ]
    sizes = ["48x48", "64x64", "128x128", "256x256", "512x512", "scalable", "symbolic"]
    subdirs = ["apps", "actions", "categories", "devices", "places", "status", "emblems"]

    for base in bases:
        for size in sizes:
            for sub in subdirs:
                d = os.path.join(base, size, sub)
                if not os.path.isdir(d):
                    continue
                for ext in (".png", ".svg"):
                    p = os.path.join(d, name + ext)
                    if os.path.isfile(p):
                        ICON_CACHE[name] = p
                        return p

    px = os.path.join("/usr/share/pixmaps", name + ".png")
    if os.path.isfile(px):
        ICON_CACHE[name] = px
        return px

    ICON_CACHE[name] = ""
    return ""

def parse_desktop_files():
    apps = []
    seen = set()
    dirs = [
        '/usr/share/applications',
        os.path.expanduser('~/.local/share/applications'),
        '/usr/local/share/applications',
    ]

    for d in dirs:
        if not os.path.isdir(d):
            continue
        for f in sorted(os.listdir(d)):
            if not f.endswith('.desktop'):
                continue
            path = os.path.join(d, f)

            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as fh:
                    content = fh.read()
            except Exception:
                continue

            entries = {}
            in_entry = False
            for line in content.split('\n'):
                line = line.strip()
                if line.startswith('[Desktop Entry]'):
                    in_entry = True
                    continue
                if line.startswith('['):
                    in_entry = False
                    continue
                if not in_entry or not line or line.startswith('#'):
                    continue
                if '=' in line:
                    k, v = line.split('=', 1)
                    entries[k.strip()] = v.strip()

            if entries.get('NoDisplay', '').lower() == 'true':
                continue
            if entries.get('Hidden', '').lower() == 'true':
                continue

            name = entries.get('Name', '')
            icon = entries.get('Icon', '')
            exec_cmd = entries.get('Exec', '')

            if not name or not exec_cmd:
                continue
            if name in seen:
                continue
            seen.add(name)

            exec_cmd = re.sub(r'%[fFuUdDnNickvm]', '', exec_cmd).strip()
            # Remove orphaned -- and flags left after field code removal
            # e.g. "command --url -- %u" -> "command --url --" -> "command"
            exec_cmd = re.sub(r'\s+--\s*$', '', exec_cmd)
            exec_cmd = re.sub(r'\s+-{1,2}[a-zA-Z-]+(?:\s+--)?\s*$', '', exec_cmd)
            exec_cmd = exec_cmd.strip()
            exec_cmd = re.sub(r'^"|"$', '', exec_cmd)

            apps.append({'name': name, 'icon': icon, 'exec': exec_cmd, 'icon_path': resolve_icon(icon)})

    apps.sort(key=lambda x: x['name'].lower())
    return apps

if __name__ == '__main__':
    try:
        result = parse_desktop_files()
        print(json.dumps(result, ensure_ascii=False))
    except Exception as e:
        print(json.dumps({'error': str(e)}), file=sys.stderr)
        sys.exit(1)
