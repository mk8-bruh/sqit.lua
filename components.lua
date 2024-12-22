local _PATH = (...):match("(.-)%.")

--[[
PREDEFINED COMPONENTS

each constructor should be called with a table of properties for the component, as well as optional callback overrides

sqit.components.dummy
    empty base class for a centered component
    properties (apply to ALL other elements):
        x, y (number): the position of the center of the component (will default to pivot positions if left unspecified)
        w, h (number): the size of the component (will fit the content size if left unspecified)
        xpivot, ypivot (Element): the pivots of the component on the respective axes
        xalign, yalign (string): "center" (default), "start" (left, top) or "end" (right, bottom)
        xoffset, yoffset (number): the gap from the pivoting element on the unpivoted / the offset from the target position on the pivoted axes
sqit.components.textLabel
    an inline text element
    properties:
        style (table): a table with color and graphics settings
            padding = {
                x, y (number)
            },
            color (table: {number, number, number[, number]} ),
            font (Font)
        scene (Scene): the scene the component is a part of
        text (string): the display text
        align (string): "center" (default), "left" or "right"
sqit.components.textButton
    a button with a text label
    properties:
        style (table): a table with color and graphics settings
            padding = {
                x, y (number)
            },
            cornerRadius (number),
            background = {
                color = {
                    default, active, hovered, pressed (table: {number, number, number[, number]} )
                },
            },
            text = {
                color = {
                    default, active, hovered, pressed (table: {number, number, number[, number]} )
                },
                font (Font)
            },
            outline = {
                color = {
                    default, active, hovered, pressed (table: {number, number, number[, number]} )
                },
                width (number)
            }
        scene (Scene): the scene the component is a part of
        text (string): the display text
        align (string): "center" (default), "left" or "right"
        action (function): the function to be called when the button is pressed
        previous, next (Element): the previous/next elements in the navigation layout
sqit.components.inlineTextbox
    a textbox in just one line of text (scrollable)
    properties:
        style (table): a table with color and graphics settings
            padding = {
                x, y (number)
            },
            cornerRadius (number),
            background = {
                color = {
                    default, active, hovered (table: {number, number, number[, number]} )
                },
            },
            text = {
                color = {
                    default, active, hovered (table: {number, number, number[, number]} )
                },
                font (Font)
            },
            cursor = {
                color, width, blinkSpeed (number)
            },
            alttext = {
                color (table: {number, number, number[, number]} ),
                font (Font)
            },
            outline = {
                color = {
                    default, active, hovered (table: {number, number, number[, number]} )
                },
                width (number)
            }
        scene (Scene): the scene the component is a part of
        text (string): the initial text of the input field
        encrypt (function): a function that transforms the input text before it is rendered (e.g. `function(s) return string.rep("*", #s) end` for a password field)
        alttext (string): alternative text to display if the field is empty
        action (function): a function called when the user presses enter
        previous, next (Element): the previous/next elements in the navigation layout
sqit.components.scrollableList
    -- TODO
--]]

local utf8 = require("utf8")
local scene = require(_PATH..".scene")
local style = require(_PATH..".style")
local utils = require(_PATH..".utils")

local emptyf = function(...) return ... end

local sign = function(x) return (x < 0 and -1) or (x > 0 and 1) or 0 end

local inlineScrollSpeed = 10
local inlineScrollThreshold = 3

local listScrollSpeed = 10
local listScrollThreshold = 3

local dummy = {
    check = function(t, x, y)
        return math.abs(x - t.x) <= t.w/2 and math.abs(y - t.y) <= t.h/2
    end
}
local dummyMt = {
    __index = function(t, k)
            if k == "xoffset" then return 0
        elseif k == "yoffset" then return 0
        elseif k == "xalign" then return "center"
        elseif k == "yalign" then return "center"
        elseif k == "x" then
            if t.xpivot then return ((t.xalign == "start" and t.xpivot.x - t.xpivot.w/2 + t.w/2) or (t.align == "end" and t.xpivot.x + t.xpivot.w/2 - t.w/2) or t.xpivot.x) + t.xoffset
            elseif t.ypivot then return t.ypivot.x + sign(t.xoffset) * t.ypivot.w/2 + t.xoffset + t.w/2 end
        elseif k == "y" then
            if t.ypivot then return ((t.yalign == "start" and t.ypivot.y - t.ypivot.h/2 + t.h/2) or (t.align == "end" and t.ypivot.y + t.ypivot.h/2 - t.h/2) or t.ypivot.y) + t.yoffset
            elseif t.xpivot then return t.xpivot.y + sign(t.yoffset) * t.xpivot.h/2 + t.yoffset + t.h/2 end
        elseif k == "w" then return 0
        elseif k == "h" then return 0
        else return dummy[k] end
    end
}

local textLabel = {
    draw = function(t)
        love.graphics.setColor(t.style.text.color)
        love.graphics.setFont(t.style.text.font)
        local width = t.style.text.font:getWidth(t.text)
        local offset = (t.align == "left" and -t.w/2) or (t.align == "right" and t.w/2 - width) or -width/2
        love.graphics.print(t.text, t.x + offset, t.y - t.style.text.font:getHeight()/2)
    end
}
local textLabelMt = {
    __index = function(t, k)
        if k == "style" then return style.textLabel
        elseif k == "text" then return ""
        elseif k == "align" then return "center"
        elseif k == "w" then return t.style.text.font:getWidth(t.text) + 2*t.style.padding.x
        elseif k == "h" then return t.style.text.font:getHeight() + t.style.padding.y * 2
        else return textLabel[k] ~= nil and textLabel[k] or dummyMt.__index(t, k) end
    end
}

local textButton = {
    draw = function(t)
        love.graphics.setColor((t.scene.isPressed(t) and t.style.background.color.pressed) or (t.scene.isHovered(t) and t.style.background.color.hovered) or (t.scene.isActive(t) and t.style.background.color.active) or t.style.background.color.default)
        love.graphics.rectangle("fill", t.x - t.w/2, t.y - t.h/2, t.w, t.h, t.style.cornerRadius)
        love.graphics.setColor((t.scene.isPressed(t) and t.style.outline.color.pressed) or (t.scene.isHovered(t) and t.style.outline.color.hovered) or (t.scene.isActive(t) and t.style.outline.color.active) or t.style.outline.color.default)
        love.graphics.setLineWidth(t.style.outline.width)
        love.graphics.rectangle("line", t.x - t.w/2, t.y - t.h/2, t.w, t.h, t.style.cornerRadius)
        love.graphics.setColor((t.scene.isPressed(t) and t.style.text.color.pressed) or (t.scene.isHovered(t) and t.style.text.color.hovered) or (t.scene.isActive(t) and t.style.text.color.active) or t.style.text.color.default)
        love.graphics.setFont(t.style.text.font)
        local width = t.style.text.font:getWidth(t.text)
        local offset = (t.align == "left" and -t.w/2) or (t.align == "right" and t.w/2 - width) or -width/2
        love.graphics.print(t.text, t.x + offset, t.y - t.style.text.font:getHeight()/2)
    end,
    released = function(t)
        t:action()
    end,
    hovered = function(t)
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    end,
    unhovered = function(t)
        love.mouse.setCursor()
    end,
    keypressed = function(t, k)
        if k == "return" or k == "space" then
            t:action()
        elseif k == "up" or k == "left" then
            if t.previous then t.scene.activate(t.previous) end
        elseif k == "down" or k == "right" then
            if t.next then t.scene.activate(t.next) end
        end
    end
}
local textButtonMt = {
    __index = function(t, k)
        if k == "style" then return style.textButton
        elseif k == "text" then return ""
        elseif k == "align" then return "center"
        elseif k == "w" then return t.style.text.font:getWidth(t.text) + 2*t.style.padding.x
        elseif k == "h" then return t.style.text.font:getHeight() + t.style.padding.y * 2
        elseif k == "action" then return emptyf
        else return textButton[k] ~= nil and textButton[k] or dummyMt.__index(t, k) end
    end
}

local inlineTextbox = {
    update = function(t, dt)
        t.cursor = math.min(t.cursor, utf8.len(t.text))
        local txt = (t.scene.isActive(t) or utf8.len(t.text) > 0) and t.encrypt(t.text) or t.alttext
        t.cursorBlink = (t.cursorBlink + 2*t.style.cursor.blinkSpeed * dt) % 2
        t.scroll = math.min(math.max(t.scroll, t.w - 2*t.style.padding.x - (t.style.text.font:getWidth(txt) + math.ceil(t.style.cursor.width/2))), 0)
    end,
    draw = function(t)
        t.cursor = math.min(t.cursor, #t.text)
        love.graphics.setColor((t.scene.isActive(t) and t.style.background.color.active) or (t.scene.isHovered(t) and t.style.background.color.hovered) or t.style.background.color.default)
        love.graphics.rectangle("fill", t.x - t.w/2, t.y - t.h/2, t.w, t.h, t.style.cornerRadius)
        love.graphics.setColor((t.scene.isActive(t) and t.style.outline.color.active) or (t.scene.isHovered(t) and t.style.outline.color.hovered) or t.style.outline.color.default)
        love.graphics.setLineWidth(t.style.outline.width)
        love.graphics.rectangle("line", t.x - t.w/2, t.y - t.h/2, t.w, t.h, t.style.cornerRadius)
        love.graphics.stencil(function()
            love.graphics.setColorMask(false, false, false, false)
            love.graphics.rectangle("fill", t.x - t.w/2 + t.style.padding.x, t.y - t.h/2 + t.style.padding.y, t.w - 2*t.style.padding.x, t.h - 2*t.style.padding.y - t.style.scrollbar.width)
            love.graphics.setColorMask()
        end, "replace", 1, false)
        love.graphics.setStencilTest("equal", 1)
        if t.scene.isActive(t) or utf8.len(t.text) > 0 then
            local txt = t.encrypt(t.text)
            love.graphics.setColor(t.textcolor or (t.scene.isActive(t) and t.style.text.color.active) or (t.scene.isHovered(t) and t.style.text.color.hovered) or t.style.text.color.default)
            love.graphics.setFont(t.style.text.font)
            love.graphics.print(txt, t.x - t.w/2 + t.style.padding.x + t.scroll, t.y - t.style.text.font:getHeight()/2 - t.style.scrollbar.width/2)
            love.graphics.setStencilTest()
            if t.scene.isActive(t) and math.floor(t.cursorBlink) == 0 then
                local cx = t.x - t.w/2 + t.style.padding.x + t.scroll + t.style.text.font:getWidth(txt:sub(0, utf8.offset(txt, t.cursor + 1) - 1)) + math.ceil(t.style.cursor.width/2)
                love.graphics.setColor(t.style.cursor.color)
                love.graphics.setLineWidth(t.style.cursor.width)
                love.graphics.line(cx, t.y - t.style.text.font:getHeight()/2, cx, t.y + t.style.text.font:getHeight()/2)
            end
            if t.style.text.font:getWidth(txt) > t.w - 2*style.padding.x then
                local w = (t.w - 2*style.padding.x)^2 / t.style.text.font:getWidth(txt)
                local t = -t.scroll / t.style.text.font:getWidth(txt) * (t.w - 2*style.padding.x)
                love.graphics.setColor(t.style.scrollbar.color)
                love.graphics.rectangle("fill", t.x - t.w/2 + t.style.padding.x + t, t.y + t.h/2 - t.style.padding.y - t.style.scrollbar.width, w, t.style.scrollbar.width)
            end
        else
            love.graphics.setColor(t.style.alttext.color)
            love.graphics.setFont(t.style.alttext.font)
            love.graphics.print(t.alttext, t.x - t.w/2 + t.style.padding.x + t.scroll, t.y - t.style.alttext.font:getHeight()/2)
        end
    end,
    pressed = function(t, x, y)
        t._press = x
    end,
    moved = function(t, x, y, dx, dy)
        t.scroll = t.scroll + dx
        return true
    end,
    released = function(t, x, y)
        t.cursor = math.min(t.cursor, utf8.len(t.text))
        if t._press and math.abs(t._press - x) <= inlineScrollThreshold then
            if t.scene.getPressButton(t) == 1 then
                t.scene.activate(t)
                local txt = t.encrypt(t.text)
                local p, d = 0, math.abs(t.x - t.w/2 + t.style.padding.x + t.scroll - x)
                for i = 1, utf8.len(txt) do
                    local o = utf8.offset(txt, i + 1)
                    if math.abs(t.x - t.w/2 + t.style.padding.x + t.scroll + t.style.text.font:getWidth(txt:sub(0, o - 1)) - x) < d then
                        p, d = i, math.abs(t.x - t.w/2 + t.style.padding.x + t.scroll + t.style.text.font:getWidth(txt:sub(0, o - 1)) - x)
                    end
                end
                t.cursor = p
            end
        end
    end,
    activated = function(t)
        love.keyboard.setKeyRepeat(true)
        if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
            love.keyboard.setTextInput(true, self.x - self.w/2, self.y - self.h/2, self.w, self.h)
        end
        t.cursorBlink = 0
    end,
    deactivated = function(t)
        love.keyboard.setKeyRepeat(false)
        if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
            love.keyboard.setTextInput(false)
        end
    end,
    hovered = function(t)
        love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"))
    end,
    unhovered = function(t)
        love.mouse.setCursor()
    end,
    textinput = function(t, txt)
        txt = txt:gsub("\n", "")
        t.cursor = math.min(t.cursor, utf8.len(t.text))
        t.scroll = t.scroll - t.style.text.font:getWidth(txt)
        t.text = t.text:sub(1, utf8.offset(t.text, t.cursor + 1) - 1) .. txt .. t.text:sub(utf8.offset(t.text, t.cursor + 1), -1)
        t.cursor = t.cursor + utf8.len(txt)
    end,
    keypressed = function(t, k)
        t.cursor = math.min(t.cursor, utf8.len(t.text))
        if k == "backspace" then
            if t.cursor > 0 then
                t.scroll = t.scroll + t.style.text.font:getWidth(t.text:sub(utf8.offset(t.text, t.cursor + 1) - 1, utf8.offset(t.text, t.cursor + 1) - 1))
                t.text = t.text:sub(1, utf8.offset(t.text, t.cursor) - 1) .. t.text:sub(utf8.offset(t.text, t.cursor + 1), -1)
                t.cursor = t.cursor - 1
            end
        elseif love.keyboard.isDown("lctrl", "rctrl") and k == "v" then
            t:textinput(love.system.getClipboardText() or "")
        elseif k == "left" then
            if t.cursor > 0 then
                t.scroll = t.scroll + t.style.text.font:getWidth(t.text:sub(utf8.offset(t.text, t.cursor + 1) - 1, utf8.offset(t.text, t.cursor + 1) - 1))
                t.cursor = t.cursor - 1
            else
                if t.previous then t.scene.activate(t.previous) end
            end
        elseif k == "right" then
            if t.cursor < utf8.len(t.text) then
                t.scroll = t.scroll - t.style.text.font:getWidth(t.text:sub(utf8.offset(t.text, t.cursor + 2) - 1, utf8.offset(t.text, t.cursor + 2) - 1))
                t.cursor = t.cursor + 1
            else
                if t.next then t.scene.activate(t.next) end
            end
        elseif k == "up" then
            if t.previous then t.scene.activate(t.previous) end
        elseif k == "down" then
            if t.next then t.scene.activate(t.next) end
        elseif k == "return" then
            t:action()
            if t.next then t.scene.activate(t.next) end
        end
    end,
    scrolled = function(t, x)
        t.scroll = t.scroll + x * t.scrollSpeed
    end
}
local inlineTextboxMt = {
    __index = function(t, k)
        if k == "style" then return style.inlineTextbox
        elseif k == "text" then return ""
        elseif k == "alttext" then return ""
        elseif k == "cursor" then return utf8.len(t.text)
        elseif k == "cursorBlink" then return 0
        elseif k == "scroll" then return 0
        elseif k == "scrollSpeed" then return inlineScrollSpeed
        elseif k == "w" then return t.style.text.font:getWidth(t.text) + 2*t.style.padding.x
        elseif k == "h" then return t.style.text.font:getHeight() + 2*t.style.padding.y + t.style.scrollbar.width
        elseif k == "encrypt" then return emptyf
        elseif k == "action" then return emptyf
        else return inlineTextbox[k] ~= nil and inlineTextbox[k] or dummyMt.__index(t, k) end
    end
}

local scrollableList = {
    update = function(t, dt)
        t.scroll = math.min(math.max(t.scroll, t.direction == "x" and t.w - 2*t.style.padding.x - t.contentWidth or t.h - 2*t.style.padding.y - t.contentHeight), 0)
    end,
    draw = function(t)
        love.graphics.setColor(t.style.background.color)
        love.graphics.rectangle("fill", t.x - t.w/2, t.y - t.h/2, t.w, t.h, t.style.cornerRadius)
        love.graphics.setColor(t.style.outline.color)
        love.graphics.setLineWidth(t.style.outline.width)
        love.graphics.rectangle("line", t.x - t.w/2, t.y - t.h/2, t.w, t.h, t.style.cornerRadius)
        if t.direction == "x" and t.contentWidth > t.w - 2*t.style.padding.x or t.contentHeight > t.h - 2*t.style.padding.y then
            local s = t.direction == "x" and (t.w - 2*style.padding.x)^2 / t.contentWidth or (t.h - 2*style.padding.y)^2 / t.contentHeight
            local t = t.direction == "x" and -t.scroll / t.contentWidth * (t.w - 2*style.padding.x) or -t.scroll / t.contentHeight * (t.h - 2*style.padding.y)
            love.graphics.setColor(t.style.scrollbar.color)
            if t.direction == "x" then
                love.graphics.rectangle("fill", t.x - t.w/2 + t.style.padding.x + t, t.y + t.h/2 - t.style.padding.y - t.style.scrollbar.width, s, t.style.scrollbar.width)
            else
                love.graphics.rectangle("fill", t.x + t.w/2 - t.style.padding.x - t.style.scrollbar.width, t.y - t.h/2 + t.style.padding.y + t, t.style.scrollbar.width, s)
            end
        end
        love.graphics.stencil(function()
            love.graphics.setColorMask(false, false, false, false)
            if t.direction == "x" then
                love.graphics.rectangle("fill", t.x - t.w/2 + t.style.padding.x, t.y - t.h/2 + t.style.padding.y, t.w - 2*t.style.padding.x, t.h - 2*t.style.padding.y - t.style.scrollbar.width)
            else
                love.graphics.rectangle("fill", t.x - t.w/2 + t.style.padding.x, t.y - t.h/2 + t.style.padding.y, t.w - 2*t.style.padding.x - t.style.scrollbar.width, t.h - 2*t.style.padding.y)
            end
            love.graphics.setColorMask()
        end, "replace", 1, false)
        love.graphics.setStencilTest("equal", 1)
    end,
    pressed = function(t, x, y)
        t._press = t.direction == "x" and y or x
    end,
    moved = function(t, x, y, dx, dy)
        t.scroll = t.scroll + (t.direction == "x" and dx or dy)
        if t._press and math.abs(t._press - (t.direction == "x" and y or x)) > listScrollThreshold then
            t.cancelPress(t.scene.getPress(t))
        end
        return true
    end,
    released = function(t, x, y)
        if t._press and math.abs(t._press - (t.direction == "x" and y or x)) <= listScrollThreshold then
            t.scene.activate(t)
        end
    end,
    added = function(t, e)
        e.x, e.y = nil, nil
        if e.direction == "x" then
            e.xpivot = nil
            e.ypivot = t.last or t.pivot
            e.yalign = t.align
            e.xoffset = t.space
        else
            e.ypivot = nil
            e.xpivot = t.last or t.pivot
            e.xalign = t.align
            e.yoffset = t.space
        end
        t.first, t.last = t.first or e, t.last or e
        e.previous, e.next = t.last, t.first
        t.last = e
    end,
    removed = function(t, e)
        if e == t.first and e == t.last then
            t.first, t.last = nil, nil
        else
            if e == t.first then
                t.first = e.next
            elseif e == t.last then
                t.last = e.previous
            end
        end
        e.previous.next, e.next.previous = e.next, e.previous
        e.previous, e.next = nil, nil
    end,
    elementactivatd = function(t, e)
        t.scene.activate(t)
        if not (t.direction == "x" and math.abs(t.x - e.x) <= t.w/2 - e.w/2 or math.abs(t.y - e.y) <= t.h/2 - e.h/2) then
            t.scroll = t.direction == "x" and -e.x + e.w/2 or -e.y + e.h/2
        end
    end,
    deactivated = function(t)
        t.deactivate()
    end,
    enabled = function(t)
        local e = t.getActive()
        if e and not (t.direction == "x" and math.abs(t.x - e.x) <= t.w/2 - e.w/2 or math.abs(t.y - e.y) <= t.h/2 - e.h/2) then
            t.scroll = t.direction == "x" and -e.x + e.w/2 or -e.y + e.h/2
        end
    end,
    scrolled = function(t, x)
        t.scroll = t.scroll + x * t.scrollSpeed
    end
}
local scrollableListMt = {
    __index = function(t, k)
        if k == "style" then return style.scrollableList
        elseif k == "direction" then return "y"
        elseif k == "align" then return "center"
        elseif k == "pivot" then
            t.pivot = setmetatable({}, __index = function(p, k)
                    if l == "x" then return t.direction == "x" and t.x - t.w/2 + t.style.padding.x + t.scroll or t.x - t.style.scrollbar.width/2
                elseif l == "y" then return t.direction == "x" and t.y - t.style.scrollbar.width/2 or t.y - t.h/2 + t.style.padding.y + t.scroll
                elseif l == "w" then return t.direction == "x" and 0 or t.w - 2*t.style.padding.x - t.style.scrollbar.width
                elseif l == "h" then return t.direction == "x" and t.h - 2*t.style.padding.y - t.style.scrollbar.width or 0
                end
            end)
            return t.pivot
        elseif k == "items" then
            -- generate item list
        elseif k == "space" then return 0
        elseif k == "scroll" then return 0
        elseif k == "scrollSpeed" then return inlineScrollSpeed
        elseif k == "contentWidth" then
            if #t.getElements() == 0 then return 0 end
            local l, r = math.huge, -math.huge
            for i, e in ipairs(t.getElements()) do
                if e ~= t.pivot then l, r = math.min(l, e.x - e.w/2), math.max(r, e.x + e.w/2) end
            end
            return r - l
        elseif k == "contentHeight" then
            if #t.getElements() == 0 then return 0 end
            local t, b = math.huge, -math.huge
            for i, e in ipairs(t.items) do
                if e ~= t.pivot then t, b = math.min(t, e.y - e.h/2), math.max(b, e.y + e.h/2) end
            end
            return b - t
        elseif k == "w" then return t.contentWidth + 2*t.style.padding.x + (t.direction == "x" and 0 or t.style.scrollbar.width)
        elseif k == "h" then return t.contentHeight + 2*t.style.padding.y + (t.direction == "x" and t.style.scrollbar.width or 0)
        else return scrollableList[k] ~= nil and scrollableList[k] or dummyMt.__index(t, k) end
    end,
    __newindex = function(t, k, v)
        if k == "contentWidth" or k == "contentHeight" then return
        else rawset(t, k, v) end
    end
}

return {
    dummy = function(t)
        return setmetatable(t, dummyMt)
    end,
    textButton = function(t)
        return setmetatable(t, textButtonMt)
    end,
    inlineTextbox = function(t)
        return setmetatable(t, inlineTextboxMt)
    end,
    scrollableList = function(t)
        return scene.new(setmatatable(t, scrollableListMt))
    end
}