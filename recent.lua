local o = {
    -- Automatically save to log, otherwise only saves when requested
    -- you need to bind a save key if you disable it
    auto_save = true,
    save_bind = "",
    -- Runs automatically when --idle
    auto_run_idle = true,
    -- Display menu bind
    display_bind = "`",
    -- Middle click: Select; Right click: Exit;
    -- Scroll wheel: Up/Down
    mouse_controls = true,
    -- Only the first 10 entries have key binds
    list_size = 15,
    -- Reads from config directory or an absolute path
    log_path = "history.log",
    -- Reads from config directory or an absolute path
    date_format = "%d/%m/%y %X",
    -- Font settings
    font_scale = 50,
    border_size = 0.7,
    -- Highlight color in BGR hexadecimal
    hi_color = "H46CFFF",
    -- Splitting urls; yt links would look like `?watch...`
    split_urls = true
}
(require "mp.options").read_options(o)
local utils = require("mp.utils")

o.log_path = utils.join_path(mp.find_config_file("."), o.log_path)
local cur_file_path
local table_drawn = false

-- Escape string for pattern matching
function esc_string(str)
    return str:gsub("([%p])", "%%%1")
end

-- Handle urls
function get_path()
    local path = mp.get_property("path")
    if not path then return end
    if path:find("http.?://") then
        return path
    else
        return utils.join_path(mp.get_property("working-directory"), path)
    end
end

-- Script exit function
function unbind()
    if o.mouse_controls then
        mp.remove_key_binding("recent-WUP")
        mp.remove_key_binding("recent-WDOWN")
        mp.remove_key_binding("recent-MMID")
        mp.remove_key_binding("recent-MRIGHT")
    end
    mp.remove_key_binding("recent-UP")
    mp.remove_key_binding("recent-DOWN")
    mp.remove_key_binding("recent-ENTER")
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
    mp.remove_key_binding("recent-DEL")
    mp.set_osd_ass(0, 0, "")
    table_drawn = false
end

-- Write path to log on file end
-- removing duplicates along the way
-- `end-file` event or save_bind
function write_log(delete)
    if not cur_file_path then return end
    local f = io.open(o.log_path, "r")

    -- Create the file and return if it doesn't exist
    if f == nil then
        f = io.open(o.log_path, "w+")
        f:write(("[%s] %s\n"):format(os.date(o.date_format), cur_file_path))
        f:close()
        return
    end

    -- Read file into memory and remove duplicates
    local content = {}
    for line in f:lines() do
        line = line:gsub("^.-"..esc_string(cur_file_path)..".-$", "")
        if line ~= "" then
            content[#content+1] = line
        end
    end
    f:close()

    -- Write contents back to file without duplicates
    f = io.open(o.log_path, "w+")
    for i=1, #content do
        f:write(("%s\n"):format(content[i]))
    end

    -- If delete flag given then don't write path back to log
    if delete == 0 then
        f:write(("[%s] %s\n"):format(os.date(o.date_format), cur_file_path))
    end
    f:close()
end

-- Display list on OSD and terminal
function draw_table(table, choice)
    local size = #table
    local msg = string.format("{\\fscx%f}{\\fscy%f}{\\bord%f}",
                o.font_scale, o.font_scale, o.border_size)
    local hi_start = string.format("{\\1c&H%s}", o.hi_color)
    local hi_end = "{\\1c&HFFFFFF}"
    local max = o.list_size > size and size or o.list_size
    for i=0, max-1, 1 do
        local key
        if i < 9 then
            key = i+1
        elseif i == 9 then
            key = 0
        else
            key = "●"
        end

        local p
        if not o.split_urls and table[size-i]:find("http.?://") then
            p = table[i]
        else
            _, p = utils.split_path(table[size-i])
        end

        if i == choice then
            msg = msg..hi_start.."("..key..")  "..p.."\\N\\N"..hi_end
        else
            msg = msg.."("..key..")  "..p.."\\N\\N"
        end

        if not table_drawn then
            print("("..key..") "..p)
        end
    end
    mp.set_osd_ass(0, 0, msg)
end

-- Handle up/down keys
function select(choice, inc, list)
    choice = choice + inc
    local max = o.list_size < #list and o.list_size or #list
    if choice < 0 or choice >= max then return choice-inc end
    draw_table(list, choice)
    return choice
end

-- Delete selected entry from the log
function delete(list, choice)
    cur_file_path = list[#list-choice]
    write_log(1)
    print("Deleted \""..cur_file_path.."\"")
    cur_file_path = get_path()
    list = read_log()
    draw_table(list, choice)
    return list
end

-- Load file and remove binds
function load(list, choice)
    unbind()
    local max = o.list_size < #list and o.list_size or #list
    if choice >= max then return end
    mp.commandv("loadfile", list[#list-choice], "replace")
end

-- Read entries from the log into a list
function read_log()
    local f = io.open(o.log_path, "r")
    if f == nil then return end
    local list = {}
    for line in f:lines() do
        list[#list+1] = string.gsub(line, "^(%[.-%]%s)", "")
    end
    f:close()
    return list
end

-- Read log, display list and add keybinds
-- `idle` event or hotkey
function display_list()
    if table_drawn then
        unbind()
        return
    end

    local list = read_log()
    if not list or not list[1] then
        mp.osd_message("Log empty")
        return
    end

    local choice = 0
    draw_table(list, choice)

    mp.add_forced_key_binding("UP", "recent-UP", function()
        choice = select(choice, -1, list)
    end, {repeatable=true})
    mp.add_forced_key_binding("DOWN", "recent-DOWN", function()
        choice = select(choice, 1, list)
    end, {repeatable=true})
    mp.add_forced_key_binding("ENTER", "recent-ENTER", function()
        load(list, choice)
    end)
    mp.add_forced_key_binding("DEL", "recent-DEL", function()
        list = delete(list, choice)
    end)
    if o.mouse_controls then
        mp.add_forced_key_binding("WHEEL_UP", "recent-WUP", function()
            choice = select(choice, -1, list)
        end)
        mp.add_forced_key_binding("WHEEL_DOWN", "recent-WDOWN", function()
            choice = select(choice, 1, list)
        end)
        mp.add_forced_key_binding("MBTN_MID", "recent-MMID", function()
            load(list, choice)
        end)
        mp.add_forced_key_binding("MBTN_RIGHT", "recent-MRIGHT", function()
            unbind()
        end)
    end
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
    mp.add_forced_key_binding("ESC", "recent-ESC", function() unbind() end)
    table_drawn = true
end

if o.auto_save then
    mp.register_event("end-file", function() write_log(0) end)
else
    mp.add_key_binding(o.save_bind, "recent-save", function()
        write_log(0)
        mp.osd_message("Saved entry to log")
    end)
end

if o.auto_run_idle then
    mp.register_event("idle", display_list)
end

mp.register_event("file-loaded", function()
    unbind()
    cur_file_path = get_path()
end)

mp.add_key_binding(o.display_bind, "display-recent", display_list)
