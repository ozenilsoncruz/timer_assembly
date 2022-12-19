# Timer

<details>
<summary>Texto do Problema</summary>

---

## Tema

Desenvolvimento de programas usando linguagem Assembly e aplicação de conceitos
básicos de arquitetura de computadores.

## Objetivos de Aprendizagem

Ao final da realização deste problema, o/a discente deverá ser capaz de:

- Programar em Assembly para um processador com arquitetura ARM;
- Entender o conjunto de instruções da arquitetura ARM e saber como utilizá-las de acordo com a necessidade do sistema;
- Entender como montar uma biblioteca a partir de um código assembly;
- Avaliar o desempenho de um código assembly através de medidas sobre o comportamento de sua execução no sistema.

## Problema

Desenvolver um aplicativo de temporização (timer) que apresente a contagem num display LCD. O tempo inicial deverá ser configurado diretamente no código. Além disso, deverão ser usados 2 botões de controle: 1 para iniciar/parar a contagem e outro para reiniciar a partir do tempo definido.

Com o objetivo de desenvolver uma biblioteca para uso futuro em conjunto com um programa em linguagem C, a função para enviar mensagem para o display deve estar separada como uma biblioteca (.o), e permitir no mínimo as seguinte operações:

1. Limpar display;
2. Escrever caractere;
3. Posicionar cursor (linha e coluna).

---

</details>

### Autores
<div align="justify">
  <li><a href="https://github.com/traozin">@Antônio Neto</a></li>
  <li><a href="https://github.com/ozenilsoncruz">@Ozenilson Cruz</a></li>
</div>

### Instruções

1. Em uma Raspiberry Pi Zero W, clone o repositório.
   ```sh
   git clone https://github.com/ozenilsoncruz/timer_assembly
   ```
2. Dentro da pasta execute os passos abaixo:
    1. Makefile:
          ```sh
          make
          ```
    2. Script 
          ```sh
          sudo ./temporizador
          ```
## LCD

### Especificação

Ao todo, o LCD possui 16 pinos, dispostos dessa forma:

- **1** GND
- **2** VCC(Tensão 5V)
- **3** controle de contraste dos caracteres
- **4** controle para qual tipo de comando
- **5** enviar ou ler dados
- **6** enviar comando dos pinos de dados
- **7 - 14** pinos de entrada de dados
- **15 e 16** responsáveis por controlar o backlight, quando disponível (Vcc e GND respectivamente)

### Arquitetura interna

Além da pinagem, vale ressaltar que o LCD tem 3 módulos de memória para diferentes usos, são esses:

**CGROM _(Character Graphics Read only Memory)_:** 

Essa ROM faz parte do microcontrolador de exibição no LCD e armazena todos os padrões padrão para os caracteres de matriz de pontos de 5 x 7. Por exemplo: se quisermos exibir o caractere "A", precisamos enviar o código ASCII 65 (decimal) para o DDRAM. O controlador de exibição procura o padrão de pontos a ser exibido para este código no CGROM e acende os apropriados para "A".

<div id="fpga" style="display: inline_block" align="center">
			<img src="/resource/TABLE.png"/><br>
		<p>
		<b>Imagem 01</b> - Tabela de variações para caracteres do LCD <b>Fonte:</b> <a href="https://www.sparkfun.com/datasheets/LCD/HD44780.pdf">Datasheet HD44780U </a>
		</p>
	</div>

**CGRAM _(Character Graphics Random Access Memory)_:** 

Permite que o usuário defina tipos de caracteres não padronizados suplementares especiais que não estão no CGROM. Você pode carregar suas próprias formas de padrão de pontos, por exemplo. um retângulo em CGRAM e usando certos códigos reservados em DDRAM, chame-os para exibição.

**DDRAM _(Data Display Random Access Memory)_:** 

É o buffer de dados do display. Cada caractere no visor tem uma localização DDRAM correspondente e o byte carregado no DDRAM controla qual caractere é exibido.


## Soluções

### Verificação de erros

O temporizador utiliza um algoritmo para subtrair strings. Para isso, afim de evitar erros, antes de iniciar a contagem são verificados os caracteres inseridos na string. Se for maior que a capacidade de exibição do display ou se algum dos caracteres não for um número com representação ASCII, um erro é lançado no display LCD e no monitor.
O código que realiza essas funções pode ser visto abaixo.

```s
@------------------ VERFICAÇÃO DE ERROS ------------------@
    @ verifica se o numero esta dentro do limite permitido
    verificacao_erros:
        mov r9, #len_num
        cmp r9, #32
        bgt _erro1                  @ se for maior, que 32, erro!
    ldr r10, =num               @ passa o valor do num para r10
    @ varifica se a string contem apenas numero
    verificacao_num:            @ loop que percorre cada caracter
        sub r9, #1
        ldrb r11, [r10, r9]     @ Load Register Byte 
                                @ carrega 1 byte na posicao indicada
        @ se for menor que 48 ou maior que 57, desvia para informar que nao e um numero
        cmp r11, #48 @'0'
        blt _erro2
        cmp r11, #57 @'9' 
        bgt _erro2
        cmp r9, #0      @ compara com o tamanho do caractere -1
        ble iniciar    @ se for menor ou igual a zero, devia para o contador
    b verificacao_num
```

### Contador

Para subtrair a string o algoritimo utiliza a lógica de uma subtração simples:
1. Carrega a String em um registrador com o comando ldr;
2. Em um loop, seleciona cada byte da String (Cada caractere ocupa 1 byte) com o comando ldrb;
3. Verifica se o último digito é 0, se não for, subtrai 1;
4. Se for 0, verifica o anterior e adiciona 9;
5. O processo de verificação dos anteriores só é encerrado após encontrar um digito maior que 0;
6. Carrega o valor de volta na variável definida
7. O loop é encerrado quando todos os caracteres são iguais a 0;
```s
    ...

@------------------------------- CONTADOR -------------------------------@
    contador:
        print pular_linha len_pular_linha
        print num len_num		       @ mostra na tela do computador
        print pular_linha len_pular_linha
	
	setString msg_inicial len_msg_inicial  @ mostra um mensagem no display
	
        nanoSleep segundo      @ aguarda 1 segundo
        mov r9, #len_num
        sub r9, #1                  @ subtrai 1 de r9 para ser igual a posicao do ultimo caractere
        ldrb r11, [r10, r9]         @ carrega o byte especificado
        cmp r11, #48
        bne subtrai
        
        cmp r9, #0                  @ se r9 for 0, todos os caracteres foram percorridos, logo, contagem acabou
        beq _fim                    @ desvia para encerrar o contador
        mov r11, #57                @ adiciona o digito 9 ao registrador r1   
        strb r11, [r10, r9]         @ registra no byte especificado
        loop_anteriores:            @ faz um loop de todos os anteriores ate que encontre um inteiro
                sub r9, #1              @ remove 1 de r6 para selecionar o byte anterior
                        ldrb r11, [r10, r9]     @ carrega o byte especificado
                        cmp r11, #48            @ compara com '0'
                        bne subtrair_anterior   @ se nao for 0, subtrai 1
                        @ verifica se r6 e zero, se for, remove
                        cmp r9, #0
                        bne verificar_1
                        @ se chegar em r9 = 0 e o valor contidor for '0', encerra o loop
                b _fim
                verificar_1:
                        cmp r11, #48
                        bne subtrair_anterior
                        mov r11, #57
                        strb r11, [r10, r9]
                b loop_anteriores
                subtrair_anterior:
                        sub r11, #1         @ subtrai 1
                        strb r11, [r10, r9]
                b contador
        b loop_anteriores
        subtrai:
            sub r11, #1             @ se r11 nao for igual a zero, subtrai 1
            strb r11, [r10, r9]     @ registra no byte especificado
    b contador
```
### Botões

Os botões são utilizados para executar diferentes ações durante a execução do sistema. O contador só começa a decrementar após o botão no pino 19 ser pressionado. Além disso, após a execução do contador o usário pode pausar ou reiniciar a contagem. Dentro do contador na label 'botoes' temos a verificação se algum dos botões foi pressionado novamente. Se for o botão do pino 19 novamente, a contagem é pausada. Se for o do pino 26, a contagem recomeça.

```s
    iniciar:
        GPIOReadRegister pin19
        cmp r0, r3
        bne contador
    b iniciar
   
    ...
   
    botoes:
	@ verifica se o botao do pino 19 foi precionado novamente, se sim, pausa
	GPIOReadRegister pin19
	cmp r0, r3
	bne iniciar
	@ verifica se o botao do pino 26 foi precionado, se sim, reinicia
	GPIOReadRegister pin26
	cmp r0, r3
	bne _start
```

### Setar caracteres no display

O display funciona seguindo a mesma codificação da tabela ASCII, sendo assim, para exibir qualquer mensagem no display, basta percorrer cada caractere, selecionar cada bit e setar na ordem correta no display.
O código abaixo possui dois loops, um para selecionar o byte correspondente e outro para selecionar o bit. Para selecionar o bit foi utilizado um 'and' para filtrar apenas o bit especifico e lsr para deslocar o bit de comparação a cada iteração.

```s
    loop_byte:                  @ loop que percorre cada caracter
	ldrb r11, [r10, r9]     @ Load Register Byte 
			    @ carrega 1 byte na posicao indicada
	@ passa o caractere para ser exibito no display
	mov r6, #7               @ variavel de controle para considera apenas 8 bits
	mov r12, #256            @ variavel auxiliar que define qual bit esta ativo
	loop_bit:                @ percorre todos os 8 bits do bit para sabe o nivel logico
		lsr r12, #1      @ desloca o bit para a direita  ex: 100000000 -> 
		and r4, r12, r11 @ faz um and entre r1 e r3 para saber se o bit esta ativo ou nao
		cmp r4, #0
		beq switch 	 @ se for igual a 0 valor nao sera alterado, se for diferente r2 = 1            
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
			b retornar @ pula os outros casos
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
	displayShift             @ move o cursor para a direita
	cmp r9, r13              @ compara com 0
     bne loop_byte
```

|.......................................................... :arrow_up: [Voltar ao topo](#IoTPlatform) :arrow_up: ..........................................................| :arrow_right: [Próximo Problema](https://github.com/traozin/IOInterface) |
| :----: |-----|
