import System.Nemesis (run)
import System.Nemesis.DSL
import Air.Env ((-))
import Prelude hiding ((-))

nemesis = do
  task "hello" - do
    sh "echo 'hello world'"
    
main = run nemesis