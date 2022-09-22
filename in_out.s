/* Implementacao dos metodos de 
   Leitura (input) e Escrita (print) na tela */


.macro input
    mov r0, #0            @ atribui 0 a r0 para receber dados do teclado
    mov r7, #3            @ chamada de sistema para leitura
    ldr r1, =texto        @ dado recebido
    ldr r2, =len_texto    @ tamanho da palavra lida
    
    mov r7, #1          @ termina os processos
    swi 0
.endm

.macro print
    mov r0, #1          @ atribui 1 ao r0 para escrever na tela
    mov r7, #4          @ chamada de sistema para escrita
    ldr r1, =texto      @ dado para impressao
    ldr r2, =len_texto  @ tamanho da palavra a ser exidida

    mov r7, #1          @ termina os processos
    swi 0
.endm
    

.data
    texto: .asciiz "%s"
    len_texto = .-texto