+++
title = "iOS Programming with Lua"
date = "2010-09-23"
author = "mathewburke"
+++

### Matthew Burke, Bluedino Software

In this article I will discuss three methods for using Lua to build iOS apps.  The techniques range from using Lua to build the entire application (<a href="#corona">Corona</a>) to using Lua as a component for scripting your application (<a href="#diy">do it yourself</a> or <a href="#wax">Wax</a>).  Before getting into the details, there are two main questions to answer:

1. Why use Lua?
2. Will Apple let you use Lua?

The answers to these questions are intertwined.

In case you landed here without knowing anything about Lua, let me hit the high points of the language.  If you already are familiar with Lua, you can <a href="#iphone-script">skip ahead</a>.

### About Lua

<a href="http://www.lua.org">Lua</a> is a fast, lightweight, embedded scripting language.  It is similar to languages such as JavaScript, Ruby or Python.  Many of its users, including myself, feel Lua is a particularly clean and elegant language.

Lua was created in 1993 by Roberto Ierusalimschy, Waldemar Celes and Luiz Henrique de Figueiredo at the Pontifical Catholic University in Rio de Janeiro, Brazil.  It is used in a range of applications including <a href="http://micasaverde.com/">Mi Casa Verde</a>, <a href="http://since1968.com/article/190/mark-hamburg-interview-adobe-photoshop-lightroom-part-2-of-2">Adobe Lightroom</a>, <a href="http://www.shatters.net/celestia/">Celestia</a>, <a href="http://www.lighttpd.net/">lighttpd</a>, <a href="http://www.luatex.org/">LuaTeX</a>, <a href="http://nmap.org/">nmap</a>, <a href="http://www.wireshark.org/">Wireshark</a>, Cisco's Adaptive Security Appliance, <a href="http://www.hempeldesigngroup.com/lego/pbLua/">pbLua</a>, and a ton of games including <a href="http://en.wikipedia.org/wiki/Grim_Fandango">Grim Fandango</a>, <a href="http://en.wikipedia.org/wiki/World_of_Warcraft">World of Warcraft</a>, <a href="http://en.wikipedia.org/wiki/Tap_Tap_Revenge">Tap Tap Revenge</a>, and many others.  <a href="http://www.lua.org/license.html">Lua's license</a> is a variation of the MIT License&mdash;this means that there are essentially no hurdles to including Lua in both commerical and non-commerical projects.

Lua's main data structuring mechanism is the table&mdash;a combination resizable array and hash.  Listing 1 shows a table we might use in a hypothetical application to keep track of automobiles and their gas mileage.  We can store information about the automobile using string keys such as <strong>license</strong> and <strong>make</strong>.  A series of mileage readings are stored using integer indices.

<div class="panelHeader">Listing 1: A Lua Table</div>

{{< highlight lua >}}
car_data = { license = 'XVW1942', make = 'Volvo',
                model = 'XC70', 30, 31.3, 32.4, 34.0 }

print(car_data[1])                -- 30
print(car_data['license'])       -- XVW1942
print(car_data.license)          -- XVW1942 (also!)
{{< /highlight >}}

<div class="panelFooter">In Lua, array indices start at one, not zero.
Comments are indicated by '--' and run to the end of the line.
</div>

Out of the box, Lua is neither an object-oriented (OO) programming language nor a functional programming language.  Rather, it provides a small set of mechanisms with which you can build your own higher-level features.  A number of different object systems have been built in Lua including more traditional OO systems as well as classless OO systems (<em>&agrave; la</em> languages like <a href="http://research.sun.com/self/language.html">Self</a> or <a href="http://www.iolanguage.com/">Io</a>).  Lua supports first-class functions and lexical closures and has a meta-programming facility (known as metatables and metamethods).  Lua can be used in a functional programming style

For a gentle introduction to OO in Lua, read <a href="http://www.lua.org/pil/16.html">Programming in Lua</a> (<span class="tiny">in fact, PIL is a very well-written book on Lua in particular and programming in general</span>).  You should also look at the several examples available on <a href="http://lua-users.org/wiki/ObjectOrientedProgramming">Lua wiki</a>.

If you <em>like</em> drinking from a firehose, Listing 2 shows one possible implementation for a linked list class.  The table stored in the variable <strong>List</strong> serves as a metatable for all linked list objects.  It  provides a fall-back location for looking up table indexes and thus serves as a class dispatch mechanism.  The line "<strong>List.__index = List</strong>" is what allows us to create methods for our list objects.  Methods are implemented as functions stored in the <strong>List</strong> metatable.  When we attempt to call one of these functions on our list object, the lookup mechanism will lead us to the function defined on the <strong>List</strong> metatable and that's what will get run.

The code shows a number of additional features of Lua: multiple assignment (<span class="tiny">and functions can return multiple results</span>), syntactic sugar for method calls (the ':' notation, this performs the common technique&mdash;used in languages ranging from Python to Objective-C&mdash;of rewriting the function call to have an additional parameter which points to <strong>self</strong>).

<div class="panelHeader">Listing 2: Linked List Class</div>

{{< highlight lua >}}
List = {}
List.__index = List

function List:new()
  local l = { head = {}, tail = {}, size = 0 }
  l.head.__next, l.tail.__prev = l.tail, l.head
  return setmetatable(l, self)
end

function List:first()
  if self.size > 0 then
    return self.head.next
  else
    return nil
  end
end

function List:addFirst(elem)
   local node = { prev = self.head, value = elem,
                        next = self.head.next }
   node.next.prev = node
   self.head.next = node
   self.size = self.size + 1
end

mylist = List:new()
mylist:addFirst(12)
print(mylist:first())
{{< /highlight >}}

I'm sure I've left out the really interesting/important things (<span class="tiny">such as lexical closures</span>), but this at least gives you a little taste of Lua.  There are more samplings below when we get to actual iPhone coding.  For further details on Lua, see the <a href="">web site</a>.

<a name="iphone-script"></a>
### Can I Script on iOS?

Of the two questions listed at the beginning of this article, the most important question to address is are you allowed to use Lua (or any interpreted language) on the iPhone?  After all, early on the iPhone Developer Program License Agree stated that "[n]o interpreted code may be downloaded or used in an Application except for code that is interpreted and run by Apple's Documented APIs and built- in interpreter(s)."

In fact, an earlier version of this article was tabled when Apple made changes to the developer license  (circa April 2010) which forbade developing iOS applications in any language other than Objective-C and Javascript (<span class="tiny">the Javascript could be used either to build web apps or native apps via the UIWebView</span>).  Recently (September 2010), Apple again changed the developer license to allow the use of scripting languages..

There are still several important constraints in place.  In particluar, although you can use Lua and other scripting languages, you cannot create an application where users could download plugins for your app from your website (<span class="tiny">in-app purchasing anyone?</span>), nor can you allow the user to write scripts, download scripts, etc.  There are (<span class="tiny">and have been, e.g. Tap Tap Revenge</span>) quite a number of apps available on the app store that use Lua as well as other languages.

Of course, creating a plugin system and allowing users to write scripts are two major use cases for including a language like Lua in your application, so what's left?  Plenty!

### Why Use Lua for iOS development?

Although you cannot expose a plugin system to the end user, nor can you give her the ability to write her own scripts, you can still develop your system using a plugin architecture!  This can both speed up initial development as well as be a big help when it's time to add functionality for the next version.

There are other benefits from using Lua.  It allows you to develop using rapid prototyping (<span class="tiny">beware my pet peeve: don't devolve into seat-of-your-pants programming</span>), reduces/eliminates the need to worry about memory allocation, allows more of your team to participate in development (<span class="tiny">many Lua projects have non-programmers writing code</span>), makes it easier to <em>tune</em> your application, and provides a powerful persistence mechanism.

In short, using Lua can reduce development time and lower entry barriers. And it's just plain <em>fun</em>!

Assuming you're sold you on the idea of using Lua, how do we go about it?

<a name="corona"></a>
### Corona

Ansca Mobile's Corona allows you to develop your iOS app entirely in Lua.  And it's not just for iOS.  You can also develop apps for Android.  In fact, you can use the same source code to build both an iOS and an Android app.  This adds a compelling reason to use Lua (<span class="tiny">and, in particular, to use Corona</span>): the ability to easily build cross-platform applications.

Listing 3 is the complete source for an app.

<div class="panelHeader">Listing 3: main.lua from the Swirly Text app</div>

{{< highlight lua >}}
local w, h = display.stageWidth, display.stageHeight
local dx, dy, dtheta = 5, 5, 5


local background = display.newRect(0, 0, w, h)
background:setFillColor(255, 255, 255)


local message = display.newText('Hello from Corona', w/2, h/2)
message:setTextColor(0, 0, 200)


local function update(event)
   local counter_spin = false
   message:translate(dx, dy)
   message:rotate(dtheta)
   if message.x > w or message.x < 0 then
      dx = -1 * dx
      counter_spin = true
   end
   if message.y > h or message.y < 0 then
      dy = -1 * dy
      counter_spin = true
   end
   if counter_spin then
      dtheta = -1 * dtheta
   end
end


Runtime:addEventListener('enterFrame', update)
{{< /highlight >}}

Corona apps are developed using your favorite text editor&mdash;I use Emacs.  All Lua source code and any necessary resources (images, sounds, and data) must reside in a single directory and Corona expects a Lua file, <strong>main.lua</strong> which is where your app starts executing.  You test your code in Corona's simulator which runs on both Intel and PPC Macs.  Figure 1 shows my Corona 'IDE': namely Emacs with two windows (a Lua file and the project directory), the Corona terminal (you can print debugging info to the terminal), and the Corona simulator.

<div class="panelHeader">Figure 1: My Corona 'IDE'</div>

<a href="/images/corona-ide.png">
<img src="/images/corona-ide.png" width="760px" style="margin: 10px" /></a>

<div class="panelFooter">Clockwise from the left: Corona simulator, Emacs with two windows (a source file and project directory), the Corona terminal (for debugging info).</div>

When you are ready to run your app on actual hardware, you use the Corona Simulator's <strong>Open for Build</strong> option.  For an iOS build, you must have a provisioning profile (either development or distribution)&mdash;<span class="tiny">yes, Virginia, you do need a membership in the iOS Developer Program</span>&mdash;which is uploaded, along with your app's source and resources, to Ansca's servers.  A compiled app is returned to you. For Android builds, you will need a suitable signing certificate.  Again the build process is handled by uploading your source to Ansca's servers.  You do not need to have the Android SDK installed.

I haven't done any in-depth poking around, but both the .apk file from the Android build process and the iOS .app bundle contain a file containing all your Lua code pre-processed in some fashion.  Approximately seven seconds of examination suggests that it's not <em>standard</em> byte-compiled Lua code, but I'm guessing it must be a similar format.

Corona's event system lets you handle touches (<span class="tiny">including multi-touch</span>), access the GPS and the acceleratometer, handle animation, and define custom events.  There is a powerful graphics system which allows you to draw circles, rectangles and text.  They've recently added polylines so you can draw regular lines and polygons.  You can also display images.  Corona allows you to group these objects and do transformations on them.  Listing 4, an excerpt from a Solar System simulator, shows a (crude) example of grouping graphics objects.  Other Corona features include playing audio and video clips, a cryptography library, networking using the LuaSocket library, and access to SQLite databases (using LuaSQLite).  There is some access to native widgets including textfields, alerts and activity indicators. There's a nice feature where you can overlay a web view for doing things like login screens and a sample application provides a library for connecting to Facebook.  The last thing I'll mention is that there is a (more expensive) game edition that includes the Box2D physics engine, sprites and some OpenFeint functionality such as leaderboards.

<div class="panelHeader">Listing 4: excerpt from Solar System app</div>

{{< highlight lua >}}
function new(params)
   local color = params.color or planet_colors[random(#planet_colors)]
   local radius = params.radius or planetRadius()
   local planet = display.newGroup()

   planet.theta = 0
   local x = params.x - ox
   local y = params.y - oy
   planet.orbital_radius = sqrt(x*x+y*y)

   local body = display.newCircle(x + ox, y + oy, radius, radius)
   body:setFillColor(unpack(color))
   planet:insert(body, true)
   planet.body = body

   planet.delta_theta = (40/planet.orbital_radius) * 0.1

   return planet
end
{{< /highlight >}}

<div class="panelFooter">By passing a table as a function's paramter, we can make use of named
parameters and default values.  Thus, the idiom of local radius = params.radius or planetRadius()
</div>


Corona gives you a lot.  However, there are still a lot of things missing with Corona.  The biggest item is the limited access to native controls.  Not to mention the access that is provided is awkward to use because of limited support in Corona's simulator.  In the simulator, native alerts and activity indicators are implemented using OS X equivalents, rather than the iOS widgets.  However, text fields, text boxes and web popups are unusable when running in the simulator. This makes development, to say the least, painful.

Finally, there is no mechanism to access the Objective-C API except for what ANSCA has specifically provided.  Not only does this mean you cannot access large portions of the standard libraries, but you cannot make use of third-party libraries like Three20, or one of the mobile ads APIs.  Of course, with the release of the Android version of Corona, you may not want to access the Objective-C API since it limits (<span class="tiny">or complicates</span>) your ability to do multi-platform applications.  It would be nice, however, to be able to add in Lua extensions that use Lua's C API, as many of these are multi-platform.

I've found the ANSCA staff to be quite helpful and responsive to questions posted in the forums on their website.  With the release of version 2.0 (September 2010), Corona costs $249 per developer per year.  The Game Edition is $349 per developer per year.  Ansca's website indicates that the game edition prices is pre-release.  I assume that means it will be higher when it is officially released.

<a name="diy"></a>
### DIY

Including the Lua interpeter in your iOS app is simple. Open an Xcode project and add the Lua source files (<span class="tiny">except <strong>lua.c</strong> and <strong>luac.c</strong>&mdash;source for the command line programs</span>).  Compile.  You can now make use of the standard Lua C API to create an interpreter and run some code.  An example project, iLua, may be downloaded from <a href="http://github.com/profburke/ilua">http://github.com/profburke/ilua</a>.  iLuaShell is a simple, view-based application that presents the user with two text fields&mdash;an editable one where the user can enter Lua code and a non-editable one where the results of evaluating the Lua code are displayed.

The work is done in the method, <strong>evaluate</strong>, which is shown in Listing 5.  The method retrieves the text of the first text field, hands it off to the Lua interpreter which parses and executes it, and then sets the Lua output as the text of the output field.

<div class="panelHeader">Listing 5: LuaTrial's <strong>evaluate</strong> method.</div>

{{< highlight c >}}
-(void)evaluate {
    int err;

    [input resignFirstResponder];
    lua_settop(L, 0);

    err = luaL_loadstring(L, [input.text
                     cStringUsingEncoding:NSASCIIStringEncoding]);
    if (0 != err) {
        output.text = [NSString stringWithCString:lua_tostring(L, -1)
                             encoding:NSASCIIStringEncoding];
        lua_pop(L, 1);
        return;
    }

    err = lua_pcall(L, 0, LUA_MULTRET, 0);
    if (0 != err) {
        output.text = [NSString stringWithCString:lua_tostring(L, -1)
                             encoding:NSASCIIStringEncoding];
        lua_pop(L, 1);
        return;
    }
    int nresults = lua_gettop(L);

    if (0 == nresults) {
        output.text = @"<no results>";
    } else {
        NSString *outputNS = [NSString string];
        for (int i = nresults; i > 0; i--) {
            outputNS = [outputNS stringByAppendingFormat:@"%s ",
                                               lua_tostring(L, -1 * i)];
        }
        lua_pop(L, nresults);
        output.text = outputNS;
    }
}
{{< /highlight >}}

Note the error checking and handling is minimal.  A little additional effort could yield a nice Lua shell&mdash;not that you could actually put it in the App Store...

What are the drawbacks to this approach?  The biggest one is the lack of a bridge to Objective-C.  Ideally we want to call Objective-C methods from Lua. Going the other direction is important also.  Being able to code callbacks and delegate methods in Lua would be a big win.

Pursuing that leads us to...

<a name="wax"></a>
### iPhone Wax

Powerful interoperability between Lua and Objective-C is the star attraction of iOS Wax by Corey Johnson.  Using Wax, you can easily subclass Objective-C classes <em>in Lua</em>!  Listing 6 shows a Wax implementation of a custom view controller.  In particular, this code is a port of the application described in the DIY section.  Details after the listing.

<div class="panelHeader">Listing 6: RootViewController.lua</div>

{{< highlight lua >}}
waxClass{'RootViewController', UI.ViewController }

function init(self)
        self.super:init()

    self.input = UI.TextView:initWithFrame(CGRect(20, 20, 280, 114))

    self.output = UI.TextView:initWithFrame(CGRect(20, 184, 280, 225))

    local evalButton = UI.Button:buttonWithType(UIButtonTypeRoundedRect)
    evalButton:setTitle_forState('Evaluate', UIControlStateNormal)
    evalButton:setFrame(CGRect(200, 142, 100, 32))
    evalButton:addTarget_action_forControlEvents(self, 'eval:',
                            UIControlEventTouchUpInside)
    self.evalButton = evalButton

    self:view():addSubview(self.input)
    self:view():addSubview(self.output)
    self:view():addSubview(self.evalButton)

    return self
end

function eval(self, sender)
    self.input:resignFirstResponder()

    local code, errmsg = loadstring(self.input:text())
    if not code then
        self.output:setText(errmsg)
        return
    end

    local success, result = pcall(code)
    print('result is ' .. tostring(result))
    if not success then
        self.output:setText('Error: ' .. tostring(result))
    else
        self.output:setText(tostring(result))
    end

end
{{< /highlight >}}

The <strong>waxClass</strong> function essentially defines a new Objective-C class.  In this instance we are defining a class named <strong>RootViewController</strong> which is a sub-class of <strong>UIViewController</strong>.  (<span class="tiny">In Wax, the Objective-C classes have been put into namespaces, hence <strong>UI.ViewController</strong>, rather than <strong>UIViewController</strong></span>).  The Lua representation of instances of this class is a table (<span class="tiny">well, really a <strong>userdata</strong>, but you can think table...</span>), hence items like <strong>self.input</strong> are Lua table fields and <strong>not</strong> Objective-C properties.  To access properties you use setters and getters, e.g. <strong>self.output:setText()</strong>.  If you're like me, this will trip you up until you embarass yourself by asking about it in the <a href="http://groups.google.com/group/iphonewax">mailing list</a>.  Aftewards, you won't mix it up again. (<span class="tiny">Actually, the people on the mailing list are quite nice.</span>)

Wax classes can also implement protocols.  For instance, the Wax sample project, <strong>States</strong>, demonstrates handling a <strong>UITableView</strong> with two custom <strong>UITableViewController</strong> classes.  Each of which implement the <strong>UITableViewDelegate</strong> and <strong>UITableViewDataSource</strong> protocols.  Listing 7 is a minor variation on this theme and presents a class that implements the <strong>UITableViewDataSource</strong> protocol for a multi-section table.

<div class="panelHeader">Listing 7: SortedDataSource.lua</div>

{{< highlight lua >}}
waxClass{'SortedDataSource', NS.Object, protocols = {'UITableViewDataSource'}, }


function init(self, source_table)
    self.source_table = source_table
    return self
end


function numberOfSectionsInTableView(self, tableView)
    return #self.source_table.headers
end


function tableView_numberOfRowsInSection(self, tableView, section)
    local index = self.source_table.headers[section+1]
    return #self.source_table[index]
end


function tableView_cellForRowAtIndexPath(self, tableView, indexPath)
    local identifier = 'TableViewCell'
    local cell = tableView:dequeueReusableCellWithIdentifier(identifier)
    cell = cell or UI.TableViewCell:initWithStyle_reuseIdentifier(UITableViewCellStyleDefault,
                                                      identifier)

    local key = self.source_table.headers[indexPath:section()+1]
    local component = self.source_table[key]
    local player = component[indexPath:row()+1]
    cell:setText(player[1] .. ' ' .. player[2] .. ' ' .. player[3])

    return cell
end

function tableView_titleForHeaderInSection(self, tableView, section)
    return self.source_table.headers[section+1]
end
{{< /highlight >}}

<div class="panelFooter">
Note the <em>toll-free</em> conversion of Lua strings to Objective-C strings in functions such as <strong>tableView_titleForHeaderInSection</strong>.
</div>

The uniform naming scheme Wax uses allows you to easily predict the name to use for accessing an Objective-C function from Lua.  Wax comes with a TextMate bundle which makes it very easy to manipulate the Objective-C calls.  For example, you can paste method signatures copied from Xcode's documentation and have them automatically transformed into Lua calls. (<span class="tiny">I'm debating writing Emacs functions to do this or just drink the Kool-ade and start using TextMate.</span>)

Wax has a number of other goodies including extensions for working with SQLite, easy HTTP requests, XML and JSON handling, and working with Core Graphics transforms and gradients.  In addition, recent updates include the ability to write the App delegate in Lua (rather than having a small Objective-C implementation that launches Wax), and the ability to run tests from the command line (in a headless simulator).  Perhaps the most interesting (and powerful) new development is that Wax now provides an interactive console so you can telnet into the simulator (or a device!) and interact with a running application: tweak its parameters or inspect its current state.

Wax is open source and is also licensed with an MIT-style license.  The project is being actively developed and used by a number of developers.

### Summary

Lua-powered apps <em>are</em> available in the app store.  The Ansca forum for listing Corona apps has over 150 topics (<span class="tiny">I haven't read them all...they may not <strong>all</strong> announce new apps</span>).   Reading through the Wax mailing list, you'll see several developers announcing apps they've written using Wax, and there are likely to be many others who have not posted to the list.  And there are many apps that have taken the DIY approach.

Corona offers a very nice alternative for building iOS apps, but only if you don't need native UI elements.  It's great that they've added native text fields, but the fact that you can't see them in the simulator is a real show-stopper.  But throw its Android capabilities into the mix, and Corona is certainly worth considering.  I like using Corona and I hope/expect to see lots of improvements over time.  Just to weasel out of making an endorsement, I should add that although I have not had any major problems building apps with Corona, the dependency on Ansca and their servers to do builds is something you should seriously think about.

Of course the DIY approach is the complete opposite: you have total control.  But if you need a lot of interaction between your Lua code and your Objective-C code, doing the bindings can be a fair amount of effort.  Johnson's Wax does a fantastic job of bridging Lua and Objective-C.  Wax also plays well with Lua C libraries&mdash;something which Corona doesn't handle.

Although they may not go as far as we'd like, the recent changes to the iOS developer agreement mean that you can now use Lua in iOS development without the stress of worrying that you're setting youself up for app rejection.  I believe the range of techniques available for using Lua in your iOS project means that using Lua will often be a useful tool for successfully completing your iOS project.  Given the active communities surrounding Corona and Wax, as well as the ease of plotting your own course if you want more direct control of your use of Lua, I encourage you to take advantage of this gem of a language.


### References

* <a href="http://www.lua.org">Lua's Website</a> (<span class="tiny">http://www.lua.org</span>)</li>
* <a href="http://developer.anscamobile.com">Corona Developer Portal</a> (<span class="tiny">http://developer.anscamobile.com</span>)</li>
* <a href="http://github.com/probablycorey/wax/">Wax's Repository</a> (<span class="tiny">http://github.com/probablycorey/wax/</span>)</li>
* <a href="http://probablyinteractive.com/2009/10/19/How%20does%20iPhone%20Wax%20work.html">Wax Syntax Tips</a> (<span class="tiny">http://probablyinteractive.com/2009/10/19/How%20does%20iPhone%20Wax%20work.html</span>)</li>
* <a href="http://groups.google.com/group/iphonewax">http://groups.google.com/group/iphonewax</a></li>
