{-# LANGUAGE NoMonomorphismRestriction #-}

module System.Nemesis.Util where

import Control.Arrow ((>>>))
import Control.Category (Category)
import Data.Char (toLower)
import Data.Function (on)
import Data.List (isPrefixOf, isSuffixOf, (\\))
import Prelude hiding ((>), (.), (^))
import System.Directory
import qualified Data.List as L

-- utility functions from mps

(.) :: a -> (a -> b) -> b
a . f = f a
infixl 9 .

(^) :: (Functor f) => f a -> (a -> b) -> f b
(^) = flip fmap
infixl 8 ^

(>) :: (Category cat) => cat a b -> cat b c -> cat a c
(>) = (>>>)
infixl 8 >


join :: [a] -> [[a]] -> [a]
join    = L.intercalate

join' :: [[a]] -> [a]
join'   = concat

ljust, rjust :: Int -> a -> [a] -> [a]
ljust n x xs 
  | n < xs.length = xs
  | otherwise     = ( n.times x ++ xs ).reverse.take n.reverse

rjust n x xs
  | n < xs.length = xs
  | otherwise     = ( xs ++ n.times x ).take n
    
compare_by :: (Ord b) => (a -> b) -> a -> a -> Ordering
compare_by = on compare

first :: [a] -> a
first = head

times :: b -> Int -> [b]
times = flip replicate

has :: (Eq a) => a -> [a] -> Bool
has = elem

belongs_to :: (Eq a) => [a] -> a -> Bool
belongs_to = flip elem


lower :: String -> String
lower = map toLower

starts_with :: String -> String -> Bool
starts_with = isPrefixOf

ends_with :: String -> String -> Bool
ends_with = isSuffixOf

ls :: String -> IO [String]
ls s = getDirectoryContents s ^ (\\ [".", ".."])

rm :: String -> IO ()
rm = removeFile

rm_rf :: String -> IO ()
rm_rf = removeDirectoryRecursive