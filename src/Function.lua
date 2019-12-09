require "src.Type"
--Use default type methods
FunctionType = newtype {
    contains = function(self, sometype)
        return Type:contains(sometype)
               and
               Type:contains(sometype.argts)
               and
               Type:contains(sometype.retts)
               and
               getmetatable(sometype)
               and
               getmetatable(sometype).__call ~= nil
    end,
    superset = function(self, other)
        return other == Bottom
    end
}

FunctionTypeInstanceOperators = {
    --Construct a new Functor, restricted by the function type instance
    __call = function(self, lambda)
        assert(
            type(lambda) == "function"
            or
            (
                type(lambda) == "table"
                and
                type(getmetatable(lambda).__call) == "function"
            ),
            "Function types can only restrict function-like objects."
        )
        return setmetatable(
            {__func = lambda, __type = self},
            FunctorOperators
        )
    end
}

FunctorOperators = {
    __call = function(self, ...)
        local args = {...}
        for argIndex, argType in pairs(Tuple:contains(self.__type.argts) and self.__type.argts.__typelist or {self.__type.argts}) do
            assert(
                argType:contains(args[argIndex]),
                "Argument type of "..tostring(args[argIndex]).." is incompatible with parameter "..argIndex.." with expected type: "..tostring(self.__type.argts)
            )
        end
        
        
        local returns = { self.__func(...) }
        assert(
            self.__type.retts:contains(table.unpack(returns)),
            "Return type of wrapped function invalid. Expected: "
                ..
                tostring(self.__type.retts)
                ..
                " Got: "
                ..
                tostring(table.unpack(returns) or "nil")
        )
        return table.unpack(returns)
    end,
    __tostring = function(self)
        return tostring(self.__func).." of type "..tostring(self.__type)
    end
}

--Construct a new function type
local function func(returns, args)
    assert(Type:contains(returns), "return type must be a Type, got: "..tostring(returns))
    assert(Type:contains(args), "args type must be a Type, got: "..tostring(args))
    return newtype ({
        __type = FunctionType;
        argts = args;
        retts = returns;
        superset = function(self, other)
            return FunctionType:contains(other) and self.argts:superset(other.argts) and self.retts:superset(other.retts)
        end;
        contains = function(self, other)
            
            return type(other) == "table" and FunctionType:contains(other.__type) and self.argts:superset(other.__type.argts) and self.retts:superset(other.__type.retts)
            
        end;
        tostring = function(self)
            return "("..tostring(self.retts) .. " << " .. tostring(self.argts)..")"
        end;
    },
    FunctionTypeInstanceOperators)
end

local function method(returns, args)
    return function(Self)
        return func(returns, Self * args)
    end
end

_G.method = method
_G.func = func