display_lcd: display_lcd.o
	ld -o display_lcd display_lcd.o

display_lcd.o: display_lcd.s
	as -g -o display_lcd.o display_lcd.s

clean:
  rm -i *.o *~
