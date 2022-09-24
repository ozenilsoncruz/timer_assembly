/* map.s */

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

/*======================================================
        Funcao de espara
  ======================================================
        Entradas:
                segundos: segundo a aguardar
                milissegundo: milissegundo a aguardar
        Registradores utilizados: r0, r1, r7
                obs:    r0 carrega o valor em s
                        r1 carrega o valor em ms
  ------------------------------------------------------*/
.macro nanosleep2 segundo, milissegundo
        LDR R0,=\segundo        @adiciona o valor da variavel second
        LDR R1,=\milissegundo   @paramentro da macro
        MOV R7, #nano_sleep
        SVC 0
.endm

/*======================================================
        ----------------------------------
  ======================================================
        Entradas:  
                pin: pino a ser acessado
        Registradores utilizados: r0, r2, r3, r8
                obs:    r2 carrega ...
                        r3 carrega o pino
  ------------------------------------------------------*/
.macro GPIOReadRegister pin
        mov r2, r8      @ Endereço dos registradores da GPIO
        add r2, #level  @ offset para acessar o registrador do pin level 0x34 
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