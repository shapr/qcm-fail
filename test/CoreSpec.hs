{-# LANGUAGE OverloadedStrings #-}

module CoreSpec where

import Control.Monad
import qualified Data.Base32String as Base32
import qualified Data.ByteString as B
import qualified Data.Text as T
import Data.Word (Word8)
import Test.Hspec
import Test.QuickCheck
import Test.QuickCheck.Monadic
import qualified Test.QuickCheck.Monadic as QCM

spec :: Spec
spec =
    describe "my great test" $ do
        it "should be true" $
            True `shouldBe` True
        it "fails the test when error is called" $
            property $
                forAll genStorageIndex indexIt

-- it "generates stuff" $
--   hedgehog $ do
--     xs <- forAll $ Gen.list (Range.linear 0 100) Gen.alpha
--     reverse (reverse xs) === xs

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

getIt :: String -> IO String
getIt s = do
    when (length s `mod` 2 == 1) (error "no way")
    readFile s

indexIt :: StorageIndex -> IO ()
indexIt s = do
    error "no"

testIt :: String -> Property
testIt s = do
    monadicIO $ runna

runna = do
    run $ getIt "foo" >> pure False
