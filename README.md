# recent.lua
![recent-screenshot](https://raw.githubusercontent.com/nightedt/mpv-scripts/master/etc/recent.png)
* Default hotkey is **`` ` ``**
* Modify settings through `script-opts/recent.conf`
    * Log path is `history.log` inside whatever config directory mpv reads
    * Mouse controls are middle click: select, right click: exit, scroll wheel: up/down
    * Disabling `auto_save` makes it only save with a keybind
        * No save key is bound by default, see `script-opts`
        * Saving while the current file is the top entry will remove it from the log
