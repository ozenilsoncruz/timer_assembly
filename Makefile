nome = display_lcd

$(nome): $(nome).o
	ld -o $(nome) $(nome).o

$(nome).o: $(nome).s
	as -g -o $(nome).o $(nome).s

clean:
  rm *.o
