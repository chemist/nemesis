Nemesis: a task management tool for Haskell
=====================================================

Demo
----
  
    nemesis = do

      clean
        [ "**/*.hi"
        , "**/*.o"
        , "manifest"
        ]
        
      task "dist" - do
        sh "cabal clean"
        sh "cabal configure"
        sh "cabal sdist"

      task "i" (sh "ghci -isrc src/System/Nemesis.hs")

      task "manifest" - do
        sh "find . | grep 'hs$' > manifest"

Tutorial
--------

### Install

    cabal update
    cabal install nemesis

### DSL

Put the following code into a file named `Nemesis`

    nemesis = do
    
      -- desc is optional, it gives some description to the task that follows
      desc "Hunter attack macro"

      -- syntax: task "keyword: dependencies" io-action
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

`nemesis`

    attack          Hunter attack macro
    auto-attack     Auto attack
    mark            Hunter's mark
    pet-attack      Pet attack

`nemesis attack`

    casting hunter's mark
    pet attack
    auto shoot
    attack macro done!


### Namespace

Create namespaces for tasks with the keyword `namespace`
    
    nemesis = do
    
      namespace "eat" - do

        task "bread: salad" - putStrLn "eating bread"
        task "salad: /drink/coke" - putStrLn "nice salad"


      namespace "drink" - do

        task "coke" - putStrLn "drinking coke"

Namespaces are used as a path component.

    nemesis bread =>
    .nemesis: bread does not exist!
    
    nemesis eat/bread =>
    drinking coke
    nice salad
    eating bread
    

Hints
-----

* Add `.nemesis` to `.gitignore` or equivalents to prevent the nemesis binary from being added to your SCM
* alias `nemesis` or `runghc Nemesis` to something sweeter, e.g. `n`

Advance usage
-------------

### As an EDSL

    import System.Nemesis.Env
    import Air.Env ((-))
    import Prelude hiding ((-))

    main = run nemesis
    
    nemesis = do
      task "hello" - do
        sh "echo 'hello world'"
        

This file can be run by the Haskell interpreter:

    runghc Nemesis hello

