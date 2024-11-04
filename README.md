# sqit.lua
SQIT = **S**uper **Q**uick **I**nterface **T**oolkit

a simple and versatile UI-oriented object system

# Documentation

## Importing

download the file `sqit.lua` into your project folder, then in your program, require it with

```lua
sqit = require "sqit"
```

## Creating an instance:

```lua
ui = sqit()
```

or
 ```lua
ui = sqit.new()
```

## Adding/removing elements:
```lua
ui.add(element [, name])
```
optionally assigns a name by which the element can be retrieved from the instance (if there was previously an element registered under the same name, it will be overwritten!), can also be used to assign name to an already added element

```lua
ui.remove(element|name)
```
remove an element either by its object or by its name

> chaining: ui.add(e1).add(e2).remove(e3) ...

## Element properties:

```lua
x: number, y: number, w: number, h: number
```
the position (top-left) and size of the bounding box of the element, unless a custom checking function is implemented (if unspecified, the element will not respond to presses)

```lua
z: number
```
sorting order priority (`0` if left unspecified)

## Element callbacks:
```lua
element:check(x, y)
```
checking function for custom element shapes, should return `true` if the point x, y is inside of the element's hitbox, false otherwise

> the default function checks for a rectangle with its top-left at `(e.x, e.y)` and a size of `(e.w, e.h)`

```lua
element:pressed(x, y)
```
called when the element's press is initiated (if this function returns `false`, the press will be cancelled and passed to the next `z` layer)

```lua
element:moved(x, y, dx, dy)
```
called when the element's press moves (if this function returns a boolean value, as long as it is `true` the element will remain pressed even if the press exits the bounding area)

```lua
element:released(x, y)
```
called when the element's press is released

```lua
element:cancelled()
```
called when the element's press is cancelled (not released properly)

```lua
element:scrolled(t)
```
called when the mouse wheel is moved over the element

```lua
element:activated()
```
called when the element is activated

```lua
element:deactivated()
```
called when the element is deactivated or a new element is activated

```lua
element:hovered()
```
called when the cursor enters this element's bounding box (if this function returns `false`, the hover will be cancelled and passed to the next `z` layer)

```lua
element:unhovered()
```
called when the cursor exits this element's bounding box

```lua
element:enabled()
```
called right after this object (or the entire instance) is enabled

```lua
element:disabled()
```
called right before this object (or the entire instance) is disabled

### LÖVE callbacks

| callback |
| :---: |
| *all elements* |
| `resize` |
| *enabled elements* |
| `update` |
| `draw` |
| `quit` |
| *active element* |
| `keypressed` |
| `keyreleased` |
| `textinput` |
| `filedropped` |
| `directorydropped` |
| `joystickadded` |
| `joystickremoved` |
| `joystickaxis` |
| `joystickhat` |
| `joystickpressed` |
| `joystickreleased` |
| `gamepadaxis` |
| `gamepadpressed` |
| `gamepadreleased` |

> _**all callbacks are called with a semicolon**_

## Instance callbacks:

for a list refer to the table above

> called from within the respective LÖVE callbacks

> all input callbacks return `true` if the instance responded to the input, which can be used for blocking the inputs:
```lua
function love.keypressed(key)
  if instance.keypressed(key) then
    return
  end

  ...
end
```

you can add additional code to be run on the instance before the element callbacks are invoked, by assigning a function to the respective key

```lua
function instance:callback(...)
  ...
end
```

if this function returns `false`, the callback will be aborted and element callbacks will not be invoked

> these functions can be accessed via the `instance.callbacks` table

## Instance methods:

> all elements can be specified by their object or by their registered name

```lua
instance.registerCallbacks()
```
automatically register all instance callbacks

```lua
instance.contains(element|name, ...)
```
check whether the instance contains the element(s)

```lua
instance.hasNamed(name)
```
check if the insance has an element registered under this name

```lua
instance.getNamed(name)
```
retrieve the element registered under this name

```lua
instance.activate(element|name)
```
activate an element within the instance

```lua
instance.deactivate(element|name)
```
deactivate an element (or the currently active element)

```lua
instance.isActive(element|name)
```
check whether an element is active

```lua
instance.getActive()
```
get the currently active element

```lua
instance.isPressed(element|name)
```
check whether an element is currently pressed

```lua
instance.getPress(element|name)
```
get the element's press identificator

```lua
instance.getPressID(element|name)
```
if the element is pressed with a touch, retrieve the touch's ID

```lua
instance.getPressButton(element|name)
```
if the element is pressed with the mouse, retrieve the mouse button

```lua
instance.getPressPosition(element|name)
```
get the position of the element's press

```lua
instance.cancelPress(element|name)
```
cancel the element's press (without properly releasing it)

```lua
instance.transferPress(element|name, element|name)
```
cancel both elements' current presses, then press the second element with the first element's press

```lua
instance.getHovered()
```
get the currently hovered element

```lua
instance.isHovered(element|name)
```
check whether the element is currently hovered

```lua
instance.refreshHover()
```
recalculates mouse hover (called automatically in `instance.update`, if not using this callback it should be called when a hoverable element's `z` value is changed, as the library can't automatically detect this)

```lua
instance.setEnabled(state)
```
changes the enabled state of the instance (when disabled, the element or instance won't register any callbacks apart from `resize`)

```lua
instance.setEnabled(element|name, state)
```
changes the enabled state of an element

```lua
instance.isEnabled()
```
retrieves the enabled state of the instance

```lua
instance.isEnabled(element|name)
```
retrieves the enabled state of an element

```lua
instance.getElements(reverse)
```
get a list of all the elements in the instance, sorted from front to back by default (decreasing `z` values)

> instance functions can be called both normally and with semicolon

## Instance properties

```lua
instance.callbacks
```
the table containing extra callbacks
