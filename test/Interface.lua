require("src.Interface")
require("src.Primitives")



return {
    Interface = function()
        assert(type(Interface.contains) == "function")
        assert(type(Interface.superset) == "function")
    end;
    Type = function()
        assert(Type:contains(Interface), "Type doesn't contain interface")
        assert(Type:superset(Interface), "Type isn't a superset of interface")
        assert(Type:contains(interface {}), "Type doesn't contain an interface instance")
    end;
    Supersets = function()
        local I0 = interface {}
        local I1 = interface {a = Number;}
        local IS = interface {a = String;}
        local I2 = interface {a = Number; b = Number;}
        assert(I0:superset(I0))
        assert(I0:superset(I1))
        assert(I0:superset(IS))
        assert(I0:superset(I2))

        assert(not I1:superset(I0))
        assert(I1:superset(I1))
        assert(not I1:superset(IS))
        assert(I1:superset(I2))

        assert(not IS:superset(I0))
        assert(not IS:superset(I1))
        assert(IS:superset(IS))
        assert(not IS:superset(I2))

        assert(not I2:superset(I0))
        assert(not I2:superset(I1))
        assert(not I2:superset(IS))
        assert(I2:superset(I2))

    end;
    ContainsVars = function()
        local I0 = interface {}
        local I1 = interface {a = Number;}
        local IS = interface {a = String;}
        local I2 = interface {a = Number; b = Number;}

        local t0 = {}
        local t1 = {a = 2}
        local t2 = {a = 2; b = 3}
        local t3 = {a = 2; b = 3; c = 4;}
        local ts = {a = "Hi", b = 3}

        assert(I0:contains(t0))
        assert(I0:contains(t1))
        assert(I0:contains(t2))
        assert(I0:contains(t3))
        assert(I0:contains(ts))

        assert(not I1:contains(t0))
        assert(I1:contains(t1))
        assert(I1:contains(t2))
        assert(I1:contains(t3))
        assert(not I1:contains(ts))

        assert(not I2:contains(t0))
        assert(not I2:contains(t1))
        assert(I2:contains(t2))
        assert(I2:contains(t3))
        assert(not I2:contains(ts))

        assert(not IS:contains(t0))
        assert(not IS:contains(t1))
        assert(not IS:contains(t2))
        assert(not IS:contains(t3))
        assert(IS:contains(ts))
    end;
    ViewAssignment = function()
        local I = interface {
            a = Number;
        }
        local t = {a = 0}
        local i = I (t)

        i.a = 2

        assert(t.a == 2, "Value of a did not change in original table")
        local success, error = pcall(
            function()
                i.a = "asdf"
            end
        )
        assert(not success, "Assignment i.a = \"asdf\" failed to error.")
        local success, error = pcall(
            function()
                i.b = 4
            end
        )
        assert(not success, "Assigment i.b = \"4\" failed to error.")
    end;
    ViewCreation = function()
        local I = interface {
            a = Number;
        }
        local success, error = pcall(
            function()
                I {a = 2}
            end
        )
        assert(success, "Instantiation I {a = 2} failed for reason: "..(error or "not provided"))

        local success, error = pcall(
            function()
                I {a = "asdf"}
            end
        )
        assert(not success, "Instantiation I {a = 2} failed to fail.")
    end;
    ViewHiding = function()
        local I = interface {
            a = Number;
        }
        local i = I {a = 2; b = 3}
        
        local success, error = pcall(
            function()
                local a = i.b
            end
        )
        assert(not success, "Interface failed to hide b in table")
    end;
    ViewAccess = function()
        local I = interface {
            a = Number;
        }
        local i = I {a = 2}
        assert(i.a == 2, "Interface failed to access a in table")
    end;
    Intersections = function() 
        local I1 = interface {
            a = Number;
        }
        local I2 = interface {
            b = Number;
        }
        local I3 = I1 .. I2
        assert(Interface:contains(I3))
        local t1 = {a = 1}
        local t2 = {b = 2}
        local t3 = {a = 1; b = 2}

        assert(I1:contains(t1))
        assert(I2:contains(t2))
        assert(I3:contains(t3))
        assert(I1:superset(I3), tostring(I1).." is erroniously not a superset of "..tostring(I3))
        assert(I2:superset(I3))
        assert(I1:contains(t3))
        assert(I2:contains(t3))
        assert(I1:contains(I3(t3)))
        assert(I2:contains(I3(t3)))

        assert(not I3:contains(t1))
        assert(not I3:contains(t2))
        
        assert(not I3:superset(I2), tostring(I3).." is erroniously a superset of "..tostring(I2))
        assert(not I3:superset(I1))
    end;
    Methods = function()
        local I = interface {
            action = Number << (Top * Number);
        }
        local t1 = {
            action = function(self, num)
                return num;
            end
        }
        local t2 = {
            action = function(self, num)
                self.num = self.num + num;
                return self.num
            end;
            num = 0;
        }
        local t3 = {
            action = function(self, num)
                return "hi"
            end
        }
        local i1, i2 = I(t1), I(t2)
        
        assert(i1:action(4) == 4)
        assert(i2:action(3) == 3)
        assert(i2:action(3) == 6)
        local success, reason = pcall(
            function()
                i1:action("Asdf")
            end
        )
        assert(not success, "Failed to error on call to method 'i1:action' with invalid type")
        success, reason = pcall(
            function()
                I(t3):action(1)
            end
        )
        assert(not success, "Failed to error on call to method with mismatched return type 'i3:action'")
    end;
    IllegalMutationMethods = function()
        local I = interface {
            value = Number;
            actionSuccess = Nil << Top;
            actionFail = Nil << Top;
        }
        local i = I {
            value = 5;
            actionFail = function(self)
                self.value = "woah"
            end;
            actionSuccess = function(self)
                self.value = 5
            end;
        }
        i:actionSuccess()
        local success, reason = pcall(
            function()
                i:actionFail()
            end
        )
        assert(not success, "Illegal mutation not caught.")
    end;
    InterfaceContains = function()
        assert(Interface:contains(interface {a = Number}), "Interface does not contain a filled interface")
        assert(Interface:contains(interface {}), "Interface does not contain the empty interface")
        assert(not Interface:contains(Interface), "Interface contains itself")
    end
}