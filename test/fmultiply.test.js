
const wasm_tester = require("circom_tester").wasm;
const c_tester = require("circom_tester").c;
const assert = require("assert");

const {Float32Bytes2Number, Number2Float32Bytes} = require("../src/float-circom.js");
// const Number2Float32Bytes = require("../src/floatCircom.js");
// import {Number2Float32Bytes, Float32Bytes2Number} from "../src/float-circom.mjs";

async function tester(){

    describe("Apply some floating point arithmatic", async ()=>{
       
        it("Multiply", async ()=>{
            let p1 = 122.312;
            let p2 = 0.12;

            const a = (new DataView(new ArrayBuffer(4)));
            a.setFloat32(0, p1);

            const b = (new DataView(new ArrayBuffer(4)));
            b.setFloat32(0, p2);

            const circuit = await wasm_tester("./circuits/fmultiply.circom");
            // console.log(`0x${a.getUint32(0).toString(16)}`);
            // const w = await circuit.calculateWitness({f1: a.getUint32(0), f2: b.getUint32(0)});
            const w = await circuit.calculateWitness({f1: Number2Float32Bytes(p2), f2: Number2Float32Bytes(p1)});
            await circuit.checkConstraints(w);
            const result = w[0];
            const output = w[1];
            const in1 = w[2];
            const in2 = w[3];

            const c = (new DataView(new ArrayBuffer(8)));
            c.setBigInt64(0, output);
            // console.log("Circom");
            // console.log(`${a.getFloat32(0)}x${b.getFloat32(0)}=${c.getFloat32(4)}`);
            // console.log("JS");
            // console.log(`${p1}x${p2}=${p1*p2}`);
            // assert.ok(Math.abs(p1*p2-c.getFloat32(4)) < 0.01);
            assert.ok(Math.abs(p1*p2-Float32Bytes2Number(output)) < 0.01);

        })

        it("Add", async ()=>{
            let p1 = 0.3;
            let p2 = 0.12;

            const a = (new DataView(new ArrayBuffer(4)));
            a.setFloat32(0, p1);

            const b = (new DataView(new ArrayBuffer(4)));
            b.setFloat32(0, p2);

            const circuit = await wasm_tester("./circuits/fadd.circom");
            const w = await circuit.calculateWitness({f1: a.getUint32(0), f2: b.getUint32(0)});
            
            await circuit.checkConstraints(w);
            const result = w[0];
            const output = w[1];
            const in1 = w[2];
            const in2 = w[3];

            const c = (new DataView(new ArrayBuffer(8)));
            c.setBigInt64(0, output);
            // console.log("Circom");
            // console.log(`${a.getFloat32(0)}+${b.getFloat32(0)}=${c.getFloat32(4)}`);
            // console.log("JS");
            // console.log(`${p1}+${p2}=${p1+p2}`);
            assert.ok(Math.abs(p1+p2-c.getFloat32(4)) < 0.01);
        })
    })
    
    

    
}


tester().
then(()=>console.log("OK")).
catch(e=>console.log(e));

