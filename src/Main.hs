
module Main where

import System.Nemesis.Titan
import Test.Hspec
import System.Nemesis

spec :: IO ()
spec = hspec $ do
  describe "Main" $ do
    it "should run spec" True

main = do
  with_spec spec halt
