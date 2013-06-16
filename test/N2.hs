import System.Nemesis.Env
import Air.Env ((-))
import Prelude hiding ((-))

main = run - do

  -- desc is optional, it gives some description to the task
  -- task syntax: task "keyword: space seperated dependencies" io-action
  desc "Hunter attack macro"
  task "attack: pet-attack auto-attack" (putStrLn "attack macro done!")

  desc "Pet attack"
  task "pet-attack: mark" - do
    sh "echo 'pet attack'"

  desc "Hunter's mark"
  task "mark" - do
    sh "echo \"casting hunter's mark\""

  desc "Auto attack"
  task "auto-attack" - do
    sh "echo 'auto shoot'"