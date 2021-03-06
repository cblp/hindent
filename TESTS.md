# Introduction

This file is a test suite. Each section maps to an HSpec test, and
each line that is followed by a Haskell code fence is tested to make
sure re-formatting that code snippet produces the same result.

You can browse through this document to see what HIndent's style is
like, or contribute additional sections to it, or regression tests.

# Modules

Module header

``` haskell
module X where

x = 1
```

Exports

``` haskell
module X
  ( x
  , y
  , Z
  , P(x, z)
  ) where
```

Exports, indentation 4

``` haskell 4
module X
    ( x
    , y
    , Z
    , P(x, z)
    ) where
```

# Imports

Import lists

``` haskell
import           Control.Monad (when)
import           Data.Text
import           Data.Text
import           Data.Text (a, b, c)
import           Data.Text hiding (a, b, c)
import qualified Data.Text as T
import qualified Data.Text (a, b, c)
import           Options.Applicative
                 (ParserInfo, execParser, fullDesc, help, helper, info, long,
                  metavar, short, strOption)
import           Options.Applicative hiding
                 (ParserInfo, execParser, fullDesc, help, helper, info, long,
                  metavar, short, strOption)
import           Test.ImportSpecList
                 (A, A(), A(..), A(x), A(x, y), B, B(), B(..), B(x), B(x, y))
import           Test.ImportSpecList ((+), type (+), (-))
import           "text" Data.Text (a, b, c)
import qualified "text" Data.Text hiding (d, e, f)
```

Sorted in groups

```haskell given
import           D
import           C

import           B
import           A
```

```haskell expect
import           C
import           D

import           A
import           B
```

# Declarations

Type declaration

``` haskell
type EventSource a = (AddHandler a, a -> IO ())

type API =
  "1" :>
  (("authorize" :> Get '[] ()) :<|>
   ("members" :> "me" :> "boards" :> Get '[JSON] [Board]))
```

Type declaration with infix promoted type constructor

```haskell
fun2 :: Def ('[Ref s (Stored Uint32), IBool] ':-> IBool)
```

Instance declaration without decls

``` haskell
instance C a
```

Instance declaration with decls

``` haskell
instance C a where
  foobar = do
    x y
    k p
```

# Expressions

Lazy patterns in a lambda

``` haskell
f = \ ~a -> undefined
-- \~a yields parse error on input ‘\~’
```

Bang patterns in a lambda

``` haskell
f = \ !a -> undefined
-- \!a yields parse error on input ‘\!’
```

List comprehensions, short

``` haskell
map f xs = [f x | x <- xs]
```

List comprehensions, long

``` haskell
defaultExtensions =
  [ e
  | EnableExtension {extensionField1 = extensionField1} <-
      knownExtensions knownExtensions
  , let a = b
    -- comment
  , let c = d
    -- comment
  ]
```

List comprehensions with operators

```haskell
defaultExtensions =
  [e | e@EnableExtension {} <- knownExtensions] \\
  map EnableExtension badExtensions
```

Parallel list comprehension, short

```haskell
zip xs ys = [(x, y) | x <- xs | y <- ys]
```

Parallel list comprehension, long

```haskell
fun xs ys =
  [ (alphaBetaGamma, deltaEpsilonZeta)
  | x <- xs
  , z <- zs
  | y <- ys
  , cond
  , let t = t
  ]
```

Record, short

``` haskell
getGitProvider :: EventProvider GitRecord ()
getGitProvider =
  EventProvider {getModuleName = "Git", getEvents = getRepoCommits}
```

Record, medium

``` haskell
commitToEvent :: FolderPath -> TimeZone -> Commit -> Event.Event
commitToEvent gitFolderPath timezone commit =
  Event.Event
  {pluginName = getModuleName getGitProvider, eventIcon = "glyphicon-cog"}
```

Record, long

``` haskell
commitToEvent :: FolderPath -> TimeZone -> Commit -> Event.Event
commitToEvent gitFolderPath timezone commit =
  Event.Event
  { pluginName = getModuleName getGitProvider
  , eventIcon = "glyphicon-cog"
  , eventDate = localTimeToUTC timezone (commitDate commit)
  }
```

Cases

``` haskell
strToMonth :: String -> Int
strToMonth month =
  case month of
    "Jan" -> 1
    "Feb" -> 2
    _ -> error $ "Unknown month " ++ month
```

Operators, bad

``` haskell
x =
  Value <$> thing <*> secondThing <*> thirdThing <*> fourthThing <*>
  Just thisissolong <*>
  Just stilllonger <*>
  evenlonger
```

Operators, good

```haskell pending
x =
  Value <$> thing <*> secondThing <*> thirdThing <*> fourthThing <*>
  Just thisissolong <*> Just stilllonger <*> evenlonger
```

Operator with `do`

```haskell
for xs $ do
  left x
  right x
```

Operator with lambda

```haskell
for xs $ \x -> do
  left x
  right x
```

Operator with lambda-case

```haskell
for xs $ \case
  Left x -> x
```

Type application

```haskell
fun @Int 12
```

Transform list comprehensions

```haskell
list =
  [ (x, y, map the v)
  | x <- [1 .. 10]
  , y <- [1 .. 10]
  , let v = x + y
  , then group by v using groupWith
  , then take 10
  , then group using permutations
  , t <- concat v
  , then takeWhile by t < 3
  ]
```

Type families

```haskell
type family Id a
```

Type family annotations

``` haskell
type family Id a :: *
```

Type family instances

```haskell
type instance Id Int = Int
```

Type family dependencies

```haskell
type family Id a = r | r -> a
```

Binding implicit parameters

```haskell
f =
  let ?x = 42
  in f
```

# Template Haskell

Expression brackets

```haskell
add1 x = [|x + 1|]
```

Pattern brackets

```haskell
mkPat = [p|(x, y)|]
```

Type brackets

```haskell
foo :: $([t|Bool|]) -> a
```

# Type signatures

Long arguments list

```haskell
longLongFunction
  :: ReaderT r (WriterT w (StateT s m)) a
  -> StateT s (WriterT w (ReaderT r m)) a
```

Long complex type

```haskell
-- with type operator somewhere inside
initializeResource
  :: Def ('[ Ref s Context
           , Ref 'Global Instance
           , Ref 'Global Resource
           , Parameter
           , Argument
           ] :->
          IBool)
-- with promoted type operator somewhere inside
initializeResource
  :: Def ('[ Ref s Context
           , Ref 'Global Instance
           , Ref 'Global Resource
           , Parameter
           , Argument
           ] ':->
          IBool)
```

Class constraints should leave :: on same line

``` haskell pending
-- see https://github.com/chrisdone/hindent/pull/266#issuecomment-244182805
fun ::
  (Class a, Class b)
  => foo bar mu zot
  -> foo bar mu zot
  -> c
```

Class constraints

``` haskell
fun
  :: (Class a, Class b)
  => a -> b -> c
```

Tuples

``` haskell
fun :: (a, b, c) -> (a, b)
```

Quasiquotes in types

```haskell
fun :: [a|bc|]
```

Default signatures

```haskell
-- https://github.com/chrisdone/hindent/issues/283
class Foo a where
  bar :: a -> a -> a
  default bar :: Monoid a =>
    a -> a -> a
  bar = mappend
```

Implicit parameters

```haskell
f
  :: (?x :: Int)
  => Int
```

# Function declarations

Prefix notation for operators

``` haskell
(+)
  :: Num a
  => a -> a -> a
(+) a b = a
```

Where clause

``` haskell
sayHello = do
  name <- getLine
  putStrLn $ greeting name
  where
    greeting name = "Hello, " ++ name ++ "!"
```

Guards and pattern guards

``` haskell
f x
  | x <- Just x
  , x <- Just x =
    case x of
      Just x -> e
  | otherwise = do e
  where
    x = y
```

Multi-way if

``` haskell
x =
  if | x <- Just x,
       x <- Just x ->
       case x of
         Just x -> e
         Nothing -> p
     | otherwise -> e
```

Case inside a `where` and `do`

``` haskell
g x =
  case x of
    a -> x
  where
    foo =
      case x of
        _ -> do
          launchMissiles
      where
        y = 2
```

Let inside a `where`

``` haskell
g x =
  let x = 1
  in x
  where
    foo =
      let y = 2
          z = 3
      in y
```

Lists

``` haskell
exceptions = [InvalidStatusCode, MissingContentHeader, InternalServerError]

exceptions =
  [ InvalidStatusCode
  , MissingContentHeader
  , InternalServerError
  , InvalidStatusCode
  , MissingContentHeader
  , InternalServerError
  ]

type Exceptions = '[]

type Exceptions = '[InvalidStatusCode]

type Exceptions = '[InvalidStatusCod, MissingContentHeader, InternalServerError]

type Exceptions =
  '[InvalidStatusCode, MissingContentHeader, InternalServerError]

type Exceptions =
  '[ InvalidStatusCode
   , MissingContentHeader
   , InternalServerError
   , InvalidStatusCode
   ]

exceptions :: '[]
exceptions :: '[InvalidStatusCode]
exceptions :: '[InvalidStatusCode, MissingContentHeader, InternalServerError]
exceptions
  :: '[InvalidStatusCoders, MissingContentHeaders, InternalServerErrors]
exceptions
  :: '[ InvalidStatusCode
      , MissingContentHeader
      , InternalServerError
      , InvalidStatusCode
      ]
```

Long line, function application

```haskell
test = do
  alphaBetaGamma deltaEpsilonZeta etaThetaIota kappaLambdaMu nuXiOmicron piRh79
  alphaBetaGamma deltaEpsilonZeta etaThetaIota kappaLambdaMu nuXiOmicron piRho80
  alphaBetaGamma
    deltaEpsilonZeta
    etaThetaIota
    kappaLambdaMu
    nuXiOmicron
    piRhoS81
```

Long line, tuple

```haskell
test
  (alphaBetaGamma, deltaEpsilonZeta, etaThetaIota, kappaLambdaMu, nuXiOmicro79)
  (alphaBetaGamma, deltaEpsilonZeta, etaThetaIota, kappaLambdaMu, nuXiOmicron80)
  ( alphaBetaGamma
  , deltaEpsilonZeta
  , etaThetaIota
  , kappaLambdaMu
  , nuXiOmicronP81)
```

Long line, tuple section

```haskell
test
  (, alphaBetaGamma, , deltaEpsilonZeta, , etaThetaIota, kappaLambdaMu, nu79, )
  (, alphaBetaGamma, , deltaEpsilonZeta, , etaThetaIota, kappaLambdaMu, , n80, )
  (
  , alphaBetaGamma
  ,
  , deltaEpsilonZeta
  ,
  , etaThetaIota
  , kappaLambdaMu
  ,
  , nu81
  ,)
```

# Record syntax

Pattern matching, short

```haskell
fun Rec {alpha = beta, gamma = delta, epsilon = zeta, eta = theta, iota = kappa} = do
  beta + delta + zeta + theta + kappa
```

Pattern matching, long

```haskell
fun Rec { alpha = beta
        , gamma = delta
        , epsilon = zeta
        , eta = theta
        , iota = kappa
        , lambda = mu
        } =
  beta + delta + zeta + theta + kappa + mu + beta + delta + zeta + theta + kappa
```

# Johan Tibell compatibility checks

Basic example from Tibbe's style

``` haskell
sayHello :: IO ()
sayHello = do
  name <- getLine
  putStrLn $ greeting name
  where
    greeting name = "Hello, " ++ name ++ "!"

filter :: (a -> Bool) -> [a] -> [a]
filter _ [] = []
filter p (x:xs)
  | p x = x : filter p xs
  | otherwise = filter p xs
```

Data declarations

``` haskell
data Tree a
  = Branch !a
           !(Tree a)
           !(Tree a)
  | Leaf

data HttpException
  = InvalidStatusCode Int
  | MissingContentHeader

data Person = Person
  { firstName :: !String -- ^ First name
  , lastName :: !String -- ^ Last name
  , age :: !Int -- ^ Age
  }
```

Spaces between deriving classes

``` haskell
-- From https://github.com/chrisdone/hindent/issues/167
data Person = Person
  { firstName :: !String -- ^ First name
  , lastName :: !String -- ^ Last name
  , age :: !Int -- ^ Age
  } deriving (Eq, Show)
```

Hanging lambdas

``` haskell
bar :: IO ()
bar =
  forM_ [1, 2, 3] $ \n -> do
    putStrLn "Here comes a number!"
    print n

foo :: IO ()
foo =
  alloca 10 $ \a ->
    alloca 20 $ \b ->
      cFunction fooo barrr muuu (fooo barrr muuu) (fooo barrr muuu)
```

# Comments

Comments within a declaration

``` haskell
bob -- after bob
 =
  foo -- next to foo
  -- line after foo
    (bar
       foo -- next to bar foo
       bar -- next to bar
     ) -- next to the end paren of (bar)
    -- line after (bar)
    mu -- next to mu
    -- line after mu
    -- another line after mu
    zot -- next to zot
    -- line after zot
    (case casey -- after casey
           of
       Just -- after Just
        -> do
         justice -- after justice
          *
           foo
             (blah * blah + z + 2 / 4 + a - -- before a line break
              2 * -- inside this mess
              z /
              2 /
              2 /
              aooooo /
              aaaaa -- bob comment
              ) +
           (sdfsdfsd fsdfsdf) -- blah comment
         putStrLn "")
    [1, 2, 3]
    [ 1 -- foo
    , ( 2 -- bar
      , 2.5 -- mu
       )
    , 3
    ]
    -- in the end of the function
  where
    alpha = alpha
    -- between alpha and beta
    beta = beta
    -- after beta

foo = 1 -- after foo

gamma = do
  delta
  epsilon
  -- in the end of a do-block 1

gamma = do
  delta
  epsilon
  -- the very last block is detected differently
```

Doesn't work yet (wrong comment position detection)

```haskell pending
gamma = do
  -- in the beginning of a do-block
  delta
  where
    -- before alpha
    alpha = alpha
```

Haddock comments

``` haskell
-- | Module comment.
module X where

-- | Main doc.
main :: IO ()
main = return ()

data X
  = X -- ^ X is for xylophone.
  | Y -- ^ Y is for why did I eat that pizza.

data X = X
  { field1 :: Int -- ^ Field1 is the first field.
  , field11 :: Char
    -- ^ This field comment is on its own line.
  , field2 :: Int -- ^ Field2 is the second field.
  , field3 :: Char -- ^ This is a long comment which starts next to
    -- the field but continues onto the next line, it aligns exactly
    -- with the field name.
  , field4 :: Char
    -- ^ This is a long comment which starts on the following line
    -- from from the field, lines continue at the sme column.
  }
```

Comments around regular declarations

``` haskell
-- This is some random comment.
-- | Main entry point.
main = putStrLn "Hello, World!"
-- This is another random comment.
```

Multi-line comments

``` haskell
bob {- after bob -}
 =
  foo {- next to foo -}
  {- line after foo -}
    (bar
       foo {- next to bar foo -}
       bar {- next to bar -}
     ) {- next to the end paren of (bar) -}
    {- line after (bar) -}
    mu {- next to mu -}
    {- line after mu -}
    {- another line after mu -}
    zot {- next to zot -}
    {- line after zot -}
    (case casey {- after casey -}
           of
       Just {- after Just -}
        -> do
         justice {- after justice -}
          *
           foo
             (blah * blah + z + 2 / 4 + a - {- before a line break -}
              2 * {- inside this mess -}
              z /
              2 /
              2 /
              aooooo /
              aaaaa {- bob comment -}
              ) +
           (sdfsdfsd fsdfsdf) {- blah comment -}
         putStrLn "")
    [1, 2, 3]
    [ 1 {- foo -}
    , ( 2 {- bar -}
      , 2.5 {- mu -}
       )
    , 3
    ]

foo = 1 {- after foo -}
```

Multi-line comments with multi-line contents

``` haskell
{- | This is some random comment.
Here is more docs and such.
Etc.
-}
main = putStrLn "Hello, World!"
{- This is another random comment. -}
```

# Regression tests

jml Adds trailing whitespace when wrapping #221

``` haskell
x = do
  config <- execParser options
  comments <-
    case config of
      Diff False args -> commentsFromDiff args
      Diff True args -> commentsFromDiff ("--cached" : args)
      Files args -> commentsFromFiles args
  mapM_ (putStrLn . Fixme.formatTodo) (concatMap Fixme.getTodos comments)
```

meditans hindent freezes when trying to format this code #222

``` haskell
c
  :: forall new.
     ( Settable "pitch" Pitch (Map.AsMap (new Map.:\ "pitch")) new
     , Default (Book' (Map.AsMap (new Map.:\ "pitch")))
     )
  => Book' new
c = set #pitch C (def :: Book' (Map.AsMap (new Map.:\ "pitch")))

foo
  :: ( Foooooooooooooooooooooooooooooooooooooooooo
     , Foooooooooooooooooooooooooooooooooooooooooo
     )
  => A
```

bitemyapp wonky multiline comment handling #231

``` haskell
module Woo where

hi = "hello"
{-
test comment
-}
-- blah blah
-- blah blah
-- blah blah
```

cocreature removed from declaration issue #186

``` haskell
-- https://github.com/chrisdone/hindent/issues/186
trans One e n =
  M.singleton
    (Query Unmarked (Mark NonExistent)) -- The goal of this is to fail always
    (emptyImage {notPresent = S.singleton (TransitionResult Two (Just A) n)})
```

sheyll explicit forall in instances #218

``` haskell
-- https://github.com/chrisdone/hindent/issues/218
instance forall x. C

instance forall x. Show x =>
         C x
```

tfausak support shebangs #208

``` haskell
#!/usr/bin/env stack
-- stack runghc
main = pure ()
-- https://github.com/chrisdone/hindent/issues/208
```

joe9 preserve newlines between import groups

``` haskell
-- https://github.com/chrisdone/hindent/issues/200
import           Data.List
import           Data.Maybe

import           FooBar
import           MyProject

import           GHC.Monad

-- blah
import           Hello

import           CommentAfter -- Comment here shouldn't affect newlines
import           HelloWorld

import           CommentAfter -- Comment here shouldn't affect newlines

import           HelloWorld

-- Comment here shouldn't affect newlines
import           CommentAfter

import           HelloWorld
```

Wrapped import list shouldn't add newline

```haskell
import           ATooLongList
                 (alpha, beta, delta, epsilon, eta, gamma, theta, zeta)
import           B
```

radupopescu `deriving` keyword not aligned with pipe symbol for type declarations

``` haskell
data Stuffs
  = Things
  | This
  | That
  deriving (Show)

data Simple =
  Simple
  deriving (Show)
```

sgraf812 top-level pragmas should not add an additional newline #255

``` haskell
-- https://github.com/chrisdone/hindent/issues/255
{-# INLINE f #-}
f :: Int -> Int
f n = n
```

ivan-timokhin breaks code with type operators #277

```haskell
-- https://github.com/chrisdone/hindent/issues/277
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE MultiParamTypeClasses #-}

type m ~> n = ()

class (a :< b) c
```

ivan-timokhin variables swapped around in constraints #278

```haskell
-- https://github.com/chrisdone/hindent/issues/278
data Link c1 c2 a c =
  forall b. (c1 a b, c2 b c) =>
            Link (Proxy b)
```

ttuegel qualified infix sections get mangled #273

```haskell
-- https://github.com/chrisdone/hindent/issues/273
import qualified Data.Vector as V

main :: IO ()
main = do
  let _ = foldr1 (V.++) [V.empty, V.empty]
  pure ()

-- more corner cases.
xs = V.empty V.++ V.empty

ys = (++) [] []

cons :: V.Vector a -> V.Vector a -> V.Vector a
cons = (V.++)
```

ivan-timokhin breaks operators type signatures #301

```haskell
-- https://github.com/chrisdone/hindent/issues/301
(+) :: ()
```

cdepillabout Long deriving clauses are not reformatted #289

```haskell
newtype Foo =
  Foo Proxy
  deriving ( Functor
           , Applicative
           , Monad
           , Semigroup
           , Monoid
           , Alternative
           , MonadPlus
           , Foldable
           , Traversable
           )
```

# Behaviour checks

Unicode

``` haskell
α = γ * "ω"
-- υ
```

Empty module

``` haskell
```

Trailing newline is preserved

``` haskell
module X where

foo = 123
```

# Complex input

A complex, slow-to-print decl

``` haskell
quasiQuotes =
  [ ( ''[]
    , \(typeVariable:_) _automaticPrinter ->
        (let presentVar = varE (presentVarName typeVariable)
         in lamE
              [varP (presentVarName typeVariable)]
              [|(let typeString = "[" ++ fst $(presentVar) ++ "]"
                 in ( typeString
                    , \xs ->
                        case fst $(presentVar) of
                          "GHC.Types.Char" ->
                            ChoicePresentation
                              "String"
                              [ ( "String"
                                , StringPresentation
                                    "String"
                                    (concatMap
                                       getCh
                                       (map (snd $(presentVar)) xs)))
                              , ( "List of characters"
                                , ListPresentation
                                    typeString
                                    (map (snd $(presentVar)) xs))
                              ]
                            where getCh (CharPresentation "GHC.Types.Char" ch) =
                                    ch
                                  getCh (ChoicePresentation _ ((_, CharPresentation _ ch):_)) =
                                    ch
                                  getCh _ = ""
                          _ ->
                            ListPresentation
                              typeString
                              (map (snd $(presentVar)) xs)))|]))
  ]
```

Random snippet from hindent itself

``` haskell
exp' (App _ op a) = do
  (fits, st) <- fitsOnOneLine (spaced (map pretty (f : args)))
  if fits
    then put st
    else do
      pretty f
      newline
      spaces <- getIndentSpaces
      indented spaces (lined (map pretty args))
  where
    (f, args) = flatten op [a]
    flatten :: Exp NodeInfo -> [Exp NodeInfo] -> (Exp NodeInfo, [Exp NodeInfo])
    flatten (App _ f' a') b = flatten f' (a' : b)
    flatten f' as = (f', as)
```
