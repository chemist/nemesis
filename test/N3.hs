import System.Nemesis.Env
import Air.Env ((-))
import Prelude hiding ((-))

main = run - do

  namespace "eat" - do

    task "bread: salad" - putStrLn "eating bread"
    task "salad: /drink/coke" - putStrLn "eating salad"


  namespace "drink" - do

    task "coke" - putStrLn "drinking coke"