{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TemplateHaskell #-}

module System.Nemesis where

import Prelude ()
import Air.Env hiding (lookup, get)
import Air.TH hiding (get)
import Control.Monad.State hiding (State, join)
import Data.List (sort)
import Data.Map (Map, insert, empty, lookup, elems)
import System.Environment
import System.Nemesis.Util
import Text.Printf

newtype ShowIO = ShowIO {unShowIO :: IO () }

instance Show ShowIO where
  show _ = "IO"

instance Default ShowIO where
  def = ShowIO (return ())

data Task = Task
  {
    name :: String
  , action :: ShowIO
  , deps :: [String]
  , description :: Maybe String
  , namespace :: [String]
  }
  deriving (Show)

mkDefault ''Task

data Nemesis = Nemesis
  {
    tasks :: Map String Task
  , target :: String
  , current_desc :: Maybe String
  , current_namespace :: [String]
  }
  deriving (Show)

mkDefault ''Nemesis

full_name :: Task -> String
full_name t = (t.name : t.namespace).reverse.join "/"

display_name :: Task -> String
display_name t = (t.name : t.namespace).reverse.map (printf "-10%s") .join " "

show_task :: Task -> String
show_task = show_with_ljust 44

instance Eq Task where
  a == b = a.name == b.name

instance Ord Task where
  compare = compare_by full_name

type Unit = StateT Nemesis IO ()

show_with_ljust :: Int -> Task -> String
show_with_ljust n task=
  case task.description of
    Nothing -> task.full_name
    Just x -> task.full_name.ljust n ' ' + x

run :: Unit -> IO ()
run unit = do
  args <- getArgs
  if args.null
    then help
    else execStateT unit def {target = args.first} >>= run_nemesis
  
  where
    help = execStateT unit def >>= list_task
    list_task n = do
      let _tasks = n.tasks.elems
      
          _task_len = _tasks.map (full_name > length) .maximum + 5
      
      br
      n.tasks.elems.sort.map (show_with_ljust _task_len) .mapM_ putStrLn
      br
    br = puts ""

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
      Just x -> run_task x
      where
        bye = error - printf "%s does not exist!" s

    run_task :: Task -> IO ()
    run_task t = t.deps.mapM_ run' >> t.action.unShowIO
