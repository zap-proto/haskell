{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}

-- | Module: Zap.Constraints
-- Description: convenience shorthands for various constraints.
module Zap.Constraints where

import qualified Zap.Classes as C
import qualified Zap.Repr as R
import qualified Zap.Repr.Parsed as RP

-- | Constraints needed for @a@ to be a zap type parameter.
type TypeParam a =
  ( R.IsPtr a,
    C.Parse a (RP.Parsed a)
  )
