;******************
;*** SIMPLE.ASM ***
;******************

.model tiny

.data

;Text scrolla:
Text    db  'Najprostszy scroll z fontem uzytkownika       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
color   db  15   ;kolor scrolla

;FONT    db 4096 dup(?)
FONT:
include font.inc

SCROLL  db 320*16 dup(0)



.code

org 100h

Start:

        mov     ax,13h
        int     10h
MAIN:
;        call    Opoz       ;dostosowanie do ekranu
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
        cmp     Pznak,3      ;Czy jeste�my w znaku?
        ja      No_draw      ;Nie? - nic nie rysuj
                             ;Tak otrzymujemy odst�p mi�dzy
                             ;znakami w scrollu
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
        ;DL i DH - u�ywane do kontroli odpowiednich kolumn 
        ;znaku.
        mov     cl,Pznak        
        shl     cl,1
        mov     dl,10000000b 
        mov     dh,01000000b
        shr     dx,cl
        mov     cx,16
Draw_c:
        xor     bx,bx
        lodsb
        test    al,dl       ;Czy jest 1 punkt?
        jz      No1
        mov     bl,color
No1:
        test    al,dh       ;Czy jest 2 punkt?
        jz      No2
        mov     bh,color
No2:            
        mov     ax,bx
        stosw
        add     di,318
        loop    Draw_c                                  
No_draw:
        inc     Pznak
        cmp     Pznak,6     ;6 - opisuje odst�p mi�dzy 
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
        mov     di,320*180
        mov     cx,160*16
        rep     movsw
        ret
ENDP            




END Start               
