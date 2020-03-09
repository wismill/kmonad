module KLisp.Types
  ( -- * $bsc
    Parser
  , PErrors

    -- * $but
  , DefButton(..)

    -- * $tls
  , DefAlias
  , DefIO(..)
  , DefLayer(..)
  , DefSrc
  , KExpr(..)

    -- * $defio
  , IToken(..)
  , OToken(..)

    -- * Reexports
  , module Text.Megaparsec
  , module Text.Megaparsec.Char
) where


import KPrelude

import KMonad.Keyboard

import Text.Megaparsec
import Text.Megaparsec.Char

import qualified RIO.HashMap as M

--------------------------------------------------------------------------------
-- $bsc
--
-- The basic types of parsing

-- | Parser's operate on Text and carry no state
type Parser = Parsec Void Text

-- | The type of errors returned by the Megaparsec parsers
type PErrors = ParseErrorBundle Text Void


--------------------------------------------------------------------------------
-- $but
--
-- Tokens representing different types of buttons

-- | Button ADT
data DefButton
  = KRef Text                              -- ^ Reference a named button
  | KEmit Keycode                          -- ^ Emit a keycode
  | KLayerToggle Text                      -- ^ Toggle to a layer when held
  | KTapNext DefButton DefButton           -- ^ Do 2 things based on behavior
  | KTapHold Int DefButton DefButton       -- ^ Do 2 things based on behavior and delay
  | KMultiTap [(Int, DefButton)] DefButton -- ^ Do things depending on tap-count
  | KAround DefButton DefButton            -- ^ Wrap 1 button around another
  | KTapMacro [DefButton]                  -- ^ Sequence of buttons to tap
  | KTrans                                 -- ^ Transparent button that does nothing
  | KBlock                                 -- ^ Button that catches event
  deriving Show


--------------------------------------------------------------------------------
-- $tls
--
-- A collection of all the different top-level statements possible in a config
-- file.

-- | A list of keycodes describing the ordering of all the other layers
type DefSrc = [Keycode]

-- | A mapping from names to button tokens
type DefAlias = M.HashMap Text DefButton

-- | A layer of buttons
data DefLayer = DefLayer
  { _layerName :: Text        -- ^ A unique name used to refer to this layer
  , _buttons   :: [DefButton] -- ^ A list of button tokens
  }
  deriving Show

-- | A collection of all the IO configuration for KMonad
data DefIO = DefIO
  { _itoken  :: IToken     -- ^ How to read key events from the OS
  , _otoken  :: OToken     -- ^ How to write key events to the OS
  , _initStr :: Maybe Text -- ^ Shell command to execute before starting
  }
  deriving Show


--------------------------------------------------------------------------------
-- $defio
--
-- Different IO settings

-- | All different input-tokens KMonad can take
data IToken
  = KDeviceSource FilePath
  deriving Show

-- | All different output-tokens KMonad can take
data OToken
  = KUinputSink Text (Maybe Text)
  deriving Show


--------------------------------------------------------------------------------
-- $tkn

data KExpr
  = KDefIO    DefIO
  | KDefSrc   DefSrc
  | KDefLayer DefLayer
  | KDefAlias DefAlias
  deriving Show
makePrisms ''KExpr