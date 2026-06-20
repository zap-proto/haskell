-- | Module: Zap
-- Description: Re-export commonly used things from elsewhere in the library.
module Zap
  ( module X,
    Parsed,

    -- * Working with raw values
    R.Raw (..),

    -- ** Working with raw lists
    R.List,
    R.index,
    R.setIndex,
    R.length,

    -- * Working with fields
    F.Field,
    F.FieldKind,
    F.HasField (..),
    F.HasUnion (..),
    F.HasVariant (..),

    -- * Working with messages
    Message.Message,
    Message.Segment,
    Message.Mutability (..),
    Message.MonadReadMessage (..),
    Message.newMessage,
    Message.fromByteString,
    Message.toByteString,

    -- * Building messages in pure code
    PureBuilder,
    createPure,

    -- * Canonicalizing messages
    canonicalize,

    -- * Implementing RPC servers
    MethodHandler,
    SomeServer (..),
    Export (Server),
    export,
    handleParsed,
    handleRaw,
    methodUnimplemented,

    -- * Shorthands for types
    R.IsStruct,
    R.IsCap,
    R.IsPtr,

    -- * Re-exported from "Data.Default", for convienence.
    def,
  )
where

-- TODO: be more intentional about the ordering of the stuff we're
-- currently exposing as X, so the haddocks are clearer.

import Zap.Accessors as X
import Zap.Basics as X hiding (Parsed)
import Zap.Canonicalize (canonicalize)
import Zap.Classes as X hiding (Parsed)
import Zap.Constraints as X
import Zap.Convert as X
import qualified Zap.Fields as F
import Zap.IO as X
import qualified Zap.Message as Message
import qualified Zap.Repr as R
import Zap.Repr.Methods as X
import Zap.Repr.Parsed (Parsed)
import Zap.Rpc.Server
import Zap.TraversalLimit as X
import Data.Default (def)
import Internal.BuildPure (PureBuilder, createPure)
import Internal.Rpc.Export (export)
