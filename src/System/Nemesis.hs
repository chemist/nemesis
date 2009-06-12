{-# LANGUAGE NamedFieldPuns #-}

module System.Nemesis (run, sh, task) where

import MPS hiding (empty)
import Prelude hiding ((.), (>), (^), lookup)
import Control.Monad.State hiding (State, join)
import Data.Default
import Data.Map (Map, insert, empty, lookup, elems)
import System.Cmd (system)
import System
import GHC.IOBase hiding (liftIO)

data Task = Task
  {
    name :: String
  , action :: IO ()
  , deps :: [String]
  }

data Nemesis = Nemesis
  {
    tasks :: Map String Task
  , target :: String
  }
  deriving (Show)

instance Default Nemesis where
  def = Nemesis empty def

instance Default Task where
  def = Task def (return ()) def

instance Show Task where
  show x 
    | x.deps.null = title
    | otherwise = 
      [
        title
      , x.deps.join " "
      , ""
      ] .concat
    where
      title = x.name.ljust 20 ' ' ++ ": "

instance Eq Task where
  a == b = a.name == b.name

instance Ord Task where
  compare = compare_by name

type Unit = StateT Nemesis IO ()

-- sh :: String -> IO GHC.IOBase.ExitCode
sh :: String -> IO ()
sh s = do
  status <- system s
  case status of 
    ExitSuccess -> return ()
    ExitFailure code -> error $ s ++ " failed with status code" ++ show code

run :: Unit -> IO ()
run unit = do
  args <- getArgs
  if args.null
    then help
    else execStateT unit def {target = args.first} >>= run_nemesis
  
  where
    help = execStateT unit def >>= list_task
    list_task n = do
      br
      n.tasks.elems.mapM_ print
      br
    br = putStrLn ""

task :: String -> IO () -> Unit
task s action = 
  let x:xs = s.split "\\s*:\\s*"
  in
  task' x (xs.join'.words)
  where
    task' name deps = insert_task Task {name, deps, action}

insert_task :: Task -> Unit
insert_task t = do
  n <- get
  let tasks' = n.tasks.insert (t.name) t
  put n {tasks = tasks'}

run_nemesis :: Nemesis -> IO ()
run_nemesis n = run' (n.target)
  where
    run' :: String -> IO ()
    run' s = case (n.tasks.lookup s) of
      Nothing -> bye
      Just x -> revenge x
      where
        bye = error $ s ++  " does not exist!"

    revenge :: Task -> IO ()
    revenge t = t.deps.to_list.mapM_ run' >> revenge_and_say
      where
        revenge_and_say = do
          -- putStrLn $ "running: " ++ t.name
          t.action