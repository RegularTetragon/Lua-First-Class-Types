require "src.Tuple"
require "src.Primitives"

return {
    Superset = function()
        assert((Number * Number):superset(Number * Number))
        assert((Top * Number):superset(Number * Number))
        assert(not (Top * Number):contains(4))
        assert(not (Top * Number):contains(4, "hi"))
    end;
    Contains = function()
        assert((Number*Number):contains(2,2))
    end;
}