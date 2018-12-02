unit ControlePonto;

interface

uses
   Ponto,SysUtils;

function InicializaPontos(): TListaDePontos;
procedure AdicionaPonto(var ListaDePontos: TListaDePontos;
                        DataMarcacao:TDateTime;
                        HoraEntrada,MinEntrada,
                        HoraSaidaAlmoco,MinSaidaAlmoco,
                        HoraRetornoAlmoco,MinRetornoAlmoco,
                        HoraSaida,MinSaida:Integer);
function Const_str(Palavra:string;Rep:Integer):Ansistring;
function inttostr2(num:integer):Ansistring;
function BateMesReferencia(Referencia,Informado:TDateTime):Boolean;
function VerificaSeJaBateuDia(ListaDePontos: TListaDePontos;Referencia:TDateTime):Boolean;
function TotalSegEntreHorarios(Ponto:TPonto):Integer;
function FormataHoras( Seg:LongInt ):string;
function SegEntre2Horarios(Hora1,Min1,Hora2,Min2:Integer):Integer;
procedure SalvaListaDePontos(ListaDePontos: TListaDePontos);

implementation

function InicializaPontos(): TListaDePontos;
var
  ListaDePontosAux: TListaDePontos;
  i,posSep:integer;
  Arq : TextFile;
  line: Ansistring;
  NomeArq:Ansistring;
  strAux:Ansistring;
begin
    for i := 0 to MAX do begin
      ListaDePontosAux[i]:= TPonto.Create;
    end;
 try
    NomeArq:='Pontos.csv';
    line:='';
    posSep:=0;
    strAux:='';
    if fileexists(NomeArq) then
    begin
      AssignFile(Arq, NomeArq);
      Reset(Arq);
      // Ignora a primeira linha do Arquivo pois ela contem o
      // cabe�alho do arquivo csv
      ReadLn(Arq, line);
      i:=0;
      while not Eof(Arq) and (i<=MAX) do
      begin
        ReadLn(arq, line);
        posSep:=pos(';',line);
        strAux:=copy(line,1,posSep-1);
        // primeiro vem a data
        ListaDePontosAux[i].FDataMarcacao:=StrToDate(strAux);
        ListaDePontosAux[i].FInicializado:=true;
        line:=copy(line,posSep+1, (Length(line)-posSep));
        // depois hora e minutos da entrada
        posSep:=pos(';',line);
        strAux:=copy(line,1,posSep-1);
        ListaDePontosAux[i].FHoraEntrada:=strtoint(copy(strAux,1,2));
        ListaDePontosAux[i].FMinEntrada:=strtoint(copy(strAux,4,2));

        line:=copy(line,posSep+1, (Length(line)-posSep));
        posSep:=pos(';',line);
        strAux:=copy(line,1,posSep-1);
        ListaDePontosAux[i].FHoraSaidaAlmoco:=strtoint(copy(strAux,1,2));
        ListaDePontosAux[i].FMinSaidaAlmoco:=strtoint(copy(strAux,4,2));

        line:=copy(line,posSep+1, (Length(line)-posSep));
        posSep:=pos(';',line);
        strAux:=copy(line,1,posSep-1);
        ListaDePontosAux[i].FHoraRetornoAlmoco:=strtoint(copy(strAux,1,2));
        ListaDePontosAux[i].FMinRetornoAlmoco:=strtoint(copy(strAux,4,2));

        line:=copy(line,posSep+1, (Length(line)-posSep));
        strAux:=line;
        ListaDePontosAux[i].FHoraSaida:=strtoint(copy(strAux,1,2));
        ListaDePontosAux[i].FMinSaida:=strtoint(copy(strAux,4,2));

        i:=i+1;
      end;
      CloseFile(Arq);
    end;
 except
    on e:Exception do raise Exception.Create('N�o foi poss�vel recuperar marca��es. Arquivo corrompido!.');
 end;
    result:=ListaDePontosAux;
end;

function Const_str(Palavra:string;Rep:Integer):Ansistring;
var
  i:Integer;
begin
     result:='';
     for i:=0 to Rep -1 do
     begin
        result:=result+Palavra;
     end;

end;

function inttostr2(num:integer):Ansistring;
begin
     if(num>=0)and(num<=9) then
       result:='0'+inttostr(num)
     else
       result:=inttostr(num);
end;

function BateMesReferencia(Referencia,Informado:TDateTime):Boolean;
var
  str_MesAnoRefe,str_MesAnoinfo:ansistring;
begin
     str_MesAnoRefe:='';
     str_MesAnoinfo:='';
     str_MesAnoRefe:=trim(copy(datetostr(Referencia),4,7));
     str_MesAnoinfo:=trim(copy(datetostr(Informado),4,7));
     result:=(str_MesAnoinfo=str_MesAnoRefe);
end;

procedure AdicionaPonto(var ListaDePontos: TListaDePontos;
                        DataMarcacao:TDateTime;
                        HoraEntrada,MinEntrada,
                        HoraSaidaAlmoco,MinSaidaAlmoco,
                        HoraRetornoAlmoco,MinRetornoAlmoco,
                        HoraSaida,MinSaida:Integer);
var
  i:integer;
begin
       i:=0;
       while ((assigned(ListaDePontos[i])) and (ListaDePontos[i].FInicializado)) do i:=i+1;
       //if(i>0) then
      //   ListaDePontos[i]:= TPonto.Create;
       ListaDePontos[i].FDataMarcacao:=DataMarcacao;
       ListaDePontos[i].FHoraEntrada:=HoraEntrada;
       ListaDePontos[i].FMinEntrada:=MinEntrada;

       ListaDePontos[i].FHoraSaidaAlmoco:=HoraSaidaAlmoco;
       ListaDePontos[i].FMinSaidaAlmoco:=MinEntrada;

       ListaDePontos[i].FHoraRetornoAlmoco:=HoraRetornoAlmoco;
       ListaDePontos[i].FMinRetornoAlmoco:=MinRetornoAlmoco;

       ListaDePontos[i].FHoraSaida:=HoraSaida;
       ListaDePontos[i].FMinSaida:=MinSaida;
       ListaDePontos[i].FInicializado:=True;
end;

// ================================= Criticas Para a Batida de ponto =========================================================

function VerificaSeJaBateuDia(ListaDePontos: TListaDePontos;Referencia:TDateTime):Boolean;
var
   ipos:integer;
begin
      result:=false;
      while ((assigned(ListaDePontos[ipos])) and (ListaDePontos[ipos].FInicializado)) do
      begin
            if(trim(datetostr(Referencia))=trim(datetostr(ListaDePontos[ipos].FDataMarcacao))) then
            begin
              result:=true;
              break;
            end;
            ipos:=ipos+1;
      end;
end;

function TotalSegEntreHorarios(Ponto:TPonto):Integer;
var
   totalDif,ini,fim:integer;
begin
   totalDif:=0;
   ini:=0;
   fim:=0;
   // Segundos trabalhados entre a entrada e a hora do almoco
   ini:=Ponto.FHoraEntrada*(3600)+Ponto.FMinEntrada*(60);
   fim:=Ponto.FHoraSaidaAlmoco*(3600)+Ponto.FMinSaidaAlmoco*(60);
   totalDif:=totalDif+(fim-ini);
   // Segundos em almoco
   //ini:=Ponto.FHoraSaidaAlmoco*(3600)+Ponto.FMinSaidaAlmoco*(60);
  // fim:=Ponto.FHoraRetornoAlmoco*(3600)+Ponto.FMinRetornoAlmoco*(60);
  //totalDif:=totalDif-(fim-ini);
   // Segundos trabalhados entre a volta do almoco e a saida
   ini:=Ponto.FHoraRetornoAlmoco*(3600)+Ponto.FMinRetornoAlmoco*(60);
   fim:=Ponto.FHoraSaida*(3600)+Ponto.FMinSaida*(60);
   totalDif:=totalDif+(fim-ini);
   result:= totalDif;
end;

function SegEntre2Horarios(Hora1,Min1,Hora2,Min2:Integer):Integer;
var
   totalDif,ini,fim:integer;
begin
   totalDif:=0;
   ini:=0;
   fim:=0;
   // Segundos entre horas
   ini:=Hora1*(3600)+Min1*(60);
   fim:=Hora2*(3600)+Min2*(60);
   totalDif:=totalDif+(fim-ini);
   result:= totalDif;
end;

function FormataHoras( Seg:LongInt ):string;
Var
    Hora,Min:LongInt;
    tempo : Double;
begin
  tempo := Seg / 3600;
  Hora := Round(Int(tempo));
  Seg :=  Round(Seg - (Hora*3600));
  tempo := Seg / 60;
  Min := Round(Int(tempo));
  Seg :=  Round(Seg - (Min*60));
  Result := FormatFloat( '00', Hora )+ ':' + FormatFloat( '00', Min );
end;

procedure SalvaListaDePontos(ListaDePontos: TListaDePontos);
var
  i,ipos:integer;
  Arq : TextFile;
  line: Ansistring;
  NomeArq:Ansistring;
begin
   NomeArq:='Pontos.csv';
   ipos:=0;
   AssignFile(Arq,NomeArq);
   ReWrite(Arq);
   WriteLn(Arq,'Data da Marcacao;Hora Entrada;Hora Saida para Almoco;Hora Retorno do Almoco;Hora da Saida');// cabe�alho
   while ((assigned(ListaDePontos[ipos])) and (ListaDePontos[ipos].FInicializado)) do
   begin
      Write(Arq,datetostr(ListaDePontos[ipos].FDataMarcacao)+';');
      write(Arq,FormataHoras((ListaDePontos[ipos].FHoraEntrada*3600)+(ListaDePontos[ipos].FMinEntrada*60))+';');
      write(Arq,FormataHoras((ListaDePontos[ipos].FHoraSaidaAlmoco*3600)+(ListaDePontos[ipos].FMinSaidaAlmoco*60))+';');
      write(Arq,FormataHoras((ListaDePontos[ipos].FHoraRetornoAlmoco*3600)+(ListaDePontos[ipos].FMinRetornoAlmoco*60))+';');
      write(Arq,FormataHoras((ListaDePontos[ipos].FHoraSaida*3600)+(ListaDePontos[ipos].FMinSaida*60))+';');
      WriteLn(Arq,'');
      ipos:=ipos+1;
   end;
   CloseFile(Arq);

end;

end.
