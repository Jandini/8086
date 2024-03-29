.model tiny
.code
.386
org 100h

Start:
  jmp  StartTutaj

; tutaj b�d� nasze zmienne:
staraproc dd 0
; znacznik potrzebny do sprawdzenia zainstalowania TSRa:
znacznik db 'Sekundnik, odc. 3'

NaszaProc:
  push ax
  push bx
  push di
  push es
  xor  ax,ax                 ; segment kom�rki ze stanem klawiatury
  mov  es,ax
  mov  bh,0ch                ; standardowy kolor jasnoczerwony do BH
  test byte ptr es:[417h],40h; sprawdzamy, czy w��czony jest CapsLock
  jnz  CapsOn                ; skok gdy CapsLock wci�ni�ty
  mov  bh,1                  ; kolor niebieski - CapsLock wy��czony
CapsOn:
  mov  ax,0b800h
  mov  es,ax
  xor  di,di
  xor  al,al
  out  70h,al
  jmp  $+2
  in   al,71h
  mov  bl,al
  and  bl,0fh
  add  bl,'0'
  shr  al,4
  add  al,'0'
  mov  ah,bh                 ; �adujemy do AH wcze�niej ustalony kolor
  stosw                      ; i rzucamy na ekran pierwsz� cyfr�
  mov  al,bl
  stosw                      ; potem drug�
  pop  es
  pop  di
  pop  bx
  pop  ax
  jmp  dword ptr cs:[staraproc]        ; skok do oryginalnej procedury

; koniec cz�ci rezydentnej

StartTutaj:
  mov  ah,9                  ; 09h: wydruk nag��wka na ekran
  mov  dx,offset Logo
  int  21h
  mov  si,81h                ; pocz�tek ci�gu parametr�w
  cld
Petla:
  lodsb                      ; wczytanie do AL jednego znaku z DS:SI, SI=SI+1
  cmp  al,'u'                ; mo�e to jest 'u' ?
  je   Rozinstaluj
  cmp  al,'U'                ; a mo�e du�e 'U' ?
  je   Rozinstaluj
  cmp  al,0dh                ; mo�e kod ENTERa (CR) ?
  je   Instaluj
  jmp  Petla                 ; skok gdy nic nie trafimy

Rozinstaluj:
  mov  ax,3508h              ; 35h: pobranie wektora przerwania
  int  21h
  cmp  bx,offset NaszaProc   ; sprawdzamy, czy si� zgadzaj� offsety
  jne  NieMa
  mov  si,offset znacznik    ; adres lokalnego znacznika do DS:SI
  mov  di,si                 ; i znacznika sprawdzanego do ES:DI
  mov  cx,17                 ; d�ugo�� znacznika w bajtach
  cld
  repe cmpsb                 ; sprawdzamy a� do r�ni�cego si� bajtu
  jnz  NieMa                 ; skok gdy si� nie zgadzaj� znaczniki
; Teraz ju� nie ma przeciwwskaza� do rozinstalowania TSRa
  mov  dx,word ptr es:[staraproc]      ; czytamy oryginalny wektor
  mov  ax,word ptr es:[staraproc +2]   ; z bloku TSRa
  mov  ds,ax
  mov  ax,2508h              ; 25h: ustawienie wektora przerwania
  int  21h
  mov  ah,49h                ; 49h: zwolnienie bloku pami�ci z TSRem
  int  21h                   ; w ES mamy segment TSRa
  mov  ax,cs
  mov  ds,ax                 ; przywracamy do DS segment naszego programu
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Uninst
  int  21h                   ; drukujemy komunikat o pomy�lym usuni�ciu TSRa
  mov  ax,4c02h              ; 4ch: powr�t do DOSu, w AL kod b��du
  int  21h

NieMa:
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Brak
  int  21h
  mov  ax,4c04h              ; 4ch: powr�t do DOSu, w AL kod b��du
  int  21h

Instaluj:
  mov  ax,word ptr ds:[2ch]  ; numer segmentu �rodowiska odczytamy z PSP,
  mov  es,ax                 ; wrzucimy do ES
  mov  ah,49h                ; 49h: zwolnienie bloku pami�ci
  int  21h
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
  mov  dx,offset StartTutaj  ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; kt�ry ma by� zwolniony, wcze�niejsze
                             ; zostaj� w pami�ci na sta�e

Logo   db 'Sekundnik 1996.',13,10
       db '     parametr /u - usuni�cie programu z pami�ci',13,10,'$'
Napis  db 'Program zainstalowany w pami�ci.',13,10,'$'
Brak   db 'Program nie by� wcze�niej instalowany w pami�ci.',13,10,'$'
Uninst db 'Program usuni�ty z pami�ci.',13,10,'$'

end Start
