# sawfish-extras
Extra configuration/utilit(y|ies) for the Sawfish window manager

This will be a spot to put all of the custom Sawfish-related configuration that I might want to keep somewhere.  You are welcome to it, though it is made for my own system and not really all that clean.  It might well serve as an example of how to do -- or how not to do -- something.

Right now, we have the following things:

   * rc - The ~/.sawfish/rc file I use.  Just sets the number of workspaces and loads ~/.sawfish/autostart
   * autostart - Adjusts some video output parameters with xrandr, does some things to enable xscreensaver, and a few other things you migh totherwise see in a .Xinitrc
   * lemonbar.sh - On my system, this lives in ~/.sawfish/lemonbar.sh.  It is a self-contained zsh script -- it must be zsh and not, for example, bash, because it makes pretty heavy use of floating point math.  This script allows lemonbar to do some resource monitoring and to fumnction as a dock, an iconbox, and a pager.  It is not ideal, and I may at some point rewrite the whole thing in lisp, but this works for now.
   * Xdefaults - This is my .Xdefaults file that makes urxvt (and pretty much only that) look a bit nicer.
