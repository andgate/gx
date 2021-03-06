{-# LANGUAGE OverloadedStrings #-}
module Gx.Data.AppConfig where


import Control.Applicative
import Data.Yaml
import System.FilePath


data AppConfig = AppConfig
  { appConfigName :: String
  , appConfigMaxFPS :: Int
  , appConfigWindowWidth :: Int
  , appConfigWindowHeight :: Int
  , appConfigIsFullscreen :: Bool
  }

appConfigFile :: FilePath
appConfigFile = "data" </> "app.yaml"

instance FromJSON AppConfig where
    parseJSON (Object v) =
      AppConfig <$>
        v .: "name" <*>
        v .: "maxFPS" <*>
        v .: "width" <*>
        v .: "height" <*>
        v .: "isFullscreen"
    -- A non-Object value is of the wrong type, so fail.
    parseJSON _ = empty
