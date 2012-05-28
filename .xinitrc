#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# switch to secondary monitor if present
[[ 2 -eq `disper -l | grep display | wc -l` ]] && disper -S

# prevent video leaking for flash plugin
export VDPAU_NVIDIA_NO_OVERLAY=1

setxkbmap pl
xsetroot -cursor_name left_ptr

# exec gnome-session
# exec startkde
# exec startxfce4
# exec xmonad
exec ck-launch-session gnome-session --session=xmonad-gnome-nopanel
# exec gnome-terminal
# ...or the Window Manager of your choice
