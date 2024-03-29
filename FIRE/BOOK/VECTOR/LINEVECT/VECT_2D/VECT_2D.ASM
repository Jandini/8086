;*******************
;*** VECT_2D.ASM *** 
;*******************
DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE 

CODE SEGMENT 

Sname db 'SINUS.DAT',0
Cname db 'COSINUS.DAT',0

ile_punktow equ 12   ;ilo�� obracanych punkt�w
ile_linii   equ 12   ;ilo�� rysowanych linii
Dl_x    dw      150        ;Liczba koryguj�ca wsp��rz�dn� X
Dl_y    dw      100        ;i wsp��rz�dn� Y
kat     dw      0          ;k�t obrotu od pozycji pocz�tkowej 
iler    equ     8
XO      dw      0
YO      dw      0

Start: 
     mov  ax,13h 
     int  10h 
     call LoadDATA   
     call Trans_lacz ;Przelicz tablic� ��cznik�w
MAIN: 
     mov  color,0 
     call Draw      ;Zetrzyj stary rysunek 
     call Rotate    ;Obr�� 
     mov  color,63h 
     call Draw      ;Narysuj nowy rysunek 
     call Opoz
     inc  kat       ;Nast�pny k�t 
     cmp  kat,90   ;Sprawd� czy przeszed� zakres 
     jb   Ok_kat 
     mov  kat,0     ;ustaw k�t na zerowy 
Ok_kat: 
     mov  ah,01h    ;sprawd� czy naci�ni�ty klawisz 
     int  16h       ;je�li nie, to obracaj dalej
     jz   MAIN 
     mov  ax,3h 
     int  10h 
     mov  ax,4c01h 
     int  21h 
;-------- Op��nienie -------- 
;Procedura dostosowuje rysowanie bry�y do wy�wietlania obrazu 
;przez komputer na ekranie
Opoz PROC 
     mov  dx,3dah 
Wai: 
     in   al,dx 
     test al,8 
     je   Wai 
     ret 
     ENDP 
;-------- Przeliczenie tablicy ��cznik�w ---------- 
;Procedura �zamienia �liczby z tablicy LACZ na offsety punkt�w w 
;tablicy R_KWADRAT
Trans_lacz PROC 
     mov  cx,ile_linii 
     shl  cx,1 
     push cs
     pop  es
     lea  di,Lacz 
Tr: 
     mov  ax,es:[di]     ;Pobierz liczb�
     shl  ax,1           ;Pomn�� przez 2
     shl  ax,1           ;Pomn�� przez 2
     stosw               ;Wstaw w to samo miejsce
     loop Tr 
     ret 
     ENDP
;**************** Procedura obracaj�ca punkty ********************
;Procedura oblicza nowe wsp��rz�dne punkt�w na podstawie tablicy 
;KWADRAT (wierzcho�ki bry�y) i umieszcza je w tablicy R_KWADRAT. 
;Punkty �obracane �s� wed�ug punktu (XO,YO) o k�t wyznaczony 
;przez zmienn� KAT
;*****************************************************************
Rotate PROC
        mov     dx,SCOS
        mov     ds,dx
        mov     dx,SSIN
        mov     es,dx
        mov     bp,KAT
        mov     cl,9
        shl     bp,cl
        mov     cx,ile_punktow
        mov     si,0
Rotz:
        ;Wczytaj X 
        push    cx
        mov     cl,iler
        mov     bx,cs:KWADRAT[si]
        add     bx,127  ;przelicz na offset
        sub     bx,xo
        shl     bx,1
        add     bx,bp

        ;Wczytaj Y
        mov     di,cs:KWADRAT[si+2]
        add     di,127  ;przelicz na offset
        sub     di,yo
        shl     di,1
        add     di,bp

        ;policz X * cos + Y * sin
        mov     ax,ds:[bx]
        add     ax,es:[di]
        ;policz Y * cos - X * sin
        mov     dx,ds:[di]
        sub     dx,es:[bx]
        ;przelicz na wsp��rz�dne rzeczywiste
        sar     ax,cl
        sar     dx,cl
        
        add     ax,xo
        add     dx,yo
        ;zapami�taj     
        mov     cs:R_KWADRAT[si],ax
        mov     cs:R_KWADRAT[si+2],dx
        add     si,4
        pop     cx
        loop    RotZ
        ret
        ENDP    
;-------- Procedura rysuj�ca figur� na ekranie --------- 
Draw PROC 
     push cs
     push cs
     pop  ds
     pop  es
     lea  si,R_kwadrat   ;Rysowanie na podstawie R_KWADRAT 
     lea  di,Lacz        ;Tablica ��cznik�w
     mov  cx,ile_linii 
Rysuj: 
     mov  bx,es:[di]          ;Wczytaj X pocz�tkowego punktu
     mov  bp,es:[di][2]       ;Wczytaj Y pocz�tkowego punktu
     mov  ax,ds:[si][bx]      ;X1 
     mov  dx,ds:[si][bx][2]   ;Y1 
     add  �ax,dl_x �            ;Dodaj �odpowiednie �warto�ci do 
                                ;wsp��rz�dnych tak aby przesun�� 
     add  dx,dl_y               ;figur� na �rodek 
     mov  cs:x1,ax 
     mov  cs:y1,dx 
     mov  ax,ds:[si][bp]      ;X2 
     mov  dx,ds:[si][bp][2]   ;Y2 
     add  ax,dl_x               ;Dodaj odpowiednie liczby do
     add  dx,dl_y               ;do wsp��rz�dnych
     mov  cs:x2,ax 
     mov  cs:y2,dx 
     push si 
     push di 
     push ds 
     push es 
     push cx 
     call Line           ;Rysuj lini� od (X1,Y1) do (X2,Y2)
     pop  cx 
     pop  es 
     pop  ds 
     pop  di 
     pop  si 
     add  di,4 
     loop Rysuj 
     ret 
     ENDP 
;*********************************
;Wczytaj tablice sinusa i cosinusa
;*********************************
LoadDATA PROC
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Sname
        mov     al,0
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     dx,SSIN
        mov     ds,dx
        mov     dx,offset SIN
        mov     cx,49152
        int     21h
        mov     ah,3eh
        int     21h
        ;***************************
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Cname
        mov     al,0
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     dx,SCOS
        mov     ds,dx
        mov     dx,offset COS
        mov     cx,49152
        int     21h
        mov     ah,3eh
        int     21h
        ret
ENDP    
     
include linia.asm   ;Do��cz procedur� rysuj�c� lini�

Kwadrat   dw -20,60, 20,60, 20,20, 60,20, 60,-20, 20,-20, 20,-60 
          dw -20,-60, -20,-20, -60,-20, -60,20, -20,20 
Lacz      dw 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,0 
R_kwadrat dw ile_punktow dup(0,0) 

CODE ENDS 

SSIN SEGMENT
SIN db 50000 dup(?)
SSIN ENDS

SCOS SEGMENT
COS db 50000 dup(?)
SCOS ENDS

END Start 
