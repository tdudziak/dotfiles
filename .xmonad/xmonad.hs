import XMonad
import XMonad.Config.Gnome
import XMonad.Config.Desktop
import XMonad.StackSet(swapMaster)

import XMonad.Layout.Spiral
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts

import Graphics.X11.ExtraTypes.XF86

import qualified Data.Map as Map

myManageHook = composeAll (
    [ manageHook gnomeConfig
    , className =? "Unity-2d-panel" --> doIgnore
    , className =? "Unity-2d-launcher" --> doFloat
    , className =? "Evince" --> doF swapMaster
    ])

myKeys config = Map.fromList [
          ((mod1Mask, xK_F4), kill)
        , ((mod1Mask, xK_grave), sendMessage ToggleLayout)
        --, ((mod1Mask .|. shiftMask, xK_t), spawn "trac report/2")
        , ((mod1Mask .|. shiftMask, xK_m), spawn "disper --cycle-stages=-s:-S -C")
        , ((0, xF86XK_HomePage), spawn "$BROWSER")
        , ((0, xF86XK_Launch5), spawn "gvim")
        , ((0, xF86XK_Launch9), spawn "gnome-terminal --command=ipython")
    ]

myLayout =
      desktopLayoutModifiers
    $ smartBorders
    $ toggleLayouts Full
    $ mainLayout ||| Mirror mainLayout
 where
    mainLayout = Tall 1 (3/100) (1/2)
    

alterConfig config = config {
          manageHook         = myManageHook
        , layoutHook         = myLayout
        , borderWidth        = 2
        , normalBorderColor  = "#cccccc"
        , focusedBorderColor = "#ff4400"
        , keys               = (keys config) <+> myKeys
    }

main = xmonad (alterConfig gnomeConfig)
