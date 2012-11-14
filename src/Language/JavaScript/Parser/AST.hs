module Language.JavaScript.Parser.AST
    ( JSNode (..)
    , JSAnnot (..)
    , JSBinOp (..)
    , JSUnaryOp (..)
    , JSSemi (..)
    , JSAssignOp (..)
    , JSTryCatch (..)
    , JSTryFinally (..)
    , JSStatement (..)
    , JSBlock (..)
    , JSSwitchParts (..)
    , JSAST (..)
    , JSAccessor (..)
    , JSIdentName (..)
    , JSArguments (..)
    , JSVarInit (..)

    , JSList (..)
    , JSNonEmptyList (..)

    , showStripped
    ) where

import Data.List
import Language.JavaScript.Parser.SrcLocation (TokenPosn (..))
import Language.JavaScript.Parser.Token

-- ---------------------------------------------------------------------

data JSAnnot = JSAnnot TokenPosn [CommentAnnotation]-- ^Annotation: position and comment/whitespace information
             | JSNoAnnot -- ^No annotation
    deriving Eq

instance Show JSAnnot where
    show JSNoAnnot = "NoAnnot"
    show (JSAnnot pos cs) = "Annot (" ++ show pos ++ ") " ++ show cs

data JSBinOp
    = JSBinOpAnd JSAnnot
    | JSBinOpBitAnd JSAnnot
    | JSBinOpBitOr JSAnnot
    | JSBinOpBitXor JSAnnot
    | JSBinOpDivide JSAnnot
    | JSBinOpEq JSAnnot
    | JSBinOpGe JSAnnot
    | JSBinOpGt JSAnnot
    | JSBinOpIn JSAnnot
    | JSBinOpInstanceOf JSAnnot
    | JSBinOpLe JSAnnot
    | JSBinOpLsh JSAnnot
    | JSBinOpLt JSAnnot
    | JSBinOpMinus JSAnnot
    | JSBinOpMod JSAnnot
    | JSBinOpNeq JSAnnot
    | JSBinOpOr JSAnnot
    | JSBinOpPlus JSAnnot
    | JSBinOpRsh JSAnnot
    | JSBinOpStrictEq JSAnnot
    | JSBinOpStrictNeq JSAnnot
    | JSBinOpTimes JSAnnot
    | JSBinOpUrsh JSAnnot
    deriving (Show, Eq)

data JSUnaryOp
    = JSUnaryOpDecr JSAnnot
    | JSUnaryOpDelete JSAnnot
    | JSUnaryOpIncr JSAnnot
    | JSUnaryOpMinus JSAnnot
    | JSUnaryOpNot JSAnnot
    | JSUnaryOpPlus JSAnnot
    | JSUnaryOpTilde JSAnnot
    | JSUnaryOpTypeof JSAnnot
    | JSUnaryOpVoid JSAnnot
    deriving (Show, Eq)

data JSSemi
    = JSSemi JSAnnot
    | JSSemiAuto
    deriving (Show, Eq)

data JSAssignOp
    = JSAssign JSAnnot
    | JSTimesAssign JSAnnot
    | JSDivideAssign JSAnnot
    | JSModAssign JSAnnot
    | JSPlusAssign JSAnnot
    | JSMinusAssign JSAnnot
    | JSLshAssign JSAnnot
    | JSRshAssign JSAnnot
    | JSUrshAssign JSAnnot
    | JSBwAndAssign JSAnnot
    | JSBwXorAssign JSAnnot
    | JSBwOrAssign JSAnnot
    deriving (Show, Eq)

data JSTryCatch
    = JSCatch JSAnnot JSAnnot JSNode JSAnnot JSBlock -- ^catch,lb,ident,rb,block
    | JSCatchIf JSAnnot JSAnnot JSNode JSAnnot JSNode JSAnnot JSBlock -- ^catch,lb,ident,if,expr,rb,block
    deriving (Show, Eq)

data JSTryFinally
    = JSFinally JSAnnot JSBlock -- ^finally,block
    | JSNoFinally
    deriving (Show, Eq)

data JSBlock
    = JSBlock JSAnnot [JSStatement] JSAnnot -- ^lbrace, stmts, rbrace
    deriving (Show, Eq)

data JSSwitchParts
    = JSCase JSAnnot JSNode JSAnnot [JSStatement]    -- ^expr,colon,stmtlist
    | JSDefault JSAnnot JSAnnot [JSStatement] -- ^colon,stmtlist
    deriving (Show, Eq)

data JSStatement
    = JSStatementBlock JSBlock      -- ^statement block
    | JSBreak JSAnnot (Maybe JSIdentName) JSSemi        -- ^break,optional identifier, autosemi
    | JSConstant JSAnnot [JSStatement] JSSemi -- ^const, decl, autosemi
    | JSContinue JSAnnot (Maybe JSIdentName) JSSemi     -- ^continue, optional identifier,autosemi
    | JSDoWhile JSAnnot JSStatement JSAnnot JSAnnot JSNode JSAnnot JSSemi -- ^do,stmt,while,lb,expr,rb,autosemi
    | JSFor JSAnnot JSAnnot [JSNode] JSAnnot [JSNode] JSAnnot [JSNode] JSAnnot JSStatement -- ^for,lb,expr,semi,expr,semi,expr,rb.stmt
    | JSForIn JSAnnot JSAnnot JSNode JSBinOp JSNode JSAnnot JSStatement -- ^for,lb,expr,in,expr,rb,stmt
    | JSForVar JSAnnot JSAnnot JSAnnot [JSStatement] JSAnnot [JSNode] JSAnnot [JSNode] JSAnnot JSStatement -- ^for,lb,var,vardecl,semi,expr,semi,expr,rb,stmt
    | JSForVarIn JSAnnot JSAnnot JSAnnot JSStatement JSBinOp JSNode JSAnnot JSStatement -- ^for,lb,var,vardecl,in,expr,rb,stmt
    | JSFunction JSAnnot JSNode JSAnnot (JSList JSIdentName) JSAnnot JSBlock  -- ^fn,name, lb,parameter list,rb,block
    | JSIf JSAnnot JSAnnot JSNode JSAnnot JSStatement -- ^if,(,expr,),stmt
    | JSIfElse JSAnnot JSAnnot JSNode JSAnnot JSStatement JSAnnot JSStatement -- ^if,(,expr,),stmt,else,rest
    | JSLabelled JSNode JSAnnot JSStatement -- ^identifier,colon,stmt
    | JSEmptyStatement JSAnnot
    | JSExpressionStatement JSNode JSSemi
    | JSReturn JSAnnot (Maybe JSNode) JSSemi -- ^optional expression,autosemi
    | JSSwitch JSAnnot JSAnnot JSNode JSAnnot JSAnnot [JSSwitchParts] JSAnnot-- ^switch,lb,expr,rb,caseblock
    | JSThrow JSAnnot JSNode -- ^throw val
    | JSTry JSAnnot JSBlock [JSTryCatch] JSTryFinally -- ^try,block,catches,finally
    | JSVarDecl JSNode JSVarInit -- ^identifier, initializer
    | JSVariable JSAnnot [JSStatement] JSSemi -- ^var|const, decl, autosemi
    | JSWhile JSAnnot JSAnnot JSNode JSAnnot JSStatement -- ^while,lb,expr,rb,stmt
    | JSWith JSAnnot JSAnnot JSNode JSAnnot JSStatement JSSemi -- ^with,lb,expr,rb,stmt list
    deriving (Show, Eq)

data JSAST
    = JSSourceElementsTop [JSStatement] -- ^source elements
    deriving (Show, Eq)

data JSVarInit
    = JSVarInit JSAnnot JSNode -- ^ assignop, initializer
    | JSVarInitNone
    deriving (Show, Eq)

-- | The JSNode is the building block of the AST.
-- Each has a syntactic part 'Node'. In addition, the leaf elements
-- (terminals) have a position 'TokenPosn', as well as an array of comments
-- and/or whitespace that was collected while parsing.

data JSNode
    -- | Terminals
    = JSIdentifier JSAnnot String
    | JSDecimal JSAnnot String
    | JSLiteral JSAnnot String
    | JSHexInteger JSAnnot String
    | JSOctal JSAnnot String
    | JSStringLiteral JSAnnot Char String
    | JSRegEx JSAnnot String

    -- | Non Terminals
    | JSArrayLiteral JSAnnot [JSNode] JSAnnot -- ^lb, contents, rb
    | JSAssignExpression JSNode JSAssignOp JSNode -- ^lhs, assignop, rhs
    | JSCallExpression JSNode JSArguments  -- ^expr, args
    | JSCallExpressionDot JSNode JSAnnot JSNode  -- ^expr, dot, expr
    | JSCallExpressionSquare JSNode JSAnnot JSNode JSAnnot  -- ^expr, [, expr, ]
    | JSElision [JSNode]               -- ^comma
    | JSCommaExpression JSNode JSAnnot JSNode          -- ^expression components
    | JSExpressionBinary JSNode JSBinOp JSNode -- ^lhs, op, rhs
    | JSExpressionParen JSAnnot JSNode JSAnnot -- ^lb,expression,rb
    | JSExpressionPostfix JSNode JSUnaryOp -- ^expression, operator
    | JSExpressionTernary JSNode JSAnnot JSNode JSAnnot JSNode -- ^cond, ?, trueval, :, falseval
    | JSFunctionExpression JSAnnot (Maybe JSIdentName) JSAnnot (JSList JSIdentName) JSAnnot JSBlock -- ^fn,name,lb, parameter list,rb,block`
    | JSMemberDot JSNode JSAnnot JSNode -- ^firstpart, dot, name
    | JSMemberExpression JSNode JSArguments -- expr, args
    | JSMemberNew JSAnnot JSNode JSArguments -- ^new, name, args
    | JSMemberSquare JSNode JSAnnot JSNode JSAnnot -- ^firstpart, lb, expr, rb
    | JSNewExpression JSAnnot JSNode -- ^new, expr
    | JSObjectLiteral JSAnnot [JSNode] JSAnnot -- ^lbrace contents rbrace
    | JSPropertyAccessor JSAccessor JSIdentName JSAnnot [JSNode] JSAnnot JSBlock -- ^(get|set), name, lb, params, rb, block
    | JSPropertyNameandValue JSIdentName JSAnnot [JSNode] -- ^name, colon, value
    | JSUnaryExpression JSUnaryOp JSNode
    deriving (Show, Eq)

-- | Accessors for JSPropertyAccessor is either 'get' or 'set'.
data JSAccessor
    = JSAccessorGet JSAnnot
    | JSAccessorSet JSAnnot
    deriving (Show, Eq)

data JSIdentName
    = JSIdentName JSAnnot String
    deriving Eq

data JSList a
    = JSParams (JSNonEmptyList a) -- ^tail, comma, ident
    | JSNoParams
    deriving (Show, Eq)

data JSNonEmptyList a
    = JSLCons (JSNonEmptyList a) JSAnnot a
    | JSLOne a
    deriving Eq

data JSArguments
    = JSArguments JSAnnot (JSList JSNode) JSAnnot    -- ^lb, args, rb
    deriving (Show, Eq)

-- Strip out the location info, leaving the original JSNode text representation
showStripped :: JSAST -> String
showStripped (JSSourceElementsTop xs) = "JSSourceElementsTop " ++ ssts xs


ss :: JSNode -> String
ss (JSArrayLiteral _lb xs _rb) = "JSArrayLiteral " ++ sss xs
ss (JSAssignExpression lhs op rhs) = "JSExpression " ++ ss lhs ++ " " ++ sopa op ++ " " ++ ss rhs
ss (JSCallExpression ex xs) = "JSExpression " ++ ss ex ++ "JSCallExpression \"()\" " ++ ssa xs
ss (JSCallExpressionDot ex _os xs) = "JSExpression " ++ ss ex ++ "JSCallExpression \".\" " ++ ss xs
ss (JSCallExpressionSquare ex _os xs _cs) = "JSExpression " ++ ss ex ++ "JSCallExpression \"[]\" " ++ ss xs
ss (JSDecimal _ s) = "JSDecimal " ++ show s
ss (JSElision c) = "JSElision " ++ sss c
ss (JSCommaExpression l _ r) = "JSExpression [" ++ ss l ++ "," ++ ss r ++ "]"
ss (JSExpressionBinary x2 op x3) = "JSExpressionBinary " ++ sbop op ++ " " ++ ss x2 ++ " " ++ ss x3
ss (JSExpressionParen _lp x _rp) = "JSExpressionParen (" ++ ss x ++ ")"
ss (JSExpressionPostfix xs op) = "JSExpressionPostfix " ++ suop op ++ " " ++ ss xs
ss (JSExpressionTernary x1 _q x2 _c x3) = "JSExpressionTernary " ++ ss x1 ++ " " ++ ss x2 ++ " " ++ ss x3
ss (JSFunctionExpression _ n _lb pl _rb x3) = "JSFunctionExpression " ++ ssmi n ++ " " ++ ssjl pl ++ " (" ++ ssb x3 ++ ")"
ss (JSHexInteger _ s) = "JSHexInteger " ++ show s
ss (JSOctal _ s) = "JSOctal " ++ show s
ss (JSIdentifier _ s) = "JSIdentifier " ++ show s
ss (JSLiteral _ []) = ""
ss (JSLiteral _ s) = "JSLiteral " ++ show s
ss (JSMemberDot x1s _d x2 ) = "JSMemberDot " ++ ss x1s ++ " (" ++ ss x2 ++ ")"
ss (JSMemberExpression e a) = "JSMemberExpression (" ++ ss e ++ ssa a ++ ")"
ss (JSMemberNew _a n s) = "JSMemberNew \"" ++ ss n ++ "\"" ++ ssa s
ss (JSMemberSquare x1s _lb x2 _rb) = "JSMemberSquare " ++ ss x1s ++ " (" ++ ss x2 ++ ")"
ss (JSNewExpression _n e) = "JSNewExpression " ++ ss e
ss (JSObjectLiteral _lb xs _rb) = "JSObjectLiteral " ++ sss xs
ss (JSPropertyNameandValue x1 _colon x2s) = "JSPropertyNameandValue (" ++ show x1 ++ ") " ++ sss x2s
ss (JSPropertyAccessor s x1 _lb1 x2s _rb1 x3) = "JSPropertyAccessor " ++ show s ++ " (" ++ show x1 ++ ") " ++ sss x2s ++ " (" ++ ssb x3 ++ ")"
ss (JSRegEx _ s) = "JSRegEx " ++ show s
ss (JSStringLiteral _ c s) = "JSStringLiteral " ++ show c ++ " " ++ show s
ss (JSUnaryExpression op x) = "JSUnaryExpression " ++ suop op ++ ss x

sss :: [JSNode] -> String
sss xs = "[" ++ commaJoin (map ss xs) ++ "]"

-- The test suite expects operators to be double quoted.
sbop :: JSBinOp -> String
sbop = show . showbinop

showbinop :: JSBinOp -> String
showbinop (JSBinOpAnd _) = "&&"
showbinop (JSBinOpBitAnd _) = "&"
showbinop (JSBinOpBitOr _) = "|"
showbinop (JSBinOpBitXor _) = "^"
showbinop (JSBinOpDivide _) = "/"
showbinop (JSBinOpEq _) = "=="
showbinop (JSBinOpGe _) = ">="
showbinop (JSBinOpGt _) = ">"
showbinop (JSBinOpIn _) = " in "
showbinop (JSBinOpInstanceOf _) = "instanceof"
showbinop (JSBinOpLe _) = "<="
showbinop (JSBinOpLsh _) = "<<"
showbinop (JSBinOpLt _) = "<"
showbinop (JSBinOpMinus _) = "-"
showbinop (JSBinOpMod _) = "%"
showbinop (JSBinOpNeq _) = "!="
showbinop (JSBinOpOr _) = "||"
showbinop (JSBinOpPlus _) = "+"
showbinop (JSBinOpRsh _) = ">>"
showbinop (JSBinOpStrictEq _) = "==="
showbinop (JSBinOpStrictNeq _) = "!=="
showbinop (JSBinOpTimes _) = "*"
showbinop (JSBinOpUrsh _) = ">>>"

suop :: JSUnaryOp -> String
suop = show . showuop

showuop :: JSUnaryOp -> String
showuop (JSUnaryOpDecr _) = "--"
showuop (JSUnaryOpDelete _) = "delete "
showuop (JSUnaryOpIncr _) = "++"
showuop (JSUnaryOpMinus _) = "-"
showuop (JSUnaryOpNot _) = "!"
showuop (JSUnaryOpPlus _) = "+"
showuop (JSUnaryOpTilde _) = "~"
showuop (JSUnaryOpTypeof _) = "typeof "
showuop (JSUnaryOpVoid _) = "void "

showsemi :: JSSemi -> String
showsemi (JSSemi _) = "JSLiteral \";\""
showsemi JSSemiAuto = ""

sopa :: JSAssignOp -> String
sopa (JSAssign _) = "="
sopa (JSTimesAssign _) = "*="
sopa (JSDivideAssign _) = "/="
sopa (JSModAssign _) = "%="
sopa (JSPlusAssign _) = "+="
sopa (JSMinusAssign _) = "-="
sopa (JSLshAssign _) = "<<="
sopa (JSRshAssign _) = ">>="
sopa (JSUrshAssign _) = ">>>="
sopa (JSBwAndAssign _) = "&="
sopa (JSBwXorAssign _) = "^="
sopa (JSBwOrAssign _) = "|="

stcs :: [JSTryCatch] -> String
stcs xs = "[" ++ commaJoin (map stc xs) ++ "]"

stc :: JSTryCatch -> String
stc (JSCatch _ _lb x1 _rb x3) = "JSCatch (" ++ ss x1 ++ ") (" ++ ssb x3 ++ ")"
stc (JSCatchIf _ _lb x1 _ ex _rb x3) = "JSCatch (" ++ ss x1 ++ ") if " ++ ss ex ++ " (" ++ ssb x3 ++ ")"

stf :: JSTryFinally -> String
stf (JSFinally _ x) = "JSFinally (" ++ ssb x ++ ")"
stf JSNoFinally = ""

sst :: JSStatement -> String
sst (JSStatementBlock blk) = "JSStatementBlock (" ++ ssb blk ++ ")"
sst (JSBreak _ n s) = "JSBreak " ++ ssmi n ++ " " ++ showsemi s
sst (JSContinue _ mi s) = "JSContinue " ++ ssmi mi ++ " " ++ showsemi s
sst (JSConstant _ xs _as) = "JSConstant const " ++ ssts xs
sst (JSDoWhile _d x1 _w _lb x2 _rb x3) = "JSDoWhile (" ++ sst x1 ++ ") (" ++ ss x2 ++ ") (" ++ showsemi x3 ++ ")"
sst (JSFor _ _lb x1s _s1 x2s _s2 x3s _rb x4) = "JSFor " ++ sss x1s ++ " " ++ sss x2s ++ " " ++ sss x3s ++ " (" ++ sst x4 ++ ")"
sst (JSForIn _ _lb x1s _i x2 _rb x3) = "JSForIn " ++ ss x1s ++ " (" ++ ss x2 ++ ") (" ++ sst x3 ++ ")"
sst (JSForVar _ _lb _v x1s _s1 x2s _s2 x3s _rb x4) = "JSForVar " ++ ssts x1s ++ " " ++ sss x2s ++ " " ++ sss x3s ++ " (" ++ sst x4 ++ ")"
sst (JSForVarIn _ _lb _v x1 _i x2 _rb x3) = "JSForVarIn (" ++ sst x1 ++ ") (" ++ ss x2 ++ ") (" ++ sst x3 ++ ")"
sst (JSFunction _ x1 _lb pl _rb x3) = "JSFunction (" ++ ss x1 ++ ") " ++ ssjl pl ++ " (" ++ ssb x3 ++ ")"
sst (JSIf _ _lb x1 _rb x2) = "JSIf (" ++ ss x1 ++ ") (" ++ sst x2 ++ ")"
sst (JSIfElse _ _lb x1 _rb x2 _e x3) = "JSIf (" ++ ss x1 ++ ") (" ++ sst x2 ++ ") (" ++ sst x3 ++ ")"
sst (JSLabelled x1 _c x2) = "JSLabelled (" ++ ss x1 ++ ") (" ++ sst x2 ++ ")"
sst (JSEmptyStatement _) = ""
sst (JSExpressionStatement l s) = ss l ++ showsemi s
sst (JSReturn _ me s) = "JSReturn " ++ ssme me ++ " " ++ showsemi s
sst (JSSwitch _ _lp x _rp _lb x2 _rb) = "JSSwitch (" ++ ss x ++ ") " ++ ssws x2
sst (JSThrow _ x) = "JSThrow (" ++ ss x ++ ")"
sst (JSTry _ xt1 xtc xtf) = "JSTry (" ++ ssb xt1 ++ ") " ++ stcs xtc ++ stf xtf
sst (JSVarDecl x1 x2) = "JSVarDecl (" ++ ss x1 ++ ") " ++ ssvi x2
sst (JSVariable _ xs _as) = "JSVariable var " ++ ssts xs
sst (JSWhile _ _lb x1 _rb x2) = "JSWhile (" ++ ss x1 ++ ") (" ++ sst x2 ++ ")"
sst (JSWith _ _lb x1 _rb x s) = "JSWith (" ++ ss x1 ++ ") " ++ sst x ++ showsemi s

ssvi :: JSVarInit -> String
ssvi (JSVarInit _ n) = "= " ++ ss n
ssvi JSVarInitNone = ""

ssts :: [JSStatement] -> String
ssts xs = "[" ++ commaJoin (map sst xs) ++ "]"

ssb :: JSBlock -> String
ssb (JSBlock _ xs _) = "JSStatementBlock (" ++ ssts xs ++ ")"

ssw :: JSSwitchParts -> String
ssw (JSCase _ x1 _c x2s) = "JSCase (" ++ ss x1 ++ ") (" ++ ssts x2s ++ ")"
ssw (JSDefault _ _c xs) = "JSDefault (" ++ ssts xs ++ ")"

ssws :: [JSSwitchParts] -> String
ssws xs = "[" ++ commaJoin (map ssw xs) ++ "]"

ssjl :: Show a => JSList a -> String
ssjl (JSParams nel) = "[" ++ show nel ++ "]"
ssjl JSNoParams = "[]"


ssa :: JSArguments -> String
ssa (JSArguments _lb xs _rb) = "JSArguments (" ++ show xs ++ ")"


instance Show a => Show (JSNonEmptyList a) where
    show (JSLCons l _ i) = show l ++ "," ++ show i
    show (JSLOne i)      = show i

instance Show JSIdentName where
    show (JSIdentName _ s) = "JSIdentifier " ++ show s


ssmi :: Maybe JSIdentName -> String
ssmi Nothing = ""
ssmi (Just n) = show n

ssme :: Maybe JSNode -> String
ssme Nothing = ""
ssme (Just e) = ss e

commaJoin :: [String] -> String
commaJoin s = intercalate "," $ filter (not . null) s

-- EOF
