@Definicao de macros para o mapeamento da mamoria


@ constantes importantes para o programa
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