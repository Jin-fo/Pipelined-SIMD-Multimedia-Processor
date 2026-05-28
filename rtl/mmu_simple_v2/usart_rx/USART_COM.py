import serial
import time

# Change this to your COM port (check Device Manager)
PORT = "COM4"
BAUD = 115200

# Open serial connection
ser = serial.Serial(PORT, BAUD, timeout=1)

time.sleep(2)  # allow FPGA/FTDI to reset after connection

# ---- send a single byte ----

i = 255  # Initialize counter

while True:
    if i <= 255:  # Send bytes from 'A' to 'Z'
        byte_to_send = i  # ASCII 'A' to 'Z'
        ser.write(bytes([byte_to_send]))
        print(f"Sent: {hex(byte_to_send)}")
        i += 1
    else:
        i = 0  # Reset to 'A' after 'Z'
    time.sleep(1)  # wait before sending next byte