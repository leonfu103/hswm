quit_events = {}

hs.hotkey.bind({"cmd"}, "Q", function()
    local win = hs.window.focusedWindow()
    local app = win:application()
    local appName = app:name()

    quit_events[appName] = (quit_events[appName] or 0) + 1

    if quit_events[appName] == 2 then
        quit_events[appName] =  nil
        app:kill()
    else
        hs.alert.show("Press ⌘+Q again to really quit " .. appName)
        hs.timer.doAfter(2, function() quit_events[appName] =  nil end)
    end
end)

-- Shortcuts to set window position and dimension
WIN_POSITION_DIMENSION = {}
-- C: centre
WIN_POSITION_DIMENSION["C"] = {x=0.05,y=0.05,w=0.9,h=0.9}
-- F: Full
WIN_POSITION_DIMENSION["F"] = {x=0,y=0,w=1,h=1}
-- L: Left half
WIN_POSITION_DIMENSION["L"] = {x=0,y=0,w=0.5,h=1}
-- R: Right half
WIN_POSITION_DIMENSION["R"] = {x=0.5,y=0,w=0.5,h=1}
-- T: Top half
WIN_POSITION_DIMENSION["T"] = {x=0,y=0,w=1,h=0.5}
-- B: Bottom half
WIN_POSITION_DIMENSION["B"] = {x=0,y=0.5,w=1,h=0.5}

INCREMENT_STEP = 0.01
MAX_XY = 0.4

windows_position = {}

move_window = function (key)
    local win = hs.window.focusedWindow()
    local app = win:application()
    local appName = app:name()
    local dimension = hs.geometry.rect(WIN_POSITION_DIMENSION[key])

    if win then
        win:moveToUnit(dimension)

        -- here we need to make a copy of map 'F' instead of reference
        local dim = WIN_POSITION_DIMENSION[key]
        local copyOfDim = {x=dim.x, y=dim.y, w=dim.w, h=dim.h}
        windows_position[appName] = copyOfDim
    end
end

-- horiOrVert: horizontally or vertically
-- direction: left/right/up/down
adjust_dimension = function (horiOrVert, direction)
    local win = hs.window.focusedWindow()
    local app = win:application()
    local appName = app:name()
    local unitRect = windows_position[appName]

    if win then
        if unitRect then
            if horiOrVert == 'horizontally' then
                if direction == 'left' and unitRect.x > 0 then
                    unitRect.x = unitRect.x - INCREMENT_STEP
                    unitRect.w = unitRect.w + 2 * INCREMENT_STEP
                elseif direction == 'right' and unitRect.x < MAX_XY then
                    unitRect.x = unitRect.x + INCREMENT_STEP
                    unitRect.w = unitRect.w - 2 * INCREMENT_STEP
                end
            elseif horiOrVert == 'vertically' then
                if direction == 'up' and unitRect.y > 0 then
                    unitRect.y = unitRect.y - INCREMENT_STEP
                    unitRect.h = unitRect.h + 2 * INCREMENT_STEP
                elseif direction == 'down' and unitRect.y < MAX_XY then
                    unitRect.y = unitRect.y + INCREMENT_STEP
                    unitRect.h = unitRect.h - 2 * INCREMENT_STEP
                end
            end

            win:moveToUnit(hs.geometry.rect(unitRect))
            windows_position[appName] = unitRect
        else
            move_window("F")
        end
    end
end

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "C", function()
    move_window("C")
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "F", function()
    move_window("F")
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "L", function()
    move_window("L")
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "R", function()
    move_window("R")
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "T", function()
    move_window("T")
end)

hs.hotkey.bind({"ctrl", "alt", "cmd"}, "B", function()
    move_window("B")
end)

-- Move window to the screen on the north
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "N", function()
    local win = hs.window.focusedWindow()
    win:moveOneScreenNorth()
end)

-- Move window to the screen on the south
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", function()
    local win = hs.window.focusedWindow()
    win:moveOneScreenSouth()
end)

-- enlarge horizontally
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "left", function()
    adjust_dimension('horizontally', 'left')
end)

-- shrink horizontally
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "right", function()
    adjust_dimension('horizontally', 'right')
end)

-- enlarge vertically
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "up", function()
    adjust_dimension('vertically', 'up')
end)

-- shrink vertically
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "down", function()
    adjust_dimension('vertically', 'down')
end)
