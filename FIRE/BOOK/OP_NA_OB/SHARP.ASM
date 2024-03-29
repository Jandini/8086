;*****************
;*** SHARP.ASM *** 
;*****************
Sharp PROC 
     mov  dx,SHARPS      ;Segment roboczy 
     mov  es,dx 
     mov  dx,0a000h      ;Wyostrzanie obrazu na ekranie 
     mov  ds,dx 
     mov  si,0 
     mov  di,0 
     mov  cx,64000       ;Ca�y ekran 
Go: 
     mov  bx,0           ;BX b�dzie sum� intensywno�ci 
     sub  si,321 
     push cx 
     mov  cx,3 
     ;Oblicz �sum� �intensywno�ci �kolor�w 9 punkt�w (aktualny w 
     ;�rodku) i odejmij intensywno�� koloru punktu aktualnego 
Dodaj: 
     lodsb 
     cbw 
     add  bx,ax 
     lodsb 
     cbw
     add  bx,ax 
     lodsb 
     cbw 
     add  bx,ax 
     add  si,317         ;Zejd� lini� ni�ej 
     loop Dodaj 
     sub  si,639 
     lodsb 
     cbw 
     sub  bx,ax          ;Odejmij kolor punktu aktualnego 
     mov  cl,3 
     shr  bx,cl          ;Oblicz �redni� arytmetyczn� 
     pop  cx 
     ;Licz now� intensywno�� koloru
     mov  al,ds:[si-1] 
     mov  dl,al 
     sub  al,bl 
     add  al,dl 
     ;Sprawd� czy kolor "nie przeszed�" zakresu
     cmp  al,64 
     jb   Ok3 
     cmp  al,128 
     jb   Ok1 
     mov  al,0 
     jmp  Ok3 
Ok1: 
     mov  al,63 
Ok3: 
     stosb 
     loop Go 
     ;Rysuj nowy obraz 
     mov  si,0 
     mov  di,0 
     mov  cx,32000 
     mov  dx,ds 
     mov  bx,es 
     mov  ds,bx 
     mov  es,dx 
     rep  movsw 
     ret 
     ENDP 
SHARPS SEGMENT      ;Segment roboczy dla procedury SHARP
Tab  dw 32000 dup(0) 
SHARPS ENDS 
