.model tiny
.code
.386
org 100h

Start:
  jmp  Instaluj

; tutaj b�d� nasze zmienne:
staraproc dd 0               ; dd oznacza 4 bajty (tutaj o warto�ci 0)

NaszaProc:
  push ax                    ; zapami�tujemy warto�ci u�ywanych rejestr�w
  push bx
  push di
  push es
  mov  ax,0b800h             ; B800h - segment pami�ci ekranu karty VGA
  mov  es,ax
  xor  di,di                 ; zerujemy DI - adres w pami�ci ekranu
  xor  al,al                 ; AL=0 - kom�rka z aktualn� sekund� w BCD
  out  70h,al                ; wysy�amy do zegara CMOS
  jmp  $+2                   ; ma�e op�nienie
  in   al,71h                ; odczytujemy wynik z zegara CMOS
  mov  bl,al
  and  bl,0fh                ; prawa po��wka bajtu - prawa cyfra w BCD
  add  bl,'0'                ; do tego dodajemy kod zera
  shr  al,4                  ; lewa po��wka bajtu - lewa cyfra w BCD
  add  al,'0'                ; do tego te� dodajemy kod '0'
  mov  ah,0ch                ; atrybut napisu - jasnoczerwony na czarnym tle
  stosw                      ; i rzucamy na ekran pierwsz� cyfr�
  mov  al,bl
  stosw                      ; potem drug�
  pop  es
  pop  di
  pop  bx
  pop  ax
  jmp  dword ptr cs:[staraproc]        ; skok do oryginalnej procedury

; koniec cz�ci rezydentnej

Instaluj:
  mov  ax,3508h              ; 35h: pobranie wektora przerwania
  int  21h                   ; wynik wpad� do ES:BX
  mov  word ptr cs:[staraproc],bx      ; trzeba jeszcze go gdzies zapamietac
  mov  word ptr cs:[staraproc +2],es
  mov  ax,2508h              ; 25h: ustawienie wektora przerwania
  mov  dx,offset NaszaProc   ; DS:DX - wektor naszej procedury
  int  21h
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Napis
  int  21h
  mov  dx,offset Instaluj    ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; kt�ry ma by� zwolniony, wcze�niejsze
                             ; zostaj� w pami�ci na sta�e

Napis  db 'Program zainstalowany w pami�ci.',13,10,'$'

end Start
