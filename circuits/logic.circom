pragma circom 2.0.4;

include "../node_modules/circomlib/circuits/gates.circom";
include "../node_modules/circomlib/circuits/bitify.circom";


template Decode(en,mn){
    signal input f;
    signal output s;
    signal output e[en];
    signal output m[mn+1];
    signal output exponent;
    signal output mantissa;

    component fb = Num2Bits(en+mn+1);
    component exponentC = Bits2Num(en);
    component mantissaC = Bits2Num(mn);

    fb.in <== f;
    
    var i;
    for(i=0; i<mn; i++){
        m[i] <== fb.out[i];
        mantissaC.in[i] <== fb.out[i];
    }
    mantissa <== mantissaC.out;

    for(i=0; i<en; i++){
        e[i] <== fb.out[mn+i];
        exponentC.in[i] <== fb.out[mn+i];
    }
    exponent <== exponentC.out;

    s <== fb.out[mn+en];
}


template MultiOR(n){
    signal input in[n];
    signal output out;
    component and;
    and = MultiAND(n);
    var i;
    for(i=0; i<n; i++){
        0 === (1 - in[i]) * in[i]; // Make sure that in[i] is 0 or 1
        and.in[i] <== 1 - in[i];   // Negate in[i]
    }

    out <== 1-and.out;
}

// Priority Encoder
// It is a well known circuit in Digital design, it returns the index of the first (most significant) high
// bit in bits array
// EX... 0b00110110 --> 5
// EX... 0b01000001 --> 6 and so on...
template pe(n){
    signal input integer;
    signal output o;

    component intin = Num2Bits(n);
    component intout= Bits2Num(n);

    intin.in <== integer;
    var i;
    var j;
    var counter=0;
    component ands[n+1];
    var holder;
    

    for(j=n-1; j>=0; j--){ // 31 >> 0
        ands[j] = MultiAND(n-j);
        // ands[j].in[0] <== intin.out[n-j-1];
        ands[j].in[0] <== intin.out[j];

        for(i=n-1; i>j; i--){ // 31 >> j+1
            ands[j].in[1+n-i-1] <== 1 - intin.out[i]; // Invert input, because I need the not of bits here
        }

        intout.in[j] <== ands[j].out;
    }

    // ands[n] = MultiAND(n);
    // for(j=0; j<n; j++){
    //     ands[n].in[j] <== intin.out
    // }

    // holder <== intout.out;
    var exp = intout.out;
    if(exp == 1){
        holder = 0;
    }
    if(exp == 2){
        holder = 1;
    }
    if(exp == 4){
        holder = 2;
    }
    if(exp == 8){
        holder = 3;
    }
    if(exp == 16){
        holder = 4;
    }
    if(exp == 32){
        holder = 5;
    }
    if(exp == 64){
        holder = 6;
    }
    if(exp == 128){
        holder = 7;
    }
    if(exp == 256){
        holder = 8;
    }
    if(exp == 512){
        holder = 9;
    }
    if(exp == 1024){
        holder = 10;
    }
    if(exp == 2048){
        holder = 11;
    }
    if(exp == 4096){
        holder = 12;
    }
    if(exp == 8192){
        holder = 13;
    }
    if(exp == 16384){
        holder = 14;
    }
    if(exp == 32768){
        holder = 15;
    }
    if(exp == 65536){
        holder = 16;
    }
    if(exp == 131072){
        holder = 17;
    }
    if(exp == 262144){
        holder = 18;
    }
    if(exp == 524288){
        holder = 19;
    }
    if(exp == 1048576){
        holder = 20;
    }
    if(exp == 2097152){
        holder = 21;
    }
    if(exp == 4194304){
        holder = 22;
    }
    if(exp == 8388608){
        holder = 23;
    }
    if(exp == 16777216){
        holder = 24;
    }
    if(exp == 33554432){
        holder = 25;
    }
    if(exp == 67108864){
        holder = 26;
    }
    if(exp == 134217728){
        holder = 27;
    }
    if(exp == 268435456){
        holder = 28;
    }
    if(exp == 536870912){
        holder = 29;
    }
    if(exp == 1073741824){
        holder = 30;
    }
    if(exp == 2147483648){
        holder = 31;
    }

    o <-- holder;
    
    
}