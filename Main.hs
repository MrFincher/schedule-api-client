{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns #-}

module Main where
import AesonDecode hiding (null)
import Control.Monad
import Control.Lens
import Data.Aeson
import Data.Aeson.Lens
import qualified Data.ByteString.Lazy as BS
import Data.Function
import Data.Maybe
import Data.List
import qualified Data.Set as S
import GHC.Generics
import Network.Wreq

data Event = Event {_subject :: String
                   ,_teachers :: S.Set String
                   ,_rooms :: S.Set String
                   ,_start :: String
                   ,_end :: String }
                   deriving (Generic)

makeLenses ''Event

instance FromJSON Event where
  parseJSON = withObject "Event" $ \v -> Event <$> v .: "Vak"
    <*> fmap S.singleton (v .: "DocentAfkorting")
    <*> fmap S.singleton (v .: "Lokaal")
    <*> v .: "Start" <*> v .: "Eind"
 
download :: IO ()
download = get url >>= BS.writeFile "cache.json" . (^?! responseBody)

loadEvents :: IO [Event]
loadEvents = parse <$> BS.readFile "cache.json"

parse :: BS.ByteString -> [Event]
parse = fromJust . decodeMaybe defaultDecoder . fromJust . preview (key "iPlannerRooster")

foldWhile :: (a -> a -> Bool) -> (a -> a -> a) -> [a] -> ([a],a)
foldWhile p f (x:xs) = foldM aux x xs
  where aux acc x = if p acc x then return (f acc x) else (return x, acc)

instance Show Event where
  show Event {..} = intercalate "\t"
      [_start <> " - " <> _end, _subject, limit 20 $ aux _rooms, aux _teachers]
    where aux = intercalate ", " . S.toList
          limit l s = take l $ s ++ repeat ' '

instance Semigroup Event where
  (<>) Event {..} = over teachers (<>_teachers) . over rooms (<>_rooms)
                  . over start (min _start) . over end (max _end)

combine :: [Event] -> [Event]
combine = reverse .snd . until (null . fst) aux . (,[])
  where aux (rest,acc) = (:acc) <$> foldWhile overlap (<>) rest
        overlap a b = a ^. start <= b ^. end && b ^.  start <= a ^. end

stripDates :: Event -> Event
stripDates = over start strip . over end strip where strip = take 5 . drop 11

clean :: Event -> Event
clean e = e & teachers %~ S.filter (/="<->")

prettify :: Event -> Event
prettify e = e & teachers %~ S.map convTeacher & rooms %~ S.map convRoom
  where convTeacher t = fromMaybe t $ lookup t teacherNames
        convRoom (flip lookup roomNames -> Just n) = n
        convRoom ('W':'1':'-':rs) = rs
        convRoom s = s

onDate :: String -> [Event] -> [Event]
onDate d = map (prettify . clean) . concatMap combine . groupBy (on (==) _subject)
         . map stripDates . filter ((==d) . take 10 . _start)
  
main :: IO ()
main = loadEvents >>= mapM_ print . onDate "2019-02-28"
