.model tiny
.code
.386
org 100h

Start:
  mov  ah,9                  ; numer funkcji wypisuj�cej ci�g znak�w
  mov  dx,offset Napis       ; adres tego ci�gu do rejestru DX
  int  21h                   ; teraz wywo�ujemy przerwanie dosowe
  mov  ax,4c00h              ; funkcja: zako�cz program, 00 to kod b��du
  int  21h                   ; po tym wywo�aniu ju� tu nie wr�cimy

Napis  db 'Pierwszy program z kursu TSR�w.',13,10,'$'

end Start
