{-# LANGUAGE NamedFieldPuns #-}

module System.Nemesis.DSL where

import Control.Monad.State hiding (State, join)
import Data.Default
import Prelude hiding ((.), (>), (^), lookup)
import System
import System.Nemesis
import System.Nemesis.Util

desc :: String -> Unit
desc s = do
  n <- get
  put n {current_desc = Just s}

task :: String -> IO () -> Unit
task s action = 
  if s.has ':'
    then
      let h = s.takeWhile (/= ':')
          t = s.dropWhile (/= ':') .tail
      in
      task' (h.strip) (t.words)
    else
      task' s []
  where
    task' name deps = insert_task def {name, deps, action}
    strip = dropWhile (== ' ') > reverse > dropWhile (== ' ') > reverse

sh :: String -> IO ()
sh s = do
  status <- system s
  case status of 
    ExitSuccess -> return ()
    ExitFailure code -> error $ s ++ " failed with status code: " ++ show code

clean :: [String] -> Unit
clean xs = do
  desc "Remove any temporary products. map (rm -rf)"
  task "clean" $ mapM_ (\x -> sh ("rm  -rf " ++ x)) xs