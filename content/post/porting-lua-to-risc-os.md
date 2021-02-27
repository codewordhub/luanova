+++
title = "Porting Lua to RISC OS"
date = "2010-03-03"
revised = "2015-03-06"
author = "wra1th"
+++

RISC OS is euphemistically called a minority operating system.
The fact that it has become [available on the Raspberry Pi](http://www.raspberrypi.org/downloads/) has probably brought
it slightly more publicity. The [Wikipedia article on the ARM](http://en.wikipedia.org/wiki/ARM_architecture) does not mention that the ARM cpu and RISC OS were in fact originally created for each other by Acorn Computers
Ltd, in Cambridge (UK) in 1988. The [Wikipedia article on RISC OS](http://en.wikipedia.org/wiki/RISC_OS) tells the story.

RISC OS consists of a small kernel together with Relocatable
Modules, which implement the means by which the user, or
the user's software, can interact with the computer. The user is
free to substitute modules with her own, even those that are
held in ROM. RISC OS offers a very simple interface to user 
software, via the ARM's SWI (SoftWare Interrupt) instruction. 
Data are passed between the user's software and the operating 
system in ARM registers; the data may consist of pointers to 
buffers in memory that hold further data. 

RISC OS has always incorporated the BBC BASIC programming language. 
This offers access to the operating system with:

1. DIM -- reserve a block of memory of a given size and pass
back its address;

2. Indirection operators `!` (for words), `?` (for bytes) and `$` (for strings);

3. SYS -- call an SWI, with given values in the registers on entry
and variables to receive register values on exit;

4. an inbuilt ARM assembler and a CALL command to link to assembled code.

With these facilities BBC BASIC is sufficiently powerful to enable
a user to control almost every aspect of the machine; presuming that 
she has a copy of the RISC OS PRMs (Programming Reference Manuals)
to consult. These give details, for each of the modules constituting 
RISC OS, the entry/exit protocols for each of the SWIs available, 
and of the messages by which the kernel communicates with the modules.

Acorn Computers Ltd started out as manufacturers of laboratory 
equipment. Their computers (with the exception of the RISCix work 
stations) were always intended as single-user machines over which 
the user had total control. Security? An irrelevance in those days. 
Just as today's motorist almost certainly does not carry a set of 
tappet-gauges in his hip-pocket and has never disassembled a 
carburettor on the kitchen table, so a modern computer-owner is 
unlikely to want to know about SWIs or programming. But RISC OS 
developed in an era when computers had only just become affordable.
There was a sizable minority of people which wanted not just to do 
things with the computer but to understand how it did them. 
In the end it was the association with education that did for Acorn
Computers Ltd and for RISC OS, after ARM Holdings Ltd had been split 
off.

Porting Unix or Windows software to RISC OS is fraught with problems.
RISC OS uses cooperative, not preemptive, multitasking. The RISC OS
filing system is fundamentally different, too, and not just
syntactically (a dot is the directory separator symbol). Filer objects
have a filetype attribute that is not part of the object's name.

RISC OS filing systems were designed on the supposition that they
were part of a graphical user interface - the GUI is not just
something bolted on later to a commandline interface. When a user
clicks on the icon of an object in a directory-window the window
manager broadcasts a message to all running tasks:

>"An object at coordinates (x,y) with pathname obj_name and
 filetype obj_type has just been clicked on. Are any of you
 guys interested?".

If a task is interested it sends back an acknowledgment (so that
the broadcast is aborted) and has its way with the object. If no
task replies, the taskmanager looks to see if a system command
(a sort of environment macro) `Alias$@RunType_xxx` has been defined,
where xxx are the hexadecimal digits of obj_type. If it has,
it is executed with obj_name as a commandline argument.
This command generally starts up a task and passes on its 
arguments to it. There is a special type for command files - 
known as "obeyfiles". An obeyfile always "knows" where it is 
because the operating system sets the variable Obey$Dir to the 
pathname of the directory containing it when it is executed. 
Textfiles constitute a special type. Holding down the SHIFT key 
when clicking a file will always open it in a text editor (even 
if the user has not installed a text editor - there is a basic 
multifile texteditor incorporated in the OS, so fundamental is 
the role of editing ASCII text - the same principle applies to 
graphics, both bit-mapped and vector). Each type of object is 
displayed by its own icon, apart from application directories.

RISC OS has two types of directory. There are ordinary directories,
and there are application directories.

 Click on the icon of an ordinary directory with the left mouse
 button and its window will open; with the right mouse button and
 the currently open directory window containing it will simultaneously
 close - this makes navigation and the avoidance of window clutter
 very simple and direct - no opening of menus needed.

 Application directories behave differently. Their appearance is
 governed by a file inside them called !Sprites - a bit-mapped graphics
 file. Click an application directory and the obeyfile !Run inside it
 will be executed. To open an application directory like an
 ordinary directory you must depress the SHIFT key when you click.

The point about application directories is that they can be treated
as packages. There is no such thing as installing or deinstalling
or registering an application. You simply load the application
directory to wherever you want it to be in the filing system and it 
will be launched when you click on it. To deinstall, simply delete it.
This independence of position is achieved by a file called !Boot
within the application. It is executed when the window manager is
first made aware of the application's existence by the opening of
the window of the directory containing it; this action can be
suppressed by holding down the CTRL key when opening a directory
window. The !Boot file will define system variables and macros
which will inform user software about where the application
is, and anything else they need to know of it. Alternatively the
user can "filer_boot" and "filer_run" applications from obeyfiles
that are inserted into the boot sequence. This is done by loading the
obeyfiles into appropriate places in the directory !Boot that must
reside at the top level of any RISC OS filing system. Only the !Boot
directory is off-limits for the user's personal whims (though even
that is highly customizable). In other words, the filing system is
not a thing of labyrinthine complexity that belongs to the manufacturer
or to tradition. It belongs to the user. This is made possible by the
relocatability of applications.

In the RISC OS GUI, the window on top of the window stack is not
necessarily the window with the input focus. I often find myself
inputting text even though the window containing it is partially
obscured by another window that I need to be reading at the same time,
to compose my input. If I drag a window with the left-hand button
it will come to the top of the window stack, and so be dragged over
any other windows. If I drag with the right-hand button it will retain
its position in the window stack, and so be dragged behind some
windows and over others. The single most exasperating and thoughtless
aspect in Microsoft Windows, to my mind, is the way windows leap to
the top, obscuring what you need to be reading. Real desktops do not
behave in this way, unless somebody has left the door open and there
is a gale blowing through. It is a small detail, but a crucial one.
I have not sufficient experience to know which Linux window managers,
if any, get this right.

Of course, applications in read-only filing systems may need to
rent space for their configuration files on another, writable filing
system. RISC OS is usually held in ROM, so startup and switchoff are
immediate. I can switch on both my computers, one RISC OS, a
Raspberry Pi and the other Windows XP, an Advent 4211 notebook, at the
same time, and by the time the Advent is ready to use I have
read my emails, replied to them and switched off the Raspberry Pi.

I mention all these details so that readers who are only familiar with
Windows or Unix will understand that there are other operating systems
which present a very different user experience. Many of the worries,
and tools to deal with them (defragmenting the hard disc, installing
and removing packages, viruses, rootkits), that the Windows or Unix user
must take into consideration do not exist for the RISC OS user.
The other side of the coin is that RISC OS cannot deliver much that
is now taken for granted - its user base is too small to catch up.

As BASICs go, BBC BASIC is very good. There is a version for Windows,
I believe, with many improvements. It is almost unfair to call it
BASIC, because the facilities I cited above give it a whiff of
BCPL. Recall that BCPL was developed in Cambridge and was the 
grand-daddy of C. BCPL was untyped. Although I am an admirer of BBC 
BASIC, I am not blind to its limitations as a programming language. 
For a long time I wondered if it were possible to have the best of 
both worlds: something that incorporated the advances in programming 
language design that have evolved since 1964, BASIC's year of birth, 
and yet retained the integration with the operating system and the 
ease of use which BBC BASIC can boast. I spent many years on different 
attempts to realize this dream. Then I came across Lua.

Lua is portable to any platform with an ANSI C compiler. Lua is a
modern phenomenon, if we take the development of C as the watershed
dividing ancient from modern. Lua is safe, and makes no
assumptions about its host platform; it certainly cannot peek
or poke memory. RISC OS is unsafe, tied to the ARM architecture, and
uses memory references. It is written mostly in ARM assembler; it
conflates 32-bit integers with addresses, with file-handles,
task-handles, task-manager messages, ... . It is in some ways a
relic of the age before C. To marry Lua with RISC OS, to produce
what I called in an unimaginative moment, RiscLua, these contradictions
had to be squared.

The first problem was that most of the ARM cpus on which, until recently,
RISC OS was implemented, do not have floating-point hardware. Continual 
conversion between doubles and 32-bit integers would be a burden. This 
problem is solved by #defining LUA_NUMBER to int and leaving out the 
math library. I also extended the Lua virtual machine with bit
operations, putting them on an equal footing with the other arithmetic
operations. For those that needed big numbers and decimal points I
incorporated Luiz Henrique Figueiredo's adaptation of Philip A. Nelson's 
GNU bc library.

To integrate Lua with RISC OS, something along the lines of BBC BASIC's
DIM,!,?,$ and SYS was needed. To begin with I used userdata for holding
the values of addresses. Then I could reserve blocks of garbage-collectible
memory, and I could check that references were within set bounds. One
downside was that the error-checking slowed things down. Much worse was
the problem of how to convert the data returned in a register from an
SWI call. To what sort of Lua value should it be converted? An integer,
a userdatum holding an address, a file-handle, a string, .... ? Eventually
I realised that this problem had no universal solution. The only answer
was to play as dirty as BBC BASIC; to abandon userdata and simply conflate
integers with addresses. This made RiscLua less safe, but faster,
and allowed a syntax for indirection that was very close to that
of BBC BASIC - an advantage for users more accustomed to BBC BASIC
than to anything else. The latest versions of RiscLua have a riscos
library containing dim, sys, !, ? and $ (these are allowable in variable
names in RiscLua). Where BBC BASIC might have x!4 RiscLua can have ![x+4].
The symbols !,? and $ in the riscos environment are just empty tables
with metamethods: __index peeks and __newindex pokes. The sys function
has one little twist that SYS does not have: a nil argument for a register
value means "use the value returned for that register by the previous
call to sys". This is useful because the register usage for SWI calls
in RISC OS has been carefully optimized to minimize shuffling data
between registers, something which can be exploited by this syntax.

There are some syntactic idiosyncracies of RiscLua. A backslash is sugar
for "function" and "=>" is sugar for "return". Also, after "local", Peter 
Shook's idea of unpacking tables by name is adopted.

![](/images/untangle.png)

This is a texteditor window displaying a short RiscLua script that uses 
Roberto's lpeg library to run code enclosed in <lua></lua> tags (with the 
remainder of the text taking the value "text"). The point of the picture is 
the third icon with the green arrow pointing down. If you shift-drag the icon 
of a scriptfile onto the green arrow of a texteditor window, the script is 
run; arg[1] holds the name of a pseudofile containing the contents of 
the window and the standard output of the script becomes the new content. 
This provides the texteditor with a convenient facility - any scripting language 
can be used if the texteditor has been configured appropriately. In this case, 
shift dragging "untangle" onto the green arrow of a window containing: 

    <lua>print(text:upper())</lua>hello 

would convert its contents to "HELLO". Yes, it is contrived, but I hope it 
shows the general principle.

![](/images/screen.png)

This shows the final dialogue box when the following program is run.

![](/images/fred.png)

This is a toy example of a RiscLua wimp program. It puts up a window with 
two buttons, CANCEL for stopping, OK for carrying on, and it increments a 
counter showing the number of times OK is clicked. I hope the program is 
not too opaque. The wimp.task library provides a function "task" that takes 
a string and returns a wimp task in the form of a table, called here "fred". 
A wimp task is essentially defined by its handlers, a table indexed by
the events passed back by the task manager of functions with a single argument,
the task itself. A handler returning a non-nil value causes the task
to close down, possibly first calling the special preclosedown handler.
Lua's local environments are very convenient in this context.

I will not pretend that RiscLua can do all the things that BBC BASIC
can do. It has no inbuilt ARM assembler, it does not have
extensive commands for sound or graphics. But there are things that
make RiscLua, for me, much more satisfying to use. It is more
expressive, more modular, more consistent and more concise. It
fulfils my quest, and still offers plenty of opportunities for
further development.

RiscLua and its sources are available at http://lua.riscos.org.uk/ .
