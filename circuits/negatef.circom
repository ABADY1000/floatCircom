pragma circom 2.0.4;

include "./logic.circom";
include "../node_modules/circomlib/circuits/gates.circom";

template negatef(en, mn){
    signal input f;
    signal output fo;

    component decode = Decode(en,mn);
    decode.f <== f;

    component encode = Encode(en,mn);
    for(var i=0; i<mn+1; i++){
        encode.m[i] <== decode.m[i];
    }
    for(var i=0; i<en; i++){
        encode.e[i] <== decode.e[i];
    }

    component xor = XOR();
    xor.a <== decode.s;
    xor.b <== 1;
    encode.s <== xor.out;

    fo <== encode.out;
}