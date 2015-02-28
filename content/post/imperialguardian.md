+++
title = "Guardian of the Imperial Inkstand"
date = "2010-01-22"
description = "..."
author = "wra1th"
+++

_Some experiences of using Lua to create and maintain websites
for other people_.

Making a website just for yourself is one matter; doing it for others
brings into play a range of quite separate considerations, that affect
even the technical matters of design and implementation. You are the
pig in the middle, the bacon in the sandwich, sitting between the site
on one side and its commissioners on the other. I am a slow learner, but
after a dozen years of experience of different commissions I have come to
some definite general conclusions.

First, even for modest websites, plenty of time is needed for preparation,
before you even start thinking about design or implementation; time for
establishing a proper protocol between yourself and those who have
commissioned you. Ensure that all communications between yourself and them
pass through a single intermediary, a spokesperson who can shield you from
the disagreements and internal rivalries into which it may be fatal to be
drawn. Your commissioners may well have a committee charged with
responsibility for the proposed website, and it will probably delegate its
duties to a number of people: Mr X the timetable, Miss Y the graphics,
Dr Z the document archive, ... . Fine. Nice to know you, Mr X, Miss Y,
Dr Z, ...
Have nothing to do with these arrangements. Insist that they all communicate
only through the spokesperson. The spokesperson will have to channel
information in both directions. That way, with any luck, you will not
have to explain more than a dozen times why web pages look different in
different browsers, and why enormous TIFF files intended for high quality
printing are not appropriate for graphics on web pages, because they
will take rather a long time to download.

To be realistic, it is too much to expect the more important members
of the website committee to stick to this regime. In any case, out
of friendliness they may want to express themselves personally. It
is for that reason that I recommend that during the development phase
of the website each page should contain within its header the tags

{{< highlight html >}}
<meta  http-equiv="pragma" content="no-cache" />
<meta  http-equiv="cache-control" content="no-cache" />
{{< /highlight >}}

because otherwise you will have the committee chairman sending you
messages accusing you of not getting on with the job: "Hi Gavin,
Mr X says he sent you that stuff about emergency car-parking
three weeks ago and it still is not up on the website."; and then
you will have to explain to a deeply suspicious technophobe all about
how browsers cache webpages and that he is still looking at the pages
that his browser cached three weeks ago, and no, you cannot tell him
how to clear the cache for himself because you do not know what operating
system or browser he is using ("operating system? what is that,
old boy?").

I struck an extraordinary glitch when I was making the [website](http://www.wra1th.plus.com/byzcong/ ) for the
twenty-first International Congress of Byzantine Studies, which took
place in London from 21 to 26 August 2006. It was a prestigious affair,
with the Prince of Wales as patron and a long list of eminent sponsoring
organizations. Clarence House had been persuaded to send me a facsimile
of a signed letter of welcome from HRH, in receipt of which I had to
sign an undertaking that I would not permit any improper use of it. I
put a link to it from the sponsors' page.

The organizing committee of the conference had obtained a lovely jpeg
from the British Museum, of a Byzantine wooden carving of an angel.
They used this to make a poster. I used a jpeg of that to make
the entry page of the site. Clicking on the angel was to bring one
to a page listing the sponsors, including HRH, and inviting the viewer
to choose either the English or the French version of the website.
In my innocence, I called the page "sponsor.html". When it was up for
review by the organizing committee I began to get puzzled queries from
them. "I clicked on the angel, and nothing happened", about half of them
reported. I had no problem, nor did the other half. It was very mysterious.
Eventually research showed the culprit to be an arrogant piece of Norton
AntiVirus software running on the computers of some committee members.
It had decided that "sponsor" was obscene or dangerous, apparently.
Thus was HRH's letter censored by Norton. In the end I changed the file's
name to "spons.html" and the problem went away. The moral, I suppose,
is that you have to fathom some pretty sick minds if your webpages
are to be viewable by the public.

It is time to turn from the human to the coding side of things. I have
always believed that the best principle is to keep all as simple as
possible. As none of my sites have been designed for huge traffic I have
always shunned client-side scripting. It is usually unnecessary. One
should also keep in mind that many users may not have the latest browser.
In any case, adoption of WAI (the [Web Accessibility Initiative](http://www.w3.org/WAI/ ) ) is
mandatory for .gov.uk websites, and it makes sense for any site
that is to be used by the public, especially an academic public
that is not likely to have the latest hardware.

I always create my websites on my own machine. I generally divide
the directory for website-creation into two subdirectories: "site",
to contain all the stuff to be uploaded to the server, and "data"
to hold the gubbins from which the website is to be created, usually
as a "make" project. The contents of the webpages I classify into
three groups:

1. **furniture** - the graphics and css stuff that determine a common theme;
2. **permanent content** - usually text;
3. **formatted mutable data** - usually held as a textual database, as lists of labelled records, for ease of updating with a text editor.

I use Lua format for the databases and Lua scripts to input from the
data-directory and output the finished pages to the site-directory.
To begin with, for the Art Historians' Millennium bash, I used a Lua
program, called Weave, which I had developed for creating web pages.
Over time I improved it by generalizing to the production of any
sort of marked-up text. Eventually it simply got replaced by a Lua
library. I must make another blog about this, because Lua's way
with strings was a key factor in the design of this software.
I also produced a Lua program, Infuse, to perform the abstract
task of pouring content into template files - a sort of mail-merge.
It was the actual experience of coping with the commissioned websites
that drove me to keep reinventing. The frustrating thing was that I
dared not change over to a newer regime until the project was completed.
By starting sufficiently early I could create my templates for
the approval of the commissioners, before the flood of content
hit me. It was important to have a design sufficiently flexible to
cope with sudden changes of tack. The Lua format for labelled
records was good in this respect, because extra fields could always
be added. By contrast, CSV format would have been hopeless.

Lua's extreme portability was handy. My own machine ran neither
Windows, Linux nor MacOS. Yet when I did a website for an artist,
whose agent needed to take over the running of it, even though the
agent used Windows, there was no problem getting everything working
on his machine.

For the Byzantine Congress I was told that I had been appointed
&#7952;&#960;&#8054; &#964;&#959;&#8160; &#954;&#945;&#957;&#953;&#954;&#955;&#949;&#8055;&#959;&#965; ,
guardian of the imperial inkstand, so named because it was in the shape
of a little dog (canicula). To find out more about this prestigious
office, use Google.

[Gavin Wraith](http://www.wra1th.plus.com/)

## Ropes are better than Strings: A Technical Appendix

In Lua strings are immutable values. This means that you
should avoid building up strings out of small pieces,
because although they will eventually be garbage-collected,
all the intermediate stages of your construction will still be
there taking up storage. Building up a string of n characters
by consecutive concatenations will use a number of bytes
varying quadratically with n. So concatenations are something
to be avoided. What about the construction of web pages,
where markup and text must be intertwined? Surely that will
involve lots of concatenations?

Actually, no - it need not. Whether we think of an html document
as text with markup inserted, or whether we think of it as a
structure of nested tag-pairs with text inserted, either way we
are led to the concept of strings-with-holes. To be more formal
we define the datatype of "ropes" recursively by:

    rope = string | list of rope

In Lua syntax, a rope either looks like

{{< highlight lua >}}
[[ ..... ]]
{{< /highlight >}}

or like

{{< highlight lua >}}
{ ........ }
{{< /highlight >}}

where the contents of the braces are a comma separated list of
ropes.

Put another way, a rope is a tree whose leaves are strings. We
can think of it as a string that has been broken apart leaving gaps.
If we walk over a rope, depth first, printing out the leaves to a file,
then we can construct our marked-up text without doing any
string-concatenation at all.

So this code

{{< highlight html >}}
<a href="http://luanova.org/">LuaNova</a>
{{< /highlight >}}

can be obtained by printing out the rope

{{< highlight lua >}}
{
{
[[<a ]],
{
 [[href="]],
 [[http://luanova.org/]],
 [["]],
},
[[>]],
},
[[LuaNova]],
[[</a>]],
}
{{< /highlight >}}

If we define

{{< highlight lua >}}
link = function (url)
      return function (label)
              return {
{
[[<a ]],
{
 [[href="]],
 url,
 [["]],
},
[[>]],
},
label,
[[</a>]],
} end end
{{< /highlight >}}

then our rope is just the value of

{{< /highlight >}}
link "http://luanova.org/" "LuaNova"
{{< /highlight >}}

There are two sorts of markup: "monotags" and "tags".

By a monotag I mean something like

    <tag_name attr />

and we can implement this as a function from ropes to ropes:

{{< highlight lua >}}
function(attr) return {"<tag_name ",attr," />"} end
{{< /highlight >}}

By a tag I mean something like

    <tag_id attr>stuff</tag_id>

which we can implement as a function from ropes to functions from
ropes to ropes:

{{< highlight lua >}}
function(attr)
return function(stuff) return
       {"<tag_id ",attr,">",stuff,"</tag_id>"}
       end
end
{{< /highlight >}}

To simplify construction of webpages I invented a little language,
which I called _Weave_, as a fragment of Lua using strings and ropes
and named functions for the tags and monotags of HTML (see [Lua technical
note 30](http://www.lua.org/notes/ltn010a.html) .)
After a while I broadened Weave's abilities
so that it could cope with any sort of markup and no longer had
HTML's tags and monotags built in. I introduced empty tables called
"TAG" and "MONOTAG" with metatables, so that using the __index key
I could define tag and monotag functions with notations like
"TAG.a" and "MONOTAG.img" and so on. This was more flexible, but it
did mean that the user had to define her own tags before building
a webpage. That did not matter, because by then CSS had appeared and
most webpages needed only a handful of tags and monotags. Eventually
I did away with Weave as a separate entity and simply used the Lua
module "xhtml" instead.

To create a very trivial webpage "foo.html" in the current directory,
run a Lua script as follows:

{{< highlight lua >}}
#! lua
require "xhtml"
do
local mydoc = BEGIN "foo.html"
local hstyle = [[style="text-align: centre;"]]
local myheader, link = xhtml.TAG.h1, xhtml.link
mydoc.BODY = {
             myheader (hstyle) "Try this";
             link "http://luanova.org/" "Lua Nova";
            }
END(mydoc) -- write the rope out to file
end -- do
{{< /highlight >}}

OK, this takes almost as long as creating the webpage by hand, for
this trivial example. But it should not take too much imagination
to see the possibilities. Practically every webpage I have created
for the last ten years has used this method.


Here are the relevant modules:

**weave.lua**

{{< highlight lua >}}
--[[
 The rope datatype is defined recursively:

 data rope = string | list of rope.

Use:  status,err = rope.walk(rope,function)
     print(table.concat(err,"."))
Error message prints out index at each level.
]]
local pcall = pcall
local type = type
local ipairs = ipairs
local tostring = tostring
local assert = assert
local setmetatable = setmetatable
local open = io.open

module "weave"

-- ropes -------

local t_err = "<bad type: %s>"
local a_err = "<bad arg: %s>"

walk = function(x,f)  -- apply f to leaves of tree x, depth first
  local g
  g = function(x,e) -- e = error stack
     local x_type, status = type(x)
     if x_type == "string" then
      status = pcall(f,x)
      if not status then e[1+#e] = a_err:format(x) end -- if
          return status,e
      elseif x_type == "table" then
          e[1+#e] = ""
          for i,y in ipairs(x) do
            e[#e] = tostring(i)
            status = g(y,e)
            if not status then return nil,e end -- if
          end -- for
          e[#e] = nil
          return true
        else
          e[1+#e] = t_err:format(x_type)
          return nil,e
        end -- if
      end -- function
      return g(x,{})
end

local file_err = "cannot open %s"
out = function(x,file)
     local o = assert(open(file,"w"),file_err:format(file))
     local f = function(s)
               o:write(s or "")
               return true
               end -- function
     local status,err = walk(x,f)
     o:close()
     return status,err
     end -- function

------ markup stuff --------------
--[[
Two types of tag:

 monotag    <foo attributestring />
 tag    <foo attributestring> rope </foo>

where attributestring could be empty.
 ]]

local monotagger = {
__index = function (_,tag)
         assert(type(tag) == "string")
         return function (attr)
                local o = {"<",tag}
                if attr and (#attr > 0) then
                  o[1+#o] = " "
                  o[1+#o] = attr
                end -- if
                o[1+#o] = " />"
                return o
                end -- function
          end -- function
         }

local bitagger = {
__index = function (_,tag)
         assert(type(tag) == "string")
         return function (attr)
                return function (rope)
                 local o = {"<",tag}
                 if attr and (#attr > 0) then
                  o[1+#o] = " "
                  o[1+#o] = attr
                 end -- if
                 o[1+#o] = ">"
                 o[1+#o] = rope
                 o[1+#o] = "</"
                 o[1+#o] = tag
                 o[1+#o] = ">"
                 return o
          end end end
          }
MONOTAG, TAG = {},{}
setmetatable(MONOTAG,monotagger)
setmetatable(TAG,bitagger)
{{< /highlight >}}

 **xhtml.lua**

{{< highlight lua >}}
--[[ The xhtml library exports

 TAG, MONOTAG, BEGIN, END, TEXT, SPACE, REM and link

]]


require "weave"

local assert = assert
local type = type
local pairs = pairs
local print = print
local this = arg[0]
local leaf = this:match("\\([^\\]*)$")
local weave = weave
local walk = weave.walk
local out = weave.out

local concat = table.concat

module "xhtml"

MONOTAG = weave.MONOTAG
TAG = weave.TAG

local doctype = [[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">]]

local HTML = TAG.html [[
xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"]]

local nl = "\n"

BEGIN = function(filename)
       if filename then
         assert(type(filename) == "string","BEGIN takes a string or nil")
       end -- if
       return { FILE = filename or this..".html"; }
       end

local META,LINK = MONOTAG.meta,MONOTAG.link
local HEAD,BODY,TITLE = TAG.head "",TAG.body,TAG.title ""
local css = [[rel="stylesheet" type="text/css" media="screen" href=""]]

END = function(rope)
     local file = rope.FILE
     local style = rope.STYLE
     local doc = {
      rope.DOCTYPE or doctype;
      nl;
      HTML {
       nl;
       HEAD {
        nl;
        TITLE (rope.TITLE or leaf);
        nl;
        META [[name="Generator" content="Lua"]];
        nl;
        META [[name="MSSmartTagsPreventParsing" content="TRUE"]];
        nl;
        rope.HEAD or "";
        style and LINK {css;style;'"'} or "";
            };
        nl;
        BODY (rope.ATTR or "") (rope.BODY or "");
        nl;
          };
                  }
      status, err = out(doc,file)
      if not status then print(concat(err,'.')) end -- if
      end --function

local entity = {
 ["<"] = "&lt;",
 [">"] = "&gt;",
 ["&&"] = "&amp;",
              }
local catchall = "(.)"
local entify = function (c)
              local n,fmts = c:byte(),"&#%s;"
              return (n > 127) and fmts:format(n) or c
              end -- function

TEXT = function(rope)
      local o = {}
      local f = function(s)
          local status = type(s) == "string"
          if status then
            for symb,ent in pairs(entity) do
              s = s:gsub(symb,ent)
            end -- for
            s = s:gsub(catchall,entify)
            o[1+#o] = s
          end -- if
           return status
         end -- function
      walk(rope,f)
      return o
      end -- function

SPACE = function(n)
       assert(type(n) == "number","SPACE takes a number")
       local s = "&nbsp;"
       return s:rep(n)
       end -- function

REM = function(s) return { "\n<!-- ";s;" -->\n"; } end -- function
link = function(url) return TAG.a { 'href="'; url; '"'; } end -- function
{{< /highlight >}}
