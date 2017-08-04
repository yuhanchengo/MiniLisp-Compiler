%{
    #include<iostream>
    #include<cstdlib>
    #include "AST.h"
    #include<map>
    #include<string>
    #include<stack>
    #include<vector>
    
    extern int yylex(void);
    void yyerror(const char *msg);
    // global variable root node for ASTTree
    typedef std::map<std::string, ASTNode *> Map;
    Map* idMap;
    Map::iterator iter;
    std::stack<ASTType> stack_ASTtype;
    std::stack<ASTType> stack_Operant;
    ASTNode *root;

    // customized functions
    int calOper(ASTNode *, Map *map);
    bool logOper(ASTNode *, Map *map);
    void constructMap(ASTNode *node);
    bool ASTEqual(ASTNode *node, Map *map);
    ASTNode *searchMap(ASTNode *node, Map *map);
    ASTVal* preTraverse(ASTNode *, Map *map);
    ASTNode* ifCond(ASTNode *node, Map *map);
    ASTVal* funMap(ASTNode *fun_exp, ASTNode *par_node);
    ASTNode* sReduce(ASTNode *exp_1, ASTNode *exp2);
    ASTNode* cReduce(ASTNode *exp_1, ASTNode *exp_2, ASTNode *exp_3);
    char * findName(int enumber);
%}

%union {
    bool boolean;
    int num;
    char *id;
    ASTNode *node;
}

%token<num> NUM
%token<id> ID
%token<boolean> BOOL
%token MOD AND OR NOT DEFINE FUN IF PRINT_NUM PRINT_BOOL
%type<node> program stmt stmts print_stmt def_stmt exps exp
%type<node> and_op or_op not_op test_exp then_exp else_exp fun_name
%type<node> plus minus multiply divide modulus greater smaller equal
%type<node> num_op logical_op fun_exp fun_call fun_ids fun_body if_exp
%type<node> variable variables params param

%left BOOL NUM ID
%left '+' '-'
%left '*' '/' MOD
%left AND OR NOT
%left '(' ')'

%%
program: stmt stmts {
            stack_ASTtype.push(AST_ROOT);
            $$ = sReduce($1, $2);
            root = $$;
        }
        ;
stmts: stmt stmts {
            stack_ASTtype.push(AST_ROOT);
            $$ = sReduce($1, $2);
        }
     |  { 
            stack_ASTtype.push(AST_NULL);
            $$ = sReduce(NULL, NULL); 
        }
     ;
stmt: exp 
    | def_stmt 
    | print_stmt 
    ;
print_stmt: '(' PRINT_NUM exp ')' { $$ = sReduce($3, NULL); }
          | '(' PRINT_BOOL exp ')' { $$ = sReduce($3, NULL); }
          ;
exps: exp exps {
            $$ = (ASTNode *)malloc(sizeof(ASTNode));
            $$->type = stack_ASTtype.top();
            $$->lhs = $1;
            $$->rhs = $2;
    }
    | { 
         stack_ASTtype.push(AST_NULL);
         $$ = sReduce(NULL, NULL); 
      }
    ;
exp: BOOL {
            stack_Operant.push(AST_BOOL);
            ASTBool *b = (ASTBool *)malloc(sizeof(ASTBool));
            b->type = AST_BOOL;
            b->boolean = $1;
            $$ = (ASTNode *)b;
        }
    | NUM  {
            stack_Operant.push(AST_NUM);
            ASTNum *num = (ASTNum *)malloc(sizeof(ASTNum));
            num->type = AST_NUM;
            num->num = $1;
            $$ = (ASTNode *)num;
        }
    | variable 
    | num_op 
    | logical_op 
    | fun_exp 
    | fun_call 
    | if_exp
    ;
num_op: plus 
      | minus 
      | multiply 
      | divide 
      | modulus 
      | greater 
      | smaller 
      | equal 
      ;
plus: '(' '+' exp exp exps ')' 
    {   
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM){
                 char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = cReduce($3, $4, $5);
     }
    ;
minus: '(' '-' exp exp ')' 
     { 
         while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM){
                  char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
             stack_Operant.pop();
         }
         $$ = sReduce($3, $4); 
     }
     ;
multiply: '(' '*' exp exp exps ')' 
    {
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM){
                 char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
         $$ = cReduce($3, $4, $5); 
    }
        ;
divide: '(' '/' exp exp ')' 
    {  while(!stack_Operant.empty()){
            if(stack_Operant.top()!=AST_NUM){
                  char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = sReduce($3, $4); 
    }
         ;
modulus: '(' MOD exp exp ')' 
    { 
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM){
                  char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = sReduce($3, $4); 
    }
        ;
greater: '(' '>' exp exp ')' {
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM){
                  char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = sReduce($3, $4); 
    }
       ;
smaller: '(' '<' exp exp ')' 
    { 
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM){
                char * name = findName(stack_Operant.top());
                 printf("Expect number but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = sReduce($3, $4);
     }
       ;
equal: '(' '=' exp exp exps ')' 
    { 
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_NUM || stack_Operant.top()!=AST_BOOL){
                  char * name = findName(stack_Operant.top());
                 printf("Expect number or bool but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = cReduce($3, $4, $5); 
    }
       ;
logical_op: and_op 
          | or_op 
          | not_op 
           ;
and_op: '(' AND exp exp exps ')' 
        {   
            while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_BOOL){
                  char * name = findName(stack_Operant.top());
                 printf("Expect bool but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
            $$ = cReduce($3, $4, $5);
         }
      ;
or_op: '(' OR exp exp exps ')' 
    { 
        while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_BOOL){
                 char * name = findName(stack_Operant.top());
                 printf("Expect bool but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
        $$ = cReduce($3, $4, $5);
     }
     ;
not_op: '(' NOT exp ')' {
             while(!stack_Operant.empty()){
             if(stack_Operant.top()!=AST_BOOL){
                  char * name = findName(stack_Operant.top());
                 printf("Expect bool but got %s\n",name);
                 exit(0);
             }
            stack_Operant.pop();
        }
         $$ = sReduce($3, NULL); 
         }
      ;
def_stmt: '(' DEFINE variable exp ')' { $$ = sReduce($3, $4); }
        ;
variable: ID {
        //  stack_Operant.push(AST_ID);
         ASTId *id = (ASTId *)malloc(sizeof(ASTId));
         id->type = AST_ID;
         id->id = (char *)malloc(sizeof(char) * strlen($1));
         id->id = $1;
        $$ = (ASTNode *)id;
        }
        ;
fun_exp: '(' FUN fun_ids fun_body ')' { $$ = sReduce($3, $4); }
        ;
fun_ids: '(' variables ')' { $$ = $2; }
       ;
fun_body: exp
        ;
fun_call: '(' fun_exp params ')'  { 
              stack_ASTtype.push(AST_FUN_CALL);
              $$ = sReduce($2, $3);
        }
        | '(' fun_name params ')' {
              stack_ASTtype.push(AST_FUN_NAME);
              $$ = sReduce($2, $3);
         }
         ;
fun_name: variable;
params: param params {
                    stack_ASTtype.push(AST_NUM);
                    $$ = sReduce($1, $2);
            }
       |  {
              stack_ASTtype.push(AST_NULL);
              $$ = sReduce(NULL, NULL);
          }
       ;
param: exp
     ;
variables: variable variables {
                stack_ASTtype.push(AST_ID);
                $$ = sReduce($1, $2);
         }
         | { 
                stack_ASTtype.push(AST_NULL);
                $$ = sReduce(NULL, NULL); 
         }
         ;
if_exp: '(' IF test_exp then_exp else_exp ')' {
            ASTIf *if_s = (ASTIf *)malloc(sizeof(ASTIf));
            if_s->type = stack_ASTtype.top();
            if_s->lhs = $3;
            if_s->mhs = $4;
            if_s->rhs = $5;
            $$ = (ASTNode *)if_s;
            stack_ASTtype.pop();
        }
        ;
test_exp: exp
        ;
then_exp: exp
        ;
else_exp: exp
        ;
%%

int main() {
    yyparse();
    idMap = new Map();
    preTraverse(root, idMap);
    return(0);
}
char * findName(int enumber){
    switch(enumber){
        case 18:
            return((char *)"boolean");
        case 19: 
            return((char *)"number");
        case 20:
            return((char *)"ID");
        default:
            break;
    }
    return((char*)"");
}
void yyerror(const char *msg) {
    if(stack_ASTtype.top() == 1 || stack_ASTtype.top() == 2 || stack_ASTtype.top() == 3
    || stack_ASTtype.top() == 4 || stack_ASTtype.top() == 5 ){
        printf("Need 2 arguments, but got %lu.\n",stack_Operant.size());
        exit(0);
    }
    fprintf(stderr, "%s\n", msg);

    exit(0);
}
ASTVal* funMap(ASTNode *fun_exp, ASTNode *par_node) {
    std::vector<std::string> ids;
    std::vector<ASTNode *> params;
    ASTNode *fun_body = fun_exp->rhs;
    ASTNode *id_node = fun_exp->lhs;
    Map* localMap = new Map();
    if (par_node == NULL) {
        return preTraverse(fun_body, localMap);
    }
    if (par_node->type == AST_NULL && id_node->type == AST_NULL) {
        return preTraverse(fun_body, localMap);
    }
    while (par_node->type != AST_NULL) {
        ASTNode *n = (ASTNode *)preTraverse(par_node->lhs, idMap);
        params.push_back(n);
        par_node = par_node->rhs;
    }
    while (id_node->type != AST_NULL) {
        ASTId *id = (ASTId *)id_node->lhs;
        std::string str(id->id);
        ids.push_back(str);
        id_node = id_node->rhs;
    }
    
    if (params.size() == ids.size()) {
        for(int i=0; i<params.size(); i++){
            (*localMap)[ids.at(i)] = params.at(i);
        }
    } else {
        printf("wrong number of paramters\n");
        exit(0);
    }
    // fun_body
    return preTraverse(fun_body, localMap);
}
ASTNode *searchMap(ASTNode *node, Map *map) {
    ASTId *id = (ASTId *)node;
    std::string strid(id->id);
    iter = map->find(strid);
    if(iter != map->end()){
      return(iter->second);
    }else{
      printf("variable  %s not defined yet\n", id->id);
      exit(0);
    }
}
void constructMap(ASTNode *node) {
    ASTId * id = (ASTId * )node->lhs;
    std::string str(id->id);
    iter = idMap->find(str);
    if (iter != idMap->end()) {
        printf("Redefined variable: %s\n", id->id);
        exit(0);
    } else {
        (*idMap)[str] = node->rhs;
    }
}

ASTNode* sReduce(ASTNode *exp_1, ASTNode *exp_2) {
    ASTNode *reduce = (ASTNode *)malloc(sizeof(ASTNode));
    reduce->type = stack_ASTtype.top();
    reduce->lhs = exp_1;
    reduce->rhs = exp_2;
    stack_ASTtype.pop();
   
    return reduce;
}

ASTNode* cReduce(ASTNode *exp_1, ASTNode *exp_2, ASTNode *exp_3) {
    ASTNode *reduce = (ASTNode *)malloc(sizeof(ASTNode));
    reduce->type = stack_ASTtype.top();
    reduce->lhs = exp_1;
    ASTNode *rhs = (ASTNode *)malloc(sizeof(ASTNode));
    rhs->type = stack_ASTtype.top();
    rhs->lhs = exp_2;
    rhs->rhs = exp_3;
    reduce->rhs = rhs;
    stack_ASTtype.pop();
    
    
    return reduce;
}

int calOper(ASTNode *node, Map *map) {
    int val;
    ASTNum *num = (ASTNum *)node;
    switch(node->type) {
        case AST_PLUS:
            val = calOper(node->lhs, map) + calOper(node->rhs, map);
            if (node->rhs->type == AST_NULL) val--;
            break;
        case AST_MINUS:
            val = calOper(node->lhs, map) - calOper(node->rhs, map);
            break;
        case AST_MUL:
            val = calOper(node->lhs, map) * calOper(node->rhs, map);
            break;
        case AST_DIV:
            val = calOper(node->lhs, map) / calOper(node->rhs, map);
            break;
        case AST_MOD:
            val = calOper(node->lhs, map) % calOper(node->rhs, map);
            break;
        case AST_NUM:
            val = num->num;
            break;
        case AST_GREATER:
            if (calOper(node->lhs, map) > calOper(node->rhs, map)){
                val = 1;
            }else val = 0;
            break;
        case AST_SMALLER:
            if (calOper(node->lhs, map) < calOper(node->rhs, map)){ 
                val = 1;
            }else val = 0;
            break;
        case AST_NULL:
            val = 1;
            break;
        case AST_ID:
            val = preTraverse(searchMap(node, map), map)->num;
            break;
        default:
            printf("unexpected type: %d\n", node->type);
            exit(0);
            break;
    }
    return val;
}


bool logOper(ASTNode *node, Map *map) {
    bool b;
    ASTBool * b_s = (ASTBool * )node;
    switch(node->type) {
        case AST_AND:
            b = logOper(node->lhs, map) && logOper(node->rhs, map);
            break;
        case AST_OR:
            if (node->rhs->type == AST_NULL) {
                b = logOper(node->lhs, map);
            } else {
                b = logOper(node->lhs, map) || logOper(node->rhs, map);
            }
            break;
        case AST_NOT:   
            b = !logOper(node->lhs, map);
            break;
        case AST_GREATER:
        case AST_SMALLER:
            if (calOper(node, map) == 1) b = true;
            else b = false;
            break;
        case AST_EQUAL:
            b = ASTEqual(node, map);
            break;
        case AST_BOOL:            
            b = b_s->boolean;
            break;
        case AST_ID:
            b = preTraverse(searchMap(node, map), map)->boolean;
            break;
        case AST_NULL:
            b = true;
            break;
        default:
            printf("unexpected type: %d\n", node->type);
            puts("syntax error");
            exit(0);
            break;
    }
    return b;
}
bool ASTEqual(ASTNode *node, Map *map) {
    if (node->rhs->type != AST_NULL) {
        if (calOper(node->lhs, map) == calOper(node->rhs->lhs, map)) 
            return ASTEqual(node->rhs, map);
        else 
            return false;
    } else {
        return true;
    }
}

ASTNode * ifCond(ASTNode * node, Map *map) {
    ASTIf * if_s = (ASTIf * )node;
    if (logOper(if_s->lhs, map))
        return if_s->mhs; 
    else 
        return if_s->rhs;
}

ASTVal* preTraverse(ASTNode *node, Map* map) {
    ASTVal *v = (ASTVal *)malloc(sizeof(ASTVal));
    switch(node->type) {
        case AST_ROOT:
            preTraverse(node->lhs, map);
            preTraverse(node->rhs, map);
            break;
        case AST_PLUS:
        case AST_MINUS:
        case AST_MUL:
        case AST_DIV:
        case AST_MOD:
        case AST_NUM:
            v->type = AST_NUM;
            v->num = calOper(node, map);
            break;
        case AST_AND:
        case AST_OR:
        case AST_NOT:        
        case AST_GREATER:
        case AST_SMALLER:
        case AST_EQUAL:
        case AST_BOOL:
            v->type = AST_BOOL;
            v->boolean = logOper(node, map);
            break;
        case AST_ID:
            /* add find id */
            v = preTraverse(searchMap(node, map), map);
            break;
        case AST_PNUM:
            v = preTraverse(node->lhs, map);
            printf("%d\n", v->num);
            break;
        case AST_PBOOL:
            v = preTraverse(node->lhs, map);
            printf(v->boolean ? "#t\n" : "#f\n");
            break;
        case AST_IF:
            v = preTraverse(ifCond(node, map), map);
            break;
        case AST_DEF:
            constructMap(node);
            break;
        case AST_FUN_NAME:
            v = funMap(searchMap(node->lhs, map), node->rhs);
            break;
        case AST_FUN_CALL:
            v = funMap(node->lhs, node->rhs);
            break;
        case AST_FUN_EXP:
            v = funMap(node, NULL);
            break;
        case AST_NULL:
            /* do nothing */
            break;
        default:
            printf("unexpected type%d\n", node->type);
            puts("syntax error");
            exit(0);
            break;
    }
    return v;
}

