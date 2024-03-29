;*****************
;*** ZEGAR.ASM *** 
;*****************
.286C 
ASSUME cs:CODE 
 
CODE SEGMENT 
        org  100h 
Start: 
        jmp  Install 
 
wsk     db 0 
old8o   dw 0 
old8s   dw 0 
        dw 'AB'     ;'AB' - do sprawdzenia, czy program jest 
                    ;ju� zainstalowany 
;--------------------------------------------     
;--- Nowa procedura obs�ugi przerwania ------ 
;--------------------------------------------
Zegar: 
        pushf                ;umie�� na stosie znaczniki 
        call ��dword ��ptr �cs:[old8o] �;wywo�aj �star� �obs�ug� 
                                        ;przerwania 8h 
        inc  wsk             ;zwi�ksz wska�nik 
        cmp  wsk,18          ;je�li min�� 18, to 
        jne  Wyskok           
        mov  wsk,0           ;wypisz nowy czas 
        pusha                ;zapami�taj rejestry 
        push ds 
        push es 
        mov  dx,0b800h       ;pami�� ekranu 
        mov  es,dx 
        mov  di,142          ;offset miejsca wy�wietlania 
        mov  ah,02h          ;odczyt czasu 
        int  1ah 
        push cs 
        pop  ds 
        ;---Pisz kolejne liczby--- 
        mov  al,ch 
        call Pisz            ;pisz godzin� 
        call Dwukropek 
        mov  al,cl     
        call Pisz            ;pisz minuty 
        call Dwukropek 
        mov  al,dh             
        call Pisz            ;pisz sekundy  
        ;***
        pop  es         
        pop  ds 
        popa 
Wyskok:         
        iret 
;Procedura wypisuj�ca liczb� w kodzie BCD zawart� w AL         
Pisz PROC  
        mov  ah,al 
        push cx 
        mov  cl,4       ;przekszta�� liczb� w kodzie BCD na 
        shl  al,cl      ;dwie binarne zawarte w AH i AL
        shr  al,cl 
        shr  ah,cl 
        pop  cx 
        add  ax,'00' 
        mov  byte ptr es:[di+1],01110000b  ;atrybut 
        mov  byte ptr es:[di+3],01110000b  ;atrybut 
        mov  es:[di],ah 
        mov  es:[di+2],al 
        add  di,4 
        ret 
     ENDP 
      
Dwukropek PROC 
        mov  byte ptr es:[di+1],01110000b  ;atrybut 
        mov  byte ptr es:[di],':' 
        add  di,2 
        ret 
        ENDP                      
;---------------------------------------------- 
Install: 
        call Czy_juz_jest            ;sprawd�, czy program ju� 
                                     ;jest zainstalowany    
        mov  ax,3508h                ;odczytaj adres procedury 
        int  21h                     ;obslugi przerwania 8h 
        mov  Old8s,es                ;i zapami�taj go 
        mov  Old8o,bx 
        push cs 
        pop  ds 
        mov  dx,offset zegar         ;ustaw nowy adres procedury 
        mov  ax,2508h                ;obs�ugi przerwania  
        int  21h 
        push cs 
        pop  ds         
        mov  dx,offset Hej 
        mov  ah,09h                  
        int  21h                ;wypisz komunikat  
        mov  dx,offset install  ;wyjd� i zostaw wszystko przed 
        int  27h                     ;adresem INSTALL 
;--------------------------------         
Czy_juz_jest: 
        mov  ax,3508h 
        int  21h 
        cmp  es:[bx-2],'AB'   ;Sprawd�, czy przed procedura 
                              ;obs�ugi przerwania znajduje si� 
                              ;'AB' 
        jne  Nie_ma           ;jesli nie, to instaluj 
        jmp  Czy_parametry    ;jesli tak, to sprawd� paramerty 
Nie_ma: 
        ret 
;--------------------------------        
Czy_parametry: 
        mov  bx,80h                  ;pobierz licznik 
        mov  cl,[bx]                 ;parametr�w  
        cmp  cl,0 
        je   Bez_prm                   
        jmp  Usun                   ;jesli jest, to usu� program 
                                    ;z pami�ci 
Bez_prm: 
        push cs 
        pop  ds 
        mov  dx,offset JuzJest 
        mov  ah,09h 
        int  21h 
        mov  ax,4c01h 
        int  21h 
;--------------------------------         
Usun: 
        mov  ax,3508h 
        int  21h           ;pobierz adres procedury obs�ugi 8h 
        mov  ds,es:[bx-4]  ;ustaw �adres �poprzedniej �procedury 
                           ;obslugi 
        mov  dx,es:[bx-6] 
        mov  ax,2508h 
        int  21h 
        mov  �ah,49h         �;zwolnij �pami�� �zajmowan� �przez 
                              ;program 
        int  21h 
        push cs 
        pop  ds 
        mov  dx,offset Deinst 
        mov  ah,09h 
        int  21h 
        mov  ax,4c01h 
        int  21h           
         
JuzJest db 'Zegar jest JUZ zainstalowany.',13,10,'$' 
Hej     db 'Zegar zainstalowany.',13,10,'$' 
Deinst  db 'Zegar zdeinstalowany.',13,10,'$' 
         
CODE ENDS 
 
END Start             
