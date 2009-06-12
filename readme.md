Nemesis: a rake like task management tool for haskell
=====================================================

Demo
----
  
    import System.Nemesis.DSL (clean)
    
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

It will generate a bin `nem` inside your current folder.

### Run

run `./nem`

         learn-fp: learn Functional Programming
    learn-haskell: learn Haskell
       learn-lisp: learn LISP
    

run `./nem learn-haskell`

    LISP is cool!
    into FP
    Haskell is awesome!
    

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

Example:

    module Main where
    
    import System.Nemesis

    nemesis = do
      task "i" (sh "ghci -isrc src/System/Nemesis.hs")
        
    main = nemesis


