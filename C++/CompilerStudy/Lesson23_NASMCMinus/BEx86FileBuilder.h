
#ifndef BE_x86_FILE_BUILDER_H
#define BE_x86_FILE_BUILDER_H

class BESymbolTable;
class BEConstantPool;
class BEx86FunctionBuilder;

class BEx86FileBuilder {
public:
    BEx86FileBuilder();
    ~BEx86FileBuilder();

    BEx86FunctionBuilder* createFunctionBuilder(const string &name);
    BEx86FunctionBuilder* getFunctionBuilder(const string &name);

    BEConstantPool* getConstantPool() { return m_constantPool; }
    BESymbolTable* getGlobalSymbolTable() { return m_globalSymbolTable; }

private:
    BEx86FileBuilder(const BEx86FileBuilder& );
    BEx86FileBuilder& operator = (const BEx86FileBuilder& );

private:
    BEConstantPool *m_constantPool;
    BESymbolTable *m_globalSymbolTable;
    map<string, BEx86FunctionBuilder*> m_funcBuilders;
};

#endif
