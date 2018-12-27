local utils = require("mp.utils")

-- Settings --
local LISTSIZE = 10 -- max, need to add more binds
local KEYBIND = "ENTER"
local LOGPATH = mp.find_config_file("scripts").."/recent.log"
--------------

local ass = mp.get_property_osd("osd-ass-cc/0")
local cur_file_path = ""

-- Save file path on file load
function writepath()
    unbind()
    cur_file_path = utils.join_path(mp.get_property("working-directory"), mp.get_property("path"))
end

-- Write path to log on file end
-- removing duplicates along the way
function writelog()
    local f, s

    f = (io.open(LOGPATH, "r+") or io.open(LOGPATH, "w+"))
    s = f:read("*a")
    s = s:gsub("[^\n]-"..esc_string(cur_file_path)..".-\n", "")
    f:seek("set")
    f:write(s, ("[%s] %s\n"):format(os.date("%d/%m/%y %X"), cur_file_path))
    f:close()
end

-- Read log, display list and add keybinds
function readlog()
    local files = {}, f
    f = io.open(LOGPATH, "r")
    if f == nil then return end
    for line in f:lines() do table.insert(files, line:sub(21)) end
    f:close()

    if #files > LISTSIZE then
        files = {unpack(files, #files-LISTSIZE+1, #files)}
    end

    mp.osd_message(ass.."{\\fs10}"..table_to_string(files), 100)

    mp.add_forced_key_binding("1", "recent-1", function() load(files, 0) end)
    mp.add_forced_key_binding("2", "recent-2", function() load(files, 1) end)
    mp.add_forced_key_binding("3", "recent-3", function() load(files, 2) end)
    mp.add_forced_key_binding("4", "recent-4", function() load(files, 3) end)
    mp.add_forced_key_binding("5", "recent-5", function() load(files, 4) end)
    mp.add_forced_key_binding("6", "recent-6", function() load(files, 5) end)
    mp.add_forced_key_binding("7", "recent-7", function() load(files, 6) end)
    mp.add_forced_key_binding("8", "recent-8", function() load(files, 7) end)
    mp.add_forced_key_binding("9", "recent-9", function() load(files, 8) end)
    mp.add_forced_key_binding("0", "recent-0", function() load(files, 9) end)
    mp.add_forced_key_binding("ESC", "recent-ESC", function() load(nil, -1) end)
end

-- Command load and remove binds
function load(files, choice)
    unbind()
    mp.osd_message("", 0)
    if choice == -1 then return end
    mp.commandv("loadfile", files[#files-choice], "replace")
end

function unbind()
    mp.remove_key_binding("recent-1")
    mp.remove_key_binding("recent-2")
    mp.remove_key_binding("recent-3")
    mp.remove_key_binding("recent-4")
    mp.remove_key_binding("recent-5")
    mp.remove_key_binding("recent-6")
    mp.remove_key_binding("recent-7")
    mp.remove_key_binding("recent-8")
    mp.remove_key_binding("recent-9")
    mp.remove_key_binding("recent-0")
    mp.remove_key_binding("recent-ESC")
end

-- Make list readable on OSD
function table_to_string(tbl)
    local result = ""
    for k, v in pairs(tbl) do
        local s, n = utils.split_path(v)
        result = #tbl+1-k..": "..n..result
        result = "\n\n"..result
    end
    return result
end

-- Escape string for pattern matching
function esc_string(str)
    return str:gsub("([%\\%[%-%]%.%(%)])", "%%%1")
end

mp.register_event("file-loaded", writepath)
mp.register_event("end-file", writelog)
mp.register_event("idle", readlog)
mp.add_key_binding(KEYBIND, "display-recent", readlog)