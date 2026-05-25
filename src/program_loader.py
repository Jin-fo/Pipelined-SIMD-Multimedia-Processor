import serial
import time

# Change this to your COM port (check Device Manager)
PORT = "COM4"
BAUD = 921600

# Open serial connection
ser = serial.Serial(PORT, BAUD, timeout=1)

time.sleep(2)  # allow FPGA/FTDI to reset after connection

# Read instructions from file
with open('instruction_file.txt', 'r') as f:
    instructions = f.readlines()

# Send each instruction byte by byte
for line in instructions:
    line = line.strip()
    if line:
        # Convert 25-bit binary string to integer
        instr_int = int(line, 2)
        # Convert to 4 bytes (big-endian, MSB first)
        bytes_to_send = instr_int.to_bytes(4, byteorder='big')
        # Send each byte
        for b in bytes_to_send:
            ser.write(bytes([b]))
            print(f"Sent: {hex(b)}")
            time.sleep(0.05)  # small delay between bytes

print("All instructions sent.")

# Close serial connection
ser.close()