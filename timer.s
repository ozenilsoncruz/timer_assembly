.include "in_out.s"

.global _start


_start:
	ldr r3, =texto
    ldrb r5, [r3, #1]
    ldrb r4, [r3, #1]
    sub r4, #1
    ldr r3, [r3]
    print texto, len_texto
_end:
    mov r0, #1
    mov r7, #1
    swi 0     

.data
        timer: .asciz "11"
        len_texto = .-texto

