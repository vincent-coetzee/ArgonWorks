# TheArgonLanguage

Argon is an OO language that works on the basis of slots. Every place that can store a value is a slot. That means objects have slots, that allow you to store values in the object, 
modules have slots and you can attach slots to modules in order to store values in a module. Similarly classes themselves have slots and values can be stored in those slots as well
It's important to note that the slots in an object are unique per instance which means if you store a value in an object's slots the slot is attached to that instance of the object. 
Slots that are stored in classes on the other, of necessity, are specific to the class and not to instances of the class. Slots that are local to a method are called strangely enough
local slots. A local slot is created using the LET keyword and thereafter can be accessed merely by referencing it. So far we have encountered

1. Local Slots - defined in emthods
2. Instance Slots - defined in classes
3. Module Slots - defined in modules
4. Class slots - defined in classes

there are also a few other kinds of slots but they don't concern us directly, we will encounter them later. Apart from local slots, slots are never accessed directly, we access
class slots, instance slots and module slots using getter and setter method. There are implicitly created, two methods associated with each slot, a method of the form

METHOD slotName(object::Object Type) -> Slot Type

and a method of the form

METHOD slotName(object::Object Type,value::Slot Type)

these methods are a getter and a setter respectively.

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
