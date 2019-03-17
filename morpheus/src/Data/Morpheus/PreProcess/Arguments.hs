module Data.Morpheus.PreProcess.Arguments
  ( validateArguments
  ) where

import           Data.List                           ((\\))
import           Data.Morpheus.Error.Arguments       (argumentError, requiredArgument,
                                                      unknownArguments)
import           Data.Morpheus.PreProcess.Input.Enum (validateEnum)
import           Data.Morpheus.PreProcess.Utils      (existsType)
import           Data.Morpheus.PreProcess.Variable   (replaceVariable)
import qualified Data.Morpheus.Schema.GQL__Field     as F
import qualified Data.Morpheus.Schema.GQL__Type      as T
import           Data.Morpheus.Schema.GQL__TypeKind  (GQL__TypeKind (..))
import qualified Data.Morpheus.Schema.InputValue     as I
import           Data.Morpheus.Types.Error           (MetaValidation, Validation)
import           Data.Morpheus.Types.Introspection   (GQLTypeLib, GQL__Field, GQL__InputValue)
import           Data.Morpheus.Types.JSType          (JSType (..))
import           Data.Morpheus.Types.Types           (Argument (..), Arguments, EnumOf (..),
                                                      GQLQueryRoot (..))
import           Data.Text                           (Text)

asGQLError :: MetaValidation a -> Validation a
asGQLError (Left err)    = Left $ argumentError err
asGQLError (Right value) = pure value

-- TODO: Validate other Types , type missmatch
checkArgumentType :: GQLTypeLib -> Text -> Argument -> Validation Argument
checkArgumentType typeLib typeName argument = asGQLError (existsType typeName typeLib) >>= checkType
  where
    checkType _type =
      case T.kind _type of
        EnumOf ENUM -> validateEnum _type argument
       -- INPUT_OBJECT is already validated
        _           -> pure argument

validateArgument :: GQLTypeLib -> GQLQueryRoot -> Arguments -> GQL__InputValue -> Validation (Text, Argument)
validateArgument types root requestArgs inpValue =
  case lookup (I.name inpValue) requestArgs of
    Nothing ->
      if I.isRequired inpValue
        then Left $ requiredArgument (I.inputValueMeta 0 inpValue)
        else pure (key, Argument JSNull 0)
    Just x -> replaceVariable root x >>= checkArgumentType types (I.typeName inpValue) >>= validated
  where
    key = I.name inpValue
    validated x = pure (key, x)

checkForUnknownArguments :: GQL__Field -> Arguments -> Validation [GQL__InputValue]
checkForUnknownArguments field args =
  case map fst args \\ map I.name (F.args field) of
    []          -> pure $ F.args field
    unknownArgs -> Left $ unknownArguments (F.name field) unknownArgs

validateArguments :: GQLTypeLib -> GQLQueryRoot -> GQL__Field -> Arguments -> Validation Arguments
validateArguments typeLib root inputs args =
  checkForUnknownArguments inputs args >>= mapM (validateArgument typeLib root args)