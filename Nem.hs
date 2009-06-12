-- template nemesis file

nemesis = do
  
  task "dist" $ do
    sh "cabal clean"
    sh "cabal configure"
    sh "cabal sdist"

  task "i" (sh "ghci -isrc src/System/Nemesis.hs")
  
  task "manifest" $ do
    sh "find . | grep 'hs$' > manifest"
