require("src.Type")
require("src.Function")
require("src.Primitives")
require("src.Tuple")


return {
    Type = function()
        assert(Type:superset(FunctionType))
        assert(Type:contains(FunctionType))
        assert(Type:contains(func(Number,Number)))
    end;
    Construction = function()
        local Nummap = func(Number, Number)
        local addone = Nummap(
            function(x)
                return x + 1
            end
        )
        addone(4)
        assert(FunctionType:contains(Nummap), "FunctionType erroniously does not contain "..tostring(Nummap))
        assert(Nummap:contains(addone))
    end;
    OperatorConstruction = function()
        local Nummap = Number << Number
        
        local addone = Nummap(
            function(x)
                return x + 1
            end
        )
        addone(4)
        assert(FunctionType:contains(Nummap))
        assert(Nummap:contains(addone))
    end
}