# Classes in WorldEngine

Classes in WorldEngine use the core `Object` library.

??? hint "Importing"
	Using Require
	```lua
	local Object = require(ReplicatedStorage.WorldEngine.Object)
	```
	
	Using Import
	```lua
	local Object = import "Object"
	```

# Class Creation
Creating a class in WorldEngine is simply the following:

```lua
local MyClass = Object:Extend("MyClass")

function MyClass:constructor()
end
```
This is similar to the [Roact](https://github.com/Roblox/roact) syntax for classes.

An object of `MyClass` then can be created via `#!lua MyClass.new()`

!!! info "Object Creation"
	Calling `.new()` will pass any arguments to `:constructor()`, you can then assign properties using `self` in `constructor`.


## Example class
```lua
-- The import library is the easiest way to import multiple files
local import = require(game:GetService("ReplicatedStorage")
	:WaitForChild("WorldEngine")
	:WaitForChild("Import"))

local Object = import "Object"
local t = import "t" -- type check

local MyClass = Object:Extend("MyClass")
function MyClass:constructor(name)
	assert(t.string(name)) -- enforce name = typeof string
	self._name = name
end

function MyClass:GetName()
	return self._name
end

local myObject = MyClass.new("Bob")
print(myObject:GetName()) -- will print "Bob"

return MyClass
```

You can also extend other objects like such (presuming `MyClass` is in the same directory as `MySubClass`)

```lua
local import = require(game:GetService("ReplicatedStorage")
	:WaitForChild("WorldEngine")
	:WaitForChild("Import"))

local t = import "t"
local MyClass = import "../MyClass"

local MySubClass = MyClass:Extend("MySubClass")
function MySubClass:constructor(name, age)
	MyClass:super(self, name) -- This will call the parent constructor

	assert(t.number(age))
	self._age = age
end

function MySubClass:GetAge()
	return self._age
end

local mySubObject = MySubClass.new("David", 20)
print(mySubObject:GetName(), mySubObject:GetAge()) -- will print David 20

return MySubClass
```

# Class Modifiers
The `Extend` method of Objects also has a second parameter, which is the `modifiers` parameter. Below are a list of those parameters.

## Abstract
Sometimes you don't want a base class to be createable, which is easy.

```lua
local MyClass = Object:Extend("MyClass", {abstract = true})
function MyClass:constructor()
	-- ...
end

-- The following will error, you have to create a sub class!
local myObject = MyObject.new()
```

## Sealed
Sometimes you don't want your class to be able to be extended. This is where `Sealed` comes in handy.

```lua
local MyClass = Object:Extend("MyClass", {sealed = true})
function MyClass:constructor()
	-- ...
end

-- The following will error, sealed classes can't be inherited!
local MySubClass = MyClass:Extend("MySubClass")
```