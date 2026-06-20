{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}

module Util
  ( MsgMetaData (..),
    zapEncode,
    zapDecode,
    zapCompile,
    zapCanonicalize,
    decodeValue,
    encodeValue,
    aircraftSchemaSrc,
    schemaSchemaSrc,
  )
where

import qualified Zap.Message as M
import Control.Monad.Trans (lift)
import Control.Monad.Trans.Resource (ResourceT, allocate, runResourceT)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Lazy.Char8 as LBSC8
import System.Directory (removeFile)
import System.Exit (ExitCode (..))
import System.IO
import System.Process hiding (readCreateProcessWithExitCode)
import System.Process.ByteString.Lazy (readCreateProcessWithExitCode)
import Text.Heredoc (there)

aircraftSchemaSrc, schemaSchemaSrc :: String
aircraftSchemaSrc = [there|tests/data/aircraft.zap|]
schemaSchemaSrc = [there|tests/data/schema.zap|]

-- | Information about the contents of a zap message. This is enough
-- to encode/decode both textual and binary forms.
data MsgMetaData = MsgMetaData
  { -- | The source of the schema
    msgSchema :: String,
    -- | The name of the root struct's type
    msgType :: String
  }
  deriving (Show)

zapCanonicalize :: LBS.ByteString -> IO LBS.ByteString
zapCanonicalize stdInBytes = do
  (exitStatus, stdOut, stdErr) <-
    readCreateProcessWithExitCode
      (proc "zap" ["convert", "binary:canonical"])
      stdInBytes
  case exitStatus of
    ExitSuccess -> pure stdOut
    ExitFailure code ->
      fail $
        concat
          [ "zap convert binary:canonical failed with exit code ",
            show code,
            ":\n",
            show stdErr
          ]

-- | @zapEncode msg meta@ runs @zap encode@ on the message, providing
-- the needed metadata and returning the output
zapEncode :: String -> MsgMetaData -> IO BS.ByteString
zapEncode msgValue meta = do
  (exitStatus, stdOut, stdErr) <-
    runResourceT $
      interactZapWithSchema "encode" (msgSchema meta) (LBSC8.pack msgValue) [msgType meta]
  case exitStatus of
    ExitSuccess -> return (LBS.toStrict stdOut)
    ExitFailure code -> fail ("`zap encode` failed with exit code " ++ show code ++ ":\n" ++ show stdErr)

-- | @zapDecode msg meta@ runs @zap decode@ on the message, providing
-- the needed metadata and returning the output
zapDecode :: BS.ByteString -> MsgMetaData -> IO String
zapDecode encodedMsg meta = do
  (exitStatus, stdOut, stdErr) <-
    runResourceT $
      interactZapWithSchema "decode" (msgSchema meta) (LBS.fromStrict encodedMsg) [msgType meta]
  case exitStatus of
    ExitSuccess -> return (LBSC8.unpack stdOut)
    ExitFailure code -> fail ("`zap decode` failed with exit code " ++ show code ++ ":\n" ++ show stdErr)

-- | @zapCompile msg meta@ runs @zap compile@ on the schema, providing
-- the needed metadata and returning the output
zapCompile :: String -> String -> IO BS.ByteString
zapCompile msgSchema outputArg = do
  (exitStatus, stdOut, stdErr) <-
    runResourceT $
      interactZapWithSchema "compile" msgSchema LBSC8.empty ["-o", outputArg]
  case exitStatus of
    ExitSuccess -> return (LBS.toStrict stdOut)
    ExitFailure code -> fail ("`zap compile` failed with exit code " ++ show code ++ ":\n" ++ show stdErr)

-- | A helper for @zapEncode@ and @zapDecode@. Launches the zap command
-- with the given subcommand (either "encode" or "decode") and metadata,
-- returning handles to its standard in and standard out. This runs inside
-- ResourceT, and sets the handles up to be closed and the process to be reaped
-- when the ResourceT exits.
interactZapWithSchema :: String -> String -> LBS.ByteString -> [String] -> ResourceT IO (ExitCode, LBS.ByteString, LBS.ByteString)
interactZapWithSchema subCommand msgSchema stdInBytes args = do
  let writeTempFile = runResourceT $ do
        (_, (path, hndl)) <-
          allocate
            (openTempFile "/tmp" "schema.zap")
            (\(_, hndl) -> hClose hndl)
        lift $ hPutStr hndl msgSchema
        return path
  schemaFile <- snd <$> allocate writeTempFile removeFile
  lift $ readCreateProcessWithExitCode (proc "zap" ([subCommand, schemaFile] ++ args)) stdInBytes

-- | @'decodeValue' schema typename message@ decodes the value at the root of
-- the message and converts it to text. This is a thin wrapper around
-- 'zapDecode'.
decodeValue :: String -> String -> M.Message 'M.Const -> IO String
decodeValue schema typename msg =
  let bytes = M.encode msg
   in zapDecode
        (LBS.toStrict $ BB.toLazyByteString bytes)
        (MsgMetaData schema typename)

-- | @'encodeValue' schema typename value@ encodes the textual value @value@
-- as a zap message. This is a thin wrapper around 'zapEncode'.
encodeValue :: String -> String -> String -> IO (M.Message 'M.Const)
encodeValue schema typename value =
  let meta = MsgMetaData schema typename
   in zapEncode value meta >>= M.decode
