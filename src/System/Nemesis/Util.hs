{-# LANGUAGE NoMonomorphismRestriction #-}

module System.Nemesis.Util (
    module MPS.Env
  , ls
  , rm
  , rm_rf
) where

import System.Directory
import MPS.Env hiding (lookup)
import Prelude ()
import Data.List ((\\))

ls :: String -> IO [String]
ls s = getDirectoryContents s ^ (\\ [".", ".."])

rm :: String -> IO ()
rm = removeFile

rm_rf :: String -> IO ()
rm_rf = removeDirectoryRecursive
