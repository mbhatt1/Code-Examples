@author: Manish Bhatt, Yessica Carrasco

Project 5
Due T 11/16

You will work in groups of no more than 3 using 2 Dragon12 boards. You will use SCI to control the LCD and 7SDs of the other board, using the keypad and DIP switch of your board. 

Full duplex SCI: Identify the pins used for serial communications and connects the boards so that they communicate with each other simultaneously. Each board should be able to control the other board at the same time. 

Controlling LCD: Anything you press on the keypad of your board must be displayed on the LCD of the other board. Use the * to clear the display and # to jump to the second line. If you press # and you are on the second line it should clear the LCD and start from beginning. 

The LCD must wrap text: if it reaches the end of line, it should continue on second line. If it reaches end of second line it should clear LCD and continue on first line. 

Controlling 7SDs: The DIP switch settings on your board will be displayed as a hex number on the other LCD. E.g. if the DIP setting are: 10101010 the 7SD should display AA. 

Before presenting your work, hand-in a printout of your code.


Project 4
Due 5pm Mon 11/2. You can use the digital scopes and digital function generator that are available for loanfrom.

Write a program that will measure the period and duty cycle of a digital input signal and display that information on the LCD. Use interrupts to capture events of the ECT. Use a function generator to test the limitations of your code. 
Write a program that will generate a periodic digital signal with varying duty cycle. Use interrupts to time events of the ECT.The period and duty cycle should be entered via the keypad. Use the oscilloscope to capture and view the output signal.
You'll demonstrate your project to your instructor. Print (and staple) your code prior to your demo.


Project 3
Fri 10/9 

 Write a program that will prompt the user to enter a a number in decimal using the keypad on your Dragon12 board. The number will be converted to hex and displayed on the screen. 

The program should: 

Prompt: input,output on LCD. Display a prompt for input (e.g. "Enter a decimal number:", prompt before output (e.g. "Hex conversion:" ). 
Each: Display the keys that are being pressed. 
Identify erroneous input: If the user hits the keys A,B,C,D, * or #, then an error message will appear and the user will be asked to enter a number number.
Detect overflow: specify the max range needed and if the calculation exceeds the max range then output an error. Max range is 65535. 
Debounce keys: overcome debouncing effects. 
You may NOT use built in functions. There will be no report. However, you must demo your code. Printout a copy of your code before demo. Demos will be after class in the circuits lab.

