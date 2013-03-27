
#ifndef LUA_VALUE_H
#define LUA_VALUE_H

typedef double NumberType;

enum LuaValueType {
    LVT_Nil,
    LVT_Boolean,
    LVT_Number,
    LVT_String,
    LVT_Table,
    LVT_Function,
};

class LuaTable;
struct IFunction;

class LuaValue
{
public:
    explicit LuaValue(NumberType n): m_type(LVT_Number){ m_data.n = n; }
    explicit LuaValue(const string& str);
    explicit LuaValue(IFunction *func);
    explicit LuaValue(LuaTable *table);

    LuaValue(): m_type(LVT_Nil) {m_data.n = 0;}
    LuaValue(const LuaValue& o);
    LuaValue(LuaValue&& o);
    LuaValue& operator = (const LuaValue& o);
    LuaValue& operator = (LuaValue&& o);
    ~LuaValue();

    bool isTypeOf(LuaValueType t) const { return m_type == t; }
    bool getBoolean() const { ASSERT(isTypeOf(LVT_Boolean)); return m_data.b;}
    NumberType getNumber() const { ASSERT(isTypeOf(LVT_Number)); return m_data.n; }
    const char *getString() const { ASSERT(isTypeOf(LVT_String)); return m_data.str;}
    LuaTable* getLuaTable() { ASSERT(isTypeOf(LVT_Table)); return m_data.table;}
    IFunction* getFunction() { ASSERT(isTypeOf(LVT_Function)); return m_data.func;}

    bool operator == (const LuaValue& o) const;
    bool operator != (const LuaValue& o) const { return !(*this == o);}
    bool operator < (const LuaValue& o) const;
    bool operator <= (const LuaValue& o) const { return *this == o || *this < o;}
    bool operator > (const LuaValue& o) const { return !(*this <= o);}
    bool operator >= (const LuaValue& o) const { return !(*this < o);}

    LuaValue& operator += (const LuaValue& o);
    LuaValue& operator -= (const LuaValue& o);
    LuaValue& operator *= (const LuaValue& o);
    LuaValue& operator /= (const LuaValue& o);
    LuaValue& operator %= (const LuaValue& o);

    LuaValue power(const LuaValue& o) const;
    LuaValue concat(const LuaValue& o) const;

    int getSize() const;

    const LuaValue& get(const LuaValue& k);
    void set(const LuaValue& k, const LuaValue& v);

    int getHash() const;

    string toString() const;
public:
    static LuaValue NIL;
    static LuaValue TRUE;
    static LuaValue FALSE;

private:
    explicit LuaValue(bool b);

private:
    LuaValueType m_type;
    union {
        bool b;
        NumberType n;
        char *str;
        LuaTable *table;
        IFunction *func;
    } m_data;
};
inline LuaValue operator + (const LuaValue& a, const LuaValue &b) { return LuaValue(a) += b; }
inline LuaValue operator - (const LuaValue& a, const LuaValue &b) { return LuaValue(a) -= b; }
inline LuaValue operator * (const LuaValue& a, const LuaValue &b) { return LuaValue(a) *= b; }
inline LuaValue operator / (const LuaValue& a, const LuaValue &b) { return LuaValue(a) /= b; }
inline LuaValue operator % (const LuaValue& a, const LuaValue &b) { return LuaValue(a) %= b; }

namespace std {
    template<>
    struct hash<LuaValue> {
        int operator () (const LuaValue& v) const {
            return v.getHash();
        }
    };
}

#endif
