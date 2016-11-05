/**
 * @author Manish Bhatt
 */
#include <hidef.h>      /* common defines and macros */
#include <mc9s12dg256.h>     /* derivative information */
#pragma LINK_INFO DERIVATIVE "mc9s12dg256b"

#include "main_asm.h" /* interface to the assembly module */



void main(void) {
  unsigned int i;
  char k;
  char address=0x00;
  int HexMSB, HexLSB;
  char DipsValue, KeyReceived, TrandRe = 0XA0, Transmit = 0X80, Receive = 0X20;  
  unsigned char Display[16] = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7C, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71};

  
 
  

  SCI0CR1 = 0x4C;    // Disabled in wait mode, Address mark wakeup,
                     // Idle Char bit count begins after stop bit 
  SCI1CR1 = 0x4C;    // Disabled in wait mode, Address mark wakeup,
                     // Idle Char bit count begins after stop bit 
  
  
  SCI0CR2 = 0x0C;    // Transmitter enabled, Receiver Enabled 
  SCI1CR2 = 0x0C;    // Transmitter enabled, Receiver Enabled 

                     // Desired Baurd Rate = 9600, at Master SCI clock of 8 MHz
                     // 9600 = (8 * 10 ^ 6)/ (16 * BRD);
                     // BRD = 52
  SCI0BDH = 0X34;      // SCI0 at 9600 Baud Rate
  SCI1BDH = 0X34;      // SCI0 at 9600 Baud Rate
  
  seg7_enable();
  DDRB = 0xFF;       //port B outputs for 7sd
  DDRP = 0x0F;      //port P 3 - 0 for 7sd selection
  DDRH = 0x00;       //port H to read dips
  lcd_init();
  keypad_enable();
  
            
while(1){

    DipsValue = (~PTH);
    while(!(SCI1SR1 & TrandRe));
      if(SCI1SR1 & Transmit){
        SCI1DRL = DipsValue;
      }
       
      if(SCI1SR1 & Receive){
        HexLSB = SCI1DRL % 16;     //least sig bit in hex
        HexMSB = SCI1DRL / 16;     //most sig bit in he
        PTP = 0x0B;               //common cathode activated for MSB
        PORTB = Display[HexMSB];
        ms_delay(5);
        PTP = 0x07;               //common cathode for LSB
        PORTB = Display[HexLSB];
        ms_delay(5);
       
       
        set_lcd_addr(address);
        i = keyscan();
        k = (char) i;
  
  
        while(!(SCI0SR1 & TrandRe));

        if(SCI0SR1 & Transmit){
          if(i != 16){
        
          wait_keyup(); 
          SCI0DRL = k;
          }
        } 
        if(SCI0SR1 & Receive){
          KeyReceived = SCI0DRL;
    
          if (KeyReceived == 0x0F){           //if # or *
            if (address > 0x0F){              //if on second line or *
              ms_delay(100);
              clear_lcd();
              address = 0x40; 
            }
            
            else  {
        
              address = 0x40;  
            } 
            }
    
        else if (KeyReceived == 0x0E)  {
      
          ms_delay(100);
          clear_lcd();
          address = 0x00;    
        }
        else {
          hex2lcd(KeyReceived);
          address++ ; 
        }
        }
      
        if(address==0x51){  
          ms_delay(500);
          clear_lcd();
          ms_delay(10);
          hex2lcd(KeyReceived);
          address = 1;
         }
    
    
        if(address==0x10)  {
      
          address=0x40; 
        }
      }
    }    
}
        