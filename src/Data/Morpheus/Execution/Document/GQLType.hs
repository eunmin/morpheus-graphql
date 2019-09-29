{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}

module Data.Morpheus.Execution.Document.GQLType
  ( deriveGQLType
  ) where

import           Language.Haskell.TH

import           Data.Morpheus.Kind                       (ENUM, INPUT_OBJECT, INPUT_UNION, OBJECT, SCALAR, UNION,
                                                           WRAPPER)

import           Data.Morpheus.Execution.Internal.Declare (tyConArgs)

--
-- MORPHEUS
import           Data.Morpheus.Types.GQLType              (GQLType (..), TRUE)
import           Data.Morpheus.Types.Internal.Data        (DataTypeKind (..), isObject)
import           Data.Morpheus.Types.Internal.DataD       (GQLTypeD (..), TypeD (..))
import           Data.Morpheus.Types.Internal.TH          (instanceHeadT, typeT)
import           Data.Typeable                            (Typeable)

deriveGQLType :: GQLTypeD -> Q [Dec]
deriveGQLType GQLTypeD {typeD = TypeD {tName}, typeKindD} = pure <$> instanceD (cxt constrains) iHead typeFamilies
    ---------------------------
  where
    typeArgs = tyConArgs typeKindD
    ----------------------------------------------
    iHead = instanceHeadT ''GQLType tName typeArgs
    headSig = typeT (mkName tName) typeArgs
    -----------------------------------------------
    constrains = map conTypeable typeArgs
      where
        conTypeable name = typeT ''Typeable [name]
    -----------------------------------------------
    typeFamilies
      | isObject typeKindD = [deriveCUSTOM, deriveKind]
      | otherwise = [deriveKind]
    ---------------------------------------------
      where
        deriveCUSTOM = do
          typeN <- headSig
          pure $ TySynInstD ''CUSTOM (TySynEqn [typeN] (ConT ''TRUE))
        ---------------------------------------------------------------
        deriveKind = do
          typeN <- headSig
          pure $ TySynInstD ''KIND (TySynEqn [typeN] (ConT $ toKIND typeKindD))
        ---------------------------------
        toKIND KindScalar      = ''SCALAR
        toKIND KindEnum        = ''ENUM
        toKIND (KindObject _)  = ''OBJECT
        toKIND KindUnion       = ''UNION
        toKIND KindInputObject = ''INPUT_OBJECT
        toKIND KindList        = ''WRAPPER
        toKIND KindNonNull     = ''WRAPPER
        toKIND KindInputUnion  = ''INPUT_UNION
