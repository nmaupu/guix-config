import qualified XMonad.Actions.FlexibleManipulate as Flex
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import System.IO (hPutStrLn)
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.MosaicAlt
import XMonad.Layout.Renamed
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Prompt
import XMonad.Util.Run
import XMonad.Util.NamedScratchpad
import XMonad.Util.WorkspaceCompare (getSortByTag)
import Data.Ratio
-- Move and resize floating windows
import XMonad.Actions.FloatKeys
import XMonad.Actions.SpawnOn
import XMonad.Layout.Hidden
import XMonad.Util.Cursor
import XMonad.Hooks.ManageHelpers
-- Virtual screens
import Data.IORef
import Data.IORef (newIORef)
-- startup
import XMonad.Util.SpawnOnce

------------------------------------------------------------------------
-- funcs
--
addKeyBinding shortcutLeft shortcutRight action xs = ((shortcutLeft, shortcutRight), action) : xs

centerWindow :: Window -> X ()
centerWindow win = do
  (_, W.RationalRect x y w h) <- floatLocation win
  -- 0.0075 takes mobar into account
  windows $ W.float win (W.RationalRect ((1 - w) / 2) (((1 - h) / 2) + 0.0075) w h)
  return ()

centerWebex :: Window -> X ()
centerWebex win = do
  (_, W.RationalRect x y w h) <- floatLocation win
  windows $ W.float win (W.RationalRect 0.25 0.015 0.5 0.985)
  return ()

-- https://wiki.haskell.org/Xmonad/Mutable_state_in_contrib_modules_or_xmonad.hs
-- Using IORef to keep track of a boolean state
-- We get the boolean and invert it then we toggle screen layout (1 <-> 3 virtual screens)
-- Parameter ref is passed along the keybindings func
-- Deprecated, using xrandr directly instead
-- toggleLayoutScreens :: IORef Bool -> X ()
-- toggleLayoutScreens ref = do
--   val <- io $ readIORef ref
--   io $ writeIORef ref (not val)
--   if val
--     then
--       rescreen
--     else
--       layoutSplitScreen 3 $ ThreeColMid 1 0 (1/2)

------------------------------------------------------------------------
-- vars
--
altKey = mod1Mask
tabbedFont = "xft:DejaVu Sans Mono:pixelsize=13,style=Regular,xft:Inconsolata for Powerline:pixelsize=13"
dmenuFont = "xft:DejaVu Sans Mono:pixelsize=15,style=Regular,xft:Inconsolata for Powerline:pixelsize=15"
iconDir = ".config/xmonad/icons"
iconSep = iconDir ++ "/separator.xbm"
myBorderWidth = 3
myTerminal = "alacritty"
myWorkspaces = take 10 $ map show [1 ..]
numLockKey = mod2Mask
scratchTerminal = myTerminal
winKey = mod4Mask

-- Wide screen
--topbarMainWidth = "3900"
--topbarRightWidth = "1020"
-- Laptop screen
topbarMainWidth = "1000"
topbarRightWidth = "900"

colBG           = "#0f0f0f"
colBorderFocus  = "#b700ff"
colBorderNormal = "#dddddd"
colFocus        = "#0099ff"
colHidden       = "#555555"
colNormal       = "#ffffff"
colUrgent       = "#ff0000"

dmenuBrightness = "param=`/usr/bin/seq 0 5 100 | " ++ dmenuCommandBasic ++ " -b` && eval " ++ scriptBrightness ++ " ${param}"
dmenuCommandBasic = "dmenu " ++ dmenuCommandOpts
dmenuCommandOpts = "-p '>' -l 10 -nf '" ++ colNormal ++ "' -nb '" ++ colBG ++ "' -fn '" ++ dmenuFont ++ "' -sb '" ++ colFocus ++ "' -sf '" ++ colNormal ++ "'"
dmenuCommandProg = "dmenu_run " ++ dmenuCommandOpts
--dmenuPass = "param=`" ++ scriptPass ++ " -l | " ++ dmenuCommandBasic ++ " -b -l 10` && eval \"" ++ scriptPass ++ " -c ${param}\""
rofiPass  = "gopass ls --flat | rofi -dmenu -p \"Password\" -matching fuzzy -theme purple | xargs --no-run-if-empty gopass show -c"
--dmenuProg = "prog=`" ++ dmenuCommandProg ++ "` && eval \"exec ${prog}\""
rofiProg = "rofi -modi run -theme sidebar -show"
rofiClipboard = "rofi -modi \"clipboard:greenclip print\" -theme solarized_alternate -show clipboard -run-command '{cmd}'"
greenclipClear = "greenclip clear"
dmenuServ = "param=`" ++ scriptServer ++ " -l | " ++ dmenuCommandBasic ++ " -b` && eval \"" ++ scriptServer ++ " -e ${param}\""
lxappearance = "lxappearance"
screenshot = "flameshot"
scriptDir = "/home/nmaupu/.config/xmonad/scripts"
scriptBrightness = scriptDir ++ "/brightness.sh"
scriptPass = scriptDir ++ "/xmonad-pass.sh"
scriptServer = scriptDir ++ "/xmonad-kube-switch-ctx.sh"

------------------------------------------------------------------------
-- Key bindings
--

newKeyBindings refState x = M.union (M.fromList (keyBindings refState x)) (keys def x)
keyBindings refState conf@(XConfig {XMonad.modMask = modMask}) =
  -- Divide physical screen in 3 panes
  --addKeyBinding modMask xK_s (layoutScreens 3 $ ThreeColMid 1 0 (1/2)) $
  -- Revert to single screen
  --addKeyBinding cModShift xK_s rescreen $
  --addKeyBinding modMask xK_s (toggleLayoutScreens refState) $
  --addKeyBinding cModCtrl xK_s (spawn $ "xmessage " ++ show width ) $

  addKeyBinding modMask xK_b (spawn dmenuBrightness) $
  addKeyBinding cModShift xK_p (sendMessage (IncMasterN 1)) $
  addKeyBinding cModShift xK_o (sendMessage (IncMasterN (-1))) $
  addKeyBinding modMask xK_Return (spawn $ XMonad.terminal conf) $
  addKeyBinding cModCtrl xK_space (setLayout $ XMonad.layoutHook conf) $
  addKeyBinding modMask xK_p (spawn rofiProg) $
  addKeyBinding cModCtrl xK_p (spawn "pavucontrol") $
  addKeyBinding cCtrl xK_period (spawn rofiPass) $
  addKeyBinding modMask xK_v (spawn rofiClipboard) $
  addKeyBinding cModShift xK_v (spawn greenclipClear) $
  -- Resize viewed windows to the correct size
  addKeyBinding cModShift xK_n refresh $
  addKeyBinding modMask xK_Right (windows W.focusDown) $
  addKeyBinding modMask xK_Left (windows W.focusUp) $
  -- this is defaulted to mod+<j,k>
  -- addKeyBinding modMask xK_l (windows W.focusDown) $
  -- addKeyBinding modMask xK_h (windows W.focusUp) $
  addKeyBinding cModShift xK_m (windows W.swapMaster) $
  addKeyBinding modMask xK_m (windows W.swapDown) $
  --addKeyBinding modMask xK_l (windows W.swapUp) $
  addKeyBinding cCtrlAlt xK_l (mapM_ spawn ["gnome-screensaver-command --lock"]) $
  addKeyBinding modMask xK_Down (sendMessage Shrink) $
  addKeyBinding modMask xK_Up (sendMessage Expand) $
  addKeyBinding modMask xK_f (sendMessage ToggleLayout) $
  addKeyBinding modMask xK_u focusUrgent $
  addKeyBinding cModShift xK_F4 (spawn screenshot) $
  -- scratchpads
  addKeyBinding cModShift xK_t (namedScratchpadAction myScratchpads "htop") $
  addKeyBinding modMask xK_d (namedScratchpadAction myScratchpads "vimScratchpad") $
  -- hide useless windows (webex...)
  -- addKeyBinding modMask xK_backslash (withFocused hideWindow) $
  -- addKeyBinding cModShift xK_backslash (popOldestHiddenWindow) $

  -- Float to center like webex window
  -- to center keeping size, use centerWindow instead of centerWebex
  addKeyBinding modMask xK_c (withFocused centerWebex) $

  -- Reset the layout
  addKeyBinding cModCtrlShift xK_space (sendMessage resetAlt) $
  addKeyBinding cModCtrl xK_Left prevWS $
  addKeyBinding cModCtrl xK_Right nextWS $
  addKeyBinding cModCtrl xK_Up toggleWS $
  addKeyBinding cModCtrl xK_Down toggleWS $
  addKeyBinding cModCtrlShift xK_Left (shiftToPrev >> prevWS) $
  addKeyBinding cModCtrlShift xK_Right (shiftToNext >> nextWS) $
  addKeyBinding cModCtrl xK_a (sendMessage MirrorShrink) $
  addKeyBinding cModCtrl xK_z (sendMessage MirrorExpand) $
  -- Restart
  addKeyBinding modMask xK_s (spawn "xmonad --recompile && xmonad --restart") $
  addKeyBinding cModShift xK_s (spawn "pgrep -f \"xmonad\" | xargs kill -9") $
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  ([ ((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        -- | (key, sc) <- zip [xK_w, xK_e, xK_r] [1,0,2] -- using ThreeCol with virtual screens, screens order are messed up
        | (key, sc) <- zip [xK_q, xK_w, xK_e] [0,1,2]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
   ]
   ++
   [ ((m .|. modMask, k), windows $ f i)
       | (i, k) <- zip (workspaces conf) numAzerty,
         (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
   ]
  )
  where
    cCtrl         = controlMask
    cModCtrl      = modMask .|. controlMask
    cModShift     = modMask .|. shiftMask
    cCtrlShift    = shiftMask .|. controlMask
    cCtrlAlt      = altKey .|. controlMask
    cModCtrlShift = cModCtrl .|. shiftMask
    numAzerty     = [0x26, 0xe9, 0x22, 0x27, 0x28, 0x2d, 0xe8, 0x5f, 0xe7, xK_0] ++ [xK_F1 .. xK_F12]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [
      -- Set the window to floating mode and move by dragging
      ((modMask, button1), (\w -> focus w >> mouseMoveWindow w)),
      -- Raise the window to the top of the stack
      ((modMask, button2), (\w -> focus w >> windows W.swapMaster)),
      -- Performs only a resize of the window, based on which quadrant the mouse is in.
      ((modMask, button3), ((\w -> focus w >> Flex.mouseWindow Flex.resize w)))
    ]

------------------------------------------------------------------------
-- Layouts:
--
full = noBorders Full
winDecoTabbed = tabbed shrinkText def {
  fontName = tabbedFont,
  decoHeight = 23
}
stdLayouts = hiddenWindows $ avoidStruts (smartBorders (threeCols ||| Grid ||| tiled ||| Mirror tiled)) ||| full
  where
    tiled = ResizableTall 1 0.1 0.1 []
    threeCols = ThreeColMid 1 (3 / 100) (1 / 2)

myLayout = (toggleLayouts $ avoidStruts winDecoTabbed) $ stdLayouts

------------------------------------------------------------------------
-- Window rules:
--
manageScratchThirdRight = customFloating (W.RationalRect l t w h)
  where
    h = 0.94
    w = 0.30
    t = (1 - h) / 2
    l = 1 - w - 0.005

manageScratchFromBottom = customFloating (W.RationalRect l t w h)
  where
    h = 0.94 -- terminal height
    w = 0.98 -- terminal width
    t = 1 - h -- distance from top edge
    l = (1 - w) / 2 -- distance from left edge

manageScratchCentered = customFloating (W.RationalRect l t w h)
  where
    h = 0.80 -- terminal height
    w = 0.80 -- terminal width
    t = (1 - h) / 2 -- distance from top edge
    l = (1 - w) / 2 -- distance from left edge

myScratchpads =
  [
    NS "htop" spawnHtop findHtop manageHtop,
    NS "vimScratchpad" spawnVimScratchpad findVimScratchpad manageVimScratchpad
  ]
  where
    -- htop
    spawnHtop = scratchTerminal ++ " --class scratchHtop -e htop"
    findHtop = resource =? "scratchHtop"
    manageHtop = manageScratchFromBottom
    -- alsamixer
    spawnAlsa = scratchTerminal ++ " --class alsamixer -e alsamixer"
    findAlsa = resource =? "alsamixer"
    manageAlsa = manageScratchCentered
    -- vim scratchpad
    spawnVimScratchpad = scratchTerminal ++ " --class vimScratchpad -e zsh -c 'nvim ~/.scratchpad'"
    findVimScratchpad = resource =? "vimScratchpad"
    manageVimScratchpad = manageScratchCentered


-- Get windows info with 'xprop' command
myManageHook = composeAll
    [ title =? "GNU Image Manipulation Program" --> doFloat,
      title =? "GIMP" --> doFloat,
      className =? "jetbrains-pycharm" --> doShift "6",
      className =? "jetbrains-idea" --> doShift "6",
      -- className =? "Pavucontrol" --> doRectFloat (W.RationalRect 0.35 0.1 0.3 0.8)
      className =? "Pavucontrol" --> manageScratchCentered
    ]
    <+> manageSpawn
    <+> namedScratchpadManageHook myScratchpads
    <+> manageDocks

------------------------------------------------------------------------
-- Status bars and logging
-- large first is workspaces and window's title
-- next, conky (700px)
-- remaining 100px for trayer app (see .xprofile file)
--
-- myStartupHook = setWMName "LG3D"
-- myStartupHook =
--   docksStartupHook
--     <+> setWMName "LG3D"
--     <+> setDefaultCursor xC_pirate

myStartupHook = do
  spawnOnce "polybar"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.
--
main = do
  refState <- newIORef False
  xmonad $
      docks $ ewmhFullscreen . ewmh $
      def {
        terminal = myTerminal,
        focusFollowsMouse = True,
        borderWidth = myBorderWidth,
        modMask = winKey,
        workspaces = myWorkspaces,
        normalBorderColor = colBorderNormal,
        focusedBorderColor = colBorderFocus,
        keys = newKeyBindings refState,
        mouseBindings = myMouseBindings,
        layoutHook = myLayout,
        manageHook = myManageHook,
        logHook = myStartupHook,
        handleEventHook = handleEventHook def
      }
