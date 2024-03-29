;*****************
;*** FILL1.ASM *** 
;*****************
R_ofs     dw ?      ;Zmienna pomocnicza 
Xf        dw ?      ;Kolumna, od kt�rej b�dzie wype�niany obszar 
Yf        dw ?      ;Wiersz, od kt�rego b�dzie wype�niany obszar 
Xp        dw ?      ;Zmienna pomocnicza 
Long      dw ?      ;Ilo�� wype�nianych linii 
f_color   db ?      ;Kolor wype�niania 
stop_color db ?     ;Kolor ramki figury 
Fill PROC 
     mov  dx,0a000h ;Wype�nianie bezpo�rednio na ekranie 
     mov  es,dx
     ;Oblicz offset punktu pocz�tkowego 
     mov  ax,Yf     ;Oblicz offset linii
     mov  bx,320 
     mul  bx        ;mno��c jej numer przez 320
     add  ax,Xf     ;Oblicz offset punktu
     mov  R_ofs,ax  ;Zapami�taj w zmiennej
     mov  di,ax 
     mov  cx,long   ;Ilo�� linii do wype�nienia
     ;Znajd� pierwszy punkt 
First_point: 
     push cx 
     mov  cx,319    ;Szukaj od kolumny Xf
     sub  cx,Xf     ;do ewentualnego ko�ca linii
     mov  al,Stop_color ;Kolor punktu zatrzymuj�cego 
     repne scasb    ;Przeszukuj
     jcxz Next_line ;Je�li koniec tej linii, to bierz nast�pn�
     mov  xp,cx     ;Zapami�taj CX
End_of_first: 
     repe scasb     ;Szukaj punktu r��nego od zatrzymuj�cego 
                    ;gdy� �mo�e �zaistnie� �taka �sytuacja, �e w 
                    ;linii �b�dzie �kilka �kolejnych �punkt�w �w 
                    ;kolorze zatrzymuj�cym
     jcxz Next_line ;Je�li ca�a linia wype�niona, to bierz 
                    ;lini� nast�pn�
Second_point: 
     repne scasb    ;Szukaj punktu ko�cowego
     jcxz Next_line ;Je�li go nie ma, to bierz nast�pn� lini�
     sub  Xp,cx     ;Oblicz r��nic� mi�dzy ostatnim a pierwszym 
                    ;Wyznacza ona ilo�� punkt�w do zamalowania
     mov  cx,Xp 
     sub  di,cx     ;Wr�� do punktu pierwszego
     dec  di 
     inc  cx 
     mov  al,f_color ;Kolor wype�niania
     rep  stosb     ;Wype�niaj 
Next_line: 
     pop  cx 
     add  R_ofs,320 
     mov  di,R_ofs 
     loop First_point 
     ret 
     ENDP 
