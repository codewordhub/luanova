+++
title = "Porting Lua to RISC OS"
date = "2010-03-03"
description = "..."
author = "wra1th"
+++

I do not expect many users of Lua will have heard of the
operating system known as RISC OS. They are more likely,
though, to have heard of the ARM processor architecture.
The [Wikipedia article](http://en.wikipedia.org/wiki/ARM_architecture) on the ARM
does not mention that the ARM CPU and RISC OS were
in fact originally created for each other by Acorn Computers
Ltd, in Cambridge (UK) in 1988. The article on
[RISC OS]( http://en.wikipedia.org/wiki/RISC_OS )
gives the full story.

RISC OS offers a very simple interface to user software, via
the ARM's SWI (SoftWare Interrupt) instruction. Data is passed
between the user's software and the operating system in ARM
registers; that data may consist of pointers to buffers in
memory that hold further data. RISC OS has always contained the
BBC BASIC programming language. This offers the user means
of accessing the operating system using:

* **DIM** -- to reserve a block of memory of a given size and pass
back its address;
* Indirection operators ! (for words), ? (for bytes) and $ (for strings);
* **SYS** -- to call an SWI with given values in the registers on entry
and variables to receive register values on exit;
* an inbuilt ARM assembler and a **CALL** command to link to assembled code.

With these facilities BBC BASIC is sufficiently powerful to enable
a user to control every aspect of her machine, if she is equipped
with the RISC OS PRMs (Programming Reference Manuals) -
these give details, for each of the modules constituting RISC OS, the
protocols and input/output details for each of the SWIs available,
and of the messages by which the kernel communicates with the modules.

Acorn Computers Ltd started out as manufacturers of laboratory equipment.
Their computers (with the exception of the RISCix work stations)
were always intended as single-user machines over which the user has
total control. Security? An irrelevance in those days. Just as
today's motorist almost certainly does not carry a set of tappet-calipers
in his hip-pocket and has never disassembled a carburettor on the
kitchen table, so modern computer-owners are unlikely to want to
know about SWIs or programming. But RISC OS developed in an era
when computers had only just become affordable, and there was a sizable
minority of people who wanted not just to do things with their
computer but to understand how it did them, and how they could control it.
In the end it was the association with education that did for Acorn
Computers Ltd and for RISC OS, after ARM Holdings Ltd had been split off.

Porting Unix or Windows software to RISC OS is fraught with problems.
RISC OS uses cooperative, not preemptive, multitasking. The RISC OS
filing system is fundamentally different, too, and not just
syntactically (a dot is the directory separator symbol). Filer objects
have a filetype attribute that is not part of the object's name.

RISC OS filing systems were designed on the supposition that they
were part of a graphical user interface - the GUI is not just
something tacked on later to a commandline interface. When a user
clicks on the icon of an object in a directory-window the window
manager broadcasts a message to all running tasks:

    An object at coordinates (x,y) with pathname obj_name and
    filetype obj_type has just been clicked on. Are any of you
    guys interested?

If a task is interested it sends back an acknowledgment (so that
the broadcast is aborted) and has its way with the object. If no
task replies, the taskmanager looks to see if a system command
(a sort of environment macro) **Alias$@RunType_xxx** has been defined,
where xxx are the hexadecimal digits of **obj_type**. If it has,
it is executed with **obj_name** as a commandline argument.
This command generally starts up a task and passes on its argument
to it. There is a special type for command files - known as
"obeyfiles". An obeyfile always "knows" where it is because the
operating system sets the variable **Obey$Dir** to the pathname of the
directory containing it when it is executed. Textfiles constitute
a special type. Holding down the SHIFT key when clicking a file
will always open it in a text editor (even if the user has not
installed a text editor - there is a basic multifile texteditor
incorporated in the OS, so fundamental is the role of editing
ASCII text - the same principle applies to graphics, both
bit-mapped and vector). Each type of object is displayed by
its own icon, apart from application directories.

RISC OS has two types of directory. There are ordinary directories,
and there are application directories.

- Click on the icon of an ordinary directory with the left mouse
 button and its window will open; with the right mouse button and
 the currently open directory window containing it will simultaneously
 close - this makes navigation and the avoidance of window clutter
 very simple and direct - no opening of menus needed.

- Application directories behave differently. Their appearance is
 governed by a file inside them called !Sprites - a bit-mapped graphics
 file. Click an application directory and the obeyfile !Run inside it
 will be executed. To open an application directory like an
 ordinary directory you must depress the SHIFT key when you click.

The point about application directories is that they can be treated
as a package. There is no such thing as installing or deinstalling
or registering an application. You simply load the application
directory to wherever you want in the filing system and it will
be launched when you click on it. To deinstall, simply delete it.
This independence of position is achieved by a file called !Boot
within an application. It is executed when the window manager is
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
immediate. I can switch on both my computers, one RISC OS, an Iyonix,
and the other Windows XP, an Advent 4211 notebook, at the
same time, and by the time the Advent is ready to use I have
read my emails, replied to them and switched off the Iyonix.

I mention all these details so that readers who are only familiar with
Windows or Unix will understand that there are other operating systems
which present a very different user experience. Many of the worries
and tools to deal with them (defragmenting the hard disc, installing
and removing packages, viruses, rootkits) that the Windows or Unix user
must take into consideration do not exist for the RISC OS user.
The other side of the coin is that RISC OS cannot deliver much that
is now taken for granted - its user base is too small to catch up.

As BASICs go, BBC BASIC is very good. There is a version for Windows,
I believe, with many improvements. It is almost unfair to call it
BASIC, because the facilities I cited above give it a whiff of
BCPL. Recall that BCPL was developed in Cambridge and was the grand-daddy
of C. BCPL was untyped. Although I am an admirer of BBC BASIC, I am not
blind to its limitations as a programming language. For a long time I
wondered if it were possible to have the best of both worlds:
something that incorporated the advances in programming language design
since 1964, BASIC's year of birth, and yet retained the integration
with the operating system and the ease of use which BBC BASIC can
boast. I spent many years on different attempts to realize this dream.
Then I came across Lua.

Lua is portable to any platform with an ANSI C compiler. Lua is a
modern phenomenon, if we take the development of C as the watershed
dividing ancient from modern. Lua is safe, and it can make no
assumptions about its host platform; it certainly cannot peek
or poke memory. RISC OS is unsafe, tied to the ARM architecture, and
uses memory references. It is written mostly in ARM assembler; it
conflates 32-bit integers with addresses, with file-handles,
task-handles, task-manager messages, ... . It is in some ways a
relic of the age before C. To marry Lua with RISC OS, to produce
what I called in an unimaginative moment, RiscLua, these contradictions
had to be squared.

The first problem is that ARM CPUs tend not to have floating-point
hardware. Continual conversion between doubles and 32-bit integers would
be a burden. This problem is solved by #defining LUA_NUMBER to int
and leaving out the math library. I also extended the Lua VM with bit
operations, putting them on an equal footing with the other arithmetic
operations. For those that have to use floating point numbers I
put in a library implementing doubles in the heap.

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
library containing **dim**, **sys**, **!**, **?** and **$** (these are allowable in variable
names in RiscLua). Where BBC BASIC might have **x!4** RiscLua can have **![x+4]**.
The symbols **!**,**?** and **$** in the riscos environment are just empty tables
with metamethods: **__index** peeks and **__newindex** pokes. The **sys** function
has one little twist that **SYS** does not have: a nil argument for a register
value means "use the value returned for that register by the previous
call to sys". This is useful because the register usage for SWI calls
in RISC OS has been carefully optimized to minimize shuffling data
between registers, something which can be exploited by this syntax.

There are a few other extensions: backslash is sugar for **function** and '=>' is sugar
for **return**.

<img src="http://mysite.mweb.co.za/residents/sdonovan/lua/untangle.png"/>

This is a
texteditor window displaying a short RiscLua script that uses Roberto's
lpeg library to run code enclosed in **&lt;lua&gt; ... &lt;/lua&gt;** tags (with the
remainder of the text taking the value "text"). The point of the picture
is the third icon with the green arrow pointing down.
If you shift-drag the icon of a scriptfile onto the green arrow of
a texteditor window, the script is run (with **arg[1]** holding the
name of a pseudofile containing the contents of the window) and the
contents of the window are replaced by the standard output of the
script. This provides the texteditor with a convenient facility -
any scripting language can be used so long as the texteditor has been
configured to understand the right command line syntax for it.
In this case, shift dragging "untangle" onto the green arrow of a
window containing "&lt;lua&gt;print(text:upper())&lt;/lua&gt;hello" would
convert its contents to "HELLO". Yes, I know it is contrived, but
I hope it shows the general principle.

<img src="/i/porting-lua-to-risc-os.png"/>

This shows the final dialogue box when the
following program is run.

{{< highlight lua >}}
-- Fred, tiny wimp program using error dialogue
require "wimp.task"
do
 local dim,! in riscos
 local buffer, wimp_msgs = dim(256), dim(4)
 local title$ = dim "Fred\r"
 local ask = "Count is %d. CANCEL to stop now?"
 local goodbye = "You reached %d. Goodbye."
 local flags = 23  -- for dialogue window
 ![wimp_msgs] = 0  -- no wimp messages
 fred = task.new(title$,wimp_msgs,buffer)   -- create task "fred"
 in fred do
  count = 0                      -- give it a counter
  handler[0] = \ (self)      -- give it a null-event handler
    count = count + 1
    local click = self:report(ask:format(count),flags)
    => (click ~= 1)          -- OK button to continue
  end -- handler
  preclosedown = \ (self)     -- give it a farewell action
     self:report(goodbye:format(count))
  end -- preclosedown
 end -- do
 fred:init()                   -- register it
 fred:run()                    -- run it
end -- do
{{< /highlight >}}

This is a toy example of a RiscLua wimp program. It puts up a
window with two buttons, CANCEL for stopping, OK for carrying
on, and it increments a counter showing the number of times OK is
clicked. I hope the program is not too opaque. Note the use of
Peter Shook's patch in **local dim,! in riscos** and the convenient
syntax provided by lexical environments in **in fred do ... end**.
The wimp.task library provides a single function **task.new** which
returns a table, with methods "init", "run", "preclosedown", etc
and a table, "handler" of event-handlers, indexed by the event-codes
sent by the taskmanager. Nothing much surprising about this
approach.

I will not pretend that RiscLua can do all the things that BBC BASIC
can do. It has no inbuilt ARM assembler, it does not have
extensive commands for sound or graphics. But there are things that
make RiscLua, for me, much more satisfying to use. It is more
expressive, more modular, more consistent and more concise. It
fulfils my quest, and still offers plenty of opportunities for
further development.

RiscLua and its sources are available at http://lua.riscos.org.uk/ .

[Gavin Wraith](http://www.wra1th.plus.com/)

