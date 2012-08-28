Date: 2010-05-19 23:17:34
Summary: ...
Author: jimwhitehead


# Authentication-based permission groups in Sputnik

[Sputnik](http://sputnik.freewisdom.org/) is a novel document-storage-based wiki written in Lua which
has been previously featured on LuaNova. Today I'd like to share my
experiences adding authentication-based permission groups to my
running Sputnik installation at [wowprogramming.com](http://wowprogramming.com). Over the
course of the past two months I have had two spam posts on our forums
which were fixed by removing those nodes from the document store, but
this left me with a question of what to do with the user account that
posted the spam message.

First, I should state that we have had very few instances of spam on
our site. Any user accounts must be verified by email and require the
user to input a captcha from the [reCaptcha](http://recaptcha.net/) project. Once this is done,
the user is free to make edits to the API documentation and to post
new topics and replies on the discussion forums. However, the process
of posting spam on the site is very difficult to automate due to the
honeypots, field hashing, and post tokens that a default Sputnik
installation employs. That's not to say that the software is
bullet-proof, but in practice it seems to work for my needs on a real
site.

The first few accounts, I simply removed from my authentication system
via a simple mysql query (although removing it from a default
installation would be a easier, a simple edit of the sputnik/passwords
node.) But then I realised I was giving up information about the
spammers, including the email addresses they were using to register,
something I could share with some of the spam registration databases
that exist. It was clear that I needed an easier way to stop those
user accounts from posting on the site without simply nuking their
user accounts from the system. Really what I wanted was a way to 'ban'
a user account and prevent them from making edits on the site.

## Permissions in Sputnik

Each node in a Sputnik document store is a Lua script that is compiled
and assembled into a Lua object at runtime. Consider the following
simple node:

~~~ lua
title = "Some Page"
content = [[This is a simple test node for a Sputnik installation.

Hello World!]]
~~~

Sputnik nodes can be more than just a symbolic representation of text
data. For example, you can restrict the permissions of a node by
adding a permissions field. Consider the following definition:

~~~ lua
permissions    = [[
  deny(all_users, all_actions)
  allow(all_users, show)  -- show, show_content, cancel
  allow(Authenticated, edit_and_save) -- edit, save, preview
  allow(all_users, "post")  -- needed for login
  allow(all_users, "rss")
  allow(Admin, all_actions)
]]
~~~

When this field is loaded, it's obviously a string that we can then
further process. Specifically, we load it in an environment where a
few helpers functions are defined. The all_users function returns true
for all users, all_actions does the same for all action types.
Authenticated is a special function that returns true if the current
user is authenticated, while Anonymous can be used when the user is
not logged in. There's also a special function called Admin that
queries the authentication metadata for the current user and checks if
the is_admin flag is set.

When I started looking for a way to ban users, I started looking in
this section of the code and found the following gem that Yuri sneaked
in after the definition for the Admin group:

~~~ lua
local groups = self.saci.permission_groups -- just a local alias
-- Define group "Admin" as any user that has is_admin set to true
groups.Admin = function(user)
   return user and self.auth:get_metadata(user, "is_admin") == "true"
end

-- Define any group that starts with "is.<group>" as including all users
-- for whom "is_<group>" is set to true. For example, if is_clown is set
-- to true than user is a member of group "is.clown" and we can set:
--
--     allow(is.clown, "show")
--
local groups_mt = {
   __index = function(table, key)
      return function (user)
                return user and self.auth:get_metadata(user, "is_"..key) == "true"
             end
   end
}
groups.is = setmetatable({}, groups_mt)
~~~

Bingo! With this bit of code, without making any changes to the
Sputnik core, I had a way to ban users in my system, by setting the
**is_banned** flag in their authentication metadata. For a simple
authentication system (the default) this is just a matter of setting
the given flag in the user's authentication entry, whereas in a mysql
authentication system I just add a row to the database. This was only
part of the puzzle, since Sputnik doesn't know anything about the new
user group. I had to make a few edits to the @Root prototype to add
the following at the end:

~~~ lua
deny(is.banned, edit_and_save)
~~~

Since earlier in the permissions script the edit_and_save permissions
are granted to all authenticated users, I needed to make sure the
denial runs after that point, since the final 'permission' is what
really matters. Since I have custom forums in my system, I needed to
make the same one-line change in a few other places.

It took a total of about 6 minutes to familiarize myself with the code
and make the necessary changes, and now I have an easy way to ban a
user from being able to post anywhere on my website.

Down with the spammers!
