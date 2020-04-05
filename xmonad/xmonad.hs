import System.IO
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks   (ToggleStruts(..), avoidStruts, docks, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat,isFullscreen)
import XMonad.Hooks.SetWMName     (setWMName)
import XMonad.Layout.Reflect      (reflectHoriz)
import XMonad.Layout.NoBorders
import XMonad.Layout.TwoPane
import XMonad.Layout.Tabbed
import XMonad.Layout.Combo

import XMonad.Layout.Maximize
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import XMonad.Layout.WindowNavigation
import XMonad.Layout.Dwindle
import XMonad.Util.EZConfig       (additionalKeys)
import XMonad.Hooks.EwmhDesktops  (ewmh,fullscreenEventHook)
import XMonad.Util.Run            (spawnPipe,unsafeSpawn)
import qualified XMonad.StackSet as SS
-- import XMonad.Actions.CycleWindows
import Graphics.X11.ExtraTypes.XF86

myLayout = id
           . avoidStruts
           . smartBorders
           . mkToggle (NOBORDERS ?? FULL ?? EOT)
           . mkToggle (single MIRROR)
           $  Spiral L CCW (3/2) (11/10)
           ||| tiled
           ||| Mirror (TwoPane delta (1/2))
           ||| noBorders Full
           ||| tab
           ||| latex
    where
      -- default tiling algorithm partitions the screen into two panes
      tiled = maximize (Tall nmaster delta ratio)

      tab = tabbed shrinkText myTabConfig

      latex = windowNavigation (
                                combineTwo
                                (TwoPane delta 0.45)
                                (Full)
                                (combineTwo
                                 (Mirror (TwoPane delta 0.85))
                                 (Full)
                                 (Full)
                                )
                               )

      -- The default number of windows in the master pane
      nmaster = 1

      -- Default proportion of screen occupied by master pane
      ratio   = 1/2

      -- Percent of screen to increment by when resizing panes
      delta   = 3/100

      myTabConfig = defaultTheme { inactiveBorderColor = "#BFBFBF"
                                 , activeTextColor = "#FFFFFF"}

-- | Send a message to spotify with dbus-send
spotifyCmd :: String -> String
spotifyCmd cmd = unwords [
  "dbus-send"
  , "--print-reply"
  , "--dest=org.mpris.MediaPlayer2.spotify"
  , "/org/mpris/MediaPlayer2"
  , "org.mpris.MediaPlayer2.Player." ++ cmd
  ]

-- | The file path pattern for saving images taken with scrot
scrotFilePathPattern :: String
scrotFilePathPattern = "~/Documents/Screenshots/%b-%d-%H:%M:%S.png"

main :: IO ()
main = do
  spawn "xscreensaver -nosplash"
  spawn "trayer --height 28 --widthtype request --edge top --align right --transparent true --tint 0 --alpha 64 --monitor primary"
  xmproc <- spawnPipe "xmobar"
  xmonad $ docks $ ewmh def
    { modMask            = mod4Mask
    , terminal           = "alacritty"
    , focusedBorderColor = "#6666cc"
    , normalBorderColor  = "#373b41"
    , borderWidth        = 2
    , startupHook        = setWMName "LG3D"
    , handleEventHook    = fullscreenEventHook -- fix chrome fullscreen
    , manageHook         = manageDocks
                           <+> ( isFullscreen --> doFullFloat )
                           <+> manageHook def
                           <+> ( title =? "ediff" --> doFloat)
    -- , layoutHook         = reflectHoriz $ smartBorders $ avoidStruts $ layoutHook def
    , layoutHook         = myLayout
    , logHook            = dynamicLogWithPP $ xmobarPP
        { ppOutput       = hPutStrLn xmproc
        , ppTitle        = xmobarColor "#b5bd68" "" . shorten 80
        }
    }
    `additionalKeys` [
        ((mod4Mask, xK_b), sendMessage ToggleStruts)
      , ((mod4Mask, xK_p), spawn "dmenu_run -fn \"DejaVu Sans Mono:pixelsize=12:style=Book\"")
      , ((mod4Mask .|. shiftMask, xK_l), unsafeSpawn "xscreensaver-command -lock")
      , ((mod4Mask .|. shiftMask, xK_p), spawn (spotifyCmd "PlayPause"))
      , ((mod4Mask .|. shiftMask, xK_y), spawn "brave")
      , ((mod4Mask .|. shiftMask, xK_o), spawn "brave --incognito")
      , ((mod4Mask .|. shiftMask, xK_m), spawn (spotifyCmd "Next"))
      , ((mod4Mask .|. shiftMask, xK_n), spawn (spotifyCmd "Previous"))
      , ((mod4Mask .|. shiftMask, xK_comma), spawn "amixer sset Master 3%-")
      , ((mod4Mask .|. shiftMask, xK_period), spawn "amixer sset Master 3%+")
      , ((mod4Mask .|. shiftMask, xK_3), spawn $ "scrot " ++ scrotFilePathPattern)
      -- Note: the `sleep 0.2` is a fix for an issue specific to xmonad/scrot.
      -- See: https://wiki.archlinux.org/index.php/Screen_capture#scrot
      , ((mod4Mask .|. shiftMask, xK_4), spawn $ "sleep 0.2; scrot -s " ++ scrotFilePathPattern)
      , ((mod4Mask .|. shiftMask, xK_Left), windows SS.focusDown)
      , ((mod4Mask .|. shiftMask, xK_Right), windows SS.focusUp)
      ]
