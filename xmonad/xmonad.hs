{-# LANGUAGE LambdaCase #-}
import System.IO
import System.Environment (lookupEnv, setEnv)
import System.Directory (doesDirectoryExist)
import System.FilePath ((</>))
import XMonad
--------------------------------- <Hook imports> -------------------------------------
import XMonad.Hooks.DynamicLog (ppOutput, ppTitle, dynamicLogWithPP, xmobarPP, xmobarColor, shorten)
import XMonad.Hooks.EwmhDesktops  (ewmh, fullscreenEventHook)
import XMonad.Hooks.ManageDocks   (ToggleStruts(..), avoidStruts, docks, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Hooks.SetWMName     (setWMName)
--------------------------------- </Hook imports> ------------------------------------

--------------------------------- <Layout imports> -------------------------------------
import XMonad.Layout.Dwindle (Dwindle(Spiral), Chirality(CW, CCW))
import XMonad.Layout.Grid (Grid(Grid))
import XMonad.Layout.MultiToggle (mkToggle, Toggle(..), (??), EOT(..), single)
import XMonad.Layout.MultiToggle.Instances (StdTransformers(..))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Tabbed (tabbed, shrinkText, simpleTabbed)
import XMonad.Layout.WindowNavigation (Direction2D(L, R))
--------------------------------- </Layout imports> ------------------------------------

import XMonad.Util.EZConfig       (additionalKeys)
import XMonad.Util.Run            (spawnPipe,unsafeSpawn)
import XMonad.StackSet (focusUp, focusDown)

-- This lists all of the layouts we're using. ModMask + Spacebar cycles through them.
myLayoutHook = avoidStruts
  . smartBorders
  . mkToggle (NOBORDERS ?? FULL ?? EOT)
  . mkToggle (single MIRROR)
  $ Spiral L CCW (3/2) (11/10)
  ||| Spiral R CW (3/2) (11/10)
  ||| Grid
  ||| tabbed shrinkText def

-- | Send a message to spotify with dbus-send
spotifyCmd :: String -> String
spotifyCmd cmd = unwords [
  "dbus-send"
  , "--print-reply"
  , "--dest=org.mpris.MediaPlayer2.spotify"
  , "/org/mpris/MediaPlayer2"
  , "org.mpris.MediaPlayer2.Player." ++ cmd
  ]

-- | Default browser
defaultBrowser :: String
defaultBrowser = "firefox"

-- | Backup browser
backupBrowser :: String
backupBrowser = "brave"

-- | Open browser in incognito
incognito :: String -> String
incognito browser = browser ++ " " ++ arg where
  arg = if browser == "firefox" then "--private-window" else "--incognito"

-- | The file path pattern for saving screenshots taken with maim
maimFilePathPattern :: String
maimFilePathPattern = "~/Screenshots/\"Screenshot - $(date +'%Y-%m-%d %H:%M:%S').png\""

main :: IO ()
main = do
  lookupEnv "HOME" >>= \case
    Nothing -> pure ()
    Just home -> do
      let scriptDir = (home </> ".bash-scripts/scripts")
      ((,) <$> doesDirectoryExist scriptDir <*> lookupEnv "PATH")  >>= \case
        (True, Just path) -> do
          setEnv "PATH" (scriptDir <> ":" <> path)
        _ -> pure ()

  spawn "trayer --height 28 --widthtype request --edge top --align right --transparent true --tint 0 --alpha 64 --monitor primary"
  xmproc <- spawnPipe "xmobar"
  let modShift key = (mod4Mask .|. shiftMask, key)
  let customKeys = [
        -- ToggleStruts will hide the xmobar
        ((mod4Mask, xK_b), sendMessage ToggleStruts)
        -- Fire up dmenu (launches executables in PATH)
        , ((mod4Mask, xK_p), spawn "dmenu_run -fn \"DejaVu Sans Mono:pixelsize=12:style=Book\"")
        -- Lock the screen
        , (modShift xK_End, unsafeSpawn "xscreensaver-command -lock")
        -- Play/pause spotify
        , (modShift xK_p, spawn (spotifyCmd "PlayPause"))
        -- Skip spotify track
        , (modShift xK_m, spawn (spotifyCmd "Next"))
        -- Previous spotify track
        , (modShift xK_n, spawn (spotifyCmd "Previous"))
        -- Reduce volume 3%
        , (modShift xK_comma, spawn "amixer sset Master 3%-")
        -- Increase volume 3%
        , (modShift xK_period, spawn "amixer sset Master 3%+")
        -- Start up browser
        , (modShift xK_y, spawn defaultBrowser)
        -- Start up browser in incognito mode
        , (modShift xK_u, spawn (incognito defaultBrowser))
        -- Start up backup browser
        , (modShift xK_i, spawn backupBrowser)
        -- Start up backup browser in incognito mode
        , (modShift xK_o, spawn (incognito backupBrowser))
        -- Capture shot of full screen.
        , (modShift xK_s, spawn $ "maim -m 10 " ++ maimFilePathPattern)
        -- Capture screenshot with mouse selection. `-u` hides the cursor.
        , (modShift xK_d, spawn $ "maim -m 10 -s -u " ++ maimFilePathPattern)
        -- Capture screenshot with mouse selection, not hiding the cursor.
        , (modShift xK_e, spawn $ "maim -m 10 -s " ++ maimFilePathPattern)
        -- Go to previous window within current workspace
        , (modShift xK_Left, windows focusDown)
        -- Go to next window within current workspace
        , (modShift xK_Right, windows focusUp)
        -- Toggle mirror mode
        , (modShift xK_x, sendMessage $ Toggle MIRROR)
        -- Toggle fullscreen mode
        , (modShift xK_f, sendMessage $ Toggle FULL)
        ]
  xmonad $ docks $ ewmh def
    { modMask            = mod4Mask
    , terminal           = "alacritty" -- "terminator"
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
    , logHook            = dynamicLogWithPP xmobarPP
        { ppOutput       = hPutStrLn xmproc
        , ppTitle        = xmobarColor "#b5bd68" "" . shorten 80
        }
    }
    `additionalKeys` customKeys
