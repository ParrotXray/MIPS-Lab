"""
Software model of seg7_display.sv — mirrors the always @(*) block exactly.
Verifies all 20 input values (0-19) against expected 7-segment patterns.
"""

# Active-low 7-segment encodings (gfedcba)
SEG = {
    0: 0b1000000,
    1: 0b1111001,
    2: 0b0100100,
    3: 0b0110000,
    4: 0b0011001,
    5: 0b0010010,
    6: 0b0000010,
    7: 0b1111000,
    8: 0b0000000,
    9: 0b0010000,
}
BLANK = 0b1111111

def seg7_display(inp: int):
    """Matches the SystemVerilog always @(*) block exactly."""
    ones = inp % 10
    tens = inp // 10

    if   ones == 0: hex0 = 0b1000000
    elif ones == 1: hex0 = 0b1111001
    elif ones == 2: hex0 = 0b0100100
    elif ones == 3: hex0 = 0b0110000
    elif ones == 4: hex0 = 0b0011001
    elif ones == 5: hex0 = 0b0010010
    elif ones == 6: hex0 = 0b0000010
    elif ones == 7: hex0 = 0b1111000
    elif ones == 8: hex0 = 0b0000000
    else:           hex0 = 0b0010000  # 9

    hex1 = BLANK if tens == 0 else 0b1111001  # blank or "1"

    return hex0, hex1

def fmt(v): return f"{v:07b}"

print("=== seg7_display verification ===")
print(f"{'in':>4}  {'HEX1(tens)':>12}  {'HEX0(ones)':>12}  result")
print("-" * 48)

pass_cnt = fail_cnt = 0
for i in range(20):
    hex0, hex1 = seg7_display(i)
    exp0 = SEG[i % 10]
    exp1 = BLANK if i // 10 == 0 else SEG[1]

    ok = (hex0 == exp0) and (hex1 == exp1)
    status = "PASS" if ok else "FAIL"
    if ok: pass_cnt += 1
    else:  fail_cnt += 1

    note = ""
    if not ok:
        note = f"  expected HEX1={fmt(exp1)} HEX0={fmt(exp0)}"
    print(f"{i:>4}  {fmt(hex1):>12}  {fmt(hex0):>12}  {status}{note}")

print("-" * 48)
print(f"Result: {pass_cnt} / {pass_cnt + fail_cnt} passed")
if fail_cnt == 0:
    print("All tests PASSED.")
else:
    print(f"{fail_cnt} test(s) FAILED.")
