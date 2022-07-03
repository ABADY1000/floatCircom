pragma circom 2.0.4;

include "./logic.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "./fadd.circom";

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
    
    component Eless = LessThan(e);
    Eless.in[0] <== decode1.exponent;
    Eless.in[1] <== decode2.exponent;

    component Mless = LessThan(m);
    Mless.in[0] <== decode1.mantissa;
    Mless.in[1] <== decode2.mantissa;

    component mux1 = Mux1();
    mux1.c[0] <== Eless.out;
    mux1.c[1] <== Mless.out;
    mux1.s <== Eeq.out;
    r <== mux1.out;
}
component main = lessThenF(8,23);



// !(A < B+1)
template greaterThanF(e,m){
    signal input f1;
    signal input f2;
    signal output r;

    component add = fadd();
    signal float_one <== 0xf3800000;
    add.f1 <== float_one;
    add.f2 <== f2;

    component less = lessThanF(e,m);
    less.f1 <== f1;
    less.f2 <== add.fo;

    r <== 1-less.r;
}




