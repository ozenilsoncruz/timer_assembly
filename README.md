# Timer

## Tema
Desenvolvimento de programas usando linguagem Assembly e aplicação de conceitos
básicos de arquitetura de computadores.

## Objetivos de Aprendizagem

Ao final da realização deste problema, o/a discente deverá ser capaz de:
- Programar em Assembly para um processador com arquitetura ARM;
- Entender o conjunto de instruções da arquitetura ARM e saber como utilizá-las de
acordo com a necessidade do sistema;
- Entender como montar uma biblioteca a partir de um código assembly;
- Avaliar o desempenho de um código assembly através de medidas sobre o
comportamento de sua execução no sistema.

## Problema

Desenvolver um aplicativo de temporização (timer) que apresente a contagem num
display LCD. O tempo inicial deverá ser configurado diretamente no código. Além disso,
deverão ser usados 2 botões de controle: 1 para iniciar/parar a contagem e outro para reiniciar
a partir do tempo definido.

Com o objetivo de desenvolver uma biblioteca para uso futuro em conjunto com um
programa em linguagem C, a função para enviar mensagem para o display deve estar
separada como uma biblioteca (.o), e permitir no mínimo as seguinte operações:

1. Limpar display; 
2. Escrever caractere; 
3. Posicionar cursor (linha e coluna).