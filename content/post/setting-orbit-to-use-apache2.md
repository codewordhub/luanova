+++
title = "Setting Orbit to use Apache2"
date = "2010-09-08"
author = "ryanpusztai"
+++

This article will cover how to install [Lua Orbit](http://keplerproject.github.com/orbit/index.html) on an Ubuntu 8.04+ server. This will explain how to setup Apache2 and Xavante on the server. This allows for production code to run through Apache2 and then develop using Xavante. To hook Orbit to Apache2 we will be using **FastCGI** for the best performance.

NOTE: This is just one way to configure your server to run Orbit applications; it does require that you have root access.  There are also local sandboxed methods which we will cover in a future article.

## Installing Apache

Connect to your server. Use ssh or however your host instructs you, and install Apache2 and support modules:

    $ sudo apt-get install apache2 libapache2-mod-fcgid libfcgi-dev build-essential

Enable required Apache2 modules:

     $ sudo a2enmod rewrite
     $ sudo a2enmod fcgid
     $ sudo /etc/init.d/apache2 force-reload

## Install LuaRocks

If you are running a fresh distribution (Ubuntu Lucid or Debian Squeeze) then you can get a suitable LuaRocks from the repositories - otherwise you must install it directly, as described below. If unsure, look at ‘aptitude show luarocks’ - the luarocks version must be 2.0.x.  This will also make sure you have Lua and its development library:

    $ sudo apt-get install luarocks

Otherwise, you have to do it by hand:

Install Lua, using the appropriate methods for your system.

    $ sudo apt-get install lua5.1 liblua5.1-0-dev

Download and unpack the LuaRocks tarball (http://luarocks.org/releases).

    $ wget http://luarocks.org/releases/luarocks-2.0.2.tar.gz
    $ tar xvfz luarocks-2.0.2.tar.gz

Change directories to the new extracted LuaRocks directory and configure. (This will attempt to detect your installation of Lua. If you get any error messages, the main problem will probably be the location of the Lua include files - this uses the standard Debian/Ubuntu locations.

    $ cd luarocks-2.0.2
    $ ./configure --with-lua-include=/usr/include/lua5.1"
    $ make
    $ make install

Install **WSAPI**, **fcgi**, **Orbit**, and **Xavante**

    $ sudo luarocks install orbit
    $ sudo luarocks install wsapi-xavante
    $ sudo luarocks install wsapi-fcgi

[Optional] Install support libraries; **LuaSQL**,**Sqlite3** and **md5**:

    $ sudo apt-get install libmysqlclient15-dev libsqlite3-dev
    $ sudo luarocks install md5
    $ sudo luarocks install luasql-sqlite3
    $ sudo luarocks install luasql-mysql MYSQL_INCDIR=/usr/include/mysql

## Setting up Apache2

Edit the site config file with your favourite editor. (default site is named ‘default’)

    $ sudo joe /etc/apache2/sites-available/default

Add this following section below the `<Directory /var/www/>` section of the config file. If this section has a ‘AllowOverride None’ then you need to change the ‘None’ to ‘All’ so that the .htaccess file can override the configuration locally.

    <IfModule mod_fcgid.c>
        AddHandler fcgid-script .lua
        AddHandler fcgid-script .ws
        AddHandler fcgid-script .op
        FCGIWrapper "/usr/local/bin/wsapi.fcgi" .ws
        FCGIWrapper "/usr/local/bin/wsapi.fcgi" .lua
        FCGIWrapper "/usr/local/bin/op.fcgi" .op
        #FCGIServer "/usr/local/bin/wsapi.fcgi" -idle-timeout 60 -processes 1
        #IdleTimeout 60
        #ProcessLifeTime 60
    </IfModule>

Restart the server.

To enable your application you need to add **+ExecCGI** to an .htaccess file in the root of your Orbit application - in this case, /var/www.

    Options +ExecCGI
    DirectoryIndex index.ws

Here is a simple example of a “Hello World” orbit application. Put this in /var/www/index.ws

{{< highlight lua >}}
#!/usr/bin/env wsapi.fcgi

require"orbit"

-- Orbit applications are usually modules,
-- orbit.new does the necessary initialization

module( "hello", package.seeall, orbit.new )

-- These are the controllers, each receives a web object
-- that is the request/response, plus any extra captures from the
-- dispatch pattern. The controller sets any extra headers and/or
-- the status if it's not 200, then return the response. It's
-- good form to delegate the generation of the response to a view
-- function

function index( web )
    return render_index()
end

function say( web, name )
    return render_say( web, name )
end

-- Builds the application's dispatch table, you can
-- pass multiple patterns, and any captures get passed to
-- the controller

hello:dispatch_get( index, "/", "/index" )
hello:dispatch_get( say, "/say/(%a+)" )

-- These are the view functions referenced by the controllers.
-- orbit.htmlify does through the functions in the table passed
-- as the first argument and tries to match their name against
-- the provided patterns (with an implicit ^ and $ surrounding
-- the pattern. Each function that matches gets an environment
-- where HTML functions are created on demand. They either take
-- nil (empty tags), a string (text between opening and
-- closing tags), or a table with attributes and a list
-- of strings that will be the text. The indexing the
-- functions adds a class attribute to the tag. Functions
-- are cached.
--

-- This is a convenience function for the common parts of a page

function render_layout( inner_html )
    return html
    {
        head{ title"Hello" },
        body{ inner_html }
    }
end

function render_hello()
    return p.hello "Hello World!"
end

function render_index()
    return render_layout( render_hello() )
end

function render_say( web, name )
    return render_layout( render_hello() .. p.hello( (
eb.input.greeting or "Hello " ) .. name .. "!" ) )
end

orbit.htmlify( hello, "render_.+" )

return _M
{{< /highlight >}}

Now you should be able to launch your web browser and goto                http://hostname and you should see "Hello World!"

If you go to http://hostname/index.ws/say/yourname you should see:

    "Hello World!
    Hello yourname!"

You are done!  You can now look at LuaNova's [Orbit Introduction](http://luanova.org/orbit1-2/)

