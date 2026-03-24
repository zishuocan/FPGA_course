Project: UART add experiment (4-digit + 4-digit)

Function:
1. Send 8 ASCII digits in total through UART.
2. FPGA treats the first 4 digits as number A, and next 4 digits as number B.
3. FPGA calculates A+B, then sends back the decimal sum in ASCII.
   - Range: 0000..9999 + 0000..9999 => 0..19998.

Example:
Send "2024" then send "1234".
FPGA returns "3258".

UART setting:
- Baud: 57600
- Data bits: 8
- Parity: Even
- Stop bits: 1
- Flow control: None
- Send mode: ASCII

Notes:
- Non-digit characters are ignored.
- No CR/LF is appended by FPGA.