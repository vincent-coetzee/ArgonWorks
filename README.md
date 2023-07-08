# ArgonWorks

**ArgonWorks** is the second iteration of a compiler and IDE for a language I have designed called Argon. The language has classes 
with multiple inheritance but methods are not bound to classes as in most OO languages, instead all methods are effectively generic 
or *multimethods*. Unlike traditional OO langauges where the dispatch of a method depends primarily on the class of the receiver, 
with multimethods the types of all the parameters and the return type of a method are used to dispatch a method, what this means in
real terms is that the compiler or runtime will find the most specific method available given the types of the parameters and the return 
type at a call site and then dispatch that most specific method. My algorithm for dispatch is less than elegant but I still need to do a 
lot of refinement. 

The ArgonWorks IDE also sports type inference but my implementation is not quite correct yet. The IDE that I have developed here is 
experimental and modelled after Apple's Dylan IDE from a few years back. I always thought Dylan's IDE was a step in the right direction which
is why I elected to experiment with a radically different way of coding.

I was initially going to emit bytecode from the compiler and then create a VM to execute the bytecode ala JVM, but I have decided to call it quits 
on the development of this second verison of ArgonWorks and I have created - from scratch - a new version 3 Argon IDE that is a bit more traditional 
in appearance than the previous one. I've also had the time to redesign my type system and because I now understand clearly how types and type inference 
works I have been able to produce much better algorithms for the type inference and the management of types.

The new version of the Argon IDE will not generate bytecode but makes use of LLVM 16.0 to generate native ARM or x86 executables. 
This codebase is left here purely for anyone to peruse or use however they see fit.
