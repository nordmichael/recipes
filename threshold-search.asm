; Rapid + fine threshold search.
;
; Outputs a guess on `out`, reads the oracle on `in`.
;   in == 0  -> guess is "safe" (at or below the threshold)
;   in != 0  -> guess overshot the threshold
; Goal: find the largest safe value.
;
; Register roles:
;   r0 = scratch / immediate / jump vector
;   r1, r2 = add operands   (add: r0 = r1 + r2)
;   r3 = last oracle result (jnz tests r3)
;   r4 = current guess
;   r5 = last known SAFE guess  (the answer once we overshoot)

memory_init:
imm 0
mov r1, r0
mov r2, r0
mov r3, r0
mov r4, r0
mov r5, r0

setup:
imm prog_start
jmp

; --- Function definitions -------------------------------------------------

add_one:            ; r4 += 1, return to fine search
imm 1
mov r1, r0
mov r2, r4
add
mov r4, r0          ; FIX: save the sum back into r4 before r0 is clobbered
imm search
jmp

add_ten:            ; r4 += 10, return to rapid_scan
imm 10
mov r1, r0
mov r2, r4
add
mov r4, r0          ; FIX: save the sum back into r4 before r0 is clobbered
imm rapid_scan
jmp

; --- Phase 1: rapid scan, step +10 ---------------------------------------

prog_start:
rapid_scan:
mov out, r4         ; emit current guess
mov r3, in          ; read oracle result
imm fine_init       ; target if we overshot
jnz                 ; if r3 != 0 -> overshot, hand off to fine search
mov r5, r4          ; FIX: save current guess as the last known safe value
imm add_ten
jmp                 ; still safe -> step up by 10 and rescan

; --- Phase 2: fine scan, step +1 -----------------------------------------

fine_init:
mov r4, r5          ; FIX: rewind to the last safe guess before creeping up

search:
mov out, r4         ; emit current guess
mov r3, in          ; FIX: read result into r3 (was r0, then discarded)
imm found           ; target if we overshot
jnz                 ; FIX: if r3 != 0 -> found the threshold
mov r5, r4          ; still safe -> record it
imm add_one
jmp                 ; step up by 1 and rescan

; --- Done -----------------------------------------------------------------

found:
mov out, r5         ; r5 holds the largest safe value: the answer
done:
imm done
jmp                 ; halt (spin)
