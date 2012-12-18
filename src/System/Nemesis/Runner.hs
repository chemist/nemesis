import Control.Monad hiding (join)
import Data.List (find)
import Data.Time.Clock.POSIX
import Prelude ()
import System.Environment
import System.Cmd
import System.Directory
import System.Nemesis.Util
import System.Time
import System.Nemesis.DSL
import qualified Prelude as P
import Data.Maybe


start, end :: String
start = start_nemesis + start_nemesis_dsl + init_air + init_prelude
  where 
    start_nemesis     = "import System.Nemesis (run)\n"
    start_nemesis_dsl = "import System.Nemesis.DSL\n"
    init_air          = "import Air.Light ((-))\n"
    init_prelude      = "import Prelude hiding ((-))\n"
end = "\nmain = run nemesis\n"

main :: IO ()
main = do
  recompile <- should_recompile
  when recompile compile
  
  args <- getArgs
  system - "./.nemesis " + args.join " "
  return ()
  
  where
    bin = ".nemesis"
    should_recompile = do
      bin_exists <- doesFileExist bin
      if not bin_exists
        then return True
        else do
          bin_stamp <- bin.getModificationTime
          src_stamp <- get_src_name >>= getModificationTime
          return - bin_stamp P.< src_stamp


get_src_name :: IO String
get_src_name = do
  dir <- ls "."
  return - dir.filter (belongs_to possible_source) .get_name
  where
    possible_source = ["Nemesis", "nemesis", "Nemesis.hs", "nemesis.hs"]
    get_name []     = error "Nemesis does not exist!"
    get_name xs     = xs.first

compile :: IO ()
compile = do
  src_name <- get_src_name
  let src_o  = src_base_name src_name + ".o"
      src_hi = src_base_name src_name + ".hi"
  src <- readFile src_name
  
  let maybe_patch_end   = yield_string_if_no_line_starts_with     main_src_prefix src end
      maybe_patch_start = yield_string_if_no_line_starts_with     main_src_prefix src start
      
      __nem_seperated_header = src.lines.takeWhile (lower > starts_with sep > not) .unlines
      __nem_seperated_footer = src.lines.dropWhile (lower > starts_with sep > not) .unlines

  if (maybe_patch_end.isNothing && maybe_patch_start.isNothing && src_name.ends_with ".hs")
    then do
      sh - "ghc --make -O1 " + src_name + " -o " + bin
      rm src_o
      rm src_hi
    else do
      if __nem_seperated_footer.null
        then output_tmp - maybe_patch_start.fromMaybe "" + __nem_seperated_header + maybe_patch_end.fromMaybe ""
        else output_tmp - __nem_seperated_header + maybe_patch_start.fromMaybe "" + "\n" + __nem_seperated_footer + maybe_patch_end.fromMaybe ""
        
      sh - "ghc --make -O1 " + tmp_name + " -o " + bin
      rm tmp_name
      rm tmp_o
      rm tmp_hi
  
  where

    main_src_prefix = "main ="
    
    sep             = "-- nem"
    output_tmp      = writeFile tmp_name
    tmp_name        = "nemesis-tmp.hs"
    tmp_o           = "nemesis-tmp.o"
    tmp_hi          = "nemesis-tmp.hi"
    bin             = ".nemesis"
    src_base_name s = if s.ends_with ".hs" 
                        then s.reverse.drop 3.reverse
                        else s
                        
    yield_string_if_no_line_starts_with prefix str yield = case str.lines.find (starts_with prefix) of
                        Nothing -> Just yield
                        Just _ -> Nothing
    

