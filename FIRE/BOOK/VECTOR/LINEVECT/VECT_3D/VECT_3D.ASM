;*******************
;*** VECT_3D.ASM *** 
;*******************
DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT 
Sname     db 'SINUS.DAT',0
Cname     db 'COSINUS.DAT',0

kat_y     dw 0           ;K�t obrotu wok�� osi Y
kat_x     dw 0           ;K�t obrotu wok�� osi X
kat_z     dw 0           ;K�t obrotu wok�� osi Z
;Wsp��rz�dne punktu obrotu
XO        dw 0
YO        dw 0
ZO        dw 0

ile_punktow    equ 25    ;ilo�� obracanych punkt�w
ile_linii      equ 36    ;ilo�� rysowanych linii
d_x       dw 150         ;korekcja X
d_y       dw 100         ;korekcja Y
iler      equ 8

Zv        dw -23040      ;Wsp��rz�dna Z oka pomno�ona przez 256
Zv1       dw -90         ;Wsp��rz�dna Z oka

Start: 
     mov  ax,13h 
     int  10h 
     call LoadDATA
     call Trans_lacz     ;Przelicz tablic� po��cze� 
MAIN: 
     mov  color,0 
     call Draw           ;Zetrzyj stary rysunek 
     call Copy_bryla     ;Przenie� ���wsp��rz�dne ��do ��tablicy 
                         ;roboczej 
     call Rotate_y       ;Obr�� wok�� y
     call Transform      ;Przelicz na wsp��rz�dne ekranu 
     mov  color,63h 
     call Draw           ;Rysuj nowy rysunek 
     ;*************************
     ;Czekaj na powr�t pionowy
     mov  dx,3dah       
wai:     
     in   al,dx
     test al,8
     je   wai
wai1:
     in   al,dx
     test al,8
     jne  wai1     
     ;************************* 
     inc  kat_y          ;Nast�pny k�t 
     cmp  kat_y,90 
     jb   Ok_Y 
     mov  kat_y,0 
Ok_Y: 
     mov  ah,01h 
     int  16h            ;Sprawd� czy klawisz
     jz   MAIN           ;je�li nie to obracaj dalej
     mov  ax,3h
     int  10h
     mov  ax,4c01h
     int  21h

include linia.asm
     
;---- Kopiuj wsp��rz�dne do tablicy ROT_BRYLA --- 
;Procedura przenosi wsp��rz�dne do tablicy ROT_BRYLA z kt�rej 
;b�d� brane do obrot�w
Copy_bryla PROC
     push cs
     push cs
     pop  ds
     pop  es 
     lea  si,Bryla
     lea  di,Rot_bryla
     mov  cx,ile_punktow
Kopiuj: 
     movsw 
     movsw 
     movsw 
     loop Kopiuj 
     ret 
     ENDP 
;--- Obr�� wok�� osi Y --- 
;Procedura obraca punkty zawarte w tablicy ROT_BRYLA o k�t KAT_Y 
;i �umieszcza �je �zn�w �w �tablicy �ROT_BRYLA. �Jest �to zabieg 
;konieczny �do �p��niejszej �rozbudowy �programu �o obroty wok�� 
;pozosta�ych ���osi, ��tak ��aby ��nowe ��procedury ��obracaj�ce 
;wykorzystywa�y ��wsp��rz�dne ��przeliczone ��przez ��poprzedni� 
;procedur� obracaj�c� (uwzgl�dnienie wszystkich obrot�w). 
Rotate_Y PROC
        mov     dx,SCOS
        mov     ds,dx
        mov     dx,SSIN
        mov     es,dx
        mov     bp,kat_y
        mov     cl,9
        shl     bp,cl
        mov     cx,ile_punktow
        lea     si,ROT_BRYLA
Roty:
        ;Czytaj X
        push    cx
        mov     cl,iler
        mov     bx,cs:[si]
        add     bx,127
        sub     bx,xo
        shl     bx,1
        add     bx,bp

        ;Czytaj Z
        mov     di,cs:[si+4]
        add     di,127
        sub     di,zo
        shl     di,1
        add     di,bp
        ;licz X * cos - Z * sin
        mov     ax,ds:[bx]
        sub     ax,es:[di]
        ;licz Z * cos + X * sin
        mov     dx,ds:[di]
        add     dx,es:[bx]
        ;przelicz na wsp��rz�dne rzeczywiste
        sar     ax,cl
        sar     dx,cl
        
        add     ax,xo
        add     dx,zo

        mov     cs:[si],ax
        mov     cs:[si+4],dx
        add     si,6
        pop     cx
        loop    Roty
        ret
        ENDP    
;---- Przelicz wsp��rz�dne 3D na wsp��rz�dne ekranu ---- 
;Procedura �oblicza �wsp��rz�dn� �na �ekranie �ka�dego �punktu z 
;wykorzystaniem �r�wna� �perspektywy �i �umieszcza �je w tablicy 
;EKRAN
D_z  dw ? 
Transform PROC 
     push cs
     push cs
     pop  es
     pop  ds
     lea  si,Rot_bryla   ;Wsp��rz�dne 3D
     lea  di,Ekran       ;Tablica wpo�rz�dnych ekranu 
     mov  cx,ile_punktow ;ilo�� przelicznych punkt�w
Trans: 
     ;Licz Zv/(Z-Zv1) i zachowaj na p��niej
     mov  ax,Zv               ;Wczytaj ZV (patrz wz�r) 
     mov  bx,ds:[si][4]       ;Wczytaj wsp��rz�dn� Z
     sub  bx,Zv1              ;Odejmij ZV1 (patrz wz�r)
     mov  dx,0 
     idiv bx                  ;Podziel przez (Z-Zv1)
     mov  d_z,ax      ;zapami�taj wynik w zmiennej D_Z
     ;--- Oblicz wsp��rz�dn� X --- 
     lodsw          ;Wczytaj X z ROT_BRYLA
     neg  ax        ;Zmie� znak
     imul d_z       ;Pomn�� przez D_z
     push cx 
     mov  cl,8      ;i podziel przez 256
     sar  ax,cl 
     pop  cx 
     add  ax,d_x    ;przesu�
     stosw          ;Zapami�taj w tablicy EKRAN
     ;--- Oblicz wsp��rz�dn� Y --- 
     lodsw          ;Wczytaj Y z ROT_BRYLA
     neg  ax        ;Zmie� znak
     imul d_z       ;Pomn�� przez D_z
     push cx 
     mov  cl,8      ;i podziel przez 256
     sar  ax,cl 
     pop  cx 
     add  ax,d_y    ;przesu�
     stosw          ;i zapami�taj w tablicy EKRAN
     add  si,2 
     loop Trans 
     ret 
     ENDP 
;---- Rysuj bry�� ---- 
;Procedura rysuje bry�� na ekranie na podstawie tablicy EKRAN
Draw PROC 
     push cs
     push cs
     pop  ds
     pop  es
     lea  di,Lacz        ;Tablica ��cznik�w
     lea  si,Ekran       ;Tablica wsp��rz�dnych
     mov  cx,ile_linii   ;ilo�� rysowanych linii
Rysuj: 
     mov  bx,es:[di]     ;pierwszy i 
     mov  bp,es:[di][2]  ;drugi punkt 
     mov  ax,ds:[si][bx]      ;Wczytaj X1
     mov  dx,ds:[si][bx][2]   ;Wczytaj Y1
     mov  cs:x1,ax 
     mov  cs:y1,dx 
     mov  ax,ds:[si][bp]      ;Wczytaj X2
     mov  dx,ds:[si][bp][2]   ;Wczytaj Y2
     mov  cs:x2,ax 
     mov  cs:y2,dx 
     push ds 
     push es 
     push si 
     push di 
     push cx 
     call Line           ;Rysuj lini� od (X1,Y1) do (X2,Y2)
     pop  cx 
     pop  di 
     pop  si 
     pop  es 
     pop  ds 
     add  di,4 
     loop Rysuj 
     ret 
     ENDP 
;---- Przelicz tablic� ��cznik�w ---- 
;Procedura �mno�y �przez 4 ka�d� liczb� w tablicy ��cznik�w, tak 
;aby przerobi� je na offsety w tablicy EKRAN
Trans_lacz PROC 
     push cs
     pop  es
     lea  di,Lacz 
     mov  cx,ile_linii        ;ilo�� linii pomno�ona przez 2
     shl  cx,1                ;-ka�da linia - dwa ko�ce
Tr: 
     mov  ax,es:[di]          ;Wczytaj liczb�
     shl  ax,1                ;Pomn�� przez 2
     shl  ax,1                ;Pomn�� przez 2
     stosw                    ;Zapisz w tym samym miejscu
     loop Tr 
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

;--- Wierzcho�ki bry�y --- 
Bryla     dw -30,-10,-30, 30,-10,-30, 30,-10,30, -30,-10,30 
          dw -20,-10,-20, 20,-10,-20, 20,-10,20, -20,-10,20 
          dw -20,10,-20, 20,10,-20, 20,10,20, -20,10,20 
          dw -25,10,-25, 25,10,-25, 25,10,25, -25,10,25 
          dw 0,30,0 
          dw -17,7,20, -5,7,20, -5,-3,20, -17,-3,20 
          dw 17,7,20, 3,7,20, 3,-8,20, 17,-8,20 

;--- Tablica ��cznik�w --- 
Lacz      dw 0,1, 1,2, 2,3, 3,0 
          dw 4,5, 5,6, 6,7, 7,4 
          dw 8,9, 9,10, 10,11, 11,8 
          dw 4,8, 5,9, 6,10, 7,11 
          dw 12,13, 13,14, 14,15, 15,12 
          dw 8,12, 9,13, 10,14, 11,15 
          dw 12,16, 13,16, 14,16, 15,16 
          dw 17,18, 18,19, 19,20, 20,17 
          dw 21,22, 22,23, 23,24, 24,21 
Ekran     dw ile_punktow dup(0,0) 
Rot_bryla dw ile_punktow dup(0,0,0) 
Pom_bryla dw ile_punktow dup(0,0,0) 

CODE ENDS 

SSIN SEGMENT
SIN db 50000 dup(?)
SSIN ENDS

SCOS SEGMENT
COS db 50000 dup(?)
SCOS ENDS



END Start 
