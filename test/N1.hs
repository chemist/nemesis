import System.Nemesis (run)
import System.Nemesis.DSL

nemesis = do
  task "i" (sh "ghci -isrc src/System/Nemesis.hs")
    
main = run nemesis