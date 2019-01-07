# recent.lua
![recent-screenshot](https://raw.githubusercontent.com/nightedt/mpv-scripts/master/etc/recent.png)

### Menu controls:
* Default display hotkey is **`` ` ``**
* Keyboard:
    * `UP`/`DOWN` to move selection
    * `ENTER` to load highlighted entry
    * `DEL` to delete highlighted entry
    * `0`-`9` for quick selection 
    * `ESC` to exit
* Mouse (if turned on):
    * `WHEEL_UP`/`WHEEL_DOWN` to move selection
    * `MBTN_MID` to load highlighted entry
    * `MBTN_RIGHT` to exit
### Modify settings through `script-opts/recent.conf`
* Log path is `history.log` inside whatever config directory mpv reads
* Disabling `auto_save` makes it only save with a keybind
    * No save key is bound by default, see `script-opts`
* See comments in the script for more info
        
### To do list:
* Add ability to browse the entire log from the menu
