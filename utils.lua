--[[
UTILITY FUNCTIONS

sqit.utils.merge(a, b)
    merges all entries from both tables, colliding keys from b are overlayed on top of a
    arguments:
        a, b (table): source tables
    returns:
        t (table): the destination table
sqit.utils.spaceOut(elems, direction, space, pivot, mode, spaceAround)
    spaces out the elements in the specified order (assuming elements are positioned about their cetner)
    arguments:
        elems (table): the array of elements
        direction (string): "x" (left to right) or "y" (top to bottom)
        space (number): the spacing distance
        pivot (number): the origin of the spaced-out layout
        mode (string): "start" (the layout will start at origin), "center" (the layout will be centered about the origin) or "end" (the layout will end at the origin)
        spaceAround (boolean): whether to include a space before the first and after the last element
    returns:
        size (number): the total space the spaced-out layout spans
sqit.utils.stretchOut(elems, direction, from, to, spaceAround) - stretch the elements out between 2 boundaries (assuming elements are positioned about their center)
    arguments:
        elems (table): the array of elements
        direction (string): "x" (left to right) or "y" (top to bottom)
        from, to (number): the boundaries of the layout
        spaceAround (boolean): whether to include a space before the first and after the last element
    returns:
        [nothing]
--]]

return {
    merge = function(a, b)
        local t = {}
        for k, v in pairs(a) do
            t[k] = v
        end
        for k, v in pairs(b) do
            t[k] = v
        end
        return setmetatable(t, getmetatable(b) or getmetatable(a))
    end,
    spaceOut = function(elems, direction, space, pivot, mode, spaceAround)
        space = space or 0
        pivot = pivot or 0
        mode = mode or "center"
        local pk, sk
        if direction == "x" then
            pk, sk = "x", "w"
        elseif direction == "y" then
            pk, sk = "y", "h"
        else return end
        local sum = space * (spaceAround and #elems + 1 or #elems - 1)
        for i, e in ipairs(elems) do
            sum = sum + e[sk]
        end
        local piv = pivot
        if mode == "start" then
            piv = piv
        elseif mode == "center" then
            piv = piv - sum/2
        elseif mode == "end" then
            piv = piv - sum
        else return end
        piv = spaceAround and piv + space or piv
        for i, e in ipairs(elems) do
            e[pk] = piv + e[sk]/2
            piv = piv + e[sk] + space
        end
        return sum
    end,
    stretchOut = function(elems, direction, from, to, spaceAround)
        if not to then from, to = 0, from end
        local pk, sk
        if direction == "x" then
            pk, sk = "x", "w"
        elseif direction == "y" then
            pk, sk = "y", "h"
        else return end
        local sum = 0
        for i, e in ipairs(elems) do
            sum = sum + e[sk]
        end
        local space = (to - from - sum) / (spaceAround and #elems + 1 or #elems - 1)
        local piv = spaceAround and from + space or from
        for i, e in ipairs(elems) do
            e[pk] = piv + e[sk]/2
            piv = piv + e[sk] + space
        end
    end
}