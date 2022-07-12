pragma circom 2.0.4;

include "./logic.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/gates.circom";
include "./fadd.circom";
include "./fmultiply.circom";
include "./i2f.circom";
include "./negatef.circom";

// A < B
template lessThanF(e,m){
    signal input f1;
    signal input f2;
    signal output r;

    component decode1 = Decode(e,m);
    decode1.f <== f1;

    component decode2 = Decode(e,m);
    decode2.f <== f2;

    component Eless = LessThan(e);
    Eless.in[0] <== decode1.exponent;
    Eless.in[1] <== decode2.exponent;

    component Eeq = IsEqual();
    Eeq.in[0] <== decode1.exponent;
    Eeq.in[1] <== decode2.exponent;

    // component Mless = LessThan(m);
    // Mless.in[0] <== decode1.mantissa;
    // Mless.in[1] <== decode2.mantissa;
    
    // component Eless = LessThan(e);
    // Eless.in[0] <== decode1.exponent;
    // Eless.in[1] <== decode2.exponent;

    component Mless = LessThan(m);
    Mless.in[0] <== decode1.mantissa;
    Mless.in[1] <== decode2.mantissa;

    component mux1 = Mux1();
    mux1.c[0] <== Eless.out;
    mux1.c[1] <== Mless.out;
    mux1.s <== Eeq.out;
    r <== mux1.out;
}

template greaterThanF(e,m){
    signal input f1;
    signal input f2;
    signal output r;

    component decode1 = Decode(e,m);
    decode1.f <== f1;

    component decode2 = Decode(e,m);
    decode2.f <== f2;

    component Eless = GreaterThan(e);
    Eless.in[0] <== decode1.exponent;
    Eless.in[1] <== decode2.exponent;

    component Eeq = IsEqual();
    Eeq.in[0] <== decode1.exponent;
    Eeq.in[1] <== decode2.exponent;

    component Mless = GreaterThan(m);
    Mless.in[0] <== decode1.mantissa;
    Mless.in[1] <== decode2.mantissa;

    component mux1 = Mux1();
    mux1.c[0] <== Eless.out;
    mux1.c[1] <== Mless.out;
    mux1.s <== Eeq.out;
    r <== mux1.out;
}

template inRange(e,m){
    signal input f;
    signal input ULimit;
    signal input LLimit;
    signal output r;

    component less = lessThanF(e,m);
    less.f1 <== f;
    less.f2 <== ULimit;

    component greater = greaterThanF(e,m);
    greater.f1 <== f;
    greater.f2 <== LLimit;

    component and = AND();
    and.a <== less.r;
    and.b <== greater.r;

    r <== and.out;
}

template isEqualExact(){
    signal input f1;
    signal input f2;
    signal output r;

    component eq = IsEqual();
    eq.in[0] <== f1;
    eq.in[1] <== f2;

    r <== eq.out;
}

// 0.001 >>> 1/1000
template isEqualError(p){ // accuracy rate, p is divided by 1000, 1 is 0.001 or 0.1%, 1000 is 1 or 100%
    signal input f1;
    signal input f2;
    signal output r;

    // 1000 >>> f1000
    component integer2float = i2f(32);
    integer2float.in <== p;
    
    // f1000 >>> f1, f0.001 is 0x3a83126f
    component mulp = fmultiply();
    mulp.f1 <== integer2float.out;
    mulp.f2 <== 0x3a83126f;
    signal percentage <== mulp.fo;
    

    component mule = fmultiply();
    mule.f1 <== percentage;
    mule.f2 <== f1;
    signal error <== mule.fo;

    component add1 = fadd();
    add1.f1 <== f1;
    add1.f2 <== error;
    signal upperLimit <== add1.fo;

    component neg = negatef(8,23);
    neg.f <== error;

    component add2 = fadd();
    add2.f1 <== f1;
    add2.f2 <== neg.fo;
    signal lowerLimit <== add2.fo;
    
    component range = inRange(8,23);
    range.f <== f2;
    range.ULimit <== upperLimit;
    range.LLimit <== lowerLimit;

    r <== range.r;
}

