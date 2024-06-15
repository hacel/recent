# recent.lua
#### Recently played menu
Logs played files to a history log file with an interactive 'recently played' menu that reads from the log. Allows for automatic or manual logging if you want a file bookmark menu instead.


![](../assets/recent.png)
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
#### Modify settings through `script-opts/recent.conf`
* Log path is `history.log` inside whatever config directory mpv reads
* Disabling `auto_save` makes it only save with a keybind
    * No save key is bound by default, see `script-opts`
* See comments in the script for more info

#### Play most recent one.

```ini
KEY                 script-binding recent/play-last
```

### uosc integration

**[tomasklaen/uosc](https://github.com/tomasklaen/uosc) is required.**

[Menu](https://github.com/tomasklaen/uosc#adding-items-to-menu) - add following to `input.conf`.

```ini
KEY                 script-binding recent/display-recent          #! Recently played
```

[Controls](https://github.com/tomasklaen/uosc#set-prop-value) - add following to `uosc.conf#controls`.

```ini
command:history:script-message-to recent display-recent?Recently played
```

### mpv-menu-plugin integration

**[mpv-menu-plugin](https://github.com/tsl0922/mpv-menu-plugin) is required.**

[Menu](https://github.com/tsl0922/mpv-menu-plugin?tab=readme-ov-file#messages) - add following to `input.conf`.

```ini
KEY                 script-binding recent/display-recent        #! Recently played  #@recent
```

