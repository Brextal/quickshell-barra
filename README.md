# Quickshell Barra

Panel flotante tipo isla para **Hyprland** con **Quickshell**.
Estilo **vidrio empañado (glassmorphism)** — fondos blancos traslúcidos, bordes suaves, acentos dinámicos vía [pywal](https://github.com/dylanaraps/pywal).

## Módulos

| Módulo | Descripción |
|---|---|
| `barra/` | Panel flotante con workspaces, reloj, volumen, brillo, red, bluetooth y música |
| `calendar/` | Calendario con pronóstico del tiempo |
| `launcher/` | Lanzador de aplicaciones |
| `wallclock/` | Reloj de pared con anillo animado y stats del sistema |
| `shared/` | Módulo compartido (colores pywal) |

## Dependencias

- [Quickshell](https://quickshell.outfoxxed.me/) (0.3.0+)
- QtQuick, QtQuick.Controls, QtQuick.Window
- Hyprland (para blur, workspaces, capas)
- [pywal](https://github.com/dylanaraps/pywal) o [pywal16](https://github.com/eylles/pywal16)
- Nerd Fonts (iconos)
- `nmcli` (NetworkManager) para la sección de red
- `brightnessctl` para el control de brillo
- `wpctl` (WirePlumber) para el control de volumen
- `mpv` + `mpv-mpris` para reproducción musical con MPRIS
- `zenity` para selector de carpetas
- `hyprlock` para bloquear sesión
- `systemctl` para apagar / reiniciar / suspender / hibernar

## Instalación

```bash
git clone https://github.com/Brextal/quickshell-barra.git ~/.config/quickshell
```

O usar el script de instalación:

```bash
bash ~/.config/quickshell/install.sh
```

## Configuración de Hyprland

Agregá al final de `~/.config/hypr/hyprland.conf`:

```conf
source = ~/.config/quickshell/barra/hypr/barra.conf
source = ~/.config/quickshell/barra/hypr/lookandfeel.conf
source = ~/.config/quickshell/calendar/hypr/calendar.conf
```

## Estructura

```
~/.config/quickshell/
├── barra/          shell.qml, secciones, hypr/, reload.sh
├── calendar/       shell.qml, CalendarStrip, hypr/, weather_fetch.sh
├── launcher/       shell.qml, AppItem, LauncherPanel, demo/
├── wallclock/      shell.qml, RingArc, stats.sh, find-cover.sh, cava-read.sh
├── shared/         Pywal.qml
├── install.sh
└── README.md
```

Los módulos comparten `shared/` mediante symlinks (`barra/shared -> ../shared`, etc.).

## Módulo barra

Panel principal con glassmorphism. Sections:

| Acción | Resultado |
|---|---|
| Click en el reloj | Abre el panel de control |
| Click derecho en la isla | Toggle panel (abrir/cerrar) |
| Escape | Cerrar panel |
| Super + Escape | Toggle panel |
| Click en un workspace | Cambia a ese workspace |
| Click en \u2715 | Cerrar panel |
| Super + K | Toggle barra musical |
| Click en \uf07b | Seleccionar carpeta y reproducir con mpv |

### Secciones del panel

- **Power grid** — Bloquear, Suspender, Hibernar, Reiniciar, Apagar, Cerrar sesión
- **Volumen** — Slider de volumen
- **Brillo** — Slider de brillo
- **Red** — Conexión actual, redes WiFi disponibles, conectar por contraseña
- **Bluetooth** — Estado y alias del dispositivo
- **Barra musical** — Widget MPRIS con barras animadas y marquee infinito (Super + K)

## Colores (glassmorphism)

Los colores de acento se cargan automáticamente desde pywal (`color4`, `color5`, `foreground`, `background`).

| Elemento | Color | Descripción |
|---|---|---|
| Fondo isla cerrada | `#18ffffff` | Blanco muy traslúcido |
| Fondo panel abierto | `#22ffffff` | Blanco semitraslúcido |
| Bordes | `#30ffffff` | Borde blanco sutil |
| Acento | Pywal `color4` | Dinámico según tema |
| Texto principal | Pywal `foreground` | Dinámico según tema |

## Archivos compartidos

| Archivo | Descripción |
|---|---|
| `shared/Pywal.qml` | Carga colores de pywal para todos los módulos |

## Recargar después de cambios

```bash
~/.config/quickshell/barra/reload.sh
```
