return {
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