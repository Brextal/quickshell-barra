# quickshell-launcher

App launcher flotante con efecto vidrio esmerilado para Hyprland + Quickshell.

![Vista previa](demo/launcher.gif)

## Características

- Carrusel animado con todas las aplicaciones del sistema
- Búsqueda en vivo: escribe y el carrusel gira hasta la app que coincide
- Iconos de aplicaciones (con letra inicial como fallback)
- Efecto vidrio esmerilado (blur + transparencias)
- Navegación con teclado: ↑↓, Enter, Escape

## Dependencias

- [Quickshell](https://github.com/Quickshell/quickshell) (`quickshell-git` en AUR)
- Hyprland con `blur` habilitado
- Python 3

## Instalación

```bash
git clone https://github.com/Brextal/quickshell-launcher.git ~/.config/quickshell/launcher/
```

## Configuración de Hyprland

### init

```conf
exec-once = qs -p ~/.config/quickshell/launcher/shell.qml
```

### binds

```conf
bind = $mainMod, L, global, qs-shortcuts:app-launcher
```

### capa de blur (efecto vidrio)

```conf
layerrule = blur, match:namespace quickshell
layerrule = ignore_alpha 0, match:namespace quickshell
```

## Uso

| Tecla        | Acción                        |
|-------------|-------------------------------|
| `Super + L`  | Abrir / cerrar launcher       |
| `↑` / `↓`    | Navegar entre aplicaciones    |
| Escribir     | Buscar (carrusel gira al match) |
| `Enter`      | Abrir aplicación seleccionada |
| `Escape`     | Cerrar launcher               |

## Personalización

- Colores y transparencias → `AppItem.qml` y `LauncherPanel.qml`
- Tamaños y animaciones → propiedades `duration`, `width`, `height` en ambos archivos
- Búsqueda de iconos → `parse-desktop.sh` (función `resolve_icon`)

## Licencia

MIT
