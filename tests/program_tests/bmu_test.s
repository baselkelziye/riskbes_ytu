xor x5,x1,x1 
xor x6, x1,x1
xor x7,x1,x1
lui x5,0xdeadc #x5 = 0xdeadc000
xori x6, x0, 0xeef #x6 = 0x00000eef
add x7, x5,x6 #x7 = 0xdeadbeef
addi x0,x0,0
lui x1, 0x000AA #x1 = 0x000AA000
addi x2, x0,2 #x2 = 0x00000002
addi x3,x0, 0x64 #x3 = 0x00000064
addi x4,x0, 0x1F #x4 = 0x0000001F
lui x5, 0xFFFFF #x5 = 0xFFFFF000
addi x0,x0,0
addi x0,x0,0 # do differentiate the machine codes
clz x31, x1    # 60009f93  x31 = 0xc
ctz x30, x1    # 60109f13  x30 = 0xd
cpop x29, x1   # 60209e93  x29 = 0x4 
orc.b x28, x1  # 2870de13  
rev8 x27, x7   # 6983dd93  
zext.h x26, x7 # 0803cd33  
sext.h x25, x1 # 60509c93  
sext.b x24, x7 # 60439c13  
rol x23, x3, x2 # 60219bb3 
ror x22, x3, x2 # 6021db33 
rori x21, x3, 2 # 6021da93
bext x18, x5, x4 # 4842d933 
bexti x17, x5, 31 # 49f2d893 
bclr x20, x5, x4 # 48429a33
bclri x19, x5, 31 # 49f29993 
binv x16, x5, x4 # 68429833
binvi x15, x5, 31 # 69f29793
bset x14, x5, x4 # 28429733
bseti x13, x5, 31 # 29f29693 
