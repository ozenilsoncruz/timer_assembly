/* display_lcd.s */
.include "map.s"
.text

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
.macro displayShift
    setDisplay 0, 0, 0, 0, 1
    setDisplay 0, 0, 1, 0, 0
    nanoSleep timespecnano150
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
    nanoSleep timespecnano150

    setDisplay 0, 0, 0, 0, 0
    setDisplay 0, 0, 1, 1, 0
    nanoSleep timespecnano150
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
.macro inicirDisplay
    setDisplay 0, 0, 0, 1, 1  
    nanoSleep timespecnano5

    setDisplay 0, 0, 0, 1, 1 
    nanoSleep timespecnano150  

    setDisplay  0, 0, 0, 1, 1


    setDisplay 0, 0, 0, 1, 0
    nanoSleep timespecnano150  

    .ltorg 

    setDisplay 0, 0, 0, 1, 0 

    setDisplay 0, 0, 0, 0, 0
    nanoSleep timespecnano150 
    setDisplay 0, 0, 0, 0, 0 

    setDisplay 0, 1, 0, 0, 0  
    nanoSleep timespecnano150

    setDisplay 0, 0, 0, 0, 0  

    setDisplay 0, 0, 0, 0, 1  
    nanoSleep timespecnano150 

    setDisplay 0, 0, 0, 0, 0

    setDisplay 0, 0, 1, 1, 0 
    nanoSleep timespecnano150

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
    nanoSleep timespecnano150 
.endm

/*======================================================
        Realiza a exibicao de uma cadeia de caracteres
        no display
  ======================================================
        Macros utilizadas:  
                setCaractere: usado para enviar um carac-
                tere para o display
                displayShift: usado para mover o cursor para 
                cada caractere
        Registradores utilizados: r6, r9, r10, r11, r12
                obs:    r10 carrega o texto 
                        r11 carrega o byte do primeiro caractere
  ------------------------------------------------------*/
.macro setString texto len_texto
        #clearDisplay           @ limpa a tela do display
        ldr r10, =\texto       @ passa o valor do texto para r10
        mov r9, #0             @ tamanho do texto
        mov r13, #\len_texto
        bl loop
        .ltorg
.endm

loop:   @ loop que percorre cada caracter
        ldrb r11, [r10, r9]     @ Load Register Byte 
                                @ carrega 1 byte na posicao indicada

        mov r6, #7
        mov r12, #256
        loop_bit:  @ percorre todos os 8 bits do bit para sabe o nivel logico
                lsr r12, #1      @ desloca o bit para a direita  ex: 100000000 -> 010000000
                and r4, r12, r11 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
                cmp r4, #0
                beq switch 	 @ se for igual a 0 valor nao sera alterado, se for diferente r2 = 1            
                mov r4, #1
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
                                GPIOValue pinDB7, r4
                                b retornar @ pula os outros casos
                        case2:
                                GPIOValue pinDB6, r4
                                b retornar  @ pula os outros casos
                        case3:
                                GPIOValue pinDB5, r4
                                b retornar @ pula os outros casos
                        case4:
                                GPIOValue pinDB4, r4
                                GPIOValue pinE, #0
                retornar:
                        sub r6, #1       @ subtrai +1 a r0
                        cmp r12, #1      @ compara o valor de r0 para saber se ja percorreu o ultimo bit
        bne loop_bit

        add r9, #1

        entryModeSet            @ move o cursor

        cmp r9, r13 
bne loop

bx lr                       @ retorna para a macro que fez a chamada
