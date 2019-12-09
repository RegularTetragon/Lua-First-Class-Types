require "../src/Type"

_G.Dictionary = newtype {
    superset = function(self, othertype)
        return othertype == Bottom or othertype == self
    end;
    contains = function(self, instance)
        return Type:contains(instance) and Type:contains(instance.keytype) and Type:contains(instance.valuetype)
    end;

}

local function dictionary(keytype, valuetype)
    return newtype {
        __type = Dictionary;
        superset = function(self, othertype)
            return Dictionary:contains(othertype) and self.keytype:superset(othertype.keytype) and self.valuetype:superset(othertype.valuetype)
        end;
        contains = function(self, obj)
            if type(obj) == "table" then
                for i, v in pairs(obj) do
                    if not self.keytype:contains(i) or not self.valuetype:contains(v) then
                        return false
                    end
                end
                return true
            end
        end;
        tostring = function(self)
            return tostring(self.valuetype).."["..self.keytype.."]"
        end;
        keytype = keytype;
        valuetype = valuetype;
    }
end

_G.dictionary = dictionary
_G.Dictionary = Dictionary