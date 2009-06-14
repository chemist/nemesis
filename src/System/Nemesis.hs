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
  , namespace :: [String]
  }

data Nemesis = Nemesis
  {
    tasks :: Map String Task
  , target :: String
  , current_desc :: Maybe String
  , current_namespace :: [String]
  }
  deriving (Show)

instance Default Nemesis where
  def = Nemesis empty def def def

instance Default Task where
  def = Task def (return ()) def def def

full_name :: Task -> String
full_name t = (t.name : t.namespace).reverse.join "/"

display_name :: Task -> String
display_name t = (t.name : t.namespace).reverse.map (rjust 10 ' ') .join " "

instance Show Task where
  show x = case x.description of
    Nothing -> title
    Just s -> title ++ s
    where
      title = x.display_name.rjust 34 ' ' ++ ": "

instance Eq Task where
  a == b = a.name == b.name

instance Ord Task where
  compare = compare_by full_name

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
      namespace   = n.current_namespace
      deps'       = t.deps.map (with_current namespace)
      task        = t {deps = deps', description, namespace}
      tasks'      = n.tasks.insert (task.full_name) task

  put n {tasks = tasks', current_desc = Nothing}
  where
    with_current namespace x
      | x.starts_with "/" = x.tail
      | otherwise = (x : namespace).reverse.join "/"

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
