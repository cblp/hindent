{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleContexts #-}

-- | All types.
module HIndent.Types
  ( Printer(..)
  , PrintState(..)
  , Config(..)
  , defaultConfig
  , NodeInfo(..)
  , NodeComment(..)
  , SomeComment(..)
  ) where

import           Control.Applicative
import           Control.Monad
import           Control.Monad.State.Strict (MonadState(..), StateT)
import           Control.Monad.Trans.Maybe
import           Data.ByteString.Builder
import           Data.Functor.Identity
import           Data.Int (Int64)
import           Data.Maybe
import           Data.Yaml (FromJSON(..))
import qualified Data.Yaml as Y
import           Language.Haskell.Exts.SrcLoc

-- | A pretty printing monad.
newtype Printer a = Printer
  { runPrinter :: StateT PrintState (MaybeT Identity) a
  } deriving ( Applicative
             , Monad
             , Functor
             , MonadState PrintState
             , MonadPlus
             , Alternative
             )

-- | The state of the pretty printer.
data PrintState = PrintState
  { psIndentLevel :: !Int64
    -- ^ Current indentation level, i.e. every time there's a
    -- new-line, output this many spaces.
  , psOutput :: !Builder
    -- ^ The current output bytestring builder.
  , psNewline :: !Bool
    -- ^ Just outputted a newline?
  , psColumn :: !Int64
    -- ^ Current column.
  , psLine :: !Int64
    -- ^ Current line number.
  , psConfig :: !Config
    -- ^ Configuration of max colums and indentation style.
  , psInsideCase :: !Bool
    -- ^ Whether we're in a case statement, used for Rhs printing.
  , psHardLimit :: !Bool
    -- ^ Bail out if we exceed current column.
  , psEolComment :: !Bool
  }

-- | Configurations shared among the different styles. Styles may pay
-- attention to or completely disregard this configuration.
data Config = Config
  { configMaxColumns :: !Int64 -- ^ Maximum columns to fit code into ideally.
  , configIndentSpaces :: !Int64 -- ^ How many spaces to indent?
  , configTrailingNewline :: !Bool -- ^ End with a newline.
  , configSortImports :: !Bool -- ^ Sort imports in groups.
  }

instance FromJSON Config where
  parseJSON (Y.Object v) =
    Config <$>
    fmap (fromMaybe (configMaxColumns defaultConfig)) (v Y..:? "line-length") <*>
    fmap
      (fromMaybe (configIndentSpaces defaultConfig))
      (v Y..:? "indent-size" <|> v Y..:? "tab-size") <*>
    fmap
      (fromMaybe (configTrailingNewline defaultConfig))
      (v Y..:? "force-trailing-newline") <*>
    fmap (fromMaybe (configSortImports defaultConfig)) (v Y..:? "sort-imports")
  parseJSON _ = fail "Expected Object for Config value"

-- | Default style configuration.
defaultConfig :: Config
defaultConfig =
  Config
  { configMaxColumns = 80
  , configIndentSpaces = 2
  , configTrailingNewline = True
  , configSortImports = True
  }

-- | Some comment to print.
data SomeComment
  = EndOfLine String
  | MultiLine String
  deriving (Show, Ord, Eq)

-- | Comment associated with a node.
-- 'SrcSpan' is the original source span of the comment.
data NodeComment
  = CommentBeforeLine SrcSpan
                      SomeComment
  | CommentSameLine SrcSpan
                    SomeComment
  | CommentAfterLine SrcSpan
                     SomeComment
  | CommentDetached SrcSpan
                    SomeComment
  deriving (Show, Eq)

instance Ord NodeComment where
  CommentBeforeLine {} <= _ = True
  CommentSameLine {} <= CommentBeforeLine {} = False
  CommentSameLine {} <= _ = True
  CommentAfterLine {} <= CommentBeforeLine {} = False
  CommentAfterLine {} <= CommentSameLine {} = False
  CommentAfterLine {} <= _ = True
  CommentDetached {} <= CommentDetached {} = True
  CommentDetached {} <= _ = False

-- | Information for each node in the AST.
data NodeInfo = NodeInfo
  { nodeInfoSpan :: !SrcSpanInfo -- ^ Location info from the parser.
  , nodeInfoComments :: ![NodeComment] -- ^ Comments attached to this node.
  }

instance Show NodeInfo where
  show (NodeInfo _ []) = "NodeInfo{}"
  show (NodeInfo _ s) = "NodeInfo{nodeInfoComments=" ++ show s ++ "}"
