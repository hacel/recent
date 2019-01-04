# recent.lua
![recent-screenshot](https://raw.githubusercontent.com/nightedt/mpv-scripts/master/etc/recent.png)
* Default display hotkey is **`` ` ``**
* Menu controls:
    * Keyboard:
        * `UP`/`DOWN` to move selection
        * `ENTER` to load highlighted entry
        * `DEL` to delete highlighted entry
        * `0`-`9` for quick selection
    * Mouse (if turned on):
        * `WHEEL_UP`/`WHEEL_DOWN` to move selection
        * `MBTN_MID` to load highlighted entry
* Modify settings through `script-opts/recent.conf`, see comments in the script for more info
    * Log path is `history.log` inside whatever config directory mpv reads
    * Disabling `auto_save` makes it only save with a keybind
        * No save key is bound by default, see `script-opts`
