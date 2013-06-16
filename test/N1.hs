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