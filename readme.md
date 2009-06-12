Nemesis: a rake like task management tool for haskell
=====================================================

Tutorial
--------

### DSL

in `nem.hs`

    nemesis = do
      task "clean: hello-world" (print "cleaning")

      task "hello-world: ls" $ do
        sh "echo HELLO"

      task "ls" $ do
        sh "ls"

run `nemesis`

It will generate a bin `nem` inside your current folder.

### Run

run `./nem`

          clean: hello-world
    hello-world: ls
             ls:
    

run `./nem ls`


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


