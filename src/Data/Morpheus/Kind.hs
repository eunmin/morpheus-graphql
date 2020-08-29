{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE TypeFamilies #-}

-- | associating types to GraphQL Kinds
module Data.Morpheus.Kind
  ( SCALAR,
    OBJECT,
    ENUM,
    WRAPPER,
    UNION,
    INPUT_OBJECT,
    GQL_KIND,
    OUTPUT,
    INPUT,
    INTERFACE,
  )
where

data GQL_KIND
  = SCALAR
  | ENUM
  | INPUT
  | OUTPUT
  | WRAPPER
  | INTERFACE

-- | GraphQL Scalar: Int, Float, String, Boolean or any user defined custom Scalar type
type SCALAR = 'SCALAR

-- | GraphQL Enum
type ENUM = 'ENUM

-- | GraphQL Arrays , Resolvers and NonNull fields
type WRAPPER = 'WRAPPER

-- | GraphQL Object and union
type OUTPUT = 'OUTPUT

-- | GraphQL input Object and input union
type INPUT = 'INPUT

{-# DEPRECATED INPUT_OBJECT "use more generalized kind: INPUT" #-}

-- | GraphQL input Object
type INPUT_OBJECT = 'INPUT

{-# DEPRECATED UNION "use: deriving(GQLType), IMPORTANT: only types with <type constructor name><constructor name> will sustain their form, other union constructors will be wrapped inside an new object" #-}

-- | GraphQL Union
type UNION = 'OUTPUT

{-# DEPRECATED OBJECT "use: deriving(GQLType), will be automatically inferred" #-}

-- | GraphQL Object
type OBJECT = 'OUTPUT

type INTERFACE = 'INTERFACE
