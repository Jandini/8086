;*******************
;*** FULLSCR.ASM ***
;*******************

DSTACK SEGMENT STACK 'STACK'
db 20 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Fname   db 'big.fnt',0   ;nazwa pliku z fontem
;Text scrolla:
Text    db  'Scroll na caly ekran       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
LEN     equ 3    ;ilo�� wy�wietle� ka�dej linii
licz    db  LEN  ;licznik - ilo�� wy�wietle� ka�dej kolumny
color   db  15   ;kolor scrolla

Start:
        call    LoadFONT   ;wczytaj font

        mov     ax,13h
        int     10h
        ;* Zmie� wysoko�� ekranu
        mov     dx,3d4h
        mov     al,9h
        out     dx,al
        inc     dx
        mov     al,23
        out     dx,al
        ;*z
MAIN:
        call    Opoz       ;dostosowanie do ekranu
        call    ShowSCROLL ;rysuj scrolla
        call    MoveSCROLL ;przesun tablic� SCROLL
        call    DrawZNAK   ;dorysuj kolejn� kolumn�
        
        mov     ah,01h
        int     16h
        jz      MAIN

        mov     ah,08h
        int     21h
        mov     ax,4c01h
        int     21h
;*******************************************
;Dostosowanie do ekranu
Opoz PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai
        ret
ENDP                    
;*******************************************
;Przesu� tablic� SCROLL
MoveSCROLL PROC
        ;Najpierw wyczy�� pierwsz� kolumn�,
        ;�eby po przesuni�ciu nie "wysz�a" 
        ;z prawej strony
        push    cs
        pop     es
        lea     di,SCROLL
        mov     cx,16
        mov     ax,0
Clear:
        stosw
        add     di,318
        loop    Clear
        ;i dopiero teraz przesu�
        push    cs
        pop     ds
        lea     si,SCROLL[2]
        lea     di,SCROLL
        mov     cx,160*16-1
        rep     movsw
        ret
ENDP            
;*******************************************
;Dopisz kolumn� z prawej strony SCROLL
DrawZNAK PROC
        cmp     Pznak,8      ;Czy jeste�my w znaku?
        ja      No_draw      ;Nie? - nic nie rysuj
                             ;w�a�nie tak otrzymujemy odst�p 
                             ;mi�dzy znakami w scrollu
        mov     bx,Znak      ;Numer znaku
        mov     bl,Text[bx]  ;i sam kod znak
        and     bl,bl        ;Czy = 0
        jnz     Not_end      ;Je�li nie to dalej,
        mov     Znak,0       ;a je�li tak to od nowa
        jmp     DrawZNAK
Not_end:        
        ;policz offset znaku w FONT
        ;offset := kod znaku * 16
        xor     bh,bh        
        shl     bx,1
        shl     bx,1
        shl     bx,1
        shl     bx,1
        lea     si,FONT[bx]
        push    cs
        pop     ds
        push    cs
        pop     es
        lea     di,SCROLL[318]  ;ustaw si� na praw� kolumn�
        ;DL - u�ywane do kontroli kolumny znaku
        mov     cl,Pznak        
        mov     dl,10000000b 
        shr     dl,cl
        mov     cx,16
Draw_c:
        xor     bx,bx
        lodsb
        test    al,dl       ;Czy jest punkt?
        jz      No1
        mov     bl,color
        mov     bh,color
No1:
        mov     ax,bx
        stosw
        add     di,318
        loop    Draw_c                                  
No_draw:
        dec     licz
        jns     No_next
        mov     licz,LEN    ;LEN - ilo�� wy�wietle� ka�dej
                            ;kolumny
        inc     Pznak
        cmp     Pznak,10    ;10 - opisuje odst�p mi�dzy 
                            ;znakami
        jne     No_next
        mov     Pznak,0
        inc     Znak
No_next:
        ret
ENDP    
;*******************************************
;Narysuj SCROLL na ekranie
ShowSCROLL PROC
        push    cs
        pop     ds
        lea     si,SCROLL
        mov     dx,0a000h
        mov     es,dx
        mov     di,0
        mov     cx,160*16
        rep     movsw
        ret
ENDP            
;*******************************************
;Wczytaj font do FONT
LoadFONT PROC
        push    cs
        pop     ds
        lea     dx,Fname
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        mov     cx,4096
        lea     dx,FONT
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP

FONT    db 4096 dup(?)
SCROLL  db 320*16 dup(0)

CODE ENDS

END Start               