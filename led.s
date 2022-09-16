@ Acende e apaga um LED em um intervalo de tempo

.section .init

.global _start

_start: acende
        apaga

    ldr r0, =0x20200000 @ carrega o endereco os onde registradores do controlador GPIO são mapeados na memória
    
    @   GPFSEL ->       byte 0 a 27
    mov r1, #1          /* atribui o valor 1 para configurar um pino de saida -> 32 bits
                           r1 = 00 000 000 000 000 000 000 000 000 000 001 */
    lsl r1, #15         /* realiza um deslocamento logico para a esquerda de 15 bits que corresponde ao 6 pino
                           r1 = 00 000 000 000 000 001 000 000 000 000 000 */
    str r1, [r0, #0]    @ armazena o conteudo de r1 em um local da memoria dado por r0+0 bytes
    
    mov r6, #10
    loop:
        acende          @ GPSET0 ->       byte 28
        nanoSleep       @ aguarda 1 segundo
        apaga           @ GPCLR0 ->       byte 40 
        subs r6, #1
    bne loop            @loop infinito
_end:   
    mov r0, #0
    mov r7, #1
    svc 0


.macro nanoSleep
    ldr r0, =timesec    @segundos
    ldr r1, =timenano   @nanossegundos
    mov r7, #162        @ funcao sleep do Linux
    swi 0

.macro acende
    mov r1, #1
    lsl r1, #6          @ realiza um deslocamento logico para a esquerda de 6 bists, referente ao pino a ser ativado              
    str r1, [r0, #28]   @ armazena o conteudo de r1 em um local da memoria dado por r0+28 bytes

.macro apaga
    mov r1, #1
    lsl r1, #6          @ realiza um deslocamento logico para a esquerda de 6 bists, referente ao pino a ser ativado              
    str r1, [r0, #40]   @ armazena o conteudo de r1 em um local da memoria dado por r0+28 bytes


.data timesec:   .word 1 @ 1 segundos
      timenano:  .word 000000000 @ 0 nanossegundos
