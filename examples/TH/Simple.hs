{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module TH.Simple
  ( thSimpleApi
  ) where

import qualified Data.ByteString.Lazy.Char8 as B

import           Data.Morpheus              (interpreter)
import           Data.Morpheus.Document     (importGQLDocumentWithNamespace)
import           Data.Morpheus.Types        (GQLRootResolver (..), Undefined (..))
import           Data.Text                  (Text)

importGQLDocumentWithNamespace "examples/TH/simple.gql"

rootResolver :: GQLRootResolver IO () Query Undefined Undefined
rootResolver =
  GQLRootResolver
    {
      queryResolver = return Query {queryDeity},
      mutationResolver = pure Undefined,
      subscriptionResolver = pure Undefined
    }
  where
    queryDeity QueryDeityArgs {queryDeityArgsName} = pure Deity {deityName, deityPower}
      where
        deityName _ = pure "Morpheus"
        deityPower _ = pure (Just "Shapeshifting")

thSimpleApi :: B.ByteString -> IO B.ByteString
thSimpleApi = interpreter rootResolver