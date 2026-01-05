local bit =  require("bit")
print(bit.band( 239, 0x01) == 0 and "11" or "22")