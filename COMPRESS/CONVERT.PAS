uses Crt;

Const
 ZnakiEkr : array[1..9] of Byte = (176,177,178,219,220,223,96,126,32);

{
 � - 176

 � - 177

 � - 178

 � - 219

 � - 220

 � - 223

 ` - 96

 ~ - 126
}
  Function Hex(b:byte):string;                 { funkcja zmienia Dec na Hex }
   const HexArray:String='0123456789ABCDEF';
   var OutHex:String;
   begin
    OutHex:='';
    OutHex:=HexArray[(b shr 4)+1]+HexArray[(b mod 16)+1]+'h';
    if OutHex[1] in ['A'..'F'] then OutHex:='0'+OutHex;
    Hex:=OutHex;
   end;


Var

   Plik00  : File;
   Plik01  : Text;
   Bufor   : Array[1..4096] of Byte;
   Rozmiar : Word;
   Pos     : Word;
   Znak    : Byte;
   Licznik : Byte;
   Comp,l  : byte;

 Begin
  Assign(Plik00,'c.asm');
  Reset(Plik00,1);
  Rozmiar:=FileSize(Plik00);
  BlockRead(Plik00,Bufor,Rozmiar);
  Close(Plik00);

  Assign(Plik01,'out.asm');
  Rewrite(Plik01);

   For pos:=1 to Rozmiar do
    begin
     Write(plik01,Hex(Bufor[pos])+',');
     if pos mod 15=0 then writeln(plik01);
    end;

   Close(Plik01);


 End.


