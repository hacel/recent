-- Independent miscellaneous functions
local mp = require 'mp'
local utils = require 'mp.utils'

-- Dumb way to blackout second screen when mpv is fullscreened
-- by startng another mpv. change fs-screen and the kill command
mp.observe_property("fullscreen", "bool", function(name, fs)
    if fs then
        utils.subprocess_detached({args={
            "mpv",
            "--no-config",
            "--fs-screen=1",
            "--fullscreen",
            "--force-window",
            "--no-osc",
            "--idle",
            "--title=thisisablackwindow"
        }, cancellable=true, max_size=0})
    else
        utils.subprocess({args={"taskkill", "/FI", "WINDOWTITLE eq thisisablackwindow"}})
    end
end)

-- If loaded file is paused or at 99%, unpause and or reset pos
mp.register_event("file-loaded", function()
    if mp.get_property_native("percent-pos") and mp.get_property_native("percent-pos") > 99 then
        mp.commandv("seek", 0.0, "absolute")
    end
    if mp.get_property_bool("pause") == true then
        mp.commandv("cycle", "pause")
    end
end)

-- Temporarily slow down playback
mp.add_forced_key_binding("KP_ENTER", "slowforward", function()
    local m, r, b = 1.1, .1, .2
    if timer and timer:is_enabled() then
        timer:kill()
    else
        vol = mp.get_property("volume") - 20
    end
    mp.set_property("volume", vol * b)
    mp.set_property("speed", b)
    timer = mp.add_periodic_timer(r, function()
        mp.set_osd_ass(500, 500, ("\n\n◀◀ x%.2f"):format(mp.get_property("speed")))
        local s = mp.get_property("speed") * m
        local v = vol * math.min(1.0, s)
        if s > 1/m then
            s, v = 1, vol
            mp.set_osd_ass(0, 0, "")
            timer:kill()
        end
        mp.set_property("speed", s)
        mp.set_property("volume", v + 20)
    end)
end)
