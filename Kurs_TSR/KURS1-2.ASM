.model tiny
.code
.386
org 100h

Start:
  jmp  Instaluj

; to co wpiszemy pomi�dzy etykietami: Start oraz Instaluj pozostanie w
; pami�ci po powrocie do DOSu

  db   'To zosta�o w pami�ci i le�y od�ogiem.'

; koniec cz�ci rezydentnej

Instaluj:
  mov  ah,9
  mov  dx,offset Napis
  int  21h
  mov  dx,offset Instaluj    ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; kt�ry ma by� zwolniony, wcze�niejsze
                             ; zostaj� w pami�ci na sta�e

Napis  db 'Program zainstalowany w pami�ci.',13,10,'$'

end Start
