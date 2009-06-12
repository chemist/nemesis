{-# LANGUAGE QuasiQuotes #-}

import Prelude hiding ((.), (>), (^))
import System.Cmd
import Nemesis.Util

start, end :: String
start = "\n\n\n\nmodule Main where\n" ++ "import System.Nemesis"
end = "\n\n\nmain = run nemesis\n"

main :: IO ()
main = do
  dir <- ls "."
  src <- readFile $ dir.filter (belongs_to possible_source) .get_name
  let h = src.lines.takeWhile (lower > starts_with sep > not) .unlines
      t = src.lines.dropWhile (lower > starts_with sep > not) .unlines
  if t.null
    then output $ start ++ h ++ end
    else output $ h ++ start ++ t ++ end
  
  system $ "ghc --make -O1 " ++ tmp_name ++ " -o " ++ bin
  system $ "rm " ++ tmp_name
  return ()
  
  where
    get_name [] = error "Nemesis does not exists"
    get_name xs = xs.first
    possible_source = ["Nemesis", "nemesis", "nemesis.hs", "Nemesis.hs"]
    sep = "-- nem"
    output = writeFile tmp_name
    tmp_name = "nemesis-tmp.hs"
    bin = "nem"
 
-- helper from mps
