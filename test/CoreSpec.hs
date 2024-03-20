{-# LANGUAGE OverloadedStrings #-}

module CoreSpec where

import Control.Exception
import Control.Monad
import qualified Data.Base32String as Base32
import qualified Data.ByteString as B
import qualified Data.Text as T
import Data.Word (Word8)
import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Monadic

-- import qualified Test.QuickCheck.Monadic as QCM

spec :: Spec
spec =
    describe "my great test" $ do
        it "should be true" $
            True `shouldBe` True
        it "fails the test when error is called" $ -- and in fact, it does
            property $
                forAll genStorageIndex indexIt
        it "fails when bracket wraps the call" $
            property $
                forAll genStorageIndex wrapIt
        it "testIt correct" $
            property $
                forAll arbitrary testIt

genStorageIndex :: Gen StorageIndex
genStorageIndex =
    suchThatMap gen10ByteString (Just . b32encode)

gen10ByteString :: Gen B.ByteString
gen10ByteString =
    suchThatMap (vectorOf 10 (arbitrary :: Gen Word8)) (Just . B.pack)

{- | An opaque identifier for a single storage area.  Multiple storage objects
 may exist at one storage index if they have different share numbers.  TODO:
 This should probably be ByteString instead.
-}
type StorageIndex = String

b32table :: B.ByteString
b32table = "abcdefghijklmnopqrstuvwxyz234567"

b32encode :: B.ByteString -> String
b32encode = T.unpack . Base32.toText . Base32.fromBytes b32table

getIt :: String -> IO ()
getIt s = do
    when (length s `mod` 2 == 1) (error "don't getIt")
    void $ readFile s

indexIt :: StorageIndex -> IO ()
indexIt _s = do
    error "no"

wrapIt :: StorageIndex -> IO ()
wrapIt _s = do
    withBackend (pure "whatevs") (\_ -> pure ()) indexIt

testIt :: String -> Property
testIt _s = do
    monadicIO runna

runna :: PropertyM IO Bool
runna = do
    run $ withBackend (pure "runna") (\_ -> pure ()) (\x -> getIt "foo") >> error "PLZ WORK"

-- runBackend = withBackend makeBackend cleanupBackend
-- makeStorageSpec memoryBackend cleanupMemory
-- makeStorageSpec memoryBackend (pure ())
withBackend :: IO b -> (b -> IO ()) -> (b -> IO ()) -> IO ()
withBackend b cleanup action = bracket b action cleanup

cleanupMemory :: (Applicative f) => p -> f ()
cleanupMemory _ = pure ()
