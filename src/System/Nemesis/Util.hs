{-# LANGUAGE NoMonomorphismRestriction #-}

module System.Nemesis.Util (
    module MPS.Light
  , ls
  , rm
  , rm_rf
) where

import System.Directory
import MPS.Light
import Prelude hiding ((^), (.), (>))
import Data.List ((\\))


ls :: String -> IO [String]
ls s = getDirectoryContents s ^ (\\ [".", ".."])

rm :: String -> IO ()
rm = removeFile

rm_rf :: String -> IO ()
rm_rf = removeDirectoryRecursive