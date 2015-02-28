+++
title = "Launch: getting Lua installed"
date = "2007-11-10"
description = "Setting up Lua on Mac OS X."
author = "nathany"
+++

To play with Lua you need to download the source code and compile it. This isn't as scary as it sounds, as Lua is a positively _tiny_ download and doesn't depend on anything more than a C compiler. Lua is written in standard ANSI C, so any one should work. I will give instructions for **Mac OS X**, because that's what I use.

## Building

First, you need to have Apple's Developer Tools installed. They should be your Mac OS X disc, under Optional Installs -&gt; Xcode Tools. Run the XcodeTools package to install. You can also [download Xcode](http://developer.apple.com/tools/download/) if you sign up for a free ADC account (but note: they are large!).

Next, [download Lua source code](http://www.lua.org/download.html) and unpack the archive in Finder. Or you can use **Terminal** to download the current  release (5.1.2) to your Downloads folder (or a suitable location of your choice):

{{< highlight bash >}}
cd Downloads
curl -O http://www.lua.org/ftp/lua-5.1.2.tar.gz
tar xzvf lua-5.1.2.tar.gz
cd lua-5.1.2
{{< /highlight >}}

Either way, you need **Terminal** (from Application/Utilities) to do the rest. Make sure you are in the lua-5.1.2/ folder, and type:

{{< highlight bash >}}
make macosx
{{< /highlight >}}

Several lines should scroll by. On Leopard you will see some _deprecated_ warnings in loadlib.c. Don't worry about it. To make sure everything is okay, run:

{{< highlight bash >}}
make test
{{< /highlight >}}

You should see **"Hello world, from Lua 5.1!"**



## Installing

It is possible to run the Lua interpreter from right here, but let's install it the rest of the way. For this we will need to run "make install". By default Lua installs to /usr. This will work, but it's recommended to install under /usr/local.

So from the lua-5.1.2/ folder, run:

{{< highlight bash >}}
sudo make install INSTALL_TOP=/usr/local
{{< /highlight >}}

and provide your password.

It appears that Leopard ships with /usr/local/bin in your path. You can check by running: (make sure PATH is uppercase)

{{< highlight bash >}}
env | grep PATH
{{< /highlight >}}

If you don't see it there, you need to modify your .profile file.

{{< highlight bash >}}
pico ~/.profile
{{< /highlight >}}

and include:

{{< highlight bash >}}
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"
{{< /highlight >}}

If you are using [TextMate](http://macromates.com), and will be installing the Lua bundle later, you may also want to include:

{{< highlight bash >}}
export SVN_EDITOR="mate -w"
export LC_CTYPE=en_US.UTF-8
{{< /highlight >}}

With pico, press Ctrl-X followed by Y to exit and save.

The changes will take affect when you open a new Terminal window.

## Running

With Lua installed in your path, you can run it in Terminal from any folder. Just type:

{{< highlight bash >}}
lua
{{< /highlight >}}

This brings up the interactive interpreter. You can type in Lua code:

{{< highlight lua >}}
print "Hi"
= 2 + 3
{{< /highlight >}}

Press **Ctrl-C** to exit when you're done.

Now that Lua is installed, you _could_ remove the Downloads/lua-5.1.2 folder. But you may want to check out the test/ folder for some example code. You can run these examples from within the lua-5.1.2/test/ folder like this:

{{< highlight bash >}}
lua factorial.lua
{{< /highlight >}}

A local copy of the [Reference Manual](http://www.lua.org/manual/5.1/) can be found under doc/manual.html.


## TextMate

If you are using [TextMate](http://macromates.com/), there is a Lua bundle to give it color syntax highlighting and a few snippets. Unfortunately the Lua bundle isn't included by default. You can either use [GetBundle](http://projects.validcode.net/getbundle), or you can grab it with the command line as follows.

The bundles are stored in a Subversion repository, which requires Subversion (svn) on your computer. Leopard comes with Subversion, but for Tiger or prior you need to install it. I've had good success with [Martin Ott's Subversion package](http://homepage.mac.com/martinott/).

As per the [TextMate manual](http://macromates.com/textmate/manual/bundles#getting_more_bundles):

{{< highlight bash >}}
mkdir -p /Library/Application\ Support/TextMate/Bundles
cd /Library/Application\ Support/TextMate/Bundles
svn co http://svn.textmate.org/trunk/Bundles/Lua.tmbundle
{{< /highlight >}}

You need to restart TextMate or navigate to to Bundles -> Bundle Editor -> **Reload Bundles** in the menu.

Files with a .lua extension will be associated with the Lua language bundle. One nice feature is that you can press Command-R to run them.

So that's about it for getting setup. Now we just need to write some code!
