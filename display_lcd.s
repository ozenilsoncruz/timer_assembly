.include "map.s"
 
.global _start

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
        GPIOValue pinE, #0              @ atribui 0 ao enble
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
.macro ClearDisplay
        setDisplay 0, 0, 0, 0, 0
        setDisplay 0, 0, 0, 0, 1
        nanoSleep timespecnano150 
.endm

/*_start:
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
_end:
        mov R7,#1
        swi 0*/


_start:
    ldr r10, =texto        @ passa o valor do texto para r10
    mov r9, #0             @ tamanho do texto

    loop:    @ loop que percorre cada caracter
            ldrb r11, [r10, r9]  /* Load Register Byte 
                                    Carrega o byte na posicao indicada*/
            mov r0, #0
            mov r1, #1
           
            loop2:  @ percorre todos os 8 bits do bit para sabe o nivel logico
                and r2, r1, r11 @ faz um and entre r1 e r1 para saber se o bit esta ativo ou nao

                cmp r2, #0 @ compara o 

                beq @ manda 0 para o pino de saida



                lsl r1, #1 /* desloca o bit para a esquerda
                              ex: 0001 -> 0010 */
                
                add r0, #1
                cmp r0, #7
            beq loop2

            entryModeSet @ move o cursor

            add r9, #1
            cmp r9, #len_texto
    bne loop @ se r9 for diferente de 0, continue

_end:
    mov r7, #1
    swi 0


@ variaveis utilizadas no codigo
.data
        texto: .asciz "123456789"
        len_texto = .-texto

	second: .word 1
        timenano: .word 0000000000
        timespecsec: .word 0
        timespecnano20: .word 20000000
        timespecnano5: .word 5000000
        timespecnano150: .word 150000
        timespecnano1s: .word 999999999

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