module Main where
import Data.Time

type Kinchi = (String, (Integer, Integer, Integer))
kinchis :: [Kinchi]
kinchis =
  [ ("七七忌" , (0 ,0 ,48))
  , ("1周忌"  , (1 ,0 ,0 ))
  , ("3回忌"  , (2 ,0 ,0 ))
  , ("7回忌"  , (6 ,0 ,0 ))
  , ("13回忌" , (12,0 ,0 ))
  , ("17回忌" , (16,0 ,0 ))
  , ("23回忌" , (22,0 ,0 ))
  , ("27回忌" , (26,0 ,0 ))
  , ("33回忌" , (32,0 ,0 ))
  , ("37回忌" , (36,0 ,0 ))
  , ("50回忌" , (49,0 ,0 ))
  ]

calcKinchi :: Kinchi -> Day -> (String, Day)
calcKinchi (n, (y, m, d)) = (,) n . addDays d . addGregorianMonthsClip m . addGregorianYearsClip y

calcKinchis :: [Kinchi] -> Day -> [(String, Day)]
calcKinchis ks d = map (flip calcKinchi d) ks

printKinchis :: [(String, Day)] -> IO ()
printKinchis = mapM_ putStrLn . map (\(n, d) -> n ++ " - " ++ show d)
  
main :: IO ()
main = do
  putStrLn "命日を入力してちょ(\"yyyy-mm-dd\")"
  meinichi <- return . read =<< getLine
  printKinchis $ calcKinchis kinchis meinichi

