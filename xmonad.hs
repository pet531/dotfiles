import XMonad
import qualified XMonad.StackSet as W
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import XMonad.Layout.NoBorders
import XMonad.Actions.NoBorders
import XMonad.Actions.GridSelect
import XMonad.Actions.WindowBringer
import XMonad.Actions.WindowGo
import XMonad.Layout.PerWorkspace


myLayout = smartBorders $ avoidStruts $ Full ||| tiled ||| Mirror tiled
  where -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myManageHook = composeAll
    [  className =? "Chromium-browser"      --> doShift "web"
     , className =? "Firefox"    -->doShift "web"
     , className =? "Dwb"    -->doShift "web"
     , className =? "Zathura"    -->doShift"text"
     , className =? "Thunderbird"    --> doShift "mail"
     , className =? "Evince"   --> doShift "text"
     , className =? "Mplayer"  --> doShift "film"
     , stringProperty "WM_NAME" =? "MUTT"  --> doShift "mail"
     , stringProperty "WM_NAME" =? "GoogleChat"  --> doShift "chat"
     , stringProperty "WM_NAME" =? "vk | twitter / telegram"  --> doShift "chat"
     , className =? "Telegram"  --> doShift "chat"
     , (role =? "gimp-toolbox" <||> role =? "gimp-image-window") --> (ask >>= doF . W.sink)
    ]
      where role = stringProperty "WM_WINDOW_ROLE"
    
main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> myManageHook -- make sure to include myManageHook definition from above
                        <+> manageHook defaultConfig
        , layoutHook = onWorkspace "text" myLayout $ onWorkspace "web" myLayout $ smartBorders $  avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , terminal = "terminator"
        , workspaces = ["main", "web", "mail", "text", "film", "chat"] ++ map show [7..9]
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "lock")
        , ((shiftMask, xK_Print), spawn "screenshot area")
        , ((0, xK_Print), spawn "screenshot scr")
        , ((mod4Mask, xK_r), spawn "mydmenu")
        , ((mod4Mask, xK_F1), spawn "$HOME/.xmonad/scripts/change_sound down")
        , ((mod4Mask, xK_F2), spawn "$HOME/.xmonad/scripts/change_sound up")
        , ((mod4Mask, xK_Escape), spawn "$HOME/.xmonad/scripts/change_sound mute")
        , ((mod4Mask, xK_Return), spawn "terminator -e tmux")
        , ((mod1Mask, xK_Tab), goToSelected defaultGSConfig)
	, ((mod4Mask .|. shiftMask, xK_r), spawn "execnet")
        , ((mod4Mask, xK_w), gotoMenuArgs' "rofi" ["-dmenu", "-p", "go to ", "-filter", "web"])
        , ((mod4Mask, xK_g), gotoMenuArgs' "rofi" ["-dmenu", "-p", "go to ", "-filter", "text"])
	, ((mod4Mask .|. shiftMask, xK_t), sendMessage $ ToggleStrut U)
        , ((mod4Mask .|. shiftMask, xK_g), raise (className =? "Firefox"))	
	] 
