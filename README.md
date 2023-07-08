# ArgonWorks

ArgonWorks is the second iteration of a compiler and IDE for a language I have designed called Argon. The language has classes 
with multiple inheritance but methods are not bound to classes as in most OO languages, instead all methods are effectively generic 
or multimethods. Unlike traditional OO langauges where the dispatch of a method depends primarily on the class of the receiver, 
with multimethods the types of all the parameters and the return type of a method are used to dispatch a method, what this means in
real terms is that the compiler or runtime will find the most specific method available given the types of the parameters and the return 
type at a call site and then dispatch that most specific method. My algorithm for dispatch is less than elegant but I still need to do a 
lot of refinement. The IDE also sports type inference but my implementation is not quite correct yet. The IDE that I have developed here is 
experimental and modelled after Apple's Dylan IDE from a few years back. I always thought Dylan's IDE was a step in the right direction. 
I was initially going to emit bytecode from the compiler and then create a VM to execute the bytecode ala JVM, but I have decided to call it quits 
on the development of this second verison of ArgonWorks and I have created - from scratch - a new version 3 Argon IDE that is a bit more traditional 
in appearance than the previous one, I've also had the time to redesign my type system as well as my type inference engine in the Argon compiler. 
Version will not generate bytecode but makes use of LLVM 16.0 to generate native ARM or x86 executables. This codebase is left here purely for developers
to peruse if anyone even wants to.
