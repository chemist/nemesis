Nemesis: a task management tool for Haskell
=====================================================

Demo
----
  
    import System.Nemesis.Env

    main = run $ do

      clean
        [ "**/*.hi"
        , "**/*.o"
        , "manifest"
        ]

      task "dist" $ do
        sh "cabal clean"
        sh "cabal configure"
        sh "cabal sdist"

      task "i" (sh "ghci -isrc src/System/Nemesis.hs")

      task "manifest" $ do
        sh "find . | grep 'hs$' > manifest"

Tutorial
--------

### Install

    cabal update
    cabal install nemesis

### DSL

Create a file named `Nemesis`

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

### Run

`runghc Nemesis`

    attack          Hunter attack macro
    auto-attack     Auto attack
    mark            Hunter's mark
    pet-attack      Pet attack

`runghc Nemesis attack`

    casting hunter's mark
    pet attack
    auto shoot
    attack macro done!


### Namespace

Create namespaces for tasks with the keyword `namespace`
    
    import System.Nemesis.Env
    import Air.Env ((-))
    import Prelude hiding ((-))

    main = run - do
    
      namespace "eat" - do

        task "bread: salad" - putStrLn "eating bread"
        task "salad: /drink/coke" - putStrLn "eating salad"


      namespace "drink" - do

        task "coke" - putStrLn "drinking coke"

Namespaces are referenced as path components.

`runghc Nemesis bread`

    Nemesis: bread does not exist!
    
`runghc Nemesis eat/bread`

    drinking coke
    eating salad
    eating bread
    


Hints
-----

* alias `runghc Nemesis` to something sweeter, e.g. `n`
