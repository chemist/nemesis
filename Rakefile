require 'rake'
require 'rake/clean'

task :default => :stats

Dir['tasks/**/*.rake'].each { |rake| load rake }

CLEAN.include %w[
  **/*.o
  **/*.hi
  Main.exe*
  **/*.pid
  **/*.sock
  **/*.fcgi
  manifest
  db/public/*.fcgi
  nem
]

desc "console"
task :i do
  sh 'ghci -isrc src/System/Nemesis.hs'
end
