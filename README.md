# Quickshell Barra

Panel flotante tipo isla para **Hyprland** con **Quickshell**.
Estilo **vidrio empañado (glassmorphism)** — fondos blancos traslúcidos, bordes suaves, acentos en teal.

## Dependencias

- [Quickshell](https://quickshell.outfoxxed.me/)
- QtQuick, QtQuick.Controls, QtQuick.Window
- Hyprland (para blur, workspaces, capas)
- Nerd Fonts (iconos:          )
- `nmcli` (NetworkManager) para la sección de red
- `brightnessctl` para el control de brillo
- `pactl` / `pulseaudio-utils` para el control de volumen
- `hyprlock` para bloquear sesión
- `systemctl` para apagar / reiniciar / suspender / hibernar

## Instalación

```bash
git clone https://github.com/Brextal/quickshell-barra.git ~/.config/quickshell/barra
```

## Configuración de Hyprland

Para que el efecto **vidrio empañado** funcione correctamente, necesitás tener el blur habilitado en Hyprland.

### 1. Habilitar blur (si no lo tenés)

En `~/.config/hypr/hyprland.conf`:

```conf
decoration {
    blur {
        enabled = true
        size = 6
        passes = 3
        ignore_opacity = true
        new_optimizations = on
    }
}
```

### 2. Reglas para la barra

Agregar al final de `~/.config/hypr/hyprland.conf`:

```conf
layerrule = blur, quickshell
layerrule = ignorezero, quickshell
```

Esto hace que el fondo detrás de la barra se vea borroso, dando el efecto vidrio.

Si querés ajustar la transparencia del blur, podés cambiar los valores alfa en los colores dentro de `shell.qml`:
- `#18ffffff` → fondo isla cerrada
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

### Secciones del panel

- **Power grid** — Bloquear, Suspender, Hibernar, Reiniciar, Apagar, Cerrar sesión
- **Volumen** — Slider de volumen
- **Brillo** — Slider de brillo
- **Red** — Conexión actual, redes WiFi disponibles, conectar por contraseña
- **Bluetooth** — Estado y alias del dispositivo

## Colores (glassmorphism)

| Elemento | Color | Descripción |
|---|---|---|
| Fondo isla cerrada | `#18ffffff` | Blanco muy traslúcido |
| Fondo panel abierto | `#22ffffff` | Blanco semitraslúcido |
| Bordes | `#30ffffff` | Borde blanco sutil |
| Color de acento | `#3dd1b0` | Teal / verde menta |
| Texto principal | `#ffffff` | Blanco |
| Texto secundario | `#aaaaaa` | Gris claro |
| Divisores | `#333344` | Gris oscuro |
| Hover items | `#22ffffff` | Mismo que fondo abierto |
| Selected item | `#3dd1b033` | Teal con transparencia |

## Personalización

Los colores están hardcodeados en `shell.qml` y los archivos de sección (`VolumeSection.qml`, `BrightnessSection.qml`, `NetworkSection.qml`, `BluetoothSection.qml`). Buscá los valores hexadecimales y reemplazalos por los que quieras.

## Archivos

| Archivo | Descripción |
|---|---|
| `shell.qml` | Archivo principal, contiene la isla, spacer, anchos, animaciones |
| `VolumeSection.qml` | Control de volumen con slider |
| `BrightnessSection.qml` | Control de brillo con slider |
| `NetworkSection.qml` | Estado de red, WiFi, conexión |
| `BluetoothSection.qml` | Estado y alias de bluetooth |
| `reload.sh` | Script para recargar la configuración |

## Recargar después de cambios

```bash
~/.config/quickshell/barra/reload.sh
```

O si el proceso no se está ejecutando:

```bash
quickshell ~/.config/quickshell/barra/shell.qml
```
