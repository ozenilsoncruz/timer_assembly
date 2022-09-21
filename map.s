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
        LDR R0,=\time
        LDR R1,=\time
        MOV R7, #nano_sleep
        SVC 0
.endm


.macro GPIOReadRegister pin
        MOV R2, R8      @Endereço dos registradores da GPIO
        ADD R2, #level  @offset para acessar o registrador do pin level 0x34 
        LDR R2, [R2]    @ pino5, 19 e 26 ativos respectivamentes
        LDR R3, =\pin   @ base dos dados do pino
        ADD R3, #8      @ offset para acessar a terceira word
        LDR R3, [R3]    @ carrega a posiçao do pino -> 
                        @ex queremos saber o valor do pino5 =2^5= 32 => 00 000 000 000 000 000 000 000 000 100 000
        AND R0, R2, R3  @ Filtrando os outros bits => 00 000 000 000 000 000 000 000 000 100 000
.endm


.macro GPIODirectionOut pin
        LDR R2, =\pin
        LDR R2, [R2]
        LDR R1, [R8, R2]
        LDR R3, =\pin @ address of pin table
        ADD R3, #4 @ load amount to shift from table
        LDR R3, [R3] @ load value of shift amt
        MOV R0, #0b111 @ mask to clear 3 bits
        LSL R0, R3 @ shift into position
        BIC R1, R0 @ clear the three bits
        MOV R0, #1 @ 1 bit to shift into pos
        LSL R0, R3 @ shift by amount from table
        ORR R1, R0 @ set the bit
        STR R1, [R8, R2] @ save it to reg to do work
.endm


.macro GPIOTurnOn pin
        MOV R2, R8 @ address of gpio regs
        ADD R2, #setregoffset @ off to set reg
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =\pin @ base of pin info table
        ADD R3, #8 @ add offset for shift amt
        LDR R3, [R3] @ load shift from table
        LSL R0, R3 @ do the shift
        STR R0, [R2] @ write to the register
.endm


.macro GPIOTurnOff pin
        MOV R2, R8 @ address of gpio regs
        ADD R2, #clrregoffset @ off set of clr reg
        MOV R0, #1 @ 1 bit to shift into pos
        LDR R3, =\pin @ base of pin info table
        ADD R3, #8
        LDR R3, [R3]
        LSL R0, R3
        STR R0, [R2]
.endm


.macro GPIOValue pin, value
        MOV R0, #40     @valor do clear off set
        MOV R2, #12     @valor que ao subtrair o clear off set resulta 28 o set
        MOV R1, \value  @registra o valor 0 ou 1 no registrador
        MUL R5, R1, R2  @Ex r1 recebe o valor 1, ou seja multiplica o 12 do r2 por 1 resultando 12 no r5
        SUB R0, R0, R5  @valor do r5 que é 12 subtraido por 40 do r0 resultando 28 para o r0 ou seja o set do offset
        MOV R2, R8      @Endereço dos registradores da GPIO
        ADD R2, R2, R0  @adiciona no r2 o valor do set com o endereço dos regs
        MOV R0, #1      @ 1 bit para o shift
        LDR R3, =\pin   @valor dos endereços dos pinos
        ADD R3, #8      @ Adiciona offset para shift 
        LDR R3, [R3]    @carrega o shift da tabela
        LSL R0, R3      @realiza a mudança
        STR R0, [R2]    @Escreve no registro
.endm