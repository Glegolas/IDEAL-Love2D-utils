--@auxiliary
--//lua
    local tinsert, tremove, tsort = table.insert, table.remove, table.sort
    local pairs    = pairs
    local type     = type
    local print    = print
    local tostring = tostring
    local getmetatable = getmetatable
    local min, max, sqrt = math.min, math.max, math.sqrt
--\\
--//love
    --@filesystem
    local lf_getDirectoryItems = love.filesystem.getDirectoryItems
--\\

--@datastructures
local function HandleKeyValuePair(kvp, handler)
    for i, v in pairs(kvp) do
        handler(v, i, kvp)
    end
    return kvp
end

local function HandleOrderedList(ol, handler, backwards, start, complete, amount)
    start, complete = start or 1, complete or #ol
    if not backwards then
        amount = amount or 1
        for i = start, complete, amount  do
            handler(ol[i], i, ol)
        end
    else
        amount = amount or -1
        for i = complete, start, amount do
            handler(ol[i], i, ol)
        end
    end
end

local function HandleFileDirectory(directory, ...)
    return HandleOrderedList(lf_getDirectoryItems(directory), ...)
end

local function Deepcopy(copyable, template, keep)
    if type(copyable) == "table" then
        template = template or {}
        if keep then
            for i, v in pairs(copyable) do
                if template[i] == nil then
                    template[Deepcopy(i)] = Deepcopy(v)
                end
            end
        else
            for i, v in pairs(copyable) do
                template[Deepcopy(i)] = Deepcopy(v)
            end
        end
        return template
    end
    return copyable
end

local function Mixin(template, ...)
    local pack = {...}
    for i = #pack, 1, -1 do
        local tbl = pack[i]
        for _i, v in pairs(tbl) do
            if template[_i] == nil then
                template[Deepcopy(_i)]=Deepcopy(v)
            end
        end
    end
    return template
end

local function ReverseOrderedList(orderedlist)
end

--@string
local function ToStringTable(tbl, typedefs, onlyOrdered, start, addin, cache)
    addin = addin or ""
    if cache then
        if cache[tbl] then
            return "<" .. tostring(tbl) .. ">: {cyclic reference detected}";
        end
    else
        cache = {[tbl] = true}
    end

    local whitespace = "    "
    local r = "<" .. tostring(tbl) .. ">: {"
    if not onlyOrdered then
        if typedefs then
            for i, v in pairs(tbl) do
                local _ti, _tv = type(i), type(v)
                local _addin = addin .. whitespace
                r = r .."\n" .. _addin .. "<" .. _ti.. ">[" .. tostring(i) .. "]:   " .. (
                    (_tv == "table" and ToStringTable(v, typedefs, onlyOrdered, start, _addin, cache)) or
                    "<" .. _tv .. ">: " .. tostring(v)
                )
            end
        else
            for i, v in pairs(tbl) do
                local _tv = type(v)
                local _addin = addin .. whitespace
                r = r .."\n" .. _addin .. "[" .. tostring(i) .. "]:   " .. (
                    (_tv == "table" and ToStringTable(v, typedefs, onlyOrdered, start, _addin, cache)) or
                    tostring(v)
                )
            end
        end
    else
        if typedefs then
            for i = start or 1, #tbl do
                local v   = tbl[i]
                local _tv = type(v)
                local _addin = addin .. whitespace
                r = r .."\n" .. _addin .. "<number>[" .. i .. "]:   " .. (
                    (_tv == "table" and ToStringTable(v, typedefs, onlyOrdered, start, _addin, cache)) or
                    "<" .. _tv .. ">: " .. tostring(v)
                )
            end
        else
            for i = start or 1, #tbl do
                local v   = tbl[i]
                local _tv = type(v)
                local _addin = addin .. whitespace
                r = r .."\n" .. _addin .. "<" .. tostring(i) .. ">:   " .. (
                    (_tv == "table" and ToStringTable(v, typedefs, onlyOrdered, start, _addin, cache)) or
                    tostring(v)
                )
            end
        end
    end
    r = r .. "\n" .. addin .. "}"
    return r
end

--@math
local function Clamp(val, _min, _max)
    return max(_min, min(val, _max))
end

local function Sign(val)
    return (val > 0 and 1) or (val < 0 and -1) or val
end

local function IsPointOnRect(x, y, rx, ry, rw, rh)
    return (x >= rx and x <= rx + rw and y >= ry and y <= ry + rh)
end

local function IsPointOnCircle(x, y, cx, cy, cr)
    return sqrt((x-cx)^2+(y-cy)^2) <= cr 
end

local function IsRectOnRect(x1, y1, w1, h1, x2, y2, w2, h2)
    return (x1 + w1 >= x2 and x1 <= x2 + w2 and y1 + h1 >= y2 and y1 <= y2 + h2)
end

--@thread | deliver
return {
    HandleKeyValuePair     = HandleKeyValuePair,
    HandleOrderedList      = HandleOrderedList,
    HandleFileDirectory    = HandleFileDirectory,
    Deepcopy               = Deepcopy,
    Mixin                  = Mixin,
    Reverse                = Reverse,
    ToStringTable          = ToStringTable,
    Clamp                  = Clamp,
    Sign                   = Sign,
    IsPointOnRect          = IsPointOnRect,
    IsPointOnCircle        = IsPointOnCircle,
    IsRectOnRect           = IsRectOnRect
}
