#ifndef AST_H
#define AST_H

enum ASTType {
    AST_ROOT, AST_PLUS, AST_MINUS, AST_MUL, AST_DIV,
    AST_MOD, AST_AND, AST_OR, AST_NOT, AST_GREATER, 
    AST_SMALLER, AST_EQUAL, AST_FUN_EXP, AST_FUN_CALL, AST_DEF,
    AST_IF, AST_PNUM, AST_PBOOL, AST_BOOL, AST_NUM,
    AST_ID, AST_FUN_NAME, AST_NULL
};

typedef struct AST_Node {
    enum ASTType type;
    struct AST_Node *lhs, *rhs;
}ASTNode;

typedef struct ASTIf {
    enum ASTType type;
    ASTNode *lhs, *mhs, *rhs;
}ASTIF;

typedef struct ASTVal {
    enum ASTType type;
    int num;
    bool boolean;
    char *id;
}ASTVal;

//terminal
typedef struct ASTNum {
    enum ASTType type;
    int num;
}ASTNum;

typedef struct ASTBool {
    enum ASTType type;
    bool boolean;
}ASTBool;

typedef struct ASTId {
    enum ASTType type;
    char *id;
}ASTId;


#endif