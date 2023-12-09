{-# LANGUAGE QuasiQuotes #-}

import Text.RawString.QQ 
import Data.List
import Utils
import AoC

getInput :: IO String
getInput = readFile "input.txt"

--------------------------------------------------------------------

type Parsed = [[Int]]
type Sol1 = Int
type Sol2 = Int

parse :: String -> Parsed
parse = map (map read . words) . lines

extrapolate :: Int -> [Int] -> Int
extrapolate acc nums =
    if all (==0) nums then
        acc
    else extrapolate (acc + (last nums)) (diff nums)

solve1 :: Parsed -> Sol1
solve1 = sum . map (extrapolate 0)

solve2 :: Parsed -> Sol2
solve2 = solve1 . map reverse


testdata = [r|0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
|]
testresult1 = 114
testresult2 = 2

--------------------------------------------------------------------

test1 = test (solve1 . parse) testresult1 testdata
test2 = test (solve2 . parse) testresult2 testdata

printPart :: (Show a) => Int -> a -> IO ()
printPart part solution = do
    putStr $ "Part " ++ (show part) ++ ": "
    print solution

main' :: CLIOptions -> IO ()
main' (CLIOptions p False) = do
    parsed <- parse <$> getInput
    case p of
        1 -> printPart 1 (solve1 parsed)
        2 -> printPart 2 (solve2 parsed)
        _ -> (do
            printPart 1 (solve1 parsed)
            printPart 2 (solve2 parsed))
main' (CLIOptions p True) = 
    case p of
        1 -> printPart 1 test1
        2 -> printPart 2 test2
        _ -> (do
            printPart 1 test1
            printPart 2 test2)

main = main' =<< clioptions
