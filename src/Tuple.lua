require "src.Type"

Tuple = newtype {
    superset = function(self, othertype)
        return othertype == self or othertype == Bottom
    end;
    contains = function(self, obj)
        return Type:contains(obj) and obj.__type == Tuple;
    end
}

local function flattenTuple(types)
    local t = { }
    for _, type in pairs(types) do
        if Tuple:contains(type) then
            for _, unionSubtype in pairs(flattenTuple(type.__typelist)) do
                table.insert(t, unionSubtype)
            end
        else
            table.insert(t, type)
        end
    end
    return t;
end



function _G.tuple(...)
    local typelist = flattenTuple {...}
    return newtype {
        __type = Tuple;
        __typelist = typelist;
        superset = function(self, othertype)
            if not Tuple:contains(othertype) then
                return false
            end
            if #othertype.__typelist ~= #self.__typelist then
                return false
            end
            for i, type in pairs(self.__typelist) do
                if not type:superset(othertype.__typelist[i]) then
                    return false
                end
            end
            return true
        end;
        contains = function(self, ...)
            local args = {...}
            if #args ~= #self.__typelist then
                return false;
            end
            for i, type in pairs(self.__typelist) do
                if not type:contains(args[i]) then
                    return false;
                end
            end
            return true
        end;
        tostring = function(self)
            local outstr = "("
            for i, type in pairs(self.__typelist) do
                outstr = outstr..tostring(type)..(i==#self.__typelist and ")" or ", ")
            end
            return outstr
        end;
    }
end