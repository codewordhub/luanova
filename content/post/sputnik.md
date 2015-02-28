+++
title = "Sputnik: An Introduction I"
date = "2009-11-11"
description = "..."
author = "stevejdonovan"
+++

## Beyond WikiWiki

[Sputnik](http://sputnik.freewisdom.org/) is a second-generation extensible wiki engine written in Lua. First generation wikis (like the original [WikiWIki](http://c2.com/cgi/wiki)) opened our eyes to the possibility of easy collaborative content generation, with automatic revision control.  However, anybody who has been involved with a Wiki knows that they are not self-organizing, and so behind any Wiki is a core of busy elves correcting and 'refactoring' content.  Plus, all content is usually in the form of marked-up text, plus uploaded binary data like images.  For instance,  Wiki pages often turn into discussions, but there is usually no way to structure these discussions and no support for creating them.

A second-generation wiki allows for 'virtual' pages, pages with explicit data fields, structured discussions, complete control of permissions, and namespace management.  The site designer can choose the right balance between freedom and structure that is appropriate for the community and its common purpose.

## Frameworks and Libraries

There are two basic approaches to software development; either start small, pulling as much functionality in using libraries, or to start with a framework, which does most of the job, and customize it to fit your functionality.  Frameworks have a bad [reputation](http://discuss.joelonsoftware.com/default.asp?joel.3.219431.12) because framework developers can get just a little mad in the process of writing them.  But if you want something that can do wiki-like things, manage the content and control the revisions, handle authentication, then it's time to get a Wiki framework, because these are not easy applications to get right. As the [Sputnik git page](http://gitorious.org/sputnik?page=4) says, "Sputnik provides a good foundation for anything that's kind of like a wiki but not quite."

It is true that the first trade-off is the freedom to do things _your_ way, since you must learn how the framework does things, and cooperate with it. In a way, it is like collaboration with another developer on a project which you have just joined.  I am assuming here that you want to get something done, which is not a million miles from a Wiki, and don't want to rewrite a whole bunch of wheels, just maybe update the hubcaps.  A better analogy would be this: if you want to equip a kitchen, then using a framework that includes the kitchen sink is appropriate (and not just a joke). Maybe you just want different fittings for your kitchen sink.

## Getting Sputnik

[Installing Sputnik](http://sputnik.freewisdom.org/en/Installation) is straightforward, providing you are on a Unix-like platform (like Linux or OS X) although it does also run on Windows.  In this introduction, I assume that it is an Unix environment (although out of convenience, not religious fervour; it is very easy to get a Linux virtual machine and set it up for Sputnik testing.)   After following instructions, you will have a Sputnik install in **~/sputnik**, no special permissions necessary.  Starting the webserver is then just:

{{< highlight bash >}}
~/sputnik$ ./bin/sputnik.lua start-xavante sputnik.ws
{{< /highlight >}}

Sputnik comes with the [Kepler stack](http://www.keplerproject.org), including the Lua webserver Xavante.  This is quite good enough for testing and experimentation.

A useful change is to first edit **sputnik.ws** and set **BASE_URL** to '/' and to add **SHOW_STACK_TRACE = true**. Sputnik will then give you Lua error traces when some hitch occurs. Then just open **http://localhost:8080** in your favourite browser and start playing. Create a special user **Admin** to view and edit the configuration nodes.

All Sputnik configuration is via nodes with Lua content. For instance, **sputnik/config**  assigns a set of fields to values. If you are editing this file (as Admin) and make a syntax error (such as **'Sputnik"**, mismatching string delimiters) the edit field will turn pink. **sputnik/navigation** controls the navigation bar menu:

{{< highlight lua >}}
NAVIGATION = {
   {id="index", title="Start",
     {id="snippets", title="Snippets"},
     {id="tags", title="Tags"},
     {id="sputnik",title="Configure"},
   },
   {id="News", title="Timeline",
     {id="News"},
     {id="Future Plans"},
     {id="history", title="Recent Wiki Edits"},
     {id="history/edits_by_recent_users", title="Edits by Recent Users"},
     {id="history.rss", title="RSS Feed"},
   },
}
{{< /highlight >}}

Creating a new node is easy; if you ask for a node **test** then it will tell you that this node does not exist, but then will give you several types to choose from.  The 'Basic' type is a plain Wiki page, and the link provided is something like **http://localhost:8080/?p=test.edit&prototype=**.  In general, a Sputnik request has a _node id_ ('test'), an _action_ ('edit') and _parameters_ ('prototype=')

If you click on this link you can edit your new Wiki node.  The markup used is [Markdown](http://daringfireball.net/projects/markdown/) which has a clean, readable syntax. In addition, Sputnik supports Wiki links; a link to your new page would be **[[test]]** and a link with some text would be **[[test|My First Page]]** . There is a convenient toolbar providing the most common operations when editing.

## Customizing Sputnik

A lot can be done with basic Sputnik, just by editing the configuration nodes.  (And, yes, the configuration nodes are Wiki nodes, so you can revert to an earlier version.)  Also, like any modern Web framework, style and functionality are kept separate as CSS and HTML; these [Sputnik sites](http://sputnik.freewisdom.org/en/Sightings) show that you can get just about any look and feel.

Since the configuration is done with Lua data, it _technically_ involves programming, but not in any serious sense of the word.  Lua is particularly well-suited to expressing configuration, since it was originally conceived as a data-description language.  This data is converted into Lua table structures using Lua itself, using a [sandbox](http://lua-users.org/wiki/SandBoxes) so that it will not execute any dangerous stuff.

The first 'real' customization we will do is make a whole set of pages default to a particular node type. That is, any node like **pages/GeneralInfo** or **pages/Introduction** will be created as 'Basic' nodes.

If Sputnik cannot find a node, it will first attempt to find a _node default_ with that name.  The request for 'pages' results in Sputnik attempting to load a Lua module like so: **require "sputnik.node_defaults.pages"**. So we have to create a file **pages.lua** in a directory so that Sputnik can resolve this module.

Sputnik itself is distributed as a [LuaRocks](www.luarocks.org ) application. In my system, the Sputnik package sits at **~/sputnik/rocks/sputnik/9.03.16-0/lua** - call this **$SPUTNIK**.  The relevant package directory structure is:

        sputnik
            actions
            hooks
            node_defaults
            ....

It _is_ possible to customize Sputnik by putting a suitable **pages.lua** in **$SPUTNIK/sputnik/node_defaults**, but that is a road of misery that will end in tears.  However, it's useful to acquaint yourself with the contents of this directory because it defines the standard namespaces.

The best quick solution is to add directories to the **LUA_PATH** environment variable before launching Sputnik:

{{< highlight bash >}}
~/sputnik$ export LUA_PATH=";;$HOME/sputnik/examples/?.lua"
{{< /highlight >}}

Then create a directory **~/sputnik/examples/sputnik/node_defaults** containing this file, **pages.lua**:

{{< highlight lua >}}
module(..., package.seeall)

NODE = {
   title="Pages",
   content = "",
   child_defaults = [[
        any='prototype = ""'
    ]],
}
{{< /highlight >}}

It is structured as a Lua module, which contains a single exported table, **NODE** .  The definition of the field **child_defaults** may appear a little hairy at first, but it's now time to get the three different ways to do string literals in Lua straight.  Whether you use single or double quotes for a string, does not matter; it is a convenience so that you can embed the other kind of quotes: **'prototype = ""'**. This string is then further embedded in a Lua 'long string' literal.

After restarting Sputnik, go to **pages**: nothing much to see at this point - but note that Sputnik can find the node. If you go to **pages/Introduction** you will get another blank page with a title, which you can edit directly as a Wiki page.  The **child_defaults** field tells Sputnik that any 'child' of **pages** like **pages/Introduction** has a particular prototype value which corresponds to the 'Basic' node type.

If you enter this text

        Some text for the Introduction node. See [[pages/Basic]]

and save, the result will have a link to a new page, which you can in turn edit.

To see how Sputnik saves pages by default, look at the **~/sputnik/wiki-data** directory. There will be a subdirectory **pages%2FIntroduction** with files **000001** and **index**. (The subdirectory is just the URL-encoded form of 'pages/Introduction' ).  **index** will contain something like this:

{{< highlight lua >}}
add_version{
version   = "000001",
timestamp = "2009-11-01 14:33:07",
author    = "",
comment   = "",
 ["minor"] = "",
 ["ip"] = "127.0.0.1",
}
{{< /highlight >}}

And **000001** contains the node text:

{{< highlight lua >}}
title          = "pages/Introduction"
category       = ""
content        = [=[Some text for the Introduction node. See [[pages/Basic]]

]=]
breadcrumb     = ""
{{< /highlight >}}

As the node is edited, each revision is saved in a similar format, **000002**, etc.  In this way, edit history is managed in a simple way, easily readable by humans, as opposed to being stored in some relational database. However, using a database for storage is also supported by the Sputnik content manager, which is called [Saci](http://sputnik.freewisdom.org/en/Saci).

## Custom Output

Before actually starting with code, it's useful to have a handy shortcut to the Lua executable used by Sputnik.  I suggest creating a little executable script like this on your path:

{{< highlight bash >}}
$> cat ~/bin/slua
~/sputnik/bin/lua -lluarocks.require $*
{{< /highlight >}}

Before we actually get round to generating dynamic content, here is a quick review of [Cosmo](http://cosmo.luaforge.net/),  which is a powerful template engine used by Sputnik.

{{< highlight bash >}}
~$ slua
{{< /highlight >}}

{{< highlight lua >}}
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> require "cosmo"
> template = "$rank of $suit"
> values = {rank="Ace",suit="Spades"}
> = cosmo.fill(template,values)
Ace of Spades
{{< /highlight >}}

That's useful, although only a little more friendly than Lua's **string.format** function.  However, Cosmo goes way beyond simple [string interpolation](http://lua-users.org/wiki/StringInterpolation).

{{< highlight lua >}}
-- testcosmo.lua
require "cosmo"
template = [==[
<h1>$list_name</h1>
<ul>
 $do_items[[<li>$item</li>]]
</ul>
]==]

print(cosmo.fill(template, {
    list_name = "My List",
    do_items  = function()
        for i=1,5 do
           cosmo.yield { item = i }
        end
    end
}
))
{{< /highlight >}}

{{< highlight bash >}}
~$ slua testcosmo.lua
{{< /highlight >}}

{{< highlight html >}}
<h1>My List</h1>
<ul>
  <li>1</li><li>2</li><li>3</li><li>4</li><li>5</li>
</ul>
{{< /highlight >}}

_Subtemplates_ are a powerful feature which makes generating HTML straightforward.

Now, we create a node which creates custom HTML output.  First, put **Memory.lua** in your  **node_defaults** directory:

{{< highlight lua >}}
module(..., package.seeall)

NODE = {
    title = "Lua Memory",
    content = "",
    actions = [[
        show="Memory.show_memory"
    ]],
}
{{< /highlight >}}

Create a directory **actions** (that is, **~/sputnik/examples/sputnik/actions**) and put this **Memory.lua** in it:

{{< highlight lua >}}
module(..., package.seeall)

actions = {}

local template = [=[
   <h2>Memory used by Lua is $mem kb</h2>
]=]

function actions.show_memory (node, request, sputnik)
    node.inner_html = cosmo.f(template) {
        mem = ('%6.0f'):format(collectgarbage('count')),
    }
    return node.wrappers.default(node, request, sputnik)
end
{{< /highlight >}}

The convention is that any _action_ functions are in the **actions** directory; these functions must be in a nested **actions** table.  Visiting the node **Memory** will show the memory managed by Lua (as returned by the **collectgarbage('count')** call).

The node's **inner_html** is the source for the node's display area, that is, not including the menu and all other frame decorations.  **node.wrappers.default** is the actual function which generates the source for the _whole_ page.

So, we now have a customized node with generated output.  Please note that it does not appear in **wiki-data**; the node is fully 'virtual' and has no storage associated with it.

To take this example further, let us wrap the output of the **ps** command:

{{< highlight bash >}}
~$ ps aux --cols 256
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
...
sdonovan  2867  0.8  2.3  41972 15932 pts/1    Sl   10:47   3:57 /home/sdonovan/lua/scite/SciTE
sdonovan  2902  1.2 12.4 179152 83160 ?        Sl   10:48   5:19 /usr/lib/iceweasel/firefox-bin -a firefox
sdonovan  5993  0.0  0.4   5360  2844 pts/2    Ss   16:13   0:00 bash
sdonovan  7118  0.0  0.3   5360  2024 pts/0    S+   18:03   0:00 bash
sdonovan  7119  0.4  1.1   8384  7380 pts/0    S+   18:03   0:01 /home/sdonovan/sputnik/bin/lua -lluarocks.require /home/sdonovan/sputnik/rocks/sputnik/9.03.16-0/bin/sputnik.lua start-xavante sputnik.ws
{{< /highlight >}}

(The **--cols** flag is necessary to prevent **ps** from thoughtfully truncating the line length to fit the terminal screen)

Chopping lines up is easy using **sputnik.util.split** - notice that it returns multiple values, not a table:

{{< highlight bash >}}
~$ slua
{{< /highlight >}}

{{< highlight lua >}}
Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
> util = require 'sputnik.util'
> = util.split('one two three','%s+')
one     two     three
{{< /highlight >}}

With this, a more exciting version of **actions/Memory.lua** can be written:

{{< highlight lua >}}
module(..., package.seeall)
local util = require 'sputnik.util'
actions = {}

local template = [=[
   <h2>Memory used by Lua is $mem kb</h2>
   <h2>Processes</h2>
   <table>
   <tr>
    <th>User</th><th>CPU</th><th>Mem</th><th>Command</th>
   </tr>
   $do_processes[[
        <tr>
        <td>$user</td><td>$cpu</td><td>$mem</td><td>$cmd</td>
        </tr>
   ]]
   </table>
]=]

function actions.show_memory (node, request, sputnik)
    node.inner_html = cosmo.f(template) {
        mem = ('%6.0f'):format(collectgarbage('count')),
        do_processes = function()
            local user = os.getenv 'USER'
            -- this works on LInux, may need some mods for BSD/OS X.
            local f = io.popen('ps --cols 256 aux','r')
            f:read() -- not interested in column headers
            for line in f:lines() do
                local fields = {util.split(line,'%s+')}
                if fields[1] == user then
                    cosmo.yield {
                        user = fields[1], cpu = fields[3], mem = fields[4], cmd = fields[11],
                    }
                end
            end
        end
    }
    return node.wrappers.default(node, request, sputnik)
end
{{< /highlight >}}

Now the node **Memory** is actually useful for the administrator of the website - but probably not a good idea to expose to the world!

## Permissions

The node **Memory** should be restricted; only the Admin user should be able to view it. Also, it does not make sense to edit it, even as an administrator.  **actions/Memory.lua** needs to have a _permissions_ field:

{{< highlight lua >}}
module(..., package.seeall)

NODE = {
    title = "Lua Memory",
    content = "",
    actions = [[
        show="Memory.show_memory"
    ]],
    permissions = [[
        deny(all_users,all_actions)
        allow(Admin,show)
    ]]
}
{{< /highlight >}}

We start by prohibiting _everything_, and then only let Admin view the page.  Notice that all of the usual little action icons on the right-hand side have disappeared.

To get back to the **pages** example; we may insist that only authenticated users can edit the pages.  There are two kinds of solution to this, make it site-wide policy or only for children of **pages**.  The first solution requires no code; as Admin, go to the **@Root** node, and choose the 'configure' action (which is usually the little gear icon next to 'edit' on the actions toolbar)  Now open the 'Advanced Fields' section, and you can then edit the 'Permissions' field.  By default, Sputnik comments out this line:

{{< highlight lua >}}
-- deny(Anonymous, edit_and_save)
{{< /highlight >}}

Remove the comment and save.  Now anonymous users have lost their power to make edits anywhere on the site.

We've already seen with **Memory** how to enforce permissions for a single node. But how to do this for a group of nodes?  Sputnik _prototypes_ provide the solution.  A prototype acts as the 'type' of a node. When a node is retrieved from storage, Sputnik copies default values from its prototype node.  The basic prototype of all nodes is **@Root**.

Previously, the **pages** node has insisted that its children have an 'empty' prototype.  The idea is to create an explicit prototype that will apply to the children, which will be called **@pages**. (By convention, all prototypes begin with '@')

**node_defaults/pages.lua** becomes:

{{< highlight lua >}}
module(..., package.seeall)

NODE = {
   title="Pages",
   content = "",
   child_defaults = [[
        any='prototype = "@pages"'
    ]]
}
{{< /highlight >}}

and create a new file **node_defaults/@pages.lua** to define the **@pages** prototype:

{{< highlight lua >}}
module(..., package.seeall)

NODE = {
   content = "",
   permissions=[[
        deny(Anonymous,edit_and_save)
   ]]
}
{{< /highlight >}}

It does very little, just explicitly overrides the permissions.

## Hooks

Continuing with the **pages** example, it would be useful if we could track the author of a particular page, defined simply as the user that first edited it.  Also, we would like to track the creation date.  So the prototype for all pages must include these new_fields and define a _save hook_ which will be called when the node is saved:

{{< highlight lua >}}
-- node_defaults/@pages.lua
module(..., package.seeall)

NODE = {
   content = "",
   permissions=[[
        deny(Anonymous,edit_and_save)
   ]],
   fields = [[
      author = {1.1}
      creation_time = {1.2}
  ]],
   save_hook = "pages.save_page"
}
{{< /highlight >}}

Create a directory 'sputnik/hooks' as before, and put **pages.lua** in it:

{{< highlight lua >}}
-- hooks/pages.lua
module(..., package.seeall)

function save_page(node, request, sputnik)
    if not node.creation_time then
       local params = {}
       params.author = request.user
       params.creation_time = tostring(os.time())
       node = sputnik:update_node_with_params(node, params)
    end
    return node
end
{{< /highlight >}}

When a node's **save_hook** field is set to **MODULE.FUNCTION** , then Sputnik will try to load **sputnik.hooks.MODULE** and use the **FUNCTION** defined by that module.  In this case, the save hook is only interested in a new node, where the author and creation time fields have not been assigned yet.  It uses the **update_node_with_params** method to write the new key/value pairs into the node.

Now, after saving **pages/fred**, the revision in the **pages%2Ffred** directory will look like this:

{{< highlight lua >}}
title          = "pages/fred"
category       = ""
prototype      = "@pages"
content        = [[Some content!
]]
breadcrumb     = ""
author         = "sdonovan"
creation_time  = "1257157113"
{{< /highlight >}}

This shows that we are saving the new information, although these fields are not displayed yet.

## Wrapping up

Currently, **pages** is blank, and like **Memory**  we can output something sensible by defining a 'show' action that will display a table of the existing pages.

If you are accustomed to regular Web frameworks, you are probably tempted to maintain and use a relational database at this point.  Sputnik does not exclude that, you are free to store things as you wish, but it's best to work with the underlying 'document-oriented' database machinery provided by Saci.

The existing pages can be found by querying Saci, which provides a **get_nodes_by_prefix** method. The prefix identifies the _namespace_ for the nodes, which is **pages** in this case. This method returns a table where the keys are the _identifiers_ (e.g. **pages/fred**) and the values are the node objects. Here is code that creates a list of nodes from this table, and sorts it by creation time.

{{< highlight lua >}}
local function pages_in_order (sputnik)
    local pages = sputnik.saci:get_nodes_by_prefix 'pages'
    local res = {}
    for id,page in pairs(pages) do
        res[#res+1] = page
    end
    table.sort(res,function(p1,p2) return p1.creation_time < p2.creation_time end)
    return res
end
{{< /highlight >}}

**node_defaults/pages.lua** gets an actions field, just as with **node_defaults/Memory.lua**:

{{< highlight lua >}}
actions=[[
    show="pages.show_pages"
]]
{{< /highlight >}}

And **actions/pages.lua** will be:

{{< highlight lua >}}
module (...,package.seeall)

actions = {}

local template = [=[
   <h2>Existing Pages</h2>
   <table>
   <tr>
    <th>Page</th><th>Author</th><th>Created</th>
   </tr>
   $do_pages[[
        <tr>
        <td><a href="?p=$id">$name</a></td><td>$author</td><td>$created</td>
        </tr>
   ]]
   </table>
]=]

local function pages_in_order(sputnik)
....
end

function actions.show_pages(node, request, sputnik)
    node.inner_html = cosmo.f(template) {
        do_pages = function()
            local pages = pages_in_order(sputnik)
            for _,page in ipairs(pages) do
                cosmo.yield{
                    id = page.id,
                    name = page.id:gsub('pages/',''),
                    author = page.author,
                    created = sputnik:format_time(page.creation_time,"%d %b %Y")
                }
            end
        end
    }
    return node.wrappers.default(node, request, sputnik)
end
{{< /highlight >}}

## Beyond the Basics

If you are curious about how Sputnik creates the whole page, note that **node.wrappers.default**
is usually implemented by the **wrappers.default** function in **sputnik/actions/wiki.lua** which does a Cosmo expansion of the **node.html_main** template (see **NODE.html_main** in **sputnik/node_defaults/@Root.lua**)

If you don't like a visual feature, then it is often easy to remove it.  For instance, editing **@Root** as Admin (using **@Root.configure** as before) you can open up the 'HTML Fields' and modify the templates directly. Removing the menu bar is as easy as clearing out the text in the 'Menu' field.

For a good overview of Sputnik permissions, see this [list question](http://sputnik.freewisdom.org/en/list/Way_to_lockdown_editing_features_) and its reply.

The next part of this tutorial will deal with further customizations, like internationalization, providing a custom form for editing a node's fields, and using the built-in **@Collection** prototype to simplify the common pattern of groups of content nodes.  And Sputnik's ability to create custom actions will change the way you look at file extensions forever.

