/* Percorre cada caracter de uma string */

.global _start

_start:
    ldr r10, =texto        @ passa o valor do texto para r10
    mov r9, #0             @ tamanho do texto

    loop:    @ loop que percorre cada caracter
            ldrb r11, [r10, r9]  /* Load Register Byte 
                                    Carrega o byte na posicao indicada*/
            add r9, #1
            cmp r9, #len_texto
    bne loop @ se r9 for diferente de 0, continue

.data
    texto: .asciz "123456789"
    len_texto = .-texto