+++
title = "The Golden Wombat of Destiny"
date = "2008-03-15"
description = "..."
author = "nathany"
+++

<em>The Golden Wombat of Destiny</em> was a text adventure game (interactive fiction) written by Huw Collingbourne in early `80s. I honestly never got very far in that game, preferring Colossal Cave and The Hitchhiker's Guide to the Galaxy in the days of the Kaypro IV.

Today we're going to talk about a different wombat, with a different <em>destiny.</em>

Spear-headed by <a href="http://kasparov.skife.org/blog/src/wombat/">Brian McCallister</a>, <strong>mod_wombat</strong> embeds the <a href="http://www.lua.org">Lua</a> programming language into the <a href="http://httpd.apache.org/">Apache HTTP server</a> in the same fashion as mod_perl, mod_php and mod_python bring their respective languages into the Apache world of web development.

How mod_wombat differs has a lot to do with how Lua differs from other languages. Lua is a very lightweight scripting language originally designed for non-programmers to customize the software it is embedded in. It is simple to pick up, while offering a good amount of flexibility and power. Its popularity in game scripting has pushed its' interpreter towards being very efficient and multi-thread ready.

Apache is the heavy-weight champion of HTTP servers, responsible for <a href="http://news.netcraft.com/archives/web_server_survey.html">serving up half the Internet</a>. Apache 2.x was a substantial reworking, providing:

<ul>
<li>The Apache Portable Runtime (APR) so Module writers don't need to deal with all the OS-specific issues.</li>
<li>Swappable multi-processing modules (MPMs) including Prefork (non-threaded), Worker threads, and an Event MPM that decouples server threads from the HTTP connection (read: very efficient).</li>
</ul>

Lua is designed for embedding in C-based programs, which allows mod_wombat to take advantage of the substantial infrastructure Apache provides. More than any other language module, mod_wombat endeavors to <em>work with</em> Apache.

Matthew Burke is <a href="http://mail-archives.apache.org/mod_mbox/httpd-dev/200803.mbox/%3c47CA13D9.7080900@gwu.edu%3e">looking for students</a> to work on mod_wombat as part of the 2008 <a href="http://code.google.com/soc/2008/">Google Summer of Code</a>. If you are a student who is interested, you should definitely get in touch with Matthew Burke and Brian McCallister to discuss your ideas. Who knows, this could be your <em>destiny?</em> :-)

<h2>This is gonna be great</h2>

Lua atop Apache could make for a very sweet development platform for web applications, both large and small.

<ul>
<li>Lua is simpler than other scripting languages used for web development, making it easy to pick-up. This is exemplified by the use of <em>tables</em> as a universal data structure (like PHP Arrays, but unlike Python or Ruby). </li>
<li>Lua has several commonalities with JavaScript, like first-class functions, closures, and prototype-based object orientation. Yet it steps beyond most languages with proper tail calls and coroutines.</li>
<li>There is a fairly clean slate to start with, meaning it doesn't carry the baggage of hundreds of procedural methods like PHP, or code mixed into HTML templates. APIs can be nicely organized and designed for simplicity (i.e. ColdFusion's DateFormat and TimeFormat make it easier to reason about date formatting than Ruby or PHP's methods).</li>
<li>Apache's efficient threading modules combined with Lua's low-overhead and thread-safety make for a very performant platform. That means it is able to handle a load of traffic without a huge hardware investment.</li>
<li>Deploying with an Apache module is often the preferred method, as opposed to more complicated reverse proxy setups or FastCGI. For ease of deployment, this is an advantage over the popular Ruby platform, which <a href="http://www.rubyinside.com/no-true-mod_ruby-is-damaging-rubys-viability-on-the-web-693.html">has no true mod_ruby</a>.</li>
<li>The mod_wombat project was started by Apache Software Foundation members, is hosted with Apache, and has their backing as a supported module for Apache users.</li>
</ul>

<h2>Ideas</h2>

If you are a student joining the GSoC, you will need to come up with your own proposal. I'm not a student, so I don't qualify, but I will post here a few of the basic ideas that I believe are of general consensus.

<h3>Simplify installation</h3>

For mod_wombat to become a platform of choice, it needs to be dead-simple to deploy, whether as a development environment or a production server. This would be served by relying only on <a href="http://httpd.apache.org/docs/2.2/mod/">those modules</a> included with the Apache distribution.

There has been a desire to remove the dependency on <a href="http://httpd.apache.org/apreq/docs/libapreq2/">libapreg2</a>, which is used to parse HTTP cookies, query-strings and POST data. The required functionality would need to be incorporated into mod_wombat directly.

<h3>Tighter integration with Apache HTTP Server 2.2</h3>

There is a lot that can be done to further integrate Lua with Apache, whether using Lua to configure Apache, or to pull Apache functionality into Lua.

Perhaps the most significant and obvious, would be integration with <strong>Apache's Database Framework</strong>. With DBD, the database drivers for your web application are bundled with Apache, and Apache manages a pool of database connections in an intelligent way appropriate for the MPM being used. With mod_wombat, Lua could be the first language to really take advantage of this feature, new to Apache 2.2.

<h3>Write something with it</h3>

What mod_wombat provides is an API to higher-level web frameworks and applications. It's hard to know how those APIs should be written without using them. Building a small project atop mod_wombat could go a long way in designing a <strong>concise and friendly API.</strong>

Preferably using some sort of <a href="http://ajato.titanatlas.com/developer/code-standards">code standards</a>.

<h2>Resources</h2>

If you choose to partake in this endeavor, there a few things you must know.

<ul>
<li>Working knowledge of ANSI C, perhaps <a href="http://www.careferencemanual.com/">C: A Reference Manual</a> will help.</li>
<li><a href="http://www.inf.puc-rio.br/~roberto/pil2/">Programming in Lua</a> is an excellent resource for both the Lua programming language and how to interface it with C.</li>
<li><a href="http://www.informit.com/store/product.aspx?isbn=0132409674">The Apache Modules Book</a> goes over Apache's architecture and writing Modules for it, including a chapter on DBD.
<li>A willingness to work with <a href="http://www.gnu.org/software/autoconf/">autoconf</a> and related build tools. There is but one book dedicated to the subject, and the <a href="http://sourceware.org/autobook/">online version</a> is more up-to-date.</li>
<li>Familiarity with existing web development environments and experience with database systems.</li>
<li>An understanding of just how <a href="http://code.google.com/soc/2008/">Google Summer of Code</a> works.</li>
<li>Go through Brian's <a href="http://kasparov.skife.org/wombat_ac_us_07.pdf">slides</a> and download the <a href="http://svn.apache.org/repos/asf/httpd/mod_wombat/trunk">source code</a> from Subversion to familiarize yourself with mod_wombat.</li>
</ul>

And that's all there's to it. Ready to get coding?

<h2>Follow-up</h2>

Maxime Petazzoni has accepted the role of working on mod_wombat for GSoC this year. See the Apache <a href="http://mail-archives.apache.org/mod_mbox/httpd-dev/200804.mbox/%3c20080429195230.GA3397@bulix.org%3e">mailing list</a>.
