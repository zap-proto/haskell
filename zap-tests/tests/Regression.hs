{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module Regression (regressionTests) where

import Zap (bsToParsed, def, evalLimitT)
import Zap.Gen.Aircraft
import Zap.Gen.Zap.Rpc
import Test.Hspec

regressionTests :: Spec
regressionTests = describe "Regression tests" $ do
  it "Should decode abort message successfully (issue #56)" $ do
    -- Valid serialization of the (zap-branded) abort message below. The earlier
    -- literal was corrupted by the capnp->zap rebrand: a find-replace shortened
    -- the embedded "...capnproto library" text to "...zap library" without
    -- updating the list-pointer length word, so the decoder over-read and threw
    -- TraversalLimitError. Regenerated via parsedToLBS of the expected Message.
    let bytes =
          "\NUL\NUL\NUL\NUL\ETB\NUL\NUL\NUL\NUL\NUL\NUL\NUL\SOH\NUL\SOH\NUL\SOH\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\SOH\NUL\SOH\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\SOH\NUL\NUL\NULJ\EOT\NUL\NULYour vat sent an 'unimplemented' message for an abort message that its remote peer never sent. This is likely a bug in your zap library.\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL"
    msg <- evalLimitT maxBound $ bsToParsed bytes
    msg
      `shouldBe` Message
        ( Message'abort
            def
              { reason =
                  "Your vat sent an 'unimplemented' message for an abort "
                    <> "message that its remote peer never sent. This is likely "
                    <> "a bug in your zap library.",
                type_ = Exception'Type'failed
              }
        )
  it "Should decode negative default values correctly (issue #55)" $ do
    -- Note that this was never actually broken, but we were getting
    -- a warning about a literal overflowing the bounds of its type.
    -- It worked anyway, since it became the right value after casting,
    -- but the warning has been fixed and this test makes sure it still
    -- actually works.
    let Defaults {int} = def
    int `shouldBe` (-123)
