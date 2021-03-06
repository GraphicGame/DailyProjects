#ifndef STYPES_H
#define STYPES_H

#include "SObject.h"
#include "SValue.h"

struct SFuncProto;
struct SClassProto;

inline void writeBarrier(SObject *obj, SValue v) {
    if (v.isObject()) {
        auto p = v.getObject();
        if (obj->getAge() > p->getAge()) {
            SObject::sYoungContainer.push_back(obj);
        }
    }
}

struct SPair: public SObject {
    static const int TYPE = SVT_Pair;

    static int estimateSize(SValue car, SValue cdr) {
        return sizeof(SPair);
    }

    int estimateSize() const {
        return sizeof(SPair);
    }

    bool _equal(const SPair *o) const {
        return mCar.equal(o->mCar) && mCdr.equal(o->mCdr);
    }

    SValue getCar() {
        return mCar;
    }

    SValue getCdr() {
        return mCdr;
    }

    void setCar(SValue v) {
        writeBarrier(this, v);
        mCar = v;
    }

    void setCdr(SValue v) {
        writeBarrier(this, v);
        mCdr = v;
    }

    void _writeToStream(ostream &so) const;

private:
    SPair(SValue _car, SValue _cdr): SObject(TYPE), mCar(_car), mCdr(_cdr) {
    }

    SValue mCar;
    SValue mCdr;

    friend class SObjectManager;
};

struct SEnv: public SObject {
    static const int TYPE = SVT_Env;

    static int estimateSize(SEnv *prevEnv, int vCount) {
        return sizeof(SEnv) + (vCount - 1) * sizeof(SValue);
    }

    int estimateSize() const {
        return sizeof(SEnv) + (vCount - 1) * sizeof(SValue);
    }

    SEnv *prevEnv;
    int vCount;
    SValue values[1];

    SValue getValue(int i) {
        ASSERT(i >= 0 && i < vCount);
        return values[i];
    }

    void setValue(int i, SValue v) {
        ASSERT(i >= 0 && i < vCount);
        writeBarrier(this, v);
        values[i] = v;
    }

    SEnv* getUpEnv(int i) {
        ASSERT(i > 0);

        SEnv *e = prevEnv;
        while (i-- > 1) e = e->prevEnv;
        return e;
    }

    bool _equal(const SEnv *o) const {
        return this == o;
    }

    void _writeToStream(ostream &so) const {
        so << format("{env:%p}", this);
    }

private:
    SEnv(SEnv *_prevEnv, int _vCount): SObject(TYPE), prevEnv(_prevEnv), vCount(_vCount) {
    }

    friend class SObjectManager;
};

struct SFunc: public SObject {
    static const int TYPE = SVT_Func;

    static int estimateSize(SEnv *_env, SFuncProto *_proto) {
        return sizeof(SFunc);
    }

    int estimateSize() const {
        return sizeof(SFunc);
    }

    SEnv *env;
    SFuncProto *proto;

    bool _equal(const SFunc *o) const {
        return this == o;
    }

    void _writeToStream(ostream &so) const {
        so << format("{func:%p}", this);
    }

private:
    SFunc(SEnv *_env, SFuncProto *_proto): SObject(TYPE), env(_env), proto(_proto) {
    }

    friend class SObjectManager;
};

struct SNativeFunc: public SObject {
    static const int TYPE = SVT_NativeFunc;

    static int estimateSize(NativeFuncT f) {
        return sizeof(SNativeFunc);
    }

    int estimateSize() const {
        return sizeof(SNativeFunc);
    }

    NativeFuncT func;

    bool _equal(const SNativeFunc *o) const {
        return this == o;
    }

    void _writeToStream(ostream &so) const {
        so << format("{nativefunc:%p}", this);
    }

private:
    SNativeFunc(NativeFuncT f): SObject(TYPE), func(f) {
    }

    friend class SObjectManager;
};

struct SClass: public SObject {
    static const int TYPE = SVT_Class;

    static int estimateSize(SEnv *_env, SClassProto *_proto) {
        return sizeof(SClass);
    }

    int estimateSize() const {
        return sizeof(SClass);
    }

    SEnv *env;
    SClassProto *proto;

    SEnv* asEnv() {
        return reinterpret_cast<SEnv*>(this);
    }

    bool _equal(const SClass *o) const {
        return this == o;
    }

    void _writeToStream(ostream &so) const {
        so << format("{class:%p}", this);
    }

private:
    SClass(SEnv *_env, SClassProto *_proto): SObject(TYPE), env(_env), proto(_proto) {
    }

    friend class SObjectManager;
};

#endif
