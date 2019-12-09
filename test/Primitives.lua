require "src.Primitives"
require "src.Type"

return {
    Boolean = function()
        assert(Boolean:superset(Boolean))
        assert(Boolean:contains(false))
        assert(Boolean:contains(true))
        assert(not Boolean:contains(5))
        assert(not Boolean:superset(Nil))
    end;
    Number = function()
        assert(Number:superset(Number))
        assert(Number:contains(5))
        assert(Number:contains(3.1))
        assert(Number:superset(Integer))
        assert(not Number:superset("asdf"))
    end;
    Integer = function()
        assert(Integer:superset(Integer))
        assert(Integer:contains(5))
        assert(not Integer:superset(Number))
    end;
    String = function()
        assert(String:superset(String))
        assert(String:contains "Hello")
        assert(String:contains "")
        assert(not String:superset(Number))
        assert(not String:superset "asdf")
    end;
    Top = function()
        assert(Top:superset(Top))
        assert(Top:contains(5))
        assert(not Top:contains(Top))
        assert(Top:superset(Bottom))
        assert(Top:superset(String))
        assert(Top:contains "hi")
        assert(Top:contains(nil))
        --Type is a Type so Top contains it
        assert(Top:contains(Type))
        --Top contains every element of Type
        assert(Top:superset(Type))
    end;
    Bottom = function()
        assert(Bottom:superset(Bottom))
        assert(not Bottom:contains(5))
        assert(not Bottom:contains(Bottom))
        assert(not Bottom:superset(Top))
        assert(not Bottom:contains "hi")
        assert(not Bottom:contains(nil))
        assert(not Bottom:contains(Type))
        assert(not Bottom:superset(Type))
    end;
    Type = function()
        --Type is a type
        assert(Type:superset(Type))
        assert(Type:superset(Interface))
        assert(Type:superset(FunctionType))
        assert(not Type:superset(Number))
        assert(Type:contains(Number))
        assert(not Type:contains(5))
        assert(Type:contains(Integer))
        --Type has Top in it
        assert(Type:contains(Top))
        --Type does not have every element of top
        assert(not Type:superset(Top))
    end

}