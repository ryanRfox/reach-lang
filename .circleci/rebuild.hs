#!/usr/bin/env stack
{- stack script
 --compile
 --ghc-options -Wall
 --resolver    lts-17.8
 --package     bytestring
 --package     dhall
 --package     dhall-json
 --package     dhall-yaml
 --package     directory
 --package     filepath
 --package     process
 --package     text
 -}

{-# LANGUAGE OverloadedStrings #-}

import Control.Monad      (filterM)
import Data.List          (nub, sort)
import Dhall              (embed, inject)
import Dhall.JSON         (omitEmpty)
import Dhall.Pretty       (prettyExpr)
import Dhall.Yaml         (Options(..), defaultOptions, dhallToYaml)
import GHC.IO.Encoding    (setLocaleEncoding, utf8)
import System.Directory   (listDirectory, doesDirectoryExist)
import System.Environment (getExecutablePath)
import System.FilePath    ((</>), takeDirectory)
import System.Process     (readCreateProcess, shell, cwd)

import qualified Data.ByteString as B
import qualified Data.Text       as T
import qualified Data.Text.IO    as T


renderExamples :: [FilePath] -> T.Text
renderExamples es =
     "-- Code generated by `rebuild` script.  DO NOT EDIT.\n"
  <> (T.pack . show . prettyExpr $ embed inject es)
  <> "\n"


main :: IO ()
main = do
  -- https://github.com/dhall-lang/dhall-haskell/blob/46432f2/dhall-json/src/Dhall/DhallToYaml/Main.hs#L88
  setLocaleEncoding utf8

  circleci <- takeDirectory <$> getExecutablePath

  let o = defaultOptions { explain = True, noEdit = True, omission = omitEmpty }
  let c = circleci </> "config.dhall"
  let e = circleci </> "../examples"

  gits <- nub . (fmap takeDirectory) . lines
    <$> readCreateProcess ((shell "git ls-files") { cwd = Just e }) ""

  examples <- listDirectory e
          >>= filterM (doesDirectoryExist . (e </>))
          >>= pure . filter (`elem` gits)

  T.writeFile (circleci </> "examples.dhall") (renderExamples $ sort examples)

  config <- T.readFile c >>= dhallToYaml o (Just c)
  B.writeFile (circleci </> "config.yml") $ config <> "\n"
