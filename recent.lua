local o = {
    keybind = "`",
    list_size = 10,
    log_path = "history.log",
    font_scale = 50,
    date_format = "%d/%m/%y %X"
}
(require "mp.options").read_options(o)
local utils = require("mp.utils")

o.log_path = utils.join_path(mp.find_config_file("."), o.log_path)
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
    local f = io.open(o.log_path, "r")
    if f == nil then
        f = io.open(o.log_path, "w+")
        f:write(("[%s] %s\n"):format(os.date(o.date_format), cur_file_path))
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

    f = io.open(o.log_path, "w+")
    for i=1, #content do
        f:write(("%s\n"):format(content[i]))
    end
    f:write(("[%s] %s\n"):format(os.date(o.date_format), cur_file_path))
    f:close()
end

-- Display list on OSD and terminal
function drawtable(table)
    local size = #table
    local msg = "{\\fscx"..o.font_scale.."}{\\fscy"..o.font_scale.."}"
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

-- Load file and remove binds
function load(list, choice)
    unbind()
    if choice == -1 or choice >= #list then return end
    mp.commandv("loadfile", list[#list-choice], "replace")
end

-- Read log, display list and add keybinds
-- `idle` event or hotkey
function readlog()
    local f = io.open(o.log_path, "r")
    if f == nil then return end
    local content = {}
    for line in f:lines() do
        content[#content+1] = line
    end
    f:close()

    local list = {}
    if #content > o.list_size then
        for i=(#content-o.list_size)+1, #content, 1 do
            list[#list+1] = string.gsub(content[i], "^(%[.-%]%s)", "")
        end
    else
        for i=1, #content, 1 do
            list[i] = string.gsub(content[i], "^(%[.-%]%s)", "")
        end
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
mp.add_key_binding(o.keybind, "display-recent", readlog)