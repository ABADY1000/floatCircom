# This is prototype for the algorithm, it is made in python before working on circom

import struct
import numpy as np

def f2bytes(f):
    b = bytearray(struct.pack("f", f))
    return sum([int(x)*2**(i*8) for i,x in enumerate(b)])

# print(hex(f2bytes(0)))

def getExponent(b):
    return b>>23 & 0xff

def getMantissa(b):
    return (b & 0x7fffff)

def getFullMantissa(b):
    return getMantissa(b) + (1<<23)#1<<24

def getSign(b):
    return b>>31 & 0x01

def pe(f):
    return np.ceil(np.log2(f+1))

# print(getExponent(a))
# print(getMantissa(a))
# print(getSign(a))

def fadd(a: float, b: float):
    ab = f2bytes(a)
    bb = f2bytes(b)

    a_s = getSign(ab)
    bs  = getSign(bb)

    ae = getExponent(ab)
    be = getExponent(bb)

    am = getFullMantissa(ab)
    bm = getFullMantissa(bb)
    
    is_althb = ae < be

    smalle, greate = (ae,be) if is_althb else (be,ae)
    diff = greate - smalle

    mam = am >> diff if is_althb else am
    mbm = bm if is_althb else bm >> diff

    is_malthb = mam < mbm
    same_sign = a_s == bs
    s = a_s if same_sign else bs if is_malthb else a_s


    # print("{:>60}".format(bin(am)))
    # print("{:>60}".format(bin(mam)))
    # print("{:>60}".format(bin(bm)))
    # print("{:>60}".format(bin(mbm)))
    m = (mam + mbm) if same_sign else mbm-mam if is_malthb else mam-mbm

    print(f"mam:{hex(mam)}")
    print(f"mbm:{hex(mbm)}")

    # print(f'{hex(mam):>10}')
    # print(f'{hex(mbm):>10}')
    # print(f'{hex(m):>10}')
    if not same_sign:
        d = 24-int(pe(m))
        print(d)
        m = m<<(d)
        n = (m&0x7fffff) + ((greate-d)<<23)
        
    elif m&0x1000000 > 0:
        n = ((m>>1)&0x7fffff) + (greate+1 << 23)
    else: 
        n = (m&0x7fffff) + (greate << 23)

    n = n + (s<<31)
    return n


    print(diff)

r = fadd(-55.66, 45.36)
rr = struct.unpack('f', bytearray([r&0xff, (r&0xff00)>>8, (r&0xff0000)>>16, (r&0xff000000)>>24]))
print(f'{hex(r)}')
print("R = {}".format(rr[0]))


