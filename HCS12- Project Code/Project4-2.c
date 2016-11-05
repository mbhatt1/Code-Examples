/**
 * @author Manish Bhatt
 * @param ms
 */

#include <hidef.h>      /* common defines and macros */
#include <mc9s12dg256.h>     /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12dg256b"

#include "main_asm.h" /* interface to the assembly module */

void delayms(int ms) {        		//delay function
  unsigned int a, b;
  for(a = 0; a < ms; a++)      		//for loop based on the input ms value
  for(b = 0; b < 700; b++);   		//for loop based on internal clock of board
}



char getkey1 (void){
  char rmask, cmask, row, col;
  char keycode [16] = {0x01, 0x02, 0x03, 0x0A,
                       0x04, 0x05, 0x06, 0x0B,
                       0x07, 0x08, 0x09, 0x0C,
                       0x0E, 0x00, 0x0F, 0x0D};
  DDRA = 0x0F;                 			  // configure upper pins for input
  for(;;) {
  cmask = 0x01;
  for (col = 0; col < 4; col++){
  rmask = 0x10;
  PORTA = cmask;              		   // select the current col
  for (row = 0; row < 4; row++){		 // scan rows
  if ((PORTA & rmask)){       		   // key switch detected pressed
  delayms(1000);              		   // debounce (delay by 1s)
  if((PORTA & rmask))         		   // check the same key again
  return (keycode[col + row*4]);
  }
  rmask = rmask << 1;
  }
  cmask = (cmask << 1);
  }
  }
} 


void main(){
long int n;
int i; 
float ix = 0.0,duty, period;
char j, scale = 0x06;
char *msg1 = "Period(us):";
char *msg2 = "Duty(%):";
char *msg3 = "Not valid";
char *msg4 = "Displaying...";
char *msg5 = "Go again?";

lcd_init();

type_lcd(msg1);

              
  
n = 0;  
  
getperiod:
    i= getkey1();               		//get key from keypad
    delayms(10);
    
    if(i == 0x0A){              		//if i=A (enter key)
      clear_lcd();                  //clear lcd
      type_lcd(msg2);               //diplay duty message
      delayms(1000);                //diplay message for 1s
      period = n;                   //save period value
      n= 0;                         //reset n to be used for duty
      goto getduty;             		//get duty cycle
    }
    else if (i > 0x0A) {        		//if i not a valid input
      clear_lcd();                  //clear lcd
      type_lcd(msg3);            		//display error message
      delayms(1000);                //display for 1s
      n = 0;                        //reset n
      clear_lcd();
      type_lcd(msg1);
      goto getperiod;               //get period again
    } 
    
    if((n*10+i) > 1360){        		//if n exceeds limit
      clear_lcd();                  //clear lcd
      type_lcd(msg3);            		//display error message
      delayms(1000);                //display for 1s
      n = 0;                        //reset n
      clear_lcd();
      type_lcd(msg1);
      goto getperiod;               //get period again
     }     
    
          
    j= (char)i;                			//turn i into char
    j=j+0x30;                 			//convert hex to ASCII
    data8(j);               			  //display ASCII to LCD

    n = n*10 +i;               			//keep track of decimal value
    goto getperiod;              		//get another key



getduty:
    i= getkey1();               		//get key from keypad
    delayms(10);
    
    if(i == 0x0A){              		//if i=A (enter key)
      clear_lcd();                  //clear lcd
      duty = n;                     //save duty value
      n = 0;                        //reset n
      goto signal;             		  //output signal
    }
    else if (i > 0x0A) {        		//if i not a valid input
      clear_lcd();                  //clear lcd
      type_lcd(msg3);            		//display error message
      delayms(1000);                //display for 1s
      n = 0;                        //reset n
      clear_lcd();
      type_lcd(msg2);
      goto getduty;                 //get duty cycle again
    } 
    
    
    if((n*10+i) > 100){        		  //if n exceeds limit
      clear_lcd();                  //clear lcd
      type_lcd(msg3);            		//display error message
      delayms(1000);                //display for 1s
      n = 0;                        //reset n
      clear_lcd();
      type_lcd(msg2);
      goto getduty;                 //get duty again
     }       
    
    
          
    j= (char)i;                			//turn i into char
    j=j+0x30;                 			//convert hex to ASCII
    data8(j);               			  //display ASCII to LCD

    n = n*10 +i;               			//keep track of decimal value
    goto getduty;              			//get another key

signal:
     
                                    
     
    if(period < 10){
      period= period*24;		          //calculate count
      duty = duty/100;               //calculate duty
      duty = duty*period;
      scale = 0x00;
    }else if(period >680){
      period= period*24;		          //calculate count
     period = period/128;            //calculate count
     duty = duty/100;               //calculate duty
     duty = duty*period;
     scale = 0x07;  
    }else{
     period= period*24;		          //calculate count
     period = period/64;            //calculate count
     duty = duty/100;               //calculate duty
     duty = duty*period;            //calculate duty
     scale = 0x06;
    }
    
    PWMCLK = 0;                     //select clock A as source
    PWMPRCLK = scale;                //set clock A prescaler to 64
    PWMPOL = 1;                     //channel 9 output high at start
    PWMCAE = 0;                     //left-aligned mode
    PWMCTL = 0x0C;                  //8-bit mode, stop in wait and freeze mode
    PWMPER0 = period;               //set period value
    PWMDTY0 = duty;                 //set duty value
    PWME = 0x01;                    //enalbe PWM0 to output signal
  


  while (1){
    type_lcd(msg4);                 //displaying signal
    set_lcd_addr(0x40);
    type_lcd(msg5);                 //ask if want to create new waveform
    
    i= getkey1();               		//get key from keypad
    delayms(10);
    
    if(i == 0x0A){                  //if i=A (enter key)
      clear_lcd();                  //clear lcd
      type_lcd(msg1);               //diplay period message
      delayms(1000);                //diplay message for 1s
      n= 0;                         //reset n 
      goto getperiod;             	//get new period
    
    }else{
      clear_lcd();
    }
    
  
  }                      
}



