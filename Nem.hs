nemesis = do
  task "clean <= hello-world" (print "cleaning")
  
  task "hello-world <= ls" $ do
    sh "echo HELLO"

  task "ls" $ do
    sh "ls"

  task "i" (sh "ghci -isrc src/System/Nemesis.hs")