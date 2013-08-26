{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE TemplateHaskell, FlexibleInstances, EmptyDataDecls #-}


{- | Making labels in the style of "Data.HList.Label4"

 The following TH splice

>  $(makeLabels ["getX","getY","draw"])

should expand into the following declarations

> data GetX;     getX     = proxy::Proxy GetX
> data GetY;     getY     = proxy::Proxy GetY
> data Draw;     draw     = proxy::Proxy Draw

-}

module Data.HList.MakeLabels (makeLabels,label) where

import Data.HList.FakePrelude

import Language.Haskell.TH.Ppr (pprint)
import Language.Haskell.TH

import Data.Char (toUpper, toLower)
import Control.Monad (liftM, liftM2)

import Data.Typeable (Typeable)

capitalize, uncapitalize :: String -> String
capitalize   (c:rest) = toUpper c : rest
uncapitalize (c:rest) = toLower c : rest


-- Make the name of the type constructor whose string representation
-- is capitalized str
make_tname str = mkName $ capitalize str

-- Make the name of the value identifier whose string representation
-- is uncapitalized str
make_dname str = mkName $ uncapitalize str

dcl n = liftM2 (\a b ->[a,b])
    (dataD (return []) (make_tname n) [] [] [''Typeable])
    (valD (varP (make_dname n)) (normalB [| proxy :: Proxy $(conT (make_tname n)) |]) [])

-- | Our main function
makeLabels :: [String] -> Q [Dec]
makeLabels = liftM concat . mapM dcl

-- | Make a single label
label :: String -> Q [Dec]
label s = makeLabels [s]

-- Show the code expression
show_code cde = runQ cde >>= putStrLn . pprint

{-
t1 = show_code [d| data Foo |]

t2 = showName $ mkName "Foo"

t3 = show_code $
     liftM (replace_name
            (make_tname "foo",make_dname "foo")
            (make_tname "bar",make_dname "bar")) dcl_template
-}

-- t4 = show_code $ makeLabels ["getX","getY","draw"]
