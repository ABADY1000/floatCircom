pragma circom 2.0.4;

include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "./logic.circom";

template fadd(){
    signal input f1;
    signal input f2;
    signal output fo;


    // Decode numbers
    component f1b = Num2Bits(32);
    f1b.in <== f1;

    component f2b = Num2Bits(32);
    f2b.in <== f2;

    // Extract Sign
    signal f1s <== f1b.out[31];
    signal f2s <== f2b.out[31];
    // log(f1s);
    // log(f2s);
    // Extract Exponent, calculate ANDs & ORs of each
    var i;
    component f1exp  = Bits2Num(8);
    for(i=0; i<8; i++){
        f1exp.in[i]  <== f1b.out[23+i];
    }

    component f2exp  = Bits2Num(8);
    for(i=0; i<8; i++){
        f2exp.in[i]  <== f2b.out[23+i];
    }

    // log(f1exp.out);
    // log(f2exp.out);

    // Extract Mantissa
    component f1mant = Bits2Num(24);
    f1mant.in[23] <== 1;
    for(i=0; i<23; i++){
        f1mant.in[i] <== f1b.out[i];
    }
    
    component f2mant = Bits2Num(24);
    f2mant.in[23] <== 1;
    for(i=0; i<23; i++){
        f2mant.in[i] <== f2b.out[i];
    }
    // log(f1mant.out);
    // log(f2mant.out);

    // Determine smaller and larger numbers
    component less = LessThan(8);
    less.in[0] <== f1exp.out;
    less.in[1] <== f2exp.out;

    component eq   = IsEqual();
    eq.in[0] <== f1exp.out;
    eq.in[1] <== f2exp.out;

    component mmux = MultiMux1(2);
    mmux.c[0][0] <== f1exp.out;
    mmux.c[0][1] <== f2exp.out;
    mmux.c[1][0] <== f2exp.out;
    mmux.c[1][1] <== f1exp.out;
    mmux.s <== less.out;
    signal greate <== mmux.out[0];
    signal smalle <== mmux.out[1];

    signal diff <== greate - smalle;

    // Determine which mantissa to be used
    component mantissaSelector1 = Mux1();
    mantissaSelector1.c[0] <== f1mant.out;
    mantissaSelector1.c[1] <-- f1mant.out>>diff;
    mantissaSelector1.s <== less.out;
    signal m1 <== mantissaSelector1.out;

    component mantissaSelector2 = Mux1();
    mantissaSelector2.c[0] <== f2mant.out;
    mantissaSelector2.c[1] <-- f2mant.out>>diff;
    mantissaSelector2.s <== 1-less.out;
    signal m2 <== mantissaSelector2.out;
    // log(m1);
    // log(m2);

    // Same sign logic
    component sameSign = IsEqual();
    sameSign.in[0] <== f1s;
    sameSign.in[1] <== f2s;

    component singSelector = Mux1();
    singSelector.c[1] <== m1+m2;

    component lessM = LessThan(24);
    lessM.in[0] <== m1;
    lessM.in[1] <== m2;

    component greaterMantissaSelector = Mux1();
    greaterMantissaSelector.c[0] <== m1-m2;
    greaterMantissaSelector.c[1] <== m2-m1;

    greaterMantissaSelector.s <== lessM.out;
    // log(lessM.out);
    // singSelector.c[0] <== m1-m2;
    singSelector.c[0] <== greaterMantissaSelector.out;
    singSelector.s <== sameSign.out;
    signal fm <== singSelector.out;
    // log(fm);

    // Preperation
    component Pe = pe(32);
    Pe.integer <== fm;
    signal d <== 24-Pe.o-1;
    // log(d);


    component fm2bits = Num2Bits(25);
    fm2bits.in <== fm;

    signal m;
    component mant_mux = Mux1();
    mant_mux.c[0] <== fm;
    mant_mux.c[1] <-- fm>>1;
    mant_mux.s <== fm2bits.out[24];
    
    component step2_mant_mux = Mux1();
    step2_mant_mux.c[0] <-- fm<<(d);
    step2_mant_mux.c[1] <== mant_mux.out;
    step2_mant_mux.s <== sameSign.out;
    m <== step2_mant_mux.out;

    signal e;
    component exp_mux = Mux1();
    exp_mux.c[0] <== greate;
    exp_mux.c[1] <== greate+1;
    exp_mux.s <== fm2bits.out[24];

    component step2_exp_mux = Mux1();
    // log(greate);
    step2_exp_mux.c[0] <-- greate-d;
    step2_exp_mux.c[1] <== exp_mux.out;
    step2_exp_mux.s <== sameSign.out;
    e <== step2_exp_mux.out;

    component mbits = Num2Bits(24);
    mbits.in <== m;

    component ebits = Num2Bits(8);
    ebits.in <== e;

    component full = Bits2Num(32);
    // var i;
    for(i=0;i<23;i++){
        full.in[i] <== mbits.out[i];
    }
    for(i=0; i<8; i++){
        full.in[i+23] <== ebits.out[i];
    }

    // component gt = greaterThanF(8,23);
    // gt.f1 <== f1;
    // gt.f2 <== f2;
    component Eeq = IsEqual();
    Eeq.in[0] <== f1exp.out;
    Eeq.in[1] <== f2exp.out;

    component Eless = LessThan(8);
    Eless.in[0] <== f1exp.out;
    Eless.in[1] <== f2exp.out;

    component Mless = LessThan(24);
    Mless.in[0] <== m1;
    Mless.in[1] <== m2;

    component mux1 = Mux1();
    mux1.c[0] <== Eless.out;
    mux1.c[1] <== Mless.out;
    mux1.s <== Eeq.out;

    component signMux = Mux1();
    signMux.c[0] <== f1s;
    signMux.c[1] <== f2s;
    signMux.s <== mux1.out;
    full.in[31] <== signMux.out;

    // log(full.out);
    fo <== full.out;
}

// component main = fadd();

/*
     5 +  2 =  7
    -5 + -2 = -7
    -5 +  2 = -3
     5 + -2 =  3

*/