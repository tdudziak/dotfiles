import XMonad
import XMonad.Config.Gnome
import XMonad.Config.Desktop
import XMonad.StackSet(swapMaster)

import XMonad.Layout.Spiral
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts

import qualified Data.Map as Map

myManageHook = composeAll (
    [ manageHook gnomeConfig
    , className =? "Unity-2d-panel" --> doIgnore
    , className =? "Unity-2d-launcher" --> doFloat
    , className =? "Evince" --> doF swapMaster
    ])

myKeys config = Map.fromList [
          ((mod1Mask, xK_F4),       kill)
        , ((mod1Mask, xK_grave),    sendMessage ToggleLayout)
    ]

myLayout =
      desktopLayoutModifiers
    $ smartBorders
    $ toggleLayouts Full
    $ mainLayout ||| Mirror mainLayout
 where
    mainLayout = Tall 1 (3/100) (1/2)
    -- mainLayout = spiral (0.62)
    

alterConfig config = config {
          manageHook         = myManageHook
        , layoutHook         = myLayout
        , borderWidth        = 2
        , normalBorderColor  = "#cccccc"
        , focusedBorderColor = "#ff4400"
        , keys               = (keys config) <+> myKeys
    }

main = xmonad (alterConfig gnomeConfig)
