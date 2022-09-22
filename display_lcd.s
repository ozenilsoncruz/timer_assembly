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
 

.macro nanoSleep time
        ldr R0,=\time
        ldr R1,=\time
        mov R7, #nano_sleep
        svc 0
.endm


.macro GPIOReadRegister pin
        mov R2, R8      @Endereço dos registradores da GPIO
        add R2, #level  @offset para acessar o registrador do pin level 0x34 
        ldr R2, [R2]    @ pino5, 19 e 26 ativos respectivamentes
        ldr R3, =\pin   @ base dos dados do pino
        add R3, #8      @ offset para acessar a terceira word
        ldr R3, [R3]    /* carrega a posiçao do pino -> 
                          ex queremos saber o valor do pino5 =2^5= 32 => 00 000 000 000 000 000 000 000 000 100 000*/
        and R0, R2, R3  @ Filtrando os outros bits => 00 000 000 000 000 000 000 000 000 100 000
.endm


.macro GPIODirectionOut pin
        ldr R2, =\pin
        ldr R2, [R2]
        ldr R1, [R8, R2]
        ldr R3, =\pin @ address of pin table
        add R3, #4 @ load amount to shift from table
        ldr R3, [R3] @ load value of shift amt
        mov R0, #0b111 @ mask to clear 3 bits
        lsl R0, R3 @ shift into position
        bic R1, R0 @ clear the three bits
        mov R0, #1 @ 1 bit to shift into pos
        lsl R0, R3 @ shift by amount from table
        orr R1, R0 @ set the bit
        str R1, [R8, R2] @ save it to reg to do work
.endm


.macro GPIOTurnOn pin
        mov R2, R8 @ address of gpio regs
        add R2, #setregoffset @ off to set reg
        mov R0, #1 @ 1 bit to shift into pos
        ldr R3, =\pin @ base of pin info table
        add R3, #8 @ add offset for shift amt
        ldr R3, [R3] @ load shift from table
        lsl R0, R3 @ do the shift
        str R0, [R2] @ write to the register
.endm


.macro GPIOTurnOff pin
        mov R2, R8 @ address of gpio regs
        add R2, #clrregoffset @ off set of clr reg
        mov R0, #1 @ 1 bit to shift into pos
        ldr R3, =\pin @ base of pin info table
        add R3, #8
        ldr R3, [R3]
        lsl R0, R3
        str R0, [R2]
.endm


.macro GPIOValue pin, value
        mov R0, #40     @valor do clear off set
        mov R2, #12     @valor que ao subtrair o clear off set resulta 28 o set
        mov R1, \value  @registra o valor 0 ou 1 no registrador
        mul R5, R1, R2  @Ex r1 recebe o valor 1, ou seja multiplica o 12 do r2 por 1 resultando 12 no r5
        sub R0, R0, R5  @valor do r5 que é 12 subtraido por 40 do r0 resultando 28 para o r0 ou seja o set do offset
        mov R2, R8      @Endereço dos registradores da GPIO
        add R2, R2, R0  @adiciona no r2 o valor do set com o endereço dos regs
        mov R0, #1      @ 1 bit para o shift
        ldr R3, =\pin   @valor dos endereços dos pinos
        add R3, #8      @ Adiciona offset para shift 
        ldr R3, [R3]    @carrega o shift da tabela
        lsl R0, R3      @realiza a mudança
        str R0, [R2]    @Escreve no registro
.endm

@ Chama a saida dos pinos do display
.macro 	setOut
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

.macro escreveASCII texto
        ldr r10, #\texto        @ passa o valor do texto para r10
        mov r9, #0              @ tamanho do texto

        loop:    @ loop que percorre cada caracter
                ldrb r11, [r10, r9]     @ Load Register Byte 
                                        @ carrega 1 byte na posicao indicada
                mov r0, #0
                mov r1, #1
                loop_bit:  @ percorre todos os 8 bits do bit para sabe o nivel logico
                        and r2, r1, r11 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
                        cbz r2, casos   @ se for igual a 0 valor nao sera alterado, se for diferente r2 = 1
                        mov r2, #1
                        casos:
                        @ se for 0 seta no pino DB4
                        cbz r0, case1
                        @ se for 1 seta no pino DB5
                        cmp r0, #1
                        beq case2
                        @ se for 2 seta no pino DB6
                        cmp r0, #2
                        beq case3
                        @ se for 3 seta no pino DB7
                        cmp r0, #3
                        beq case4
                        case1:
                                GPIOValue pinE, #0 @ atribui 0 ao enable
                                GPIOValue pinRS, #1         
                                GPIOValue pinE, #1
                                GPIOValue pinDB4, r2
                                b retornar @ pula os outros casos
                        case2:
                                GPIOValue pinDB5, r2
                                b retornar  @ pula os outros casos
                        case3:
                                GPIOValue pinDB6, r2 
                                b retornar @ pula os outros casos
                        case4:
                                GPIOValue pinDB7, r2
                                GPIOValue pinE, #0
                        retornar:
                        lsl r1, #1      @ desloca o bit para a esquerda  ex: 0001 -> 0010
                        add r0, #1      @ adiciona +1 a r0
                        cmp r0, #7      @ compara o valor de r0 para saber se ja percorreu o ultimo bit

                bne loop_bit

                entryModeSet            @ move o cursor

                add r9, #1
                cmp r9, #32
        bne loop @ se r9 for diferente de 0, continue
.endm

.global _start

_start:
	ldr R0, =fileName
	mov R1, #0x1b0
	orr R1, #0x006
	mov R2, R1
	mov R7, #sys_open
	swi 0
	movs R4, R0

	ldr R5, =gpioaddr
	ldr R5, [R5]
	mov R1, #pagelen
	mov R2, #(prot_read + prot_write)
	mov R3, #map_shared
	mov R0, #0
	mov R7, #sys_map
	swi 0
	movs R8, R0

        setOut
        inicirDisplay
        entryModeSet

        @teste
        setDisplay 1, 0, 0, 1, 1 @ envia o primeiro conjunto de dados para o display
        setDisplay 1, 0, 0, 0, 1 @ envia o segundo conjunto de dados para o display
        
        entryModeSet                     @ move o cursor

        setDisplay 1, 0, 0, 1, 1 @ envia o primeiro conjunto de dados para o display
        setDisplay 1, 0, 0, 1, 0 @ envia o segundo conjunto de dados para o display

        entryModeSet                     @ move o cursor

        setDisplay 1, 0, 0, 1, 1 @ envia o primeiro conjunto de dados para o display
        setDisplay 1, 0, 0, 1, 1 @ envia o segundo conjunto de dados para o display
        /*
        ldr r10, =texto        @ passa o valor do texto para r10
        mov r9, #0             @ tamanho do texto

        loop:    @ loop que percorre cada caracter
                ldrb r11, [r10, r9]     @ Load Register Byte 
                                        @ carrega 1 byte na posicao indicada
                mov r0, #0
                mov r1, #1
                loop_bit:  @ percorre todos os 8 bits do bit para sabe o nivel logico
                        and r2, r1, r11 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
                        cbz r2, casos   @ se for igual a 0 valor nao sera alterado, se for diferente r2 = 1
                        mov r2, #1
                        casos:
                        @ se for 0 seta no pino DB4
                        cbz r0, case1
                        @ se for 1 seta no pino DB5
                        cmp r0, #1
                        beq case2
                        @ se for 2 seta no pino DB6
                        cmp r0, #2
                        beq case3
                        @ se for 3 seta no pino DB7
                        cmp r0, #3
                        beq case4
                        case1:
                                GPIOValue pinE, #0 @ atribui 0 ao enable
                                GPIOValue pinRS, #1         
                                GPIOValue pinE, #1
                                GPIOValue pinDB4, r2
                                b retornar @ pula os outros casos
                        case2:
                                GPIOValue pinDB5, r2
                                b retornar  @ pula os outros casos
                        case3:
                                GPIOValue pinDB6, r2 
                                b retornar @ pula os outros casos
                        case4:
                                GPIOValue pinDB7, r2
                                GPIOValue pinE, #0
                        retornar:
                        lsl r1, #1      @ desloca o bit para a esquerda  ex: 0001 -> 0010
                        add r0, #1      @ adiciona +1 a r0
                        cmp r0, #7      @ compara o valor de r0 para saber se ja percorreu o ultimo bit

                bne loop_bit

                entryModeSet            @ move o cursor

                add r9, #1
                cmp r9, #len_texto
        bne loop @ se r9 for diferente de 0, continue*/

_end:
    mov r7, #1
    swi 0


@ variaveis utilizadas no codigo
.data
        texto: .asciz "123456789"
        len_texto = .-texto

        timespecnano5: .word 5000000
        timespecnano150: .word 150000

	fileName: .asciz "/dev/mem"
	gpioaddr: .word 0x20200 @carrega o endereco os onde registradores do controlador GPIO são mapeados na memória


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