/* display_lcd.s */ 
.include "map.s"

/*======================================================
        Chama a saida dos pinos do display
  ======================================================
        Utiliza a macro GPIODirectionOut presente no
        map.s para chamar a saida de cada pino do display
  ------------------------------------------------------*/
.macro  setOut
        GPIODirectionOut pinE
        GPIODirectionOut pinRS
        GPIODirectionOut pinDB7
        GPIODirectionOut pinDB6
        GPIODirectionOut pinDB5
        GPIODirectionOut pinDB4
        .ltorg
.endm

/*======================================================
        Ativa ou desativa os pinos do display LCD
        Recebe o nivel logico de cada uma das entradas 
        dos pinos com excecao do enable
  ======================================================
        Macros utilizadas: 
                GPIOValue: presente no map.s, utilizada 
                para setar um determinado dado no display.
        Entradas: 
                RS, DB7, DB6, DB5, DB4
  ------------------------------------------------------*/
.macro setDisplay RS, DB7, DB6, DB5, DB4
        GPIOValue pinE, #0
        GPIOValue pinRS, #\RS
        GPIOValue pinE, #1
        GPIOValue pinDB7, #\DB7
        GPIOValue pinDB6, #\DB6
        GPIOValue pinDB5, #\DB5
        GPIOValue pinDB4, #\DB4
        GPIOValue pinE, #0
.endm

/*======================================================
        Realiza o deslocamento do cursor
  ======================================================
        Macros utilizadas:  
                setDisplay: usada para setar um
                determinado dado no display
                nanoSleep: presente no map.s, utilizada
                para aguardar um determinado tempo
  ------------------------------------------------------*/
.macro entryModeSet
        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 1, 1, 1, 0
        nanoSleep 0, timespecnano150

        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 0, 1, 1, 0
        nanoSleep 0, timespecnano150
        .ltorg
.endm

/*======================================================
        Inicializa o display seguindo as orientacoes do 
        datashit
  ======================================================
        Macros utilizadas:  
                setDisplay: usada para setar um
                determinado dado no display
                nanoSleep: presente no map.s, utilizada
                para aguardar um determinado tempo
  ------------------------------------------------------*/
.macro iniciar
        setDisplay 0, 0, 0, 1, 1  
        nanoSleep 0, timespecnano5

        setDisplay 0, 0, 0, 1, 1 
        nanoSleep 0, timespecnano150  

        setDisplay  0, 0, 0, 1, 1


        setDisplay 0, 0, 0, 1, 0
        nanoSleep 0, timespecnano150  

        .ltorg 

        setDisplay 0, 0, 0, 1, 0 

        setDisplay 0, 0, 0, 0, 0
        nanoSleep 0, timespecnano150 
        setDisplay 0, 0, 0, 0, 0 

        setDisplay 0, 1, 0, 0, 0  
        nanoSleep 0, timespecnano150

        setDisplay 0, 0, 0, 0, 0  

        setDisplay 0, 0, 0, 0, 1  
        nanoSleep 0, timespecnano150 

        setDisplay 0, 0, 0, 0, 0

        setDisplay 0, 0, 1, 1, 0 
        nanoSleep 0, timespecnano150

        .ltorg
.endm

/*======================================================
        Limpa o display
  ======================================================
        Macros utilizadas:  
                GPIOsetDisplay: usada para setar um
                determinado dado no display
                nanoSleep: presente no map.s, utilizada
                para aguardar um determinado tempo
  ------------------------------------------------------*/
.macro clearDisplay
        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 0, 0, 0, 1
        nanoSleep 0, timespecnano150 
.endm

/*======================================================
        Realiza a exibicao de um de caractere no display
  ======================================================
        Macros utilizadas:  
                GGPIOValue: presente no map.s usada para setar
                cada bit que representa o caractere
        Entradas:
                caractere: caractere a ser exibido no display
        Registradores utilizados: r1, r6, r11, r12
                obs: r11 recebe o caractere
  ------------------------------------------------------*/
.macro setCaractere caractere
        mov r11, \caractere     @ atribui o valor do caractere a r11
        mov r6, #7              @ variavel de controle para considera apenas 8 bits
        mov r12, #256           @ variavel auxiliar que define qual bit esta ativo
        loop_bit:               @ percorre todos os 8 bits do bit para sabe o nivel logico
                lsr r12, #1      @ desloca o bit para a direita  ex: 100000000 -> 010000000
                and r1, r12, r11 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
                cmp r1, #0
                beq switch 	 @ se for igual a 0 valor nao sera alterado, se for diferente r2 = 1            
                mov r1, #1
                switch:
                        @ se for 0 seta no pino DB4
                        cmp r6, #0
                        beq case4
                        cmp r6, #4
                        beq case4
                        @ se for 1 seta no pino DB5
                        cmp r6, #1
                        beq case3
                        cmp r6, #5
                        beq case3
                        @ se for 2 seta no pino DB6
                        cmp r6, #2
                        beq case2
                        cmp r6, #6
                        beq case2
                        @ se for 3 seta no pino DB7
                        cmp r6, #3
                        beq case1
                        cmp r6, #7
                        beq case1

                        case1:
                                GPIOValue pinE, #0 @ atribui 0 ao enable
                                GPIOValue pinRS, #1
                                GPIOValue pinE, #1
                                GPIOValue pinDB7, r1
                                b retornar @ pula os outros casos
                        case2:
                                GPIOValue pinDB6, r1
                                b retornar  @ pula os outros casos
                        case3:
                                GPIOValue pinDB5, r1
                                b retornar @ pula os outros casos
                        case4:
                                GPIOValue pinDB4, r1
                                GPIOValue pinE, #0
                        retornar:
                                sub r6, #1       @ subtrai +1 a r0
                                cmp r12, #1      @ compara o valor de r0 para saber se ja percorreu o ultimo bit
        bne loop_bit
.endm

/*======================================================
        Realiza a exibicao de uma cadeia de caracteres
        no display
  ======================================================
        Macros utilizadas:  
                setCaractere: usado para enviar um carac-
                tere para o display
                entryModeSet: usado para mover o cursor para 
                cada caractere
        Registradores utilizados: r9, r10, r11
                obs:    r10 carrega o texto 
                        r11 carrega o byte do primeiro caractere
  ------------------------------------------------------*/
.macro setString texto len_texto
        ldr r10, =\texto       @ passa o valor do texto para r10
        mov r9, #0             @ tamanho do texto
        loop_byte:                  @ loop que percorre cada caracter
                ldrb r11, [r10, r9]     /* Load Register Byte 
                                           carrega 1 byte na posicao indicada*/
                setCaractere r11        @ passa o caractere para ser exibito no display
                entryModeSet            @ move o cursor para a direita
                add r9, #1
                cmp r9, #\len_texto      @ compara com o tamanho do caractere -1
        bne loop_byte
.endm

/*======================================================
        Realiza a inicializacao do display, bem como o 
        mapeamento dos pinos
  ======================================================
        Macros utilizadas:  
                map: uusado paraealiza o mapeamento dos pinos
                setOut: usado para setar as saidas dos display
                iniciar: segue as instrucoes do datashit para inicia-
                lizar o display no modo de 4 bits
                entryModeSet: usado para dizer o tipo de deslocamento 
                do cursor
  ------------------------------------------------------*/
.macro iniciar_display
        map

        @ direciona as saidas do display
        setOut
        iniciar
        entryModeSet
.endm

.global _start

_start:
	iniciar_display
	
        /*iniciar:
		GPIOReadRegister pin19
                cmp r0, r3
                bne contagem
        b inciar*/


        @ Verifica se os caracteres inseridos foram corretos
	verificacao_erros:
                @ verifica se o numero esta dentro do limite permitido
                mov r9, #len_num
                cmp r9, #32
                bgt _erro1                  @ se for maior, que 32, erro!

        ldr r10, =num               @ passa o valor do num para r10
        @ varifica se a string contem apenas numero
        verificacao_num:            @ loop que percorre cada caracter
                sub r9, #1
                ldrb r11, [r10, r9]     /* Load Register Byte 
                                        carrega 1 byte na posicao indicada*/
                @ se for menor que 48 ou maior que 57, desvia para informar que nao e um numero
                cmp r11, #48 @'0'
                blt _erro2
                cmp r11, #57 @'9' 
                bgt _erro2
                cmp r9, #0      @ compara com o tamanho do caractere -1
                ble contador    @ se for menor ou igual a zero, devia para o contador
        b verificacao_num
        
        contador:
                @ verifica se o botao do pino 19 foi precionado novamente, se sim, pausa
                /*GPIOReadRegister pin19 
                        cmp r0, r3
                bne contagem
                @ verifica se o botao do pino 26 foi precionado, se sim, reinicia
                GPIOReadRegister pin26
                        cmp r0, r3
                bne _start*/

                @clearDisplay            @ limpa a tela do display
                @nanosleep second, 0     @ aguarda 1 segundo
                setString num len_num   @ mostra um numero no display 

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

                mov r11, #57                @ adiciona o digito 9 ao registrador r1   
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
                        b contador
                b loop_anteriores

                subtrai:
                        sub r11, #1         @ se r11 nao for igual a zero, subtrai 1
                        strb r11, [r10, r9] @ registra no byte especificado
        b contador
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
        pinRS:	@ Pino RS - GPIO25
		.word 8
		.word 15
		.word 25
	pinE:	@ Pino Enable - GPIO1
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