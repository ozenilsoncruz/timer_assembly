main = display_lcd

$(main): $(main).o
	ld -o $(main) $(main).o
	rm *.o
	
$(main).o: $(main).s
	as -g -o $(main).o $(main).s
