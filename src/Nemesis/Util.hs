{-# LANGUAGE NoMonomorphismRestriction #-}

module Nemesis.Util where

import Prelude hiding ((>), (.), (^))
import qualified Data.List as L
import Data.Function (on)
import Control.Arrow ((>>>))
import Data.Char (toLower)
import Data.List (isPrefixOf, (\\))
import System.Directory
import Control.Category (Category)


-- utility functions from mps

-- base DSL
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

ljust :: Int -> a -> [a] -> [a]
ljust n x xs 
  | n < xs.length = xs
  | otherwise     = ( n.times x ++ xs ).reverse.take n.reverse

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

ls :: String -> IO [String]
ls s = getDirectoryContents s ^ (\\ [".", ".."])