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

    cabal update; cabal install nemesis

### DSL

Put the following code into a file named `Nemesis`

    nemesis = do
    
      -- desc is optional, it gives some description to the following task
      desc "learn Haskell"
      
      -- syntax: task "keyword: dependencies" io-action
      task "learn-haskell: learn-fp" (putStrLn "Haskell is awesome!")

      desc "learn Functional Programming"
      task "learn-fp: learn-lisp" $ do
        sh "echo 'into FP'"

      desc "learn LISP"
      task "learn-lisp" $ do
        sh "echo 'LISP is cool!'"

run `nemesis`

It will generate a bin `.nemesis` inside your current folder.

### Run

run `./.nemesis`

    learn-fp                           : learn Functional Programming
    learn-haskell                     : learn Haskell
    learn-lisp                        : learn LISP
    

run `./.nemesis learn-haskell`

    LISP is cool!
    into FP
    Haskell is awesome!
    

### Namespace

Suppose you have the following tasks
    
    nemesis = do
    
      namespace "eat" $ do

        task "bread: salad" $ putStrLn "eating bread"
        task "salad: /drink/coke" $ putStrLn "nice salad"


      namespace "drink" $ do

        task "coke" $ putStrLn "drinking coke"

then

    ./.nemesis bread =>
    .nemesis: bread does not exist!
    
    ./.nemesis eat/bread =>
    drinking coke
    nice salad
    eating bread
    
    

Advance usage
-------------

### Use LANGUAGE

Use a separator below language extensions, e.g.

    {-# LANGUAGE QuasiQuotes #-}

    -- Nem

    nemesis = do
      task "i" (sh "ghci -isrc src/System/Nemesis.hs")

currently the separator `-- Nem` is hard coded

### Build it yourself

If you don't want `nemesis` to compile `Nemesis` through intermediate `nemesis-tmp.hs` file, rename your `Nemesis` to `Nemesis.hs`, then start with this template.

    import System.Nemesis (run)
    import System.Nemesis.DSL

    nemesis = do
      task "i" (sh "ghci -isrc src/System/Nemesis.hs")
        
    main = run nemesis

The logic is that whenever `main` is defined in `Nemesis.hs`, `nemesis` will act as `ghc --make` wrapper, so you can get nice error messages.

Hint
----

Save typing by aliasing `./.nemesis` to `n`, i.e. inside `.your_shellrc`

    alias n="./.nemesis"
