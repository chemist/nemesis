import Control.Monad hiding (join)
import Data.List (find)
import Data.Time.Clock.POSIX
import Prelude hiding ((.), (>), (^), (-))
import System
import System.Cmd
import System.Directory
import System.Nemesis.Util
import System.Time
import System.Nemesis.DSL


start, end :: String
start = start_nemesis ++ start_nemesis_dsl
  where 
    start_nemesis     = "import System.Nemesis (run)\n"
    start_nemesis_dsl = "import System.Nemesis.DSL\n"
end = "\nmain = run nemesis\n"

main :: IO ()
main = do
  recompile <- should_recompile
  when recompile compile
  
  args <- getArgs
  system - "./.nemesis " ++ args.join " "
  return ()
  
  where
    bin = ".nemesis"
    should_recompile = do
      bin_exists <- doesFileExist bin
      if not bin_exists
        then return True
        else do
          bin_stamp <- bin.file_mtime
          src_stamp <- get_src_name >>= file_mtime
          return - bin_stamp < src_stamp
    
    file_mtime path = 
      getModificationTime path ^ seconds ^ posixSecondsToUTCTime
    
    seconds (TOD s _) = s.fromIntegral

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
  let src_o  = src_base_name src_name ++ ".o"
      src_hi = src_base_name src_name ++ ".hi"
  src <- readFile src_name
  
  let patch_end   = patch_src main_src src end
      patch_start = patch_src main_src src start
      h = src.lines.takeWhile (lower > starts_with sep > not) .unlines
      t = src.lines.dropWhile (lower > starts_with sep > not) .unlines

  if ((patch_end ++ patch_start).null && src_name.ends_with ".hs")
    then do
      sh - "ghc --make -O1 " ++ src_name ++ " -o " ++ bin
      rm src_o
      rm src_hi
    else do
      if t.null
        then output_tmp - patch_start ++ h ++ patch_end
        else output_tmp - h ++ patch_start ++ "\n" ++ t ++ patch_end
      sh - "ghc --make -O1 " ++ tmp_name ++ " -o " ++ bin
      rm tmp_name
      rm tmp_o
      rm tmp_hi
  
  where

    main_src        = "main ="
    sep             = "-- nem"
    output_tmp      = writeFile tmp_name
    tmp_name        = "nemesis-tmp.hs"
    tmp_o           = "nemesis-tmp.o"
    tmp_hi          = "nemesis-tmp.hi"
    bin             = ".nemesis"
    src_base_name s = if s.ends_with ".hs" 
                        then s.reverse.drop 3.reverse
                        else s
    patch_src l s p = case s.lines.find (starts_with l) of
                        Nothing -> p
                        Just _ -> ""
    

