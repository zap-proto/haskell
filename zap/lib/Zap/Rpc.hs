-- |
-- Module: Zap.Rpc
-- Description: Zap RPC system
--
-- This module exposes the most commonly used parts of the RPC subsystem.
module Zap.Rpc
  ( -- * Establishing connections
    Conn,
    ConnConfig (..),
    acquireConn,
    handleConn,
    withConn,
    requestBootstrap,

    -- * throwing errors
    throwFailed,

    -- * Transmitting messages
    Transport (..),
    socketTransport,
    handleTransport,
    tracingTransport,

    -- * Promises
    module Zap.Rpc.Promise,

    -- * Clients
    Client,
    IsClient (..),
    newPromiseClient,
    waitClient,

    -- ** Reflection
    Untyped.unwrapServer,

    -- * Supervisors
    module Supervisors,

    -- * Misc.
  )
where

import Zap.Rpc.Errors (throwFailed)
import Zap.Rpc.Promise
import Zap.Rpc.Transport
  ( Transport (..),
    handleTransport,
    socketTransport,
    tracingTransport,
  )
import Zap.Rpc.Untyped
  ( Client,
    Conn,
    ConnConfig (..),
    IsClient (..),
    acquireConn,
    handleConn,
    newPromiseClient,
    requestBootstrap,
    waitClient,
    withConn,
  )
import qualified Zap.Rpc.Untyped as Untyped
import Supervisors
