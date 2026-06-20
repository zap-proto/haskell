{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}

module Zap.GenHelpers.Rpc
  ( module Zap.Rpc.Server,
    module Zap.Repr.Methods,
    parseCap,
    encodeCap,
  )
where

import Zap.Message (Mutability (..))
import qualified Zap.Message as M
import qualified Zap.Repr as R
import Zap.Repr.Methods
import Zap.Rpc.Server
import qualified Zap.Untyped as U

parseCap :: (R.IsCap a, U.ReadCtx m 'Const) => R.Raw a 'Const -> m (Client a)
parseCap (R.Raw cap) = Client <$> U.getClient cap

encodeCap :: (R.IsCap a, U.RWCtx m s) => M.Message ('Mut s) -> Client a -> m (R.Raw a ('Mut s))
encodeCap msg (Client c) = R.Raw <$> U.appendCap msg c
