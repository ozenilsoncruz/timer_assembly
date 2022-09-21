/* Percorre cada caracter de uma string */

.global _start

_start:
    ldr r10, =texto        @ passa o valor do texto para r10
    mov r9, #0             @ tamanho do texto

    loop:    @ loop que percorre cada caracter
            ldrb r11, [r10, r9]  /* Load Register Byte 
                                    Carrega o byte na posicao indicada*/
            mov r0, #0
            mov r1, #1

            loop2:  @ percorre todos os 8 bits do bit para sabe o nivel logico
                ldr r3
                and r2, r1, r3 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
                
                @ verificar logica >>> str r8, [r2, r0] @ adiciona o valor de r2 na memoria

                lsl r1, #1 /* desloca o bit para a esquerda
                              ex: 0001 -> 0010 */
                add r0, #1
                cmp r0, #7
            beq loop2

            setDisplay 1, DB7, DB6, DB5, DB4 @ envia o primeiro conjunto de dados para o display
            setDisplay 1, DB7, DB6, DB5, DB4 @ envia o segundo conjunto de dados para o display
            entryModeSet                     @ move o cursor

            add r9, #1
            cmp r9, #len_texto
    bne loop @ se r9 for diferente de 0, continue

_end:
    mov r7, #1
    swi 0

.data
    texto: .asciz "123456789"
    len_texto = .-texto