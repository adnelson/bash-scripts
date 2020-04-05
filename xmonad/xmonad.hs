import System.IO
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks   (ToggleStruts(..), avoidStruts, docks, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
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
import XMonad.Hooks.EwmhDesktops  (ewmh, fullscreenEventHook)
import XMonad.Util.Run            (spawnPipe,unsafeSpawn)
import qualified XMonad.StackSet as SS
-- import XMonad.Actions.CycleWindows
import Graphics.X11.ExtraTypes.XF86

-- This lists all of the layouts we're using. ModMask + Spacebar cycles through them.
myLayoutHook = id
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

-- | The file path pattern for saving screenshots taken with maim
maimFilePathPattern :: String
maimFilePathPattern = "~/Documents/Screenshots/\"Screenshot - $(date +'%Y-%m-%d %H:%M:%S').png\""

main :: IO ()
main = do
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
    , layoutHook         = myLayoutHook
    , logHook            = dynamicLogWithPP $ xmobarPP
        { ppOutput       = hPutStrLn xmproc
        , ppTitle        = xmobarColor "#b5bd68" "" . shorten 80
        }
    }
    `additionalKeys` [
      -- ToggleStruts will hide the xmobar
        ((mod4Mask, xK_b), sendMessage ToggleStruts)
      -- Fire up dmenu (launches executables in PATH)
      , ((mod4Mask, xK_p), spawn "dmenu_run -fn \"DejaVu Sans Mono:pixelsize=12:style=Book\"")
      -- Lock the screen
      , ((mod4Mask .|. shiftMask, xK_l), unsafeSpawn "xscreensaver-command -lock")
      -- Play/pause spotify
      , ((mod4Mask .|. shiftMask, xK_p), spawn (spotifyCmd "PlayPause"))
      -- Skip spotify track
      , ((mod4Mask .|. shiftMask, xK_m), spawn (spotifyCmd "Next"))
      -- Previous spotify track
      , ((mod4Mask .|. shiftMask, xK_n), spawn (spotifyCmd "Previous"))
      -- Reduce volume 3%
      , ((mod4Mask .|. shiftMask, xK_comma), spawn "amixer sset Master 3%-")
      -- Increase volume 3%
      , ((mod4Mask .|. shiftMask, xK_period), spawn "amixer sset Master 3%+")
      -- Start up brave browser
      , ((mod4Mask .|. shiftMask, xK_y), spawn "brave")
      -- Start up brave browser in incognito mode
      , ((mod4Mask .|. shiftMask, xK_o), spawn "brave --incognito")
      -- Capture shot of full screen
      , ((mod4Mask .|. shiftMask, xK_3), spawn $ "maim " ++ maimFilePathPattern)
      -- Capture screenshot with mouse selection. `-u` hides the cursor
      , ((mod4Mask .|. shiftMask, xK_4), spawn $ "maim -s -u " ++ maimFilePathPattern)
      -- Go to previous window within current workspace
      , ((mod4Mask .|. shiftMask, xK_Left), windows SS.focusDown)
      -- Go to next window within current workspace
      , ((mod4Mask .|. shiftMask, xK_Right), windows SS.focusUp)
      ]
