require("src.Primitives")
require("src.Function")
require("src.Type")
require("src.Interface")
require("src.Union")
require("src.Tuple")
return {
    ContainsNewtype = function()
        assert(Type:contains(newtype {
            superset = function()
                return false
            end;
            contains = function()
                return false
            end;
        }), "Type doesn't contain newtype {}")
    end,
    ModuleReturns = function()
        assert(func, "func undefined")
        assert(newtype, "newtype undefined")
        assert(Type, "Type undefined")
        assert(FunctionType, "Function undefined")
    end,
    Operators = function()
        assert(FunctionType:contains(Number << Number))
        assert(Union:contains(Number + Number))
        assert(Tuple:contains(Number * Number))
        assert(Interface:contains(interface {} .. interface {}))
        assert(tostring((Number * Number) << (Number * Number + Boolean)) == tostring(func(Number * Number, (Number * Number) + Boolean)))
        assert(Dictionary:contains(Number[String]))
        assert(tostring((Number * Number) * Number) == tostring(Number * (Number * Number)))
    end,
    SupersetBottom = function()
        assert(FunctionType:superset(Bottom))
        assert(Interface:superset(Bottom))
        assert(Union:superset(Bottom))
        assert(Tuple:superset(Bottom))
    end
}