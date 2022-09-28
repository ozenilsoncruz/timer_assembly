.include "display.s"


.global _start


_start:
    map

    setOut
    inicirDisplay
    entryModeSet

    @ verifica se o numero esta dentro do limite permitido
    verificacao_erros:
        mov r9, #len_num
        cmp r9, #32
        bgt _erro1                  @ se for maior, que 32, erro!

    ldr r10, =num               @ passa o valor do num para r10
    @ varifica se a string contem apenas numero
    verificacao_num:            @ loop que percorre cada caracter
        sub r9, #1
        ldrb r11, [r10, r9]     @ Load Register Byte 
                                @ carrega 1 byte na posicao indicada
        @ se for menor que 48 ou maior que 57, desvia para informar que nao e um numero
        cmp r11, #48 @'0'
        blt _erro2
        cmp r11, #57 @'9' 
        bgt _erro2
        cmp r9, #0      @ compara com o tamanho do caractere -1
        ble contador    @ se for menor ou igual a zero, devia para o contador
    b verificacao_num

    setString msg_inicial len_msg_inicial  @ mostra um mensagem no display
    iniciar:
        GPIOReadRegister pin19
        cmp r0, r3
        bne contador
    b iniciar

    contador:
        @ verifica se o botao do pino 19 foi precionado novamente, se sim, pausa
        GPIOReadRegister pin19 
        cmp r0, r3
        bne iniciar
        @ verifica se o botao do pino 26 foi precionado, se sim, reinicia
        GPIOReadRegister pin26
        cmp r0, r3
        bne _start

        setString num len_num   @ mostra um numero no display
        print pular_linha len_pular_linha
        print num len_num
        print pular_linha len_pular_linha
        nanoSleep1s timespecnano1s      @ aguarda 1 segundo

        mov r9, #len_num
        sub r9, #1                  @ subtrai 1 de r9 para ser igual a posicao do ultimo caractere

        ldrb r11, [r10, r9]         @ carrega o byte especificado

        cmp r11, #48
        bne subtrai
        
        cmp r9, #0                  @ se r9 for 0, todos os caracteres foram percorridos, logo, contagem acabou
        beq _fim                    @ desvia para encerrar o contador

        mov r11, #57                @ adiciona o digito 9 ao registrador r1   
        strb r11, [r10, r9]         @ registra no byte especificado

        loop_anteriores:            @ faz um loop de todos os anteriores ate que encontre um inteiro
                sub r9, #1              @ remove 1 de r6 para selecionar o byte anterior
                        ldrb r11, [r10, r9]     @ carrega o byte especificado

                        cmp r11, #48            @ compara com '0'
                        bne subtrair_anterior   @ se nao for 0, subtrai 1
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
                        sub r11, #1         @ subtrai 1
                        strb r11, [r10, r9]
                b contador
        b loop_anteriores
        subtrai:
            sub r11, #1             @ se r11 nao for igual a zero, subtrai 1
            strb r11, [r10, r9]     @ registra no byte especificado
    b contador
    b _end
    .ltorg
_erro1:
    setString erro_size len_erro_size
    print pular_linha len_pular_linha
    print erro_size len_erro_size
    print pular_linha len_pular_linha
    b _end
    .ltorg
_erro2:
    setString erro_num len_erro_num
    print pular_linha len_pular_linha
    print erro_num len_erro_num
    print pular_linha len_pular_linha
    b _end
    .ltorg
_fim:
    setString fim len_fim
    print pular_linha len_pular_linha
    print fim len_fim
    print pular_linha len_pular_linha
    .ltorg
    mov r7, #1
    swi 0


@ variaveis utilizadas no codigo
.data
    msg_inicial: .ascii "INICIAR?"
    len_msg_inicial = .-msg_inicial

    num: .ascii "1000"
    len_num = .-num

    erro_num: .ascii "Nao e um numero inteiro!" 
    len_erro_num = .-erro_num

    erro_size: .ascii "Numero muito grande!" 
    len_erro_size = .-erro_size

    fim: .ascii "Fim!"
    len_fim = .-fim

    pular_linha: .ascii "\n"
    len_pular_linha = .-pular_linha

    second: .word 1 @definindo 1 segundo no nanosleep
	timenano: .word 0000000000 @definindo o milisegundos para o segundo passar no nanosleep
	timespecsec: .word 0 @definição do nano sleep 0s permitindo os milissegundos
	timespecnano20: .word 20000000 @chamada de nanoSleep
	timespecnano5: .word 5000000 @valor em milisegundos para lcd
	timespecnano150: .word 150000 @valor em milisegundos para LCD
	timespecnano1s: .word 999999999 @valor para delay de contador

	fileName: .asciz "/dev/mem"
	gpioaddr: .word 0x20200 @carrega o endereco os onde registradores do controlador GPIO são mapeados na memória

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

    @ pinos do display LCD
    pinRS:  @ Pino RS - GPIO25
        .word 8
        .word 15
        .word 25
    pinE:   @ Pino Enable - GPIO1
        .word 0
        .word 3
        .word 1
    pinDB4: @ Pino DB4 - GPIO12
        .word 4
        .word 6
        .word 12
    pinDB5: @ Pino DB5 - GPIO16
        .word 4
        .word 18
        .word 16
    pinDB6: @ Pino DB6 - GPIO20
        .word 8
        .word 0
        .word 20
    pinDB7: @ Pino DB7 - GPIO21
        .word 8
        .word 3
        .word 21