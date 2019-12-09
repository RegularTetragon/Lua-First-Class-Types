TypeMethods = { }
Type = { }
TypeMethods.__type = Type;
function TypeMethods:superset(t)
    return t == FunctionType or t == Tuple or t == Union or t == Interface or t == Bottom or t == Type
end;

function TypeMethods:contains(obj)
    return  type(obj) == "table"
            and
            type(obj.contains) == "function"
            and
            type(obj.superset) == "function"
end;

function TypeMethods:equivalent(other)
    return self:superset(other) and other:superset(self)
end;

function MakeTypeOpMetatable()
    local TypeOperators = { }

    function TypeOperators:__shl(paramType)
        require "../src/Function"
        return func(self, paramType)
    end

    function TypeOperators:__add(type)
        require "../src/Union"
        return union(self, type);
    end

    function TypeOperators:__unm()
        require "../src/Union"
        require "../src/Primitives"
        return union(self, Nil)
    end

    function TypeOperators:__mul(other)
        require "../src/Tuple"
        if not Tuple:superset(other) then
            return tuple(self, other)
        else
            error "Not yet implemented multiple tuples"
        end
    end

    function TypeOperators:__pairs()
        return pairs {self};
    end

    function TypeOperators:__index(key)
        if type(key) == "string" then
            return TypeMethods[key]
        else
            assert(Type:contains(key), "No member of type found: ",tostring(key))
            require("../src/Dictionary")
            return dictionary(key, self)
        end
    end
    function TypeOperators:__tostring()
        return self.tostring and self:tostring() or "SomeAnonymousType"
    end
    return TypeOperators
end


setmetatable(Type, MakeTypeOpMetatable())


--Construct a simple type yourself
local function newtype(methods, operators)
    assert(methods.superset, "newtype must define superset")
    assert(methods.contains, "newtype must define contains")
    local newoperators = MakeTypeOpMetatable()
    for k, op in pairs(operators or {}) do
        newoperators[k] = op
    end
    return setmetatable(methods, newoperators)
end

_G.newtype = newtype
_G.Type = Type