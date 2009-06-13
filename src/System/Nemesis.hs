{-# LANGUAGE NamedFieldPuns #-}

module System.Nemesis where

import Control.Monad.State hiding (State, join)
import Data.Default
import Data.List (sort)
import Data.Map (Map, insert, empty, lookup, elems)
import Prelude hiding ((.), (>), (^), lookup)
import System
import System.Nemesis.Util

data Task = Task
  {
    name :: String
  , action :: IO ()
  , deps :: [String]
  , description :: Maybe String
  }

data Nemesis = Nemesis
  {
    tasks :: Map String Task
  , target :: String
  , current_desc :: Maybe String
  }
  deriving (Show)

instance Default Nemesis where
  def = Nemesis empty def def

instance Default Task where
  def = Task def (return ()) def def

instance Show Task where
  show x = case x.description of
    Nothing -> title
    Just s -> title ++ s
    where
      title = x.name.ljust 20 ' ' ++ ": "

instance Eq Task where
  a == b = a.name == b.name

instance Ord Task where
  compare = compare_by name

type Unit = StateT Nemesis IO ()


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
      n.tasks.elems.sort.mapM_ print
      br
    br = putStrLn ""

insert_task :: Task -> Unit
insert_task t = do
  n <- get
  let description = n.current_desc
      tasks' = n.tasks.insert (t.name) t {description}
     
  put n {tasks = tasks', current_desc = Nothing}

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
    revenge t = t.deps.mapM_ run' >> revenge_and_say
      where
        revenge_and_say = do
          -- putStrLn $ "running: " ++ t.name
          t.action
