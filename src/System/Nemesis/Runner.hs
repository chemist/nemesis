import Control.Monad hiding (join)
import Data.List (find)
import Data.Time.Clock.POSIX
import Prelude hiding ((.), (>), (^))
import System
import System.Cmd
import System.Directory
import System.Nemesis.Util
import System.Time

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
  system $ "./.nemesis " ++ args.join " "
  return ()
  
  where
    bin = ".nemesis"
    src = "Nemesis"
    should_recompile = do
      bin_exists <- doesFileExist bin
      if bin_exists
        then do
          bin_stamp <- bin.file_mtime
          src_stamp <- src.file_mtime
          return $ bin_stamp < src_stamp
        else return True
    
    file_mtime path = 
      getModificationTime path ^ seconds ^ posixSecondsToUTCTime
    
    seconds (TOD s _) = s.fromIntegral

compile :: IO ()
compile = do
  dir <- ls "."
  let src_name = dir.filter (belongs_to possible_source) .get_name
      src_o  = src_base_name src_name ++ ".o"
      src_hi = src_base_name src_name ++ ".hi"
  src <- readFile src_name
  
  let patch_end   = patch_src main_src src end
      patch_start = patch_src main_src src start
      h = src.lines.takeWhile (lower > starts_with sep > not) .unlines
      t = src.lines.dropWhile (lower > starts_with sep > not) .unlines

  if ((patch_end ++ patch_start).null && src_name.ends_with ".hs")
    then do
      system $ "ghc --make -O1 " ++ src_name ++ " -o " ++ bin
      rm src_o
      rm src_hi
    else do
      if t.null
        then output_tmp $ patch_start ++ h ++ patch_end
        else output_tmp $ h ++ patch_start ++ "\n" ++ t ++ patch_end
      system $ "ghc --make -O1 " ++ tmp_name ++ " -o " ++ bin
      rm tmp_name
      rm tmp_o
      rm tmp_hi
  
  where

    main_src        = "main ="
    get_name []     = error "Nemesis does not exist!"
    get_name xs     = xs.first
    possible_source = ["Nemesis", "nemesis", "nemesis.hs", "Nemesis.hs"]
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
    

