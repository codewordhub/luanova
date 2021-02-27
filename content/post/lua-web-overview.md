+++
title = "Lua and the web: an overview"
date = "2008-03-15"
author = "nathany"
+++

Lua is among the top 20 most popular programming languages, according to the <a href="http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html">TIOBE Programming Community index</a>. Lua is also faster and has a smaller memory footprint than other interpreted scripting languages (compare with <a href="http://shootout.alioth.debian.org/gp4/benchmark.php?test=all&amp;lang=lua&amp;lang2=ruby">Ruby</a>, <a href="http://shootout.alioth.debian.org/gp4/benchmark.php?test=all&amp;lang=lua&amp;lang2=python">Python</a>, <a href="http://shootout.alioth.debian.org/gp4/benchmark.php?test=all&amp;lang=lua&amp;lang2=php">PHP</a> and <a href="http://shootout.alioth.debian.org/gp4/benchmark.php?test=all&amp;lang=lua&amp;lang2=javascript">JavaScript SpiderMonkey</a>).

We haven't heard a lot about Lua on the web, even though
there are a number of developers working with Lua on the server-side. Lets take a brief look.

<h2>The Kepler Project</h2>

<a href="http://www.keplerproject.org/">Kepler</a> is a "web development platform" named after astronomer Johannes Kepler. It looks to be the most ambitious project of the bunch. Kepler is written as a number of modules that fit together, and includes its' own web server named Xavante.

There is also an endeavor to build <em>WSAPI,</em> in similar fashion to
Python's <a href="http://www.python.org/dev/peps/pep-0333/">WSGI</a> interface, that support pretty much any web server and configuration (CGI, FastCGI, SCGI, etc, etc.)


<h2>Nanoki</h2>

When I joined to Kepler mailing list, "Petite Abeille" was the first person to respond. He has been developing a Wiki called <a href="http://alt.textdrive.com/nanoki/">Nanoki</a>.

However, it is not built on top of Kepler. Instead there is a small built-in web server or will run atop the Unix tcp command. All the source code is released under a MIT license, and is instructive in building a light, focussed web application vs. the broad scope of Kepler.

<h2>mod_wombat</h2>

<a href="http://kasparov.skife.org/blog/">Brian McCallister</a> spear-headed a project to embed Lua in an Apache HTTP Server module. Going through Brian's <a href="http://kasparov.skife.org/wombat_ac_us_07.pdf">slides</a> is quite inspiring as to just how good a fit this is. Apache does all the heavy-lifting, such as providing a fully multi-threaded "worker MPM" (multi-processing module) and a portable runtime (APR) environment. Lua is a thread-safe language, with "share-nothing" Lua <em>states</em>, so it fits right in and is super-efficient.

Skimming through <a href="http://www.informit.com/store/product.aspx?isbn=0132409674">The Apache Modules Book</a> is even more inspiring, as you can see the potential of mod_wombat if it took advantage of Apache's database connection pooling (DBD) and the various other facilities of Apache HTTP Server.

Wombat is still a little rough around the edges, but you can find the Apache-licensed source code at:
<a href="http://svn.apache.org/repos/asf/httpd/mod_wombat/trunk">http://svn.apache.org/repos/asf/httpd/mod_wombat/trunk</a>.
