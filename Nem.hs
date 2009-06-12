-- template nemesis file

nemesis = do
  
  task "learn-haskell: learn-fp" (putStrLn "Haskell is awesome!")

  task "learn-fp: learn-lisp" $ do
    sh "echo 'into FP'"

  task "learn-lisp" $ do
    sh "echo 'LISP is cool!'"
    
  task "dist" $ do
    sh "cabal clean"
    sh "cabal configure"
    sh "cabal sdist"

  task "i" (sh "ghci -isrc src/System/Nemesis.hs")

  task "manifest" $ do
    sh "find . | grep 'hs$' > manifest"