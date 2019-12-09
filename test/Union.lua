require "Union.lua"

return {
    Contains = function()
        local NumOrString = union(Number, String)
        assert(NumOrString:contains(4))
        assert(NumOrString:contains"Hi")
        assert(not NumOrString:contains(Number))
        assert(not NumOrString:contains(true))
    end,
    Superset = function()
        local NumOrString = union(Number, String)
        assert(not NumOrString:superset(4))
        assert(not NumOrString:superset"Hi")
        assert(NumOrString:superset(Number))
        assert(NumOrString:superset(String))
        assert(NumOrString:superset(Bottom))
        assert(not NumOrString:superset(Boolean))
    end,
    TypeCase = function()
        local out = {}
        for _, e in pairs {2, "hi"} do
            local result = typecase (e) {
                [Integer] = function(val)
                    return "number"..val
                end;
                [String] = function(val)
                    return "string"..val
                end;
                [Top] = function(val)
                    return "default"
                end;
            }

            table.insert(out, result)
        end

        assert(out[1] == "number2")
        assert(out[2] == "stringhi")
        assert(out[3] == "default")
    end
}