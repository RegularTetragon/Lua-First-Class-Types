# Abstract
This projects goal is to add a form of strong algebraic typing to certain parts of Lua.
Lua is a duck typed language with extremely flexible syntax. This syntax allows you to make
what look like new keywords but are also functions, as well as perform introspection on
the current environment. For now my scope will be limited to strongly typed functions, dictionaries,
and objects, not names. That said I believe due to the ability to get the current environment as
a hash table it is likely possible to apply these type constraints to that table to allow for strongly
typed local and global variables.

By implementing Types at runtime from within Lua types are first class as they are all effectively objects. Eat your heart out SmallTalk.

This project was developed for Dr. Finkels CS655 class by Vincent Mattingly.
http://www.cs.uky.edu/~raphael/courses/CS655.html

# Environment
An installation of Lua5.3 is necessary as this library overloads the << operator
If you would like to easily run tests make is nice as well as the default make command
simply runs all the tests.

# Files
luatype
 * src
   * Dictionary.lua
   * Function.lua
   * Interface.lua
   * Primitives.lua
   * Tuple.lua
   * Type.lua
   * Union.lua
 * test
   * Dictionary.lua
   * Function.lua
   * Interface.lua
   * Primitives.lua
   * Tuple.lua
   * Type.lua
   * Union.lua
 * Main.lua
 * Makefile
 * Readme.md
 * RunTests.lua

# 1. Type
There's a hierarchy of type-like things. At the core you have this interface: called Type
Note this is a somewhat circular definition as interface itself is a type constructor (see below.)

```
Type = interface {
    --Takes a thing and returns true if the type contains it
    contains = Boolean << Self * Any
    --Takes a type and returns true if all the instances of that type are contained in itself
    superset = Boolean << Self * Type
}
```
That is to say "Type" is anything for which these two things are defined.
Types are first class and are only named by the variable they are stored in.

This is not truly how it is implemented due to the circularity but it is helpful to think of it as such.

# 2. Predefined Types
Some types are provided by the library. These include Lua's base types, and the types which form the logical
core of the type system
## Primitive Types
Type name       Type contains
 * Functor:     anything that can be called
 * Boolean:     true or false, strict
 * Falsy:       nil and false
 * Truthy:      anything that's not nil or false
 * Booly:       anything
 * Integer:     any whole number
 * Number:      any number
 * String       any string
 * Nil          only the value nil
 * Top          anything
 * Bottom       will never evaluate
 * Lambda       a bare lua function
 * Table        a dictionary from any key to any value
## Compound Types
Type name       Type contains
 * Type         all tables which have the methods contains and superset defined.
 * Union        all types which contain something is one of a few types
 * Tuple        all types which contain a flat lua argument list or a flat lua return list.
 * Dictionary   all types which contain a mapping from a key of one type to a value of another type
 * FunctionType all types which contain a wrapped piece of code which maps a parameter tuple of one type to a return tuple of another type
 * Interface    all types which contain a way of restricting table access to a limited view, erroring if you attempt to access it incorrectly.
# 3. Type constructors
Type constructors are ways of building new types. 

These are designed to look sort of like keywords, but they cleverly use some of Lua's features to hide the fact
that they are either functions or tables. You, of course, don't need to know any of this. The following type constructors
exist

Type constructor    Type                                        Description
* newtype           Type << Lambda[String] * -Lambda[String]    Manually construct a new type
* union             Union << Type...                            Construct a union
* tuple             Tuple << Type...                            Construct a tuple
* interface         Interface << Type[String]                   Construct an interface
* dictionary        Dictionary << Type * Type                   Construct a dictionary
## Newtype
You can construct a new Type manually using the "newtype" function. You must at minimum provide
contains and superset methods, but may also provide a tostring method. If you don't provide
a tostring method it will display "AnAnonymousType"

Here is an example of newtype being used
```
NewType = newtype {
    contains = function(self, instance)
        return Table:contains(instance) and Number:contains(instance.value)
    end;
    superset = function(self, othertype)
        return othertype == self or othertype == Bottom
    end;
    tostring = function(self)
        return "NewType"
    end;
}
```
Optionally, you may provide a list of operators to overload, in which case you must invoke
newtype like an ordinary function. Give the method table first, followed by the operator
overload table:
```
NewType = newtype (
    {
        contains = function(self, instance)
            return Table:contains(instance) and Number:contains(instance.value)
        end;
        superset = function(self, othertype)
            return othertype == self or othertype == Bottom
        end;
        tostring = function(self)
            return "NewType"
        end;
    },
    {
        __exp = function(self, othertype)
            return othertype
        end
    }
)
```
## Union types
Sometimes you may want a variable to contain one of several types. To do this you can
create a union type:

union (T1, T2, T3, ..., TN)

The following operators on types are available for interacting with unions:

Union construction:
T1 + T2 == union(T1, T2)
Optional construction:
-T  == union(T, Nil)

A union type is a superset of all it's composite types. If you would like to discriminate on
this you can use the typecase function:
```
typecase (value) {
    [T1] = function()
    end;
    [T2] = function()
    end;
    [T3] = function()
    end;
    ...
    [TN] = function()
    end;
}
```
Cases are checked in smallest type order. i.e. if you would like to provide a default, you may use
Top anywhere in the typecase and it will be run last. Only one case will run.
```
typecase (value) {
    [T1] = function()
        return "t1"
    end;
    [Top] = function()
        return "default"
    end;
}
```
typecase returns whatever the case that is run returns.
## Tuple Types
Lua tuples are akin to an unpacked list in Python. They are fairly ephemeral and used in the following
contexts:
1. Multiple function parameters form a tuple
2. The "..." operator forms a tuple
3. Multiple return values form a tuple
4. The comma operator in assignment forms a tuple

In the type system a Tuple represents a strong typing on all of these, but in practice will
only really be useful for 1-3.

You can construct a tuple type with
```
T1ToTN = tuple(T1,T2, ..., TN)
--which has syntactic sugar of the form
T1ToTN = T1 * T2 * ... * TN
```
For example
```
NumberPair = Number * Number
```
The contains method on tuple types accepts multiple arguments. One for each part of the tuple.
```
NumberPair:contains(4,3)
```

A tuple A is a superset of another tuple B if every type in A is a superset of the corresponding
type in B.
```
NumberPair:superset(Number * Integer)
```
## Function types
Function types restrict the type of a wrapped function's return values and arguments.
While this can't be guaranteed when the function is bound from within the language,
the function's parameters and return types will be checked every time a wrapped function is called.
```
FTypeName = func (ReturnType, ArgumentType)
```
e.g.
DoSomethingWithInt = func(Nil,Integer)
NumberOperator     = func(Number, Number * Number)
Action             = func(Nil, Nil)

You wrap a lua function in a FunctionType by applying it to the FunctionType, i.e.
```
restrictedPow = NumberOperator(
    function(n1, n2)
        return n1 ^ n2
    end
)
```

at which point calls to restrictedPow will stop you from calling it with anything
other than Numbers:

restrictedPow(4,5) is fine
restrictedPow(4,"string") will error

Types have a syntactic sugar to generate functions

ReturnType << ParamType

These can of course be any compound type on either side:
Return1 * Return2 << (Param1 + Param2) * -Param3

To construct a method, simply make the first parameter "Any"
ReturnType << Any * Param1 * Param2

If you're creating new functions you may write the function type and function expression
in the same line like so:
```
restrictedMultiply = (Number << Number * Number)(
    function(a, b)
        return a * b
    end
)
```
## Interfaces
Interfaces are a way of creating views. A view can only be accessed publicly in a manner
consistent with the interface they were created with. Attempting to read or assign to a field
to the view that isn't explicitly listed in the interface will cause an error. Attempting to write
to a field with the wrong type according to the interface also causes an error.

When a method is called on a view with the : operator a weak view is passed as the "self" parameter.
The weak view permits you to assign and read untyped properties freely from within itself. This allows
for private variables for instance.
```
IName = interface {
    --A mapping from strings to types
}
```
To construct a view you apply an interface to a table like so:
```
IValue = interface {
    value = Number
}
aTable = {value = 4, value2 = "hi"}
valueInstance = IValue(aTable)
--will succeed
valueInstance.value = 3
--will error: invalid type
valueInstance.value = "hi"
--will error: does not exist in interface
valueInstance.value2 = 4
--This does not restrict your ability to mutate aTable at all however:
aTable.value2 = 4
```
### Intersection of interfaces
Interfaces may be combined to create new interfaces with lua's concatenation operator, i.e.
```
I3 = I1 .. I2
```
I1 and I2 are both supersets of I3

The interface returned by this contains every constraint in both interfaces. If a constraint
exists in both then the union of the two are taken.
for example
```
I1 = interface {
    value1 = Number;
    value2 = String;
}
I2 = interface {
    value2 = Boolean;
    value3 = Integer;
}
I1 .. I2 == interface {
    value1 = Number;
    value2 = String + Boolean;
    value3 = Integer;
}
```
# Possible extensions
## Self type
Effectively a cyclical type for interfaces to make defining methods easier.
```
IThing = interface {
    AMethod = Nil << Self * Number * Boolean;
}
--would effectively turn into
IThing = interface {
    AMethod = Nil << IThing * Number * Boolean;
}
--assuming it were allowed.
```
Without it we have to resort to
IThing = interface {
    AMethod = Any * Number * Boolean
}
## Classes
The initial idea of this project included classes which specify all their publicly accessible members as a single (possibly compound) interface, possibly with some form of nice syntax for contain-and-delegate. For example
```
IJumper = interface {
    Jump = Nil << Self;
}
IRunner = interface {
    Run = Nil << Self;
}
IUpdatable = interface {
    Update = Nil << Self;
}
local MyClass = class (IRunner .. IJumper .. IDeveloper) {
    init = function(self)
    end;
    Jump = function(self)
        self.speedY = self.speedY + 30;
    end;
    Update = function(self)
        self.speedY = self.speedY - 4
        self.positionX = self.positionX + self.speedX
        self.positionY = self.positionY + self.speedY
    end;
    Run = function(self)
        self.speedX = 30;
    end;
    --this is private and untyped as it's not declared in any of the interfaces
    speedX = 0;
    speedY = 0;
    positionX = 0;
    positionY = 0;
}
```

