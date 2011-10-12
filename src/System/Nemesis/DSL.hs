{-# LANGUAGE NamedFieldPuns #-}

module System.Nemesis.DSL where

import Control.Monad.State hiding (State, join)
import Data.List (nub, sort)
import Prelude ()
import Air.Env
import System.Exit
import System.Process
import System.Directory
import System.FilePath.Glob
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

namespace :: String -> Unit -> Unit
namespace name unit = do
  push name
  unit
  pop
  
  where
    push s = do
      n <- get
      let current_namespace' = s : n.current_namespace
      put n {current_namespace = current_namespace'}
    
    pop = do
      n <- get
      let current_namespace' = n.current_namespace.tail
      put n {current_namespace = current_namespace'}
      
sh :: String -> IO ()
sh s = do
  status <- system s
  case status of 
    ExitSuccess -> return ()
    ExitFailure code -> error - s + " failed with status code: " + show code

clean :: [String] -> Unit
clean xs = do
  desc "Remove any temporary products."
  task "clean" - do
    paths <- globDir (xs.map compile) "." ^ fst ^ join' ^ nub ^ sort ^ reverse
    mapM_ rm_any paths
    where
      rm_any s = do
        file_exist <- doesFileExist s
        when file_exist - rm s
        dir_exist <- doesDirectoryExist s
        when dir_exist - rm_rf s