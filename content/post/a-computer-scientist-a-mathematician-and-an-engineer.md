Date: 2007-11-10 18:44:00
Summary: Thoughts on Lua, simple features that gel well together.
Author: nathany

# A Computer Scientist, a Mathematician and an Engineer...

The **Lua programming language** was developed by [three members](http://www.lua.org/authors.html) of Tecgraf, the Computer Graphics Technology Group of PUC-Rio, a University in Rio de Janeiro. Not merely an academic pursuit, it was developed primarily as a replacement for SOL (meaning "sun") and DEL (data entry language) for Brazilian oil company Petrobras.

Lua was started in 1993, near the same time as Matz began working on Ruby. It was designed to be a small and efficient scripting language that could easily be embedded in C/C++ on practically any platform.

Aiming for **simplicity**, Lua implements a single collection type called `tables`. PHP also takes this approach, with Arrays that can act as hashes (associative arrays) and standard arrays.

Python uses its dictionaries (hashes) for namespaces and passing named parameters to functions. Lua does this and more, making extensive use of tables.

One of Lua's precepts is to _"provide mechanisms instead of policies."_ You won't find Ruby's emphasis on object-oriented programming in Lua, but it still is easy enough to _OOP_. In fact, Lua works somewhat like the prototype system in JavaScript.

First-class functions allow functions to be passed as arguments, stored in tables, and treated like any other value. Proper tail calls allow for recursion without stack overflows. Closures are a bit hard to explain without an example. You are free to make use of all these mechanisms, which originated in *functional programming*, a distinct discipline from the typical C-style of programming.

Lua isn't alone in mixing programming paradigms, but its overall simplicity as a language makes it a good place to *begin* computer programming.

In 1996, Lua found its way into _Dr. Dobb's Journal_ and from there into adventure game Grim Fandango and [many other games](http://www.lua.org/uses.html) since the 1999 Game Developers' Conference, including the ever-popular World of Warcraft.

Lua has grown in response to the demands of game programmers. It now posesses an **incremental** garbage collector to avoid long pauses. Coroutines provide programmers with **co-operative multitasking**. And Lua's virtual machine is register-based, making it one of the fastest interpreted languages available.

Due to a rather strict adherence to ANSI C, Lua doesn't run multi-core out of the box. But, by having a fully reentrant API, Lua can take advantage of your OS-dependent threading code. Lua `states` isolate each thread, so scripters don't need to concern themselves with the typical locking complexities of concurrency.

If you want to dig deep into Lua's history, take a look at [The Evolution of Lua](http://www.lua.org/doc/hopl.pdf) paper (26 pages), as was presented at the 2007 History of Programming Languages (HOPL) Conference. I will conclude with a quote from the paper:

>"_It is much easier to add features later than to remove them._ This development process has been essential to keep the language simple, and **simplicity is our most important asset**. Most other qualities of Lua &mdash; speed, small size, portability &mdash; derive from its simplicity."

And contrast it with a quote from Yukihiro "Matz" Matsumoto from _Beautiful Code_:

>"When simpler tools are used to solve a complex problem, complexity is merely shifted to the programmer, which is really putting the cart before the horse."

While there is validity to his statement, **the beauty of Lua** is how it manages to be a quite powerful language, despite its' simplicity.
