# Quickshell Calendar

Calendario flotante con clima para **Hyprland** con **Quickshell**.

## Dependencias

- [Quickshell](https://quickshell.outfoxxed.me/) (0.3.0+)
- QtQuick, QtQuick.Window, QtQuick.LocalStorage
- Hyprland
- [pywal](https://github.com/dylanaraps/pywal) o [pywal16](https://github.com/eylles/pywal16)
- `curl` — para fetch del clima
- Nerd Fonts

## Instalación

```bash
git clone https://github.com/Brextal/quickshell-calendar.git ~/.config/quickshell/calendar
ln -s ~/.config/quickshell/shared ~/.config/quickshell/calendar/shared
```

## Funciones

- **Calendario mensual** con navegación entre meses
- **Clima** — temperatura actual, máxima/mínima, ícono del clima (Open-Meteo API)
- **Click en un día** — muestra detalles
- **Día actual** — resaltado con color de pywal

## Atajos de teclado

| Atajo | Acción |
|---|---|
| Super+D | Abrir/cerrar calendario |

## Configuración del clima

Por defecto usa coordenadas de **Maipu, Chile** (`-33.45, -70.66`). Para cambiar la ubicación, editá `weather_fetch.sh` y modifica las variables `LAT` y `LON`.

## Archivos

| Archivo | Descripción |
|---|---|
| `shell.qml` | Archivo principal — panel del calendario |
| `CalendarStrip.qml` | Franja de días del mes |
| `DayItem.qml` | Item individual de día |
| `weather_fetch.sh` | Fetch del clima vía Open-Meteo API |
| `hypr/calendar.conf` | Atajo de teclado Super+D |

## Recargar después de cambios

```bash
~/.config/quickshell/calendar/reload.sh
```
