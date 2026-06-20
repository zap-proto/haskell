module Main (main) where

import qualified CalculatorExample
import qualified Constants
import Module.Zap.Basics (basicsTests)
import Module.Zap.Bits (bitsTests)
import Module.Zap.Canonicalize (canonicalizeTests)
import Module.Zap.Gen.Zap.Schema (schemaTests)
import Module.Zap.Gen.Zap.Schema.Pure (pureSchemaTests)
import Module.Zap.Pointer (ptrTests)
import Module.Zap.Rpc (rpcTests)
import Module.Zap.Untyped (untypedTests)
import Module.Zap.Untyped.Pure (pureUntypedTests)
import qualified PointerOOB
import Regression (regressionTests)
import Rpc.Unwrap (unwrapTests)
import SchemaQuickCheck (schemaCGRQuickCheck)
import Test.Hspec
import WalkSchemaCodeGenRequest (walkSchemaCodeGenRequestTest)

main :: IO ()
main = hspec $ do
  describe "Tests for specific modules" $ do
    describe "Zap.Basics" basicsTests
    describe "Zap.Bits" bitsTests
    describe "Zap.Pointer" ptrTests
    describe "Zap.Rpc" rpcTests
    describe "Zap.Untyped" untypedTests
    describe "Zap.Untyped.Pure" pureUntypedTests
    describe "Zap.Canonicalize" canonicalizeTests
  describe "Tests for generated output" $ do
    describe "low-level output" schemaTests
    describe "high-level output" pureSchemaTests
  describe "Tests relate to schema" $ do
    describe "tests using tests/data/schema-codegenreq" walkSchemaCodeGenRequestTest
    describe "property tests for schema" schemaCGRQuickCheck
  describe "Regression tests" regressionTests
  CalculatorExample.tests
  PointerOOB.tests
  Constants.tests
  describe "Tests for client unwrapping" unwrapTests
