Nemesis: a rake like task management tool for haskell
=====================================================

Tutorial
--------

### DSL

in `nem.hs`

    nemesis = do
      task "learn-haskell: learn-fp" (putStrLn "Haskell is awesome!")

      task "learn-fp: learn-lisp" $ do
        sh "echo 'into FP'"

      task "learn-lisp" $ do
        sh "echo 'LISP is cool!'"

run `nemesis`

It will generate a bin `nem` inside your current folder.

### Run

run `./nem`

         learn-fp: learn-lisp
    learn-haskell: learn-fp
       learn-lisp: 

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

      task "dist" $ do
        sh "cabal clean"
        sh "cabal configure"
        sh "cabal sdist"

      task "i" (sh "ghci -isrc src/System/Nemesis.hs")

      task "manifest" $ do
        sh "find . | grep 'hs$' > manifest"

currently the separator `-- Nem` is hard coded

### Build it yourself

Example:

    module Main where
    
    import System.Nemesis

    nemesis = do
      task "i" (sh "ghci -isrc src/System/Nemesis.hs")
        
    main = nemesis


