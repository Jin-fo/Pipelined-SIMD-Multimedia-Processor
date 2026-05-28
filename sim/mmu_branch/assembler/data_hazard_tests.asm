////////////////////////////////////////////////////////////
// HAZARD TEST CASES FOR FORWARDING AND WRITE-BACK
////////////////////////////////////////////////////////////

// Test 0: Forwarding of LDI
LDI r1, 1, 0x7FFF
LDI r1, 3, 0x7FFF
// expected r1 value : 00000000000000007FFF00007FFF0000

LDI r2, 0, 0x7001
LDI r2, 1, 0xF002
LDI r2, 2, 0x7003
LDI r2, 3, 0x7004
LDI r2, 4, 0x0005
LDI r2, 5, 0x0006
LDI r2, 6, 0x0007
LDI r2, 7, 0x0008
// expected r2 value : 000800070006000570047003F0027001

LDI r3, 0, 0x7008
LDI r3, 1, 0xF007
LDI r3, 2, 0x7006
LDI r3, 3, 0x7005
LDI r3, 4, 0x0004
LDI r3, 5, 0x0003
LDI r3, 6, 0x0002
LDI r3, 7, 0x0001
// expected r3 value : 000100020003000470057006F0077008

// Test 1: Forwarding of R4-type
SIMAL r3, r2, r1, r3
// expected r3 value : 0000000E000000147FFFFFFF7FFFFFFF

// Test 2: Forwarding of R3-type
OR r2, r0, r3
// expected r3 value : 000800070006000570047003F0027001

SFWU r2, r3, r4
// expected r4 value : 00000000000000000000000000000000
