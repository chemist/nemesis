Nemesis: a rake like task management tool for haskell
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

    cabal update; cabal install nemesis

### DSL

Put the following code into a file named `Nemesis`

    nemesis = do
    
      -- desc is optional, it gives some description to the following task
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

run `nemesis`

    attack                            : Hunter attack macro
    auto-attack                       : Auto attack
    mark                              : Hunter's mark
    pet-attack                        : Pet attack

run `nemesis attack`

    casting hunter's mark
    pet attack
    auto shoot
    attack macro done!


### Namespace

Suppose you have the following tasks
    
    nemesis = do
    
      namespace "eat" - do

        task "bread: salad" - putStrLn "eating bread"
        task "salad: /drink/coke" - putStrLn "nice salad"


      namespace "drink" - do

        task "coke" - putStrLn "drinking coke"

then

    nemesis bread =>
    .nemesis: bread does not exist!
    
    nemesis eat/bread =>
    drinking coke
    nice salad
    eating bread
    

Advance usage
-------------

### Use LANGUAGE progam

Put a `-- Nem` token after the `Langauge` progma

    {-# LANGUAGE QuasiQuotes #-}

    -- Nem

    nemesis = do
      task "i" (sh "ghci -isrc src/System/Nemesis.hs")

currently the separator `-- Nem` is hard coded

### By pass preprocessing, e.g. use custom imports

Define `main`, i.e. add `main = run nemesis` in the code. The preprocessor look for the function main, if it's defined, it skip preprocessing, and Nemesis because pure EDSL that can be run by `runhaskell`.

For example:

    import System.Nemesis (run)
    import System.Nemesis.DSL
    import MPS.Light ((-))
    import Prelude hiding ((-))
    
    nemesis = do
      task "i" (sh "ghci -isrc src/System/Nemesis.hs")
        
    main = run nemesis

Test out by:

  runghc Nemesis


### Who is mnemosyne?

![mnemosyne](http://github.com/nfjinjing/nemesis/raw/master/mnemosyne.jpg)

OK, I made a mistake in the project name, but she's a cool goddess none the less.