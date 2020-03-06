import System.IO
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks   (ToggleStruts(..), avoidStruts, docks, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat,isFullscreen)
import XMonad.Hooks.SetWMName     (setWMName)
import XMonad.Layout.NoBorders    (smartBorders)
import XMonad.Layout.Reflect      (reflectHoriz)
-- import XMonad.Layout.Spiral       (Spiral(..))
import XMonad.Util.EZConfig       (additionalKeys)
import XMonad.Hooks.EwmhDesktops  (ewmh,fullscreenEventHook)
import XMonad.Util.Run            (spawnPipe,unsafeSpawn)
import qualified XMonad.StackSet as SS
-- import XMonad.Actions.CycleWindows
import Graphics.X11.ExtraTypes.XF86

spotifyCmd :: String -> String
spotifyCmd cmd = unwords [
  "dbus-send"
  , "--print-reply"
  , "--dest=org.mpris.MediaPlayer2.spotify"
  , "/org/mpris/MediaPlayer2"
  , "org.mpris.MediaPlayer2.Player." ++ cmd
  ]

main :: IO ()
main = do
  spawn "xscreensaver -nosplash"
  spawn "trayer --height 28 --widthtype request --edge top --align right --transparent true --tint 0 --alpha 64 --monitor primary"
  spawn "redshift -l -33.84:151.21 -t 6500:3500"
  xmproc <- spawnPipe "xmobar"
  xmonad $ docks $ ewmh def
    { modMask            = mod4Mask
    , terminal           = "st -f \"DejaVu Sans Mono:pixelsize=20:style=Book\""
    , focusedBorderColor = "#6666cc"
    , normalBorderColor  = "#373b41"
    , borderWidth        = 2
    , startupHook        = setWMName "LG3D"
    , handleEventHook    = fullscreenEventHook -- fix chrome fullscreen
    , manageHook         = manageDocks
                           <+> ( isFullscreen --> doFullFloat )
                           <+> manageHook def
                           <+> ( title =? "ediff" --> doFloat)
    , layoutHook         = reflectHoriz $ smartBorders $ avoidStruts $ layoutHook def
    , logHook            = dynamicLogWithPP $ xmobarPP
        { ppOutput       = hPutStrLn xmproc
        , ppTitle        = xmobarColor "#b5bd68" "" . shorten 80
        }
    }
    `additionalKeys` [
        ((mod4Mask, xK_b), sendMessage ToggleStruts)
      , ((mod4Mask, xK_p), spawn "dmenu_run -fn \"DejaVu Sans Mono:pixelsize=12:style=Book\"")
      , ((mod4Mask .|. shiftMask, xK_Return ), spawn "terminator")
      , ((mod4Mask .|. shiftMask, xK_l), unsafeSpawn "xscreensaver-command -lock")
      , ((mod4Mask .|. shiftMask, xK_p), spawn (spotifyCmd "PlayPause"))
      , ((mod4Mask .|. shiftMask, xK_m), spawn (spotifyCmd "Next"))
      , ((mod4Mask .|. shiftMask, xK_n), spawn (spotifyCmd "Previous"))
      , ((mod4Mask .|. shiftMask, xK_comma), spawn "amixer sset Master 3%-")
      , ((mod4Mask .|. shiftMask, xK_period), spawn "amixer sset Master 3%+")
      , ((mod4Mask .|. shiftMask, xK_Left), windows SS.focusDown)
      , ((mod4Mask .|. shiftMask, xK_Right), windows SS.focusUp)
      ]
