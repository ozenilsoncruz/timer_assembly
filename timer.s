.include "display_lcd.s"

.global _start

_start:
	iniciar_display
	
        @ Verifica se os caracteres inseridos foram corretos
	verificacao_erros:
                @ verifica se o numero esta dentro do limite permitido
                mov r9, #len_num
                sub r9, #1     
                cmp r9, #31
                bgt _erro1                  @ se for maior, que 31, 

        ldr r10, =num               @ passa o valor do num para r10
        @ varifica se a string contem apenas numero
        verificacao_num:            @ loop que percorre cada caracter
            ldrb r11, [r10, r9]     /* Load Register Byte 
                                    carrega 1 byte na posicao indicada*/
            @ se for menor que 48 ou maior que 57, desvia para informar que nao e um numero
            cmp r11, #48 @'0'
            blt _erro2
            cmp r11, #57 @'9' 
            bgt _erro2
            cmp r9, #0      @ compara com o tamanho do caractere -1
            ble contador    @ se for menor ou igual a zero, devia para o contador
            sub r9, #1
        b verificacao_num
        
	contador:
                @encontre um jeito de parar esse loop e já era
                while_num:
                @ r9 tem guardado a qtd de numeros-1
                ldr r10, =num
                print pular_linha len_pular_linha
                print num len_num
                print pular_linha len_pular_linha
    
                mov r9, #len_num
                sub r9, #1              @ subtrai 1 de r9 para ser igual a posicao do ultimo caractere

                ldrb r11, [r10, r9] @ carrega o byte especificado

                cmp r11, #48
                bne subtrai
                
                cmp r9, #0                  @ se r9 for 0, todos os caracteres foram percorridos, logo, contagem acabou
                beq _fim                    @ desvia para encerrar o contador

                mov r11, #57              @ adiciona o digito 9 ao registrador r1   
                strb r11, [r10, r9]         @ registra no byte especificado


                @ atribui r9 a um registrador auxiliar
                @ mov r6, r9
                loop_anteriores:            @ faz um loop de todos os anteriores ate que encontre um inteiro
                        sub r9, #1          @ remove 1 de r6 para selecionar o byte anterior
                        ldrb r11, [r10, r9] @ carrega o byte especificado

                        cmp r11, #48        @ compara com '0'
                        bne subtrair_anterior      @ se nao for 0, subtrai 1
                        @ verifica se r6 e zero, se for, remove
                        cmp r9, #0
                        bne verificar_1

                        @ se chegar em r9 = 0 e o valor contidor for '0', encerra o loop
                        b _fim

                        verificar_1:
                                cmp r11, #48
                                bne subtrair_anterior

                                mov r11, #57
                                strb r11, [r10, r9]
                        b loop_anteriores

                        subtrair_anterior:
                                sub r11, #1    @ subtrai 1
                                strb r11, [r10, r9]
                        b while_num
                b loop_anteriores

                subtrai:
                        sub r11, #1         @ se r11 nao for igual a zero, subtrai 1
                        strb r11, [r10, r9] @ registra no byte especificado
                b while_num
        bge contador            @ enquanto r9 for maior ou igual a zero, continue
    
        b _end
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

@ variaveis utilizadas no codigo
.data
        num: .ascii "10"
        len_num = .-num

        erro_num: .ascii "Nao e um numero inteiro!" 
        len_erro_num = .-erro_num

        erro_size: .ascii "Numero muito grande!" 
        len_erro_size = .-erro_size

        fim: .ascii "Fim!"
        len_fim = .-fim

        pular_linha: .ascii "\n"
        len_pular_linha = .-pular_linha