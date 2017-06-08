{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module Gx.Internal.Backend.Types
  ( module Gx.Internal.Backend.Types
  , module Gx.Data.Window
  )
where


import Gx.Data.Window
import qualified Gx.Data.Input as I

import Control.Lens
import Data.IORef
import Linear

-- | The functions every backend window managed backend needs to support.
--
--   The Backend module interfaces with the window manager, and handles opening
--   and closing the window, and managing key events etc.
--
--   It doesn't know anything about drawing lines or setting colors.
--   When we get a display callback, Vish will perform OpenGL actions, and
--   the backend needs to have OpenGL in a state where it's able to accept them.
--
class Backend a where
        -- | Initialize the state used by the backend. If you don't use any state,
        -- make a Unit-like type; see the GLUT backend for an example.
        initBackendState           :: a

        -- | Perform any initialization that needs to happen before opening a window
        --   The Boolean flag indicates if any debug information should be printed to
        --   the terminal
        initializeBackend          :: IORef a -> Bool -> IO ()

        -- | Perform any deinitialization and close the backend.
        exitBackend                :: IORef a -> IO ()

        -- | Open a window with the given display mode.
        openWindow                 :: IORef a -> Window -> IO ()

        -- | Dump information about the backend to the terminal.
        dumpBackendState           :: IORef a -> IO ()

        -- | Install the display callbacks.
        installCallbacks           :: IORef a -> Callbacks -> IO ()

        -- | The mainloop of the backend.
        runMainLoop                :: IORef a -> IO ()

        -- | Function that returns (width,height) of the window in pixels.
        getWindowDimensions        :: IORef a -> IO (Maybe (V2 Int))

        -- | Function that reports the time elapsed since the application started.
        --   (in seconds)
        elapsedTime                :: IORef a -> IO Double

        -- | Function that puts the current thread to sleep for 'n' seconds.
        sleep                      :: IORef a -> Double -> IO ()

data InputState = Up | Down

class ConvBackend a b where
  fromBackend :: a -> b

instance ConvBackend InputState I.InputState where
  fromBackend inputState =
    case inputState of
      Up -> I.Up
      Down -> I.Down


-- The callbacks should work for all backends. We pass a reference to the
-- backend state so that the callbacks have access to the class dictionary and
-- can thus call the appropriate backend functions.

-- | Display callback has no arguments.
type DisplayCallback       = forall a . Backend a => IORef a -> IO ()

-- | App pause callback has no arguments.
type PauseCallback      = forall a . Backend a => IORef a -> IO ()

-- | App resume callback has no argument.
type ResumeCallback      = forall a . Backend a => IORef a -> IO ()

-- | Close callback has no arguments.
type CloseCallBack         = forall a . Backend a => IORef a -> IO ()

-- | Arguments: (Width,Height) in pixels.
type ReshapeCallback       = forall a . Backend a => IORef a -> V2 Int -> IO ()

-- | Arguments: KeyType, Key Up \/ Down, Ctrl \/ Alt \/ Shift pressed
type KeyboardCallback = forall a . Backend a => IORef a -> I.Key -> InputState -> IO ()

-- | Arguments: (PosX,PosY) in pixels.
type MouseMoveCallback        = forall a . Backend a => IORef a -> V2 Double -> IO ()

-- | Arguments: Mouse button, Key Up \/ Down, Ctrl \/ Alt \/ Shift pressed, latest mouse location.
type MouseButtonCallback = forall a . Backend a => IORef a -> I.MouseButton -> InputState -> V2 Double -> IO ()

-- | Arguments: (ScrollX, ScrollY)
type ScrollCallback = forall a. Backend a => IORef a -> V2 Double -> IO ()

data Callbacks = Callbacks
  { displayCallback :: DisplayCallback
  , pauseCallback :: PauseCallback
  , resumeCallback :: ResumeCallback
  , closeCallback :: CloseCallBack
  , reshapeCallback :: ReshapeCallback
  , keyboardCallback :: KeyboardCallback
  , mouseMoveCallback :: MouseMoveCallback
  , mouseButtonCallback :: MouseButtonCallback
  , scrollCallback :: ScrollCallback
  }

defaultCallbacks :: Callbacks
defaultCallbacks =
  Callbacks
  { displayCallback     = defaultDisplayCallback
  , pauseCallback       = defaultPauseCallback
  , resumeCallback      = defaultResumeCallback
  , closeCallback       = defaultCloseCallback
  , reshapeCallback     = defaultReshapeCallback
  , keyboardCallback    = defaultKeyboardCallback
  , mouseMoveCallback   = defaultMouseMoveCallback
  , mouseButtonCallback = defaultMouseButtonCallback
  , scrollCallback      = defaultScrollCallback
  }

defaultDisplayCallback :: DisplayCallback
defaultDisplayCallback _ = return ()

defaultPauseCallback :: PauseCallback
defaultPauseCallback _ = return ()

defaultResumeCallback :: ResumeCallback
defaultResumeCallback _ = return ()

defaultCloseCallback :: CloseCallBack
defaultCloseCallback _ = return ()

defaultReshapeCallback :: ReshapeCallback
defaultReshapeCallback _ _ = return ()

defaultKeyboardCallback :: KeyboardCallback
defaultKeyboardCallback _ _ _ = return ()

defaultMouseMoveCallback :: MouseMoveCallback
defaultMouseMoveCallback _ _ = return ()

defaultMouseButtonCallback :: MouseButtonCallback
defaultMouseButtonCallback _ _ _ _ = return ()

defaultScrollCallback :: ScrollCallback
defaultScrollCallback _ _  = return ()