/**
 * @author Manish Bhatt
 */
#include <hidef.h>           /*Common defines and macros */
#include <mc9s12dg256.h>     /*Derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12dg256b"

void main(void){
                                   
unsigned long int edge1,edge2, edge3, period, duty;
unsigned long int r = 0, q = 0, i, n =0;
unsigned  int k[8] = {0,0,0,0,0,0,0,0};
char *msg1 = "period(ms):";
char *msg2 = "period(us):" ;
char *msg3 = "Duty:" ;
char *percent = "%";
char scale = 0x06;

 
begin:  
  TSCR1 = 0x90;		               //enable timer counter
  TIOS  = 0x00;			             //enable input-capture 0
  TSCR2 = scale;		             //disable TCNT overflow interrupt
  TCTL4 = 0x01;		               //capture rising edge
  TFLG1 = 0x00;		               //clear flags register
  

  while(!(TFLG1 & 0x01)){}		   //wait until rising edge
  edge1 = TC0;				           //save first rising edge
 
                                //decrease prescaler by 1
                                //if count less than value
  if((edge1 < 2000) || (edge1 < 1000)|| (edge1 < 500)|| (edge1 < 200) ||(edge1 < 100) || (edge1 < 50 )){
    if(scale == 0x00){          //if prescaler already 1 skip
      goto skip;
    }     
    scale = scale - 1;          //decrease prescaler by 1
    goto begin;                 //take input again
  }

skip:
  
  TCTL4 = 0x02;		               //caputre falling edge
  while(!(TFLG1 & 0x01)){}		   //wait until falling edge
  edge2 = TC0;				           //save first falling edge


  TCTL4 = 0x01;		               //detect second rising edge
  while(!(TFLG1 & 0x01)){}		   //wait until edge detected
  edge3 = TC0;                   //save value


  period =  edge3 - edge1;       //calculate period
  duty = (edge2 - edge1);        //calculate duty cycle
  duty = duty*100;               //calculate duty cycle
  duty = duty/period;            //calculate duty cycle

  lcd_init ();                   
  if(scale == 0){                //if prescaler is 1
    period = period *1;          //multiply period by scaler
    period = period/24;          //divide by 24 for us
    type_lcd(msg2);
  }
                

  if(scale == 0x01){             //if prescaler is 2
    period = period *2;          //multiply period by scaler
    period = period/24;
    type_lcd(msg2);
  }
                  
  if(scale == 0x02){             //if prescaler is 4
    period = period *4;          //multiply period by scaler
    period = period/24;          //divide by 24 for us
    type_lcd(msg2);
  }
                  
  if(scale == 0x03){             //if prescaler is 8
    period = period *8;          //multiply period by scaler
    period = period/24;          //divide by 24 for us
    type_lcd(msg2);
  }
                  
  if(scale == 0x04){             //if prescaler is 16
    period = period *16;         //multiply period by scaler
    period = period/24;          //divide by 24 for us
    type_lcd(msg2);
  }
                  
  if(scale == 0x05){             //if prescaler is 32
    period = period *32;         //multiply period by scaler
    period = period/24000;       //divide by 24000 for ms
    type_lcd(msg1);
  }
                 
  if(scale == 0x06){             //if prescaler is 64
    period = period *64;         //multiply period by scaler
    period = period/24000;       //divide by 24000 for ms
    type_lcd(msg1);
  }
                   

  do  {                          //convert period from hex to dec
    q = period/10;               
    r = period%10;               
    k[n] =r;                     //store values to be displayed
    period /= 10;                
    n++;                         //increase index
  }while(q != 0);                
                        
                                                   
  while (n != 0 )  {             //display decimal value of period
    k[n-1] = (char)k[n-1];       //convert to char
    k[n-1] = k[n-1]  + 0x30;     //convert to ASCII
    data8(k[n-1]);               //display to LCD
    n--;                         
  }
  
  
  n= 0;                          //reset n
  do  {                          //convert duty from hex to dec
    q = (duty/10);               
    r =(duty%10);                
    k[n] =r;                     //store values to be displayed
    duty /= 10;                   
    n++;                         //Increment index
  }while(q != 0);               
  
  set_lcd_addr(0x40);
  type_lcd(msg3);

                                                    
  while (n != 0 )  {              //display decimal value of duty
    k[n-1] = (char)k[n-1];        //convert to char
    k[n-1] = k[n-1]  + 0X30;      //convert to ASCII
    data8(k[n-1]);                //display to LCD
    n--;                          
  }

  type_lcd(percent);


}


