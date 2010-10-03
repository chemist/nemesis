import System.Nemesis (run)
import System.Nemesis.DSL

nemesis = do
  task "hello" (sh "echo 'hello world'")
    
main = run nemesis