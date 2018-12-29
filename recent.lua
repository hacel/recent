local utils = require("mp.utils")

-- Settings --
local LISTSIZE = 10 -- max, need to add more binds
local KEYBIND = "`"
local LOGPATH = mp.find_config_file("history.log")
local FONTSCALE = 50
local DATEFORMAT = "%d/%m/%y %X"
--------------

local cur_file_path = ""

-- Escape string for pattern matching
function esc_string(str)
    return str:gsub("([%p])", "%%%1")
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
    mp.set_osd_ass(0, 0, "")
end

-- Load file and remove binds
function load(list, choice)
    unbind()
    if choice == -1 or choice >= LISTSIZE then return end
    mp.commandv("loadfile", list[#list-choice], "replace")
end

-- Save file path on file load
-- `file-loaded` event
function writepath()
    unbind()
    cur_file_path = utils.join_path(mp.get_property("working-directory"), mp.get_property("path"))
end

-- Write path to log on file end
-- removing duplicates along the way
-- `end-file` event
function writelog()
    if cur_file_path == "" then return end
    local f = io.open(LOGPATH, "r")
    if f == nil then
        f = io.open(LOGPATH, "w+")
        f:write(("[%s] %s\n"):format(os.date(DATEFORMAT), cur_file_path))
        f:close()
        return
    end

    local content = {}
    for line in f:lines() do
        line = line:gsub("^.-"..esc_string(cur_file_path)..".-$", "")
        if line ~= "" then
            content[#content+1] = line
        end
    end
    f:close()

    f = io.open(LOGPATH, "w+")
    for i=1, #content do
        f:write(("%s\n"):format(content[i]))
    end
    f:write(("[%s] %s\n"):format(os.date(DATEFORMAT), cur_file_path))
    f:close()
end

-- Display list on OSD and terminal
function drawtable(table)
    local size = #table
    local msg = "{\\fscx"..FONTSCALE.."}{\\fscy"..FONTSCALE.."}"
    local key
    for i=size, 1, -1 do
        if size == 10 and i == 1  then
            key = 0
        else
            key = size-i+1
        end
        local _, n = utils.split_path(table[i])
        msg = msg.."("..key..")  "..n.."\\N\\N"
        print("("..key..") "..n)
    end
    mp.set_osd_ass(0, 0, msg)
end

-- Read log, display list and add keybinds
-- `idle` event or hotkey
function readlog()
    if LOGPATH == nil then
        print("Log not found")
        return
    end

    local f = io.open(LOGPATH, "r")
    local content = {}
    for line in f:lines() do
        content[#content+1] = line
    end
    f:close()

    local list = {}
    for i=#content-LISTSIZE+1, #content, 1 do
        list[#list+1] = string.gsub(content[i], "^(%[.-%]%s)", "")
    end
    drawtable(list)

    mp.add_forced_key_binding("1", "recent-1", function() load(list, 0) end)
    mp.add_forced_key_binding("2", "recent-2", function() load(list, 1) end)
    mp.add_forced_key_binding("3", "recent-3", function() load(list, 2) end)
    mp.add_forced_key_binding("4", "recent-4", function() load(list, 3) end)
    mp.add_forced_key_binding("5", "recent-5", function() load(list, 4) end)
    mp.add_forced_key_binding("6", "recent-6", function() load(list, 5) end)
    mp.add_forced_key_binding("7", "recent-7", function() load(list, 6) end)
    mp.add_forced_key_binding("8", "recent-8", function() load(list, 7) end)
    mp.add_forced_key_binding("9", "recent-9", function() load(list, 8) end)
    mp.add_forced_key_binding("0", "recent-0", function() load(list, 9) end)
    mp.add_forced_key_binding("ESC", "recent-ESC", function() load(nil, -1) end)
end

mp.register_event("file-loaded", writepath)
mp.register_event("end-file", writelog)
mp.register_event("idle", readlog)
mp.add_key_binding(KEYBIND, "display-recent", readlog)