pragma circom 2.0.4;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/gates.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
include "./logic.circom";

template fmultiply(){
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
    component xor = XOR();
    xor.a <== f1s;
    xor.b <== f2s;
    signal s <== xor.out;

    // Extract Exponent, calculate ANDs & ORs of each
    var i;
    component f1eAnd = MultiAND(8);
    component f1eOr  = MultiOR(8);
    component f1exp  = Bits2Num(8);
    for(i=0; i<8; i++){
        f1eAnd.in[i] <== f1b.out[23+i];
        f1eOr.in[i]  <== f1b.out[23+i];
        f1exp.in[i]  <== f1b.out[23+i];
    }

    component f2eAnd = MultiAND(8);
    component f2eOr  = MultiOR(8);
    component f2exp  = Bits2Num(8);
    for(i=0; i<8; i++){
        f2eAnd.in[i] <== f1b.out[23+i];
        f2eOr.in[i]  <== f1b.out[23+i];
        f2exp.in[i]  <== f2b.out[23+i];
    }

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

    // Multiply mantissas
    signal mant;
    mant <== f1mant.out * f2mant.out;

    component bits = Num2Bits(48);
    bits.in <== mant;

    // Multiply exponents part 
    // (if (&A)|(&B) then 0xff else if (|A)&(|B) then A+B-127 else 0)
    signal oexp;
    signal exp;
    
    // A+B-127
    exp <== f1exp.out + f2exp.out - 127 + bits.out[47];
    
    // (|A)&(|B)
    component and = AND();
    and.a <== f1eOr.out;
    and.b <== f2eOr.out;
    
    // if (|A)&(|B) then A+B-127 else 0
    component mux_zero_exp = Mux1();
    mux_zero_exp.c[0] <== exp;
    mux_zero_exp.c[1] <== 0x00;
    mux_zero_exp.s <== 1-and.out;
    log(mux_zero_exp.out);
    /*
    A B `A `B| `A&`B  1-(`A&`B)
    0 0  1  1|   1     0
    0 1  1  0|   0     1
    1 0  0  1|   0     1
    1 1  0  0|   0     1
    */

    // (&A)|(&B)
    component or = OR();
    or.a <== f1eAnd.out;
    or.b <== f2eAnd.out;

    // if (&A)|(&B) then 0xff else if (|A)&(|B) then A+B-127 else 0
    component mux_inf_exp = Mux1();
    mux_inf_exp.c[0] <== mux_zero_exp.out;
    mux_inf_exp.c[1] <== 0xff;
    mux_inf_exp.s <== or.out;
    oexp <== mux_inf_exp.out;

    component of = Bits2Num(32);
    signal b[23];
    for(i=0;i<23;i++){
        b[i] <== bits.out[23+i];
    }

    signal c[23];
    for(i=0;i<23;i++){
        c[i] <== bits.out[24+i];
    }

    component B = Bits2Num(23);
    for(i=0;i<23;i++){
        B.in[i] <== b[i];
    }

    component C = Bits2Num(23);
    for(i=0;i<23;i++){
        C.in[i] <== c[i];
    }

    component mux = Mux1();
    mux.c[0] <== B.out;
    mux.c[1] <== C.out;
    mux.s <== bits.out[47];
    
    //

    // component isZeroExp = IsZero | and.out
    component zero_mul = Mux1();
    zero_mul.c[0] <== mux.out;
    zero_mul.c[1] <== 0x00;
    zero_mul.s <== 1-and.out;
    log(zero_mul.out);
    
    //

    // Combine both parts
    component foe = Num2Bits(8);
    component fom = Num2Bits(23);
    component f   = Bits2Num(32);

    // fom.in <== mux.out;
    fom.in <== zero_mul.out;
    foe.in <== oexp;
    f.in[31] <== s;
    for(i=0; i<8; i++){
        f.in[23+i] <== foe.out[i];
    }  
    for(i=0; i<23; i++){
        f.in[i] <== fom.out[i];
    }  
    
    fo <== f.out;
}

// component main = fmultiply();