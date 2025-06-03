The NES controller uses a simple serial protocol to communicate with the console. Here's how it works:
### Hardware Overview
- The NES controller has 8 buttons: A, B, Select, Start, Up, Down, Left, Right
- It uses a shift register to send button states to the console
- There are 5 important wires:
    - Power (5V)
    - Ground
    - Clock (outputs data on pulses)
    - Latch (tells controller to load current button states)
    - Data (sends one bit at a time to console)

### Reading Process
1. **Latching**
    - The console sets the latch line high (1)
    - This tells the controller to "snapshot" the current state of all buttons
    - The button states are loaded into an 8-bit shift register
    - The first bit (A button) is immediately placed on the data line

2. **Reading**
    - The console pulses the clock line 8 times
    - On each pulse, one bit is read through the data line
    - The shift register shifts one position on each clock pulse
    - Bits are read in this order:
        1. A Button
        2. B Button
        3. Select
        4. Start
        5. Up
        6. Down
        7. Left
        8. Right

3. **Bit Values**
    - Buttons are active low
    - 0 = Button is pressed
    - 1 = Button is not pressed

### Example Timing Sequence:
``` 
1. Latch goes HIGH (1)
2. Controller loads button states
3. Latch goes LOW (0)
4. Clock pulses 8 times:
   ↓ Clock pulse 1 - Read A button
   ↓ Clock pulse 2 - Read B button
   ↓ Clock pulse 3 - Read Select
   ↓ Clock pulse 4 - Read Start
   ↓ Clock pulse 5 - Read Up
   ↓ Clock pulse 6 - Read Down
   ↓ Clock pulse 7 - Read Left
   ↓ Clock pulse 8 - Read Right
```
### Interesting Details
- The controller hardware is incredibly simple, using just a 4021 8-bit shift register
- The protocol is so simple that many modern microcontrollers can emulate NES controllers with just a few lines of code
- This design allows for very fast polling (can be read many times per frame)
- Some third-party controllers added additional features by using normally unused states in the shift register
- The same basic protocol was used in the Super Nintendo controller, just with more buttons

This simple but effective design has made the NES controller one of the most reliable and long-lasting game controllers ever made, with many original controllers still working perfectly after 35+ years.
