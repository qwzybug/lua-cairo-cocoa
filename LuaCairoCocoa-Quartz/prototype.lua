-- Implementation of the NewtonOS inheritance model

-- NewtonScript-style table lookup:
-- Look first in prototypes.
-- Look next in parent and its prototypes. Etc.

function lookup(obj, k)
  -- first, check the prototype chain
  v = lookupProto(obj, k)
  if v then
    do return v end
  else -- check the parent
    p = rawget(obj, "_parent")
    if p then -- recurse lookup on parent
      do return p[k] end
    else -- end of the parent chain
      do return nil end
    end
  end
end

function lookupProto(obj, k)
  p = rawget(obj, "_proto")
  if p then
    if rawget(p, k) then
      do return rawget(p, k) end
    else
      do return lookupProto(p, k) end
    end
  else -- end of the prototype chain
    do return nil end
  end
end

-- NewtonScript-style table slot assignment:
-- If you've inherited a value from your prototype, set it locally
-- Otherwise, set it on your parent. Recurse.
-- If that bottoms out, set locally.
-- That sounds inefficient, somehow...

function parentSet(obj, k, v, bottom)
  if k == "_parent" or k == "_proto" then rawset(obj, k, v); do return end end
  local result
  -- set locally if the key is defined in the prototype
  if lookupProto(obj, k) then result = rawset(obj, k, v)
  else
    p = rawget(obj, "_parent")
    -- if there's a parent, then recurse
    if p then result = parentSet(p, k, v, false)
         else result = false
         end
  end
  -- if the parentSet chain didn't go, then we might as well set it locally
  if bottom and not result then result = rawset(obj, k, v) end
  return result
end

-- object constructor
obj = function(o)
  o = o or {}
  if o[1] then o._proto = o[1] end
  setmetatable(o, {__index = lookup,
                   __newindex = function(t,k,v) parentSet(t, k, v, true) end })
  return o
end
