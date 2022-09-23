* display_lcd.s */

@ Constantes importantes para o programa
.equ pagelen, 4096
.equ setregoffset, 28
.equ clrregoffset, 40
.equ prot_read, 1
.equ prot_write, 2
.equ map_shared, 1
.equ sys_open, 5
.equ sys_map, 192
.equ nano_sleep, 162
.equ level, 52
 

@----------------------Macro da nano sleep de ms--------------------@
.macro nanoSleep timespecnano
        LDR R0,=timespecsec @carrega o valor da variavel timespecsec
        LDR R1,=\timespecnano @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
.endm

@----------------Macro da nano sleep de 1s para o contador----------@
.macro nanoSleep1s time1s
        LDR R0,=second  @adiciona o valor da variavel second
        LDR R1,=\time1s @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
.endm


.macro GPIOReadRegister pin
        mov r2, r8      @Endereço dos registradores da GPIO
        add r2, #level  @offset para acessar o registrador do pin level 0x34 
        ldr r2, [r2]    @ pino5, 19 e 26 ativos respectivamentes
        ldr r3, =\pin   @ base dos dados do pino
        add r3, #8      @ offset para acessar a terceira word
        ldr r3, [r3]    /* carrega a posiçao do pino -> 
                          ex queremos saber o valor do pino5 =2^5= 32 => 00 000 000 000 000 000 000 000 000 100 000*/
        and r0, r2, r3  @ Filtrando os outros bits => 00 000 000 000 000 000 000 000 000 100 000
.endm


.macro GPIODirectionOut pin
        ldr r2, =\pin
        ldr r2, [r2]
        ldr r1, [r8, r2]
        ldr r3, =\pin @ address of pin table
        add r3, #4 @ load amount to shift from table
        ldr r3, [r3] @ load value of shift amt
        mov r0, #0b111 @ mask to clear 3 bits
        lsl r0, r3 @ shift into position
        bic r1, r0 @ clear the three bits
        mov r0, #1 @ 1 bit to shift into pos
        lsl r0, r3 @ shift by amount from table
        orr r1, r0 @ set the bit
        str r1, [r8, r2] @ save it to reg to do work
.endm


.macro GPIOTurnOn pin
        mov r2, r8 @ address of gpio regs
        add r2, #setregoffset @ off to set reg
        mov r0, #1 @ 1 bit to shift into pos
        ldr r3, =\pin @ base of pin info table
        add r3, #8 @ add offset for shift amt
        ldr r3, [r3] @ load shift from table
        lsl r0, r3 @ do the shift
        str r0, [r2] @ write to the register
.endm


.macro GPIOTurnOff pin
        mov r2, r8 @ address of gpio regs
        add r2, #clrregoffset @ off set of clr reg
        mov r0, #1 @ 1 bit to shift into pos
        ldr r3, =\pin @ base of pin info table
        add r3, #8
        ldr r3, [r3]
        lsl r0, r3
        str r0, [r2]
.endm


.macro GPIOValue pin value
        mov r0, #40     @valor do clear off set
        mov r2, #12     @valor que ao subtrair o clear off set resulta 28 o set
        mov r1, \value  @registra o valor 0 ou 1 no registrador
        mul r5, r1, r2  @Ex r1 recebe o valor 1, ou seja multiplica o 12 do r2 por 1 resultando 12 no r5
        sub r0, r0, r5  @valor do r5 que é 12 subtraido por 40 do r0 resultando 28 para o r0 ou seja o set do offset
        mov r2, r8      @Endereço dos registradores da GPIO
        add r2, r2, r0  @adiciona no r2 o valor do set com o endereço dos regs
        mov r0, #1      @ 1 bit para o shift
        ldr r3, =\pin   @valor dos endereços dos pinos
        add r3, #8      @ Adiciona offset para shift 
        ldr r3, [r3]    @carrega o shift da tabela
        lsl r0, r3      @realiza a mudança
        str r0, [r2]    @Escreve no registro
.endm

@ Chama a saida dos pinos do display
.macro  setOut
        GPIODirectionOut pinE
        GPIODirectionOut pinRS
        GPIODirectionOut pinDB7
        GPIODirectionOut pinDB6
        GPIODirectionOut pinDB5
        GPIODirectionOut pinDB4
        .ltorg
.endm

@ Ativa ou desativa os pinos do display LCD
.macro setDisplay RS, DB7, DB6, DB5, DB4
        GPIOValue pinE, #0              @ atribui 0 ao enable
        GPIOValue pinRS, #\RS
        GPIOValue pinE, #1              @ atribui 1 ao enable
        GPIOValue pinDB7, #\DB7
        GPIOValue pinDB6, #\DB6
        GPIOValue pinDB5, #\DB5
        GPIOValue pinDB4, #\DB4
        GPIOValue pinE, #0
.endm

@ Modo de configuração de entrada
.macro entryModeSet
        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 1, 1, 1, 0
        nanoSleep timespecnano150

        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 0, 1, 1, 0
        nanoSleep timespecnano150
        .ltorg
.endm

@ Inicializa o display
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

@ Limpa o display
.macro clearDisplay
        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 0, 0, 0, 1
        nanoSleep timespecnano150 
.endm

.global _start

_start:
	ldr r0, =fileName
	mov r1, #0x1b0
	orr r1, #0x006
	mov r2, r1
	mov r7, #sys_open
	swi 0
	movs r4, r0

	ldr r5, =gpioaddr
	ldr r5, [r5]
	mov r1, #pagelen
	mov r2, #(prot_read + prot_write)
	mov r3, #map_shared
	mov r0, #0
	mov r7, #sys_map
	swi 0
	movs r8, r0

        setOut
        inicirDisplay
        entryModeSet

	setDisplay 1, 0, 0, 1, 1
        setDisplay 1, 0, 0, 0, 0

	entryModeSet
        /*mov r6, #9
        contador:
                nanoSleep timeSecond       @ aguarda 1 segundo
                sub r6, #1
                cmp r6, #0
        beq contador       @ loop infinito*/

        ldr r10, =texto        @ passa o valor do texto para r10
        mov r9, #0             @ tamanho do texto

        loop:    @ loop que percorre cada caracter
                ldrb r11, [r10, r9]     @ Load Register Byte 
                                        @ carrega 1 byte na posicao indicada

		mov r6, #7
                mov r12, #256
                loop_bit:  @ percorre todos os 8 bits do bit para sabe o nivel logico
                        and r4, r12, r11 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
                        cmp r4, #0 
                        beq casos   @ se for igual a 0 valor nao sera alterado, se for diferente r2 = 1            
                        casos:
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
                        lsr r12, #1      @ desloca o bit para a direita  ex: 0010 -> 0001
                        sub r6, #1      @ adiciona +1 a r0
                        cmp r6, #0      @ compara o valor de r0 para saber se ja percorreu o ultimo bit
                bne loop_bit

                add r9, #1
                
                entryModeSet            @ move o cursor
                
                cmp r9, #len_texto
        bne loop

_end:
    mov r7, #1
    swi 0


@ variaveis utilizadas no codigo
.data
        texto: .asciz "123456789"
        len_texto = .-texto

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

