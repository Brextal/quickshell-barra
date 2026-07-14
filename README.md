# Quickshell Barra

Panel flotante tipo isla para **Hyprland** con **Quickshell**.
Estilo **vidrio empañado (glassmorphism)** — fondos blancos traslúcidos, bordes suaves, acentos dinámicos vía [pywal](https://github.com/dylanaraps/pywal).

## Dependencias

- [Quickshell](https://quickshell.outfoxxed.me/) (0.3.0+)
- QtQuick, QtQuick.Controls, QtQuick.Window
- Hyprland (para blur, workspaces, capas)
- [pywal](https://github.com/dylanaraps/pywal) o [pywal16](https://github.com/eylles/pywal16)
- Nerd Fonts (iconos)
- `nmcli` (NetworkManager) para la sección de red
- `brightnessctl` para el control de brillo
- `pactl` / `pulseaudio-utils` para el control de volumen
- `mpv` + `mpv-mpris` para reproducción musical con MPRIS
- `zenity` para selector de carpetas
- `hyprlock` para bloquear sesión
- `systemctl` para apagar / reiniciar / suspender / hibernar

## Instalación

```bash
git clone https://github.com/Brextal/quickshell-barra.git ~/.config/quickshell/barra
ln -s ~/.config/quickshell/shared ~/.config/quickshell/barra/shared
```

## Configuración de Hyprland

Para que el efecto **vidrio empañado** funcione correctamente, necesitás tener el blur habilitado en Hyprland.

### Método rápido (recomendado)

El repo incluye los archivos de configuración listos. Solo agregá al final de `~/.config/hypr/hyprland.conf`:

```conf
source = ~/.config/quickshell/barra/hypr/lookandfeel.conf
source = ~/.config/quickshell/barra/hypr/barra.conf
```

### Método manual

Si preferís no usar `source`, copiá esto a tu configuración:

**Blur optimizado** en tu `lookandfeel.conf` o `hyprland.conf`:

```conf
decoration {
    blur {
        enabled = true
        size = 6
        passes = 3
        ignore_opacity = true
        new_optimizations = on
        vibrancy = 0.1696
    }
}
```

**Autostart y layerrules** en tu `hyprland.conf`:

```conf
exec-once = qs -p ~/.config/quickshell/barra/shell.qml

layerrule = blur on, match:namespace quickshell
layerrule = ignore_alpha 0, match:namespace quickshell
```

### Ajustar transparencia

Si querés cambiar la intensidad del vidrio, modificá los valores alfa en `shell.qml`:
- `#18ffffff` → fondo isla cerrada (más/menos transparente)
- `#22ffffff` → fondo panel abierto
- `#30ffffff` → bordes

## Uso

| Acción | Resultado |
|---|---|
| Click en el reloj | Abre el panel de control |
| Click derecho en la isla | Toggle panel (abrir/cerrar) |
| Escape | Cerrar panel |
| Super + Escape | Toggle panel |
| Click en un workspace | Cambia a ese workspace |
| Click en ✕ | Cerrar panel |
| Super + K | Toggle barra musical |
| Click en ícono de carpeta `` | Seleccionar carpeta y reproducir con mpv |

### Secciones del panel

- **Power grid** — Bloquear, Suspender, Hibernar, Reiniciar, Apagar, Cerrar sesión
- **Volumen** — Slider de volumen
- **Brillo** — Slider de brillo
- **Red** — Conexión actual, redes WiFi disponibles, conectar por contraseña
- **Bluetooth** — Estado y alias del dispositivo

### Barra musical

Widget MPRIS con barras animadas y marquee infinito. Se activa con **Super + K** o automáticamente al seleccionar una carpeta con el ícono ``. Usa `mpv` para reproducir y `mpv-mpris` para exponer la metadata via MPRIS.

## Colores (glassmorphism)

Los colores de acento se cargan automáticamente desde pywal (`color4`, `color5`, `foreground`, `background`). Los colores de fondo y bordes están en `shell.qml`:

| Elemento | Color | Descripción |
|---|---|---|
| Fondo isla cerrada | `#18ffffff` | Blanco muy traslúcido |
| Fondo panel abierto | `#22ffffff` | Blanco semitraslúcido |
| Bordes | `#30ffffff` | Borde blanco sutil |
| Acento | Pywal `color4` | Dinámico según tema |
| Texto principal | Pywal `foreground` | Dinámico según tema |

## Personalización

Los colores de acento se sincronizan con pywal automáticamente. Para cambiar los colores de fondo, editá los valores hexadecimales en `shell.qml` y los archivos de sección.

## Archivos

| Archivo | Descripción |
|---|---|
| `shell.qml` | Archivo principal, contiene la isla, spacer, anchos, animaciones |
| `VolumeSection.qml` | Control de volumen con slider |
| `BrightnessSection.qml` | Control de brillo con slider |
| `NetworkSection.qml` | Estado de red, WiFi, conexión |
| `BluetoothSection.qml` | Estado y alias de bluetooth |
| `MusicWidget.qml` | Widget musical MPRIS con barras y marquee |
| `reload.sh` | Script para recargar la configuración |
| `hypr/lookandfeel.conf` | Blur optimizado para vidrio empañado |
| `hypr/barra.conf` | Autostart y layerrules para Quickshell |

## Recargar después de cambios

```bash
~/.config/quickshell/barra/reload.sh
```

O si el proceso no se está ejecutando:

```bash
quickshell ~/.config/quickshell/barra/shell.qml
```
