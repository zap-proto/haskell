{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE TypeApplications #-}

module Examples.Serialization.HighLevel.Read (main) where

import Zap.Gen.Addressbook
import Zap (defaultLimit, getParsed)

main :: IO ()
main = do
  value <- getParsed @AddressBook defaultLimit
  print value
