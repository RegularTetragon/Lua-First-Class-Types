require "src.Type"
_G.Union = newtype {
    superset = function(self, other)
        return other == Bottom
    end;
    contains = function(self, other)
        return Type:contains(other) and other.__type == Union
    end;
}

local function flattenUnion(types)
    local t = { }
    for i, type in pairs(types) do
        if Union:contains(type) then
            for _, unionSubtype in pairs(flattenUnion(type.__typelist)) do
                table.insert(t, unionSubtype)
            end
        else
            table.insert(t, type)
        end
    end
    return t;
end

function _G.union(...)
    return newtype {
        __type = Union;
        superset = function(self, type)
            for i, subtype in pairs(self.__typelist) do
                if subtype:superset(type) then
                    return true
                end
            end
            return type==Bottom
        end;
        contains = function(self, obj)
            for i, subtype in pairs(self.__typelist) do
                if subtype:contains(obj) then
                    return true
                end
            end
            return false
        end;
        which = function(self, obj)
            for i, subtype in pairs(self.__typelist) do
                if subtype:contains(obj) then
                    return subtype
                end
            end
            return false
        end;
        tostring = function(self)
            local out = "("
            for i, subtype in pairs(self.__typelist) do
                out = out..tostring(subtype)..(i == #self.__typelist and ")" or " + ")
            end
            return out
        end;
        __typelist = flattenUnion {...};
    }
end

_G.typecase = function(of)
    return function(cases)
        local sortedcases = { }
        for case, action in pairs(cases) do
            table.insert(sortedcases, {case = case, action = action})
        end
        table.sort(
            sortedcases,
            function(case1, case2)
                return case2:superset(case1)
            end
        )
        for _, caseaction in pairs(sortedcases) do
            if caseaction.case:contains(of) then
                return caseaction.action(of)
            end
        end
        error ("Nonexhaustive typecase cannot handle "..tostring(of))
    end
end;