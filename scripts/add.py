import struct

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


# print(getExponent(a))
# print(getMantissa(a))
# print(getSign(a))

def fadd(a: float, b: float):
    ab = f2bytes(a)
    bb = f2bytes(b)

    a_s = getSign(ab)
    bs = getSign(bb)

    ae = getExponent(ab)
    be = getExponent(bb)

    am = getFullMantissa(ab)
    bm = getFullMantissa(bb)
    
    is_althb = ae < be

    smalle, greate = (ae,be) if is_althb else (be,ae)
    diff = greate - smalle

    mam = am >> diff if is_althb else am
    mbm = bm if is_althb else bm >> diff

    # print("{:>60}".format(bin(am)))
    # print("{:>60}".format(bin(mam)))
    # print("{:>60}".format(bin(bm)))
    # print("{:>60}".format(bin(mbm)))
    m = mam + mbm

    print(f'{hex(mam):>10}')
    print(f'{hex(mbm):>10}')
    print(f'{hex(m):>10}')

    n = (m&0x7fffff) + (greate << 23)

    return n


    print(diff)

r = fadd(19.25, 1423555.78)
rr = struct.unpack('f', bytearray([r&0xff, r&0xff00>>8, r&0xff0000>>16, r&0xff000000>>24]))
print(f'{hex(r)}')
print(rr)

