.include "display_lcd.s"

.global _start


_start:
    verificacao_erros:
        @ verifica se o numero esta dentro do limite permitido
        mov r9, #len_num
        	
		cmp r9, #31
        bgt _erro1                  @ se for maior, que 31, 

        ldr r10, =num               @ passa o valor do num para r10
        @ varifica se a string contem apenas numero
        verificacao_num:            @ loop que percorre cada caracter
            cmp r9, #0      @ compara com o tamanho do caractere -1
            bge verificacao_num
            ldrb r11, [r10, r9]     /* Load Register Byte 
                                    carrega 1 byte na posicao indicada*/
            @ se for menor que 48 ou maior que 57, desvia para informar que nao e um numero
            cmp r11, #48 @'0'
            blt _erro2
            cmp r11, #57 @'9' 
            bgt _erro2

            sub r9, #1
        b verificacao_num
        
	contador:        
        @ r9 tem guardado a qtd de numeros-1
        ldr r10, =num
        mov r9, #len_num
        while_num:
            print pular_linha len_pular_linha
            print num len_num
            print pular_linha len_pular_linha
            ldrb r11, [r10, r9] @ carrega o byte especificado

            cmp r11, #48         @ verifica se o numero e zero
            beq verificar_anteriores
        
            sub r11, #1         @ se r11 nao for igual a zero, subtrai 1
            strb r11, [r10, r9] @ registra no byte especificado
            cmp r11, #0         @ enquanto r11 for diferente de zero, continue
        bne while_num
    
        sub r9, #1
        cmp r9, #0
    bge contador            @ enquanto r9 for maior ou igual a zero, continue
    
    b _end                      @ desvia para encerrar o contador

    @ verifica os bytes anteriores para saber se algum sao zero
    verificar_anteriores:

        @ se o ultimo byte conter o digito 0, o programa e finalizado
        cmp r9, #0
        beq _end

        @ atribui r9 a um registrador auxiliar
        mov r6, r9  @1100
                    @1009
                    @1099
                    @1999
                    @0999
                    @999
        
        loop_anteriores:
            ldrb r11, [r10, r6] @ carrega o byte especificado
            
            cmp r11, #48        @ compara com o ascii de 0 para saber se e o numero 0
            beq set9            @ se nao for igual, retorna para o loop da subtracao

            sub r11, #1         @ subtrai 1 do byte
            strb r11, [r10, r6] @ registra no byte especificado
            b contador          @ retorna para o loop principal

            set9:
                cmp r6, #0          @ se r6 for igual a 0, remova o byte
                beq remova_byte
                mov r11, #57        @ se for igual, r11 recebe o ascii de 9
                strb r11, [r10, r6] @ registra no byte especificado

                remova_byte:
                    mov r11, #0         @ se for igual, r11 recebe o ascii de 9
                    strb r11, [r10, r6] @ registra no byte especificado
                    b contador         @ retorna para o loop principal
            sub r6, #1
            cmp r6, #0
        bge loop_anteriores         @ retorna para o loop  
        b contador                  @ retorna para o loop principal
_erro1:
	print pular_linha len_pular_linha
    print erro_size len_erro_size
	print pular_linha len_pular_linha
    b _end
_erro2:
	print pular_linha len_pular_linha
    print erro_num len_erro_num
	print pular_linha len_pular_linha
    b _end
_fim:
    print pular_linha len_pular_linha
    print fim len_fim
	print pular_linha len_pular_linha
_end:
    mov r7, #1
    swi 0

.data
        num: .asciz "012345678"
        len_num = .-num -1

        erro_num: .asciz "Nao e um numero inteiro!" 
        len_erro_num = .-erro_num -1

        erro_size: .asciz "Numero muito grande!" 
        len_erro_size = .-erro_size -1

        fim: .asciz "Fim!"
        lem_fim = .-fim -1

        pular_linha: .asciz "\n"
        len_pular_linha = .-len_pular_linha-1

        @ pino do LED
        pin6:   .word 0
                .word 18
                .word 6

        @ pinos dos botoes
        pin19:  .word 4
                .word 27
                .word 524288
        pin26:  .word 8
                .word 18
                .word 67108864 