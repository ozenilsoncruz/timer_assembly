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

## LCD




### Especificação

Ao todo, o LCD possui 16 pinos, dispostos dessa forma:

- **1** negativo
- **2** positivo tensão de alimentação de 5 volts
- **3** contraste do caractere na tela
- **4** controle
- **5** enviar ou ler dados
- **6** enviar comando dos pinos de dados
- **7 - 14** pinos de entrada de dados
- **15 e 16** controlar o backlight, quando disponível

### Arquitetura interna

Além da pinagem, vale ressaltar que o LCD tem 3 módulos de memória para diferentes usos, são esses:

**CGROM _(Character Graphics Read only Memory)_:** Esta ROM faz parte do microcontrolador de exibição no LCD e armazena todos os padrões padrão para os caracteres de matriz de pontos de 5 x 7. Por exemplo: se quisermos exibir o caractere "A", precisamos enviar o código ASCII 65 (decimal) para o DDRAM. O controlador de exibição procura o padrão de pontos a ser exibido para este código no CGROM e acende os apropriados para "A".

<div id="fpga" style="display: inline_block" align="center">
			<img src="/resource/TABLE.png"/><br>
		<p>
		<b>Imagem 01</b> - Tabela de variações para caracteres do LCD <b>Fonte:</b> <a href="https://www.sparkfun.com/datasheets/LCD/HD44780.pdf">Datasheet HD44780U </a>
		</p>
	</div>

**CGRAM:** possibilita a criação de caracteres especiais

**DDRAM:** RAM para escrita na tela do display

## Conclusão
