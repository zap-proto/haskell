{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeApplications #-}

module Main (main) where

import qualified Zap as C
import Zap.Mutability (thaw)
import qualified Zap.Untyped as U
import Control.DeepSeq (NFData (..))
import Control.Monad (unless)
import Criterion.Main
import qualified Data.ByteString as BS
import System.Exit (ExitCode (..))
import qualified System.Process.ByteString as PB

-- Get the raw bytes of a CodeGeneratorRequest for all of the bundled
-- zap core schema. Useful as a source of generic test data.
getCGRBytes :: IO BS.ByteString
getCGRBytes = do
  (exit, cgrBytes, _) <-
    PB.readProcessWithExitCode
      "zap"
      [ "compile",
        "-o-",
        "-I",
        "core-schema/",
        "--src-prefix=core-schema/",
        "core-schema/zap/schema.zap",
        "core-schema/zap/stream.zap",
        "core-schema/zap/rpc-twoparty.zap",
        "core-schema/zap/persistent.zap",
        "core-schema/zap/rpc.zap",
        "core-schema/zap/compat/json.zap",
        "core-schema/zap/c++.zap"
      ]
      ""
  unless (exit == ExitSuccess) $ error "zap compile failed"
  pure cgrBytes

instance NFData (C.Message mut) where
  rnf = (`seq` ())

main :: IO ()
main = do
  cgrBytes <- getCGRBytes
  msg <- C.bsToMsg cgrBytes
  let whnfLTIO = whnfIO . C.evalLimitT maxBound
  defaultMain
    [ bench "canonicalize/IO" $ whnfLTIO $ do
        root <- U.rootPtr msg
        C.canonicalize root,
      bench "canonicalize/PureBuilder" $ whnfLTIO $ do
        C.createPure maxBound $ do
          root <- U.rootPtr msg
          (msg, _seg) <- C.canonicalize root
          pure msg,
      env
        ( C.evalLimitT maxBound $ do
            mutMsg <- thaw msg
            newMsg <- C.newMessage Nothing
            pure (mutMsg, newMsg)
        )
        ( \ ~(mutMsg, newMsg) -> bench "copy" $ whnfLTIO $ do
            root <- U.rootPtr mutMsg
            U.copyPtr newMsg (Just (U.PtrStruct root))
        )
    ]
