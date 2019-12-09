require "../src/Type"
require "../src/Primitives"
require "../src/Dictionary"
require "../src/Function"

Interface = newtype {
    superset = function(self, other)
        return other == Bottom
    end;
    contains = function(self, other)
        return (Type:contains(other)
            and
            other.members
            and
            Type[String]:contains(other.members)
            and
            type(getmetatable(other).__call) == "function")
    end;
}
InterfaceInstanceOperators = { }

--When an interface is called, return a view of the table it is called with
--This view cannot see members which are unspecified by the interface
function InterfaceInstanceOperators.__call(interfaceInstance, rawInstance)
    local view = {__type = interfaceInstance}
    local weakview = {__type = interfaceInstance}
    --validate the table currently works with the interface
    for constraintName, constraintOrConstraintConstructor in pairs(interfaceInstance.members) do
        local constraint
        if type(constraintOrConstraintConstructor) == "function" then
            constraint = constraintOrConstraintConstructor(interfaceInstance)
        else
            constraint = constraintOrConstraintConstructor
        end
        
        assert(Type:contains(constraint), constraintName.." in interface must be a type.")

        if FunctionType:contains(constraint) then
            if not constraint:contains(rawInstance[constraintName]) then
                view[constraintName] = constraint(
                    function(firstparam, ...)
                        return rawInstance[constraintName](firstparam == view and weakview or firstparam, ...)
                    end
                )
            end
        else
            assert(constraint:contains(rawInstance[constraintName]), "Member "..constraintName.." of instance is not compatible with type "..tostring(constraint))
        end
    end
    local viewMetatable = {
        __index = function(view, k)
            local constraint = interfaceInstance.members[k]
            if constraint then
                local v = rawInstance[k]
                assert(constraint:contains(v),  "Member "..k.." was found in view but is of the wrong type.")
                return v;
            else
                error("Interface view does not contain member '"..tostring(k).."'");
            end
        end;
        __newindex = function(view, k, v)
            local constraint = interfaceInstance.members[k]
            if constraint then
                assert(constraint:contains(v), "Instance "..tostring(v).." is not of type "..tostring(constraint))
                rawInstance[k] = v;
            else
                error("Interface view does not contain "..k)
            end
        end;
        __rawinstance = rawInstance
    }
    local weakviewMetatable = {
        __index = function(view, k)
            local constraint = interfaceInstance.members[k]
            local v = rawInstance[k]
            if constraint then
                assert(constraint:contains(v),  "Member "..k.." was found in view but is of the wrong type.")
            end
            return v
        end;
        __newindex = function(view, k, v)
            local constraint = interfaceInstance.members[k]
            if constraint then
                assert(constraint:contains(v), "Instance "..tostring(v).." is not of type "..tostring(constraint))
            end
            rawInstance[k] = v;
        end;
        __rawinstance = rawInstance
    }
    setmetatable(weakview, weakviewMetatable)
    --Allows you to access the original's overloaded operators through the view.
    --Note: operators are not type safe unless the metatable they're in is also constrained by an interface.
    return setmetatable(view, viewMetatable)
end

--Combine two interfaces into one (Intersection).
--If two members have the same name their types will be unioned together
function InterfaceInstanceOperators:__concat(other)
    local members = {}
    for member, constraint in pairs(other.members) do
        members[member] = constraint
    end
    for member, constraint in pairs(self.members) do
        if members[member] then
            members[member] = members[member] + constraint
        else
            members[member] = constraint
        end
    end
    return interface(members)
end

local InterfaceInstanceMethods = {}
function InterfaceInstanceMethods:contains(obj)
    for memberName, memberType in pairs(self.members) do
        local success, contains = pcall(
            function()
                return memberType:contains(obj[memberName])
            end
        )
        if not success or not contains then
            return false
        end
    end
    return true;
end;

function InterfaceInstanceMethods:superset(otherinterface)
    if otherinterface == self then
        return true;
    end
    if not Interface:contains(otherinterface) then
        return false;
    end
    for memberName, memberType in pairs(self.members) do
        --if the other interface has all the members of this interface
        local correspondingMemberType = otherinterface.members[memberName]
        if not memberType:superset(correspondingMemberType) then
            return false
        end
    end
    return true
end

function InterfaceInstanceMethods:tostring()
    local name = "interface {"
    for memberName, memberType in pairs(self.members) do
        name = name..memberName.." = "..tostring(memberType)..";"
    end
    return name .. "}"
end

--Construct an interface
local function interface(members)
    
    return newtype (
        {
            __type = Interface;
            members = members;
            tostring = InterfaceInstanceMethods.tostring;
            superset = InterfaceInstanceMethods.superset;
            contains = InterfaceInstanceMethods.contains;
        },
        InterfaceInstanceOperators
    )
end


_G.interface = interface
_G.Interface = Interface