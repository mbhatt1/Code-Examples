/**
 * @author Manish Bhatt
 * @param ms
 */

//#include <hidef.h>      /* common defines and macros */
#include <mc9s12dg256.h>     /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12dg256b"

#include "main_asm.h" /* interface to the assembly module */


#define LCD_DAT PORTK          // Port K drives LCD data pins, E, and RS
#define LCD_DIR DDRK           // Direction of LCD port
#define LCD_E 0x02             // E signal
#define LCD_RS 0x01            // RS signal
#define LCD_E_RS 0x03          // both E and RS signals


void delayms(int ms) {         //delay function
  unsigned int a, b;
  for(a = 0; a < ms; a++)      //for loop based on the input ms value
  for(b = 0; b < 700; b++);    //for loop based on internal clock of board
}


void putcLCD(char cx) {        //display a single char to LCD
  char temp;
  temp = cx;
  LCD_DAT |= LCD_RS;           // select LCD data register
  LCD_DAT |= LCD_E;            // pull E signal to high
  cx &= 0xF0;                  // clear the lower four bits
  cx >>= 2;                    // shift to match the LCD data pins
  LCD_DAT = cx|LCD_E_RS;       // output upper four bits, E, and RS
  asm("nop");                  // dummy statements to lengthen E
  asm("nop");
  asm("nop");
  LCD_DAT &= (~LCD_E);         // pull E to low
  cx = temp & 0x0F;            // get the lower four bits
  LCD_DAT |= LCD_E;            // pull E to high
  cx <<= 2;                    // shift to align the LCD data pins
  LCD_DAT = cx|LCD_E_RS;       // output lower four bits, E, and RS
  asm("nop");                  // dummy statements to lengthen E
  asm("nop");
  asm("nop");
  LCD_DAT &= (~LCD_E);         // pull E to low
  delayms(1);
}

void putsLCD (char *ptr) {     //display a string of characters to LCD
  while (*ptr) {               //checks for end of string (null character)
  putcLCD(*ptr);               //send each individual char to putcLCD
  ptr++;                       //go to next char
  }
}

void cmd2LCD (char cmd) {      //send a command to LCD
  char temp;
  temp = cmd;                  // save a copy of the command
  cmd &=0xF0;                  // clear out the lower four bits
  LCD_DAT &= (~LCD_RS);        // select LCD instruction register
  LCD_DAT |= LCD_E;            // pull E signal to high
  cmd >>= 2;                   // shift to match LCD data pins
  LCD_DAT = cmd | LCD_E;       // output upper four bits, E, and RS
  asm ("nop");                 // dummy statements to lengthen E
  asm ("nop");                 
  asm ("nop");                 
  LCD_DAT &= (~LCD_E);         // pull E signal to low
  cmd = temp & 0x0F;           // extract the lower four bits
  LCD_DAT |= LCD_E;            // pull E to high
  cmd <<= 2;                   // shift to match LCD data pins
  LCD_DAT = cmd | LCD_E;       // output upper four bits, E, and RS
  asm("nop");                  // dummy statements to lengthen E
  asm("nop");
  asm("nop");
  LCD_DAT &= (~LCD_E);         // pull E clock to low
  delayms(1);                  // wait until the command is complete
}


void openLCD(void) {           
  LCD_DIR = 0xFF;              // configure LCD_DAT port for output
  delayms(10);
  cmd2LCD(0x28);               // set 4-bit data, 2-line display, 5x7 font
  cmd2LCD(0x0E);               // turn on display, cursor, not blinking
  cmd2LCD(0x06);               // move cursor right
  cmd2LCD(0x01);               // clear screen, move cursor to home
  delayms(2);                  // wait until "clear display" command is complete
} 


char getkey1 (void){
  char rmask, cmask, row, col;
  char keycode [16] = {0x01, 0x02, 0x03, 0x0A,
                       0x04, 0x05, 0x06, 0x0B,
                       0x07, 0x08, 0x09, 0x0C,
                       0x0E, 0x00, 0x0F, 0x0D};
  DDRA = 0x0F;                 // configure upper pins for input
  for(;;) {
  cmask = 0x01;
  for (col = 0; col < 4; col++){
  rmask = 0x10;
  PORTA = cmask;               // select the current col
  for (row = 0; row < 4; row++){ // scan rows
  if ((PORTA & rmask)){        // key switch detected pressed
  delayms(1000);               // debounce (delay by 1s)
  if((PORTA & rmask))          // check the same key again
  return (keycode[col + row*4]);
  }
  rmask = rmask << 1;
  }
  cmask = (cmask << 1);
  }
  }
} 


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

void main(void) {


unsigned int i,b;
unsigned long int n, q, k[3];
char j=0;


char *msg1,*msg2,*msg3,*msg4;   //messages to display
  
msg1 = "Enter decimal:";
msg2 = "Hex conversion:";
msg3 = "Not valid input";
msg4 = "Max range 65535";

start:

n = 0;                          //initialize to 0
q = 5;                          //initialize to not 0

openLCD();                      //turn LCD on
cmd2LCD(0x01);                  //clear LCD
delayms(10);                    //wait of LCD to clear
putsLCD(msg1);                  //display first message
cmd2LCD(0xC0);                  //go to second line
  
  
  while (1) 
  {
    
keyin:
    i= getkey1();               //get key from keypad
    delayms(10);                //wait to ensure debounce
    
    if(i == 0x0A){              //if i=A (enter key)
      goto dec2hex;             //convert decimal to hex
    }
    else if (i > 0x0A) {        //if i not a valid input
      
      cmd2LCD(0x01);            //clear LCD
      delayms(10);              //wait for LCD to be cleared
      putsLCD(msg3);            //display third message
      exit();                   //exit program
    } 
        
     if((n*10+i) > 0xFFFF){     //if n exceeds limit
      cmd2LCD(0x01);            //clear LCD
      delayms(10);              //wait for LCD to be cleared
      putsLCD(msg4);            //display message 4
      exit();
     }       
          
     j= (char)i;                //turn i into char
     j=j+0x30;                  //convert hex to ASCII
     putcLCD(j);                //display ASCII to LCD


     n = n*10 +i;               //keep track of decimal value
     delayms(5);
     goto keyin;                //get another key
    

dec2hex:                        

    cmd2LCD(0x01);              //clear LCD
    delayms(10);                //wait for LCD to clear
    putsLCD(msg2);              //display message 2
    cmd2LCD(0xC0);              //go to second line

    b = 0;                      //set b to 0
    while(q != 0){              //while quotient is not 0    
        q = n/16;               //quotient is equal to number/16
        k[b] = n%16;            //store remainder in array     
        n /= 16;                //new number value
        b ++;                    
     }
             
     while(b !=0){              //display array values to LCD
      b --;                     //decrease b
      if(k[b] < 10){            //if number add 0x30 for ASCII
        k[b] = k[b] + 0x30;
      } else{                   //if letter add 0x37 for ASCII
        k[b] = k[b] + 0x37;
      } 
      putcLCD((char)k[b]);      //display ASCII to LCD
     }
     exit();


  }
}
