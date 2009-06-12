{-# LANGUAGE QuasiQuotes #-}

import MPS
import Prelude hiding ((.), (>), (^))
import System.Cmd


start, end :: String
start = [$here|
module Main where
import System.Nemesis


|]

end = [$here|


main = run nemesis
|]

main :: IO ()
main = do
  dir <- ls "."
  src <- readFile $ dir.filter (belongs_to possible_source) .get_name
  let h = src.lines.takeWhile (lower > starts_with sep > not) .unlines
      t = src.lines.dropWhile (lower > starts_with sep > not) .unlines
  if t.null
    then output $ start ++ h ++ end
    else output $ h ++ start ++ t ++ end
  
  system $ "ghc --make " ++ tmp_name ++ " -o " ++ bin
  system $ "rm " ++ tmp_name
  return ()
  
  where
    get_name [] = error "nem.hs does not exists"
    get_name xs = xs.first
    possible_source = ["Nem.hs", "nem.hs", "nemesis.hs", "Nemesis.hs"]
    sep = "-- nem"
    output = writeFile tmp_name
    tmp_name = "nemesis-tmp.hs"
    bin = "nem"
 