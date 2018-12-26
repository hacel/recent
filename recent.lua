local utils = require("mp.utils")

local keybind = "ENTER"
local logpath = mp.find_config_file('scripts').."/recent.log"

local ass = mp.get_property_osd("osd-ass-cc/0")
local cur_file_path = ""

-- Save file path on file load
function writepath()
    cur_file_path = utils.join_path(mp.get_property("working-directory"), mp.get_property("path"))
end

-- Write path to log on file end
-- removing duplicates along the way
function writelog()
    local f, s

    f = (io.open(logpath, 'r+') or io.open(logpath, 'w+'))
    s = f:read("*a")
    s = s:gsub("[^\n]-"..esc_string(cur_file_path)..'.-\n', '')
    f:seek("set")
    f:write(s, ('%s\n'):format(cur_file_path))
    f:close()
end

-- Read log, display list and add keybinds
function readlog()
    local files = {}, f
    f = io.open(logpath, 'r')
    if f == nil then return end
    for line in f:lines() do table.insert(files, line) end
    f:close()

    if #files > 5 then
        files = {unpack(files, #files-4, #files)}
    end

    mp.osd_message(ass..'{\\fs10}'..table_to_string(files), 10)

    mp.add_key_binding("1", "1", function() load(files, 0) end)
    mp.add_key_binding("2", "2", function() load(files, 1) end)
    mp.add_key_binding("3", "3", function() load(files, 2) end)
    mp.add_key_binding("4", "4", function() load(files, 3) end)
    mp.add_key_binding("5", "5", function() load(files, 4) end)
    mp.add_key_binding("ESC", "ESC", function() load(nil, -1) end)
end

-- Command load and remove binds
function load(files, choice)
    mp.remove_key_binding("1")
    mp.remove_key_binding("2")
    mp.remove_key_binding("3")
    mp.remove_key_binding("4")
    mp.remove_key_binding("5")
    mp.remove_key_binding("ESC")
    mp.osd_message("", 0)
    if choice == -1 then return end
    mp.commandv("loadfile", files[#files-choice], "replace")
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
mp.add_key_binding(keybind, "display-recent", readlog)