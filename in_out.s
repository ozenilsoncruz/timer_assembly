/* Implementacao dos metodos de 
   Leitura (input) e Escrita (print) na tela */


/*======================================================
        Realiza a entrada de dados na tela
  ======================================================
        Registradores utilizados: r0, r1, r2, r7
                obs: r1 carrega o texto

  ------------------------------------------------------*/
.macro input
        mov r0, #1          @ atribui 1 ao r0 para escrever na tela
        ldr r1, =texto      @ dado para impressao
        mov r2, #len_texto  @ tamanho da palavra a ser exidido
        mov r7, #3          @ chamada de sistema para escrita
        swi 0
.endm

/*======================================================
        Realiza a impressao na tela
  ======================================================
        Entradas:
                texto -> texto a ser exibido na tela
                len_texto -> tamanho do texto
        Registradores utilizados: r0, r1, r2, r7
  ------------------------------------------------------*/
.macro print
        mov r0, #1          @ atribui 1 ao r0 para escrever na tela
        ldr r1, =texto      @ dado para impressao
        mov r2, #len_texto  @ tamanho da palavra a ser exidido
        mov r7, #4          @ chamada de sistema para escrita
        swi 0 
.endm

@ variaveis utilizadas no codigo
.data
    texto: .ascii "%s\n"
    len_texto = .-texto