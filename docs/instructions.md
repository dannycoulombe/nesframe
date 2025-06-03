Here’s a list of 6502 operations where you typically need to **clear the carry flag** (`CLC`) beforehand:
- `ADC` (Add with Carry) – for normal addition without any previous carry-in
- Multi-byte addition routines (before adding each new byte)
- `ROL` (Rotate Left) – when you need to start rotation with carry = 0
- Multi-byte shift/rotate routines (to ensure no old carry propagates)

**Note:**
For `SBC` (Subtract with Carry), you usually **set** the carry (`SEC`) before the operation, not clear it.
