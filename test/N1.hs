import System.Nemesis (run)
import System.Nemesis.DSL
import MPS.Env ((-))
import Prelude hiding ((-))

nemesis = do
  task "hello" - do
    sh "echo 'hello world'"
    
main = run nemesis