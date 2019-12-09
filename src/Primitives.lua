require "src.Type"
--Callable things
_G.Functor = newtype {
    superset = function(self, type)
        return type == Lambda or type == FunctionType or type == Bottom or type == Functor
    end;
    contains = function(self, obj)
        return Lambda:contains(obj) or FunctionType:contains(obj) or getmetatable(obj).__call ~= nil
    end;
    tostring = function(self)
        return "Functor"
    end;
}
--True or False, strict.
_G.Boolean = newtype {
    superset = function(self, type)
        return type == Bottom or type == Boolean
    end;
    contains = function(self, obj)
        return type(obj) == "boolean"
    end;
    tostring = function(self)
        return "Boolean"
    end;
}

_G.Falsy = newtype {
    superset = function(self, type)
        return type == Nil or type == Bottom
    end;
    contains = function(self, obj)
        return obj == nil or obj == false
    end;
    tostring = function(self)
        return "Falsy"
    end;
}
_G.Truthy = newtype {
    superset = function(self, type)
        return type ~= Nil and type ~= Falsy and type ~= Boolean
    end,
    contains = function(self, obj)
        return obj ~= false and obj ~= nil
    end;
    tostring = function(self)
        return "Truthy"
    end;
}

_G.Integer = newtype {
    superset = function(self, type)
        return type == Bottom or type == Integer
    end;
    contains = function(self, obj)
        return type(obj) == "number" and math.floor(obj) == obj
    end;
    tostring = function(self)
        return "Integer"
    end;
}

_G.Number = newtype {
    superset = function(self, type)
        return type == Integer or type == Bottom or type == Number
    end;
    contains = function(self, obj)
        return type(obj) == "number"
    end;
    tostring = function(self)
        return "Number"
    end;
}

_G.String = newtype {
    superset = function(self, type)
        return type == Bottom or type == String;
    end;
    contains = function(self, obj)
        return type(obj) == "string"
    end;
    tostring = function(self)
        return "String"
    end;
}

_G.Nil = newtype {
    superset = function(self, type)
        return type == Bottom or type == Nil
    end;
    contains = function(self, obj)
        return obj == nil
    end;
    tostring = function(self)
        return "Nil"
    end;
}

_G.Top = newtype {
    superset = function(self, type)
        return true
    end;
    --Sets cannot contain themselves
    contains = function(self, obj)
        return obj ~= self
    end;
    tostring = function(self)
        return "Top"
    end;
}

--In lua at least, anything can be used as a true or false value.
_G.Booly = Top

_G.Bottom = newtype {
    superset = function(self, type)
        return type == self
    end;
    contains = function(self, obj)
        return false
    end;
    tostring = function(self)
        return "Bottom"
    end;
}
--Raw functions
_G.Lambda = newtype {
    superset = function(self, type)
        return type == Bottom or type == Lambda or type == Functor
    end;
    contains = function(self, obj)
        return 
    end;
    tostring = function(self)
        return "Lambda"
    end;
}

_G.Table = Top[Top]