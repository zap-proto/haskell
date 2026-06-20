{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module SchemaQuickCheck (schemaCGRQuickCheck) where

import Zap.Convert (bsToParsed)
import Zap.Errors (Error)
import qualified Zap.Gen.Zap.Schema as Schema
import Zap.TraversalLimit (defaultLimit, evalLimitT)
-- Testing framework imports

-- Schema generation imports

-- Schema validation imports
import Control.Monad.Catch as C
import qualified Data.ByteString as BS
import SchemaGeneration
import Test.Hspec
import Test.QuickCheck
import Util

-- Functions to generate valid CGRs

generateCGR :: Schema -> IO BS.ByteString
generateCGR schema = zapCompile (show schema) "-"

-- Functions to validate CGRs

decodeCGR :: BS.ByteString -> IO ()
decodeCGR bytes = do
  _ <- evalLimitT defaultLimit (bsToParsed @Schema.CodeGeneratorRequest bytes)
  pure ()

-- QuickCheck properties

prop_schemaValid :: Schema -> Property
prop_schemaValid schema = ioProperty $ do
  compiled <- generateCGR schema
  decoded <- try $ decodeCGR compiled
  return $ case (decoded :: Either Error ()) of
    Left _ -> False
    Right _ -> True

schemaCGRQuickCheck :: Spec
schemaCGRQuickCheck =
  describe "generateCGR an decodeCGR agree" $
    it "successfully decodes generated schema" $
      property $
        prop_schemaValid <$> genSchema
