module Main where

import CoreSpec as Spec
import Data.Maybe (fromMaybe)
import System.Environment (lookupEnv)
import Test.Hspec (parallel)
import Test.Hspec.Core.Runner (Config (..))
import Test.Hspec.Formatters (specdoc)
import Test.Hspec.Runner as TR (defaultConfig, hspecWith)
import Text.Read (readMaybe)

main :: IO ()
main = do
    mText <- lookupEnv "TEST_CONCURRENCY"
    let maxResources :: Int
        maxResources = fromMaybe 8 (mText >>= readMaybe)
    let cfg =
            TR.defaultConfig
                { configConcurrentJobs = Just maxResources
                , configFormatter = Just specdoc
                }
    hspecWith cfg (parallel Spec.spec)
