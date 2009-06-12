import Prelude hiding ((.), (>), (^))
import System.Cmd
import System.Nemesis.Util

start, end, sep_block :: String
sep_block = "\n\n\n\n"
start = sep_block ++ start_nemesis ++ start_nemesis_dsl
  where 
    start_nemesis     = "import System.Nemesis (run)\n"
    start_nemesis_dsl = "import System.Nemesis.DSL\n"
end = sep_block ++ "main = run nemesis\n"

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
  rm tmp_name
  rm tmp_o
  rm tmp_hi
  
  where
    get_name []     = error "Nemesis does not exists"
    get_name xs     = xs.first
    possible_source = ["Nemesis", "nemesis", "nemesis.hs", "Nemesis.hs"]
    sep             = "-- nem"
    output          = writeFile tmp_name
    tmp_name        = "nemesis-tmp.hs"
    tmp_o           = "nemesis-tmp.o"
    tmp_hi          = "nemesis-tmp.hi"
    bin             = "nem"

