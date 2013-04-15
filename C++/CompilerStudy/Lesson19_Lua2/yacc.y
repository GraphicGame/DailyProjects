%token CONTINUE BREAK DO ELSE ELSEIF END FALSE 
%token FOR FUNCTION IF IN LOCAL NIL
%token REPEAT RETURN THEN TRUE UNTIL WHILE

%token OP_ARGS

%token LITERAL1 LITERAL2 LITERAL3
%token NUMBER1 NUMBER2 NUMBER3

%token ID

%right OP_ASSIGN

%left AND OR
%left OP_EQUAL OP_NEQUAL OP_LEQUAL OP_GEQUAL OP_LESS OP_GREATER
%left OP_ADD OP_SUB
%left OP_MUL OP_DIV OP_MOD
%left OP_POWER
%left OP_CONCAT

%nonassoc OP_LEN NOT

%{

#include "LuaFunction.h"
#include "SymbolTable.h"

%}

%%

Program : Block;

Block
    : StatementList 
    | LastStatement 
    | StatementList StatementSep LastStatement 
    | 
    ;

StatementList
    : Statement 
    | StatementList StatementSep Statement
    ;

StatementSep : ';' | ;

Statement
    : VarList OP_ASSIGN ExpList
    | FunctionCall 
    | DO Block END
    | WHILE Exp DO Block END
    | REPEAT Block UNTIL Exp
    | IF Exp THEN Block Opt_ElseIfList Opt_ElseBlock END 
    | FOR ID OP_ASSIGN Exp ',' Exp DO Block END
    | FOR ID OP_ASSIGN Exp ',' Exp ',' Exp DO Block END
    | FOR IDList IN ExpList DO Block END
    | FUNCTION FuncName FuncBody 
    | LOCAL FUNCTION ID FuncBody
    | LOCAL IDList
    | LOCAL IDList OP_ASSIGN ExpList
    ;

Opt_ElseBlock
    : ElseBlock 
    | 
    ;
ElseBlock: ELSE Block ;

Opt_ElseIfList 
    : ElseIfList
    | 
    ;

ElseIfList 
    : ElseIf 
    | ElseIfList ElseIf 
    ;
ElseIf : ELSEIF Exp THEN Block ;

LastStatement 
    : RETURN Opt_ExpList
    | BREAK
    | CONTINUE
    ;
        
FuncName 
    : DotIDList
    | DotIDList ':' ID
    ;

DotIDList 
    : ID
    | DotIDList '.' ID
    ;

IDList 
    : ID 
    | IDList ',' ID
    ;

Opt_ExpList 
    :
    | ExpList
    ;
ExpList 
    : Exp
    | ExpList ',' Exp
    ;
Exp 
    : NIL
    | FALSE
    | TRUE
    | Number
    | Literal
    | OP_ARGS
    | Lambda
    | PrefixExp
    | '(' Exp ')'
    | TableConstructor
    | BinOp_Exp 
    | UnOp_Exp
    ;

VarList 
    : Var
    | VarList ',' Var
    ;
Var 
    : ID
    | PrefixExp '[' Exp ']'
    | PrefixExp '.' ID
    ;

PrefixExp 
    : Var
    | FunctionCall  
    ;

FunctionCall 
    : PrefixExp Params 
    | PrefixExp ':' ID Params
    ;

Params 
    : '(' Opt_ExpList ')'
    | Literal
    | TableConstructor
    ;

Lambda : FUNCTION FuncBody
FuncBody : '(' Opt_ArgList ')' Block END

Opt_ArgList 
    :
    | ArgList
    ;
ArgList 
    : IDList
    | OP_ARGS
    | IDList ',' OP_ARGS
    ;

TableConstructor 
    : '{' Opt_FieldList '}' 
    ;

Opt_FieldList 
    : 
    | FieldList
    ;
FieldList 
    : Field
    | FieldList FieldSep Field
    ;

FieldSep : ',' | ';' ;

Field 
    : Exp
    | ID OP_ASSIGN Exp 
    | '[' Exp ']' OP_ASSIGN Exp
    ;

BinOp_Exp 
    : Exp AND Exp 
    | Exp OR Exp
    | Exp OP_LESS Exp
    | Exp OP_LEQUAL Exp
    | Exp OP_GREATER Exp
    | Exp OP_GEQUAL Exp 
    | Exp OP_EQUAL Exp
    | Exp OP_NEQUAL Exp
    | Exp OP_ADD Exp 
    | Exp OP_SUB Exp 
    | Exp OP_MUL Exp
    | Exp OP_DIV Exp
    | Exp OP_MOD Exp
    | Exp OP_POWER Exp
    | Exp OP_CONCAT Exp
    ;
UnOp_Exp 
    : OP_SUB Exp 
    | NOT Exp 
    | OP_LEN Exp
    ;

Number 
    : NUMBER1
    | NUMBER2
    | NUMBER3
    ;
Literal
    : LITERAL1
    | LITERAL2
    | LITERAL3 {
    }
    ;

%%

bool parseFile(const char *fname)
{
    bool succ = false;
    FILE *f = fopen(fname, "r");
    try
    {
        SymbolTable::push(new LuaFunctionMeta());

        yyrestart(f);
        yyparse();
        succ = true;

        SymbolTable::pop();
    }
    catch(const exception& e) {
        printf("Catch parse exception: %s\n", e.what());
    }
    fclose(f);
    return succ;
}

