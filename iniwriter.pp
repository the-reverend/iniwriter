program iniwriter;

uses
  dos, sysutils;

function wordloc(s: ansistring; start, num: word; d: char): word;
var
  w, l: integer;
  db: boolean;
begin
  l:=length(s);
  if (s='') or (num<1) or (start>l) then
  begin
    wordloc:=0;
    exit;
  end;
  db:=true;
  w:=0;
  start:=pred(start);
  while (w<num) and (start<l) do
  begin
    start:=succ(start);
    if db and not(s[start]=d) then
    begin
      w:=succ(w);
      db:=false;
    end
    else
      if not(db) and (s[start]=d) then db:=true;
  end;
  if w=num then wordloc:=start
  else wordloc:=0;
end;

function wordcount(s: ansistring; d: char): word;
var
  w, i: integer;
  db: boolean;
begin
  if s='' then
  begin
    wordcount:=0;
    exit;
  end;
  db:=true;
  w:=0;
  For  i:=1 to length(s) do
  begin
    if db and not(s[i]=d) then
    begin
      w:=succ(w);
      db:=false;
    end
    else
      if not(db) and (s[i]=d) then db:=true;
  end;
  wordcount:=w;
end;

function wordget(s: ansistring; num: word; d: char): ansistring;
var start, finish : integer;
begin
  if s='' then
  begin
    wordget:='';
    exit;
  end;
  start:=wordloc(s,1,num,d);
  if start=0 then
  begin
    wordget:='';
    exit;
  end
  else finish:=wordloc(s,start,2,d);
  if finish=0 then finish:=succ(length(s));
  repeat
    finish:=pred(finish);
  until s[finish]<>d;
  wordget:=copy(s,start,succ(finish-start));
end;

function inisection(line,section:ansistring): boolean;
begin
  if line='['+section+']' then inisection:=true
  else inisection:=false;
end;

function inikey(line,key:ansistring): boolean;
begin
  if wordcount(line,'=')=2 then
    if wordget(line,1,'=')=key then inikey:=true
    else inikey:=false
  else inikey:=false;
end;

function inivalue(line:ansistring): ansistring;
begin
  inivalue:=wordget(line,2,'=');
end;

function iniwrite(fname,section,key,value:ansistring): boolean;
var
  fhandle, tmphandle: text;
  tmpname, line: ansistring;
  insection, written: boolean;
begin
  insection:=false;
  written:=false;
  tmpname:=fname+'.tmp';
  if fileexists(tmpname) then deletefile(tmpname);
  if fileexists(fname) then
  begin
    assign(tmphandle,tmpname);
    rewrite(tmphandle);
    assign(fhandle,fname);
    reset(fhandle);
    while not(eof(fhandle)) do
    begin
      readln(fhandle,line);
      line:=trim(line);
      if insection and (leftstr(line,1)='[') and (rightstr(line,1)=']') then insection:=false;
      if not(insection) then insection:=inisection(line,section);
      if not(insection) then writeln(tmphandle,line);
      if insection and not(inikey(line,key)) then writeln(tmphandle,line);
      if insection and not(written) then
      begin
        writeln(tmphandle,key,'=',value);
        written:=true;
      end;
    end;
    close(fhandle);
    if not(written) then
    begin
      writeln(tmphandle);
      writeln(tmphandle,'[',section,']');
      writeln(tmphandle,key,'=',value);
    end;
    close(tmphandle);
    if fileexists(fname) then deletefile(fname);
    renamefile(tmpname,fname);
    iniwrite:=true;
  end
  else iniwrite:=false;
end;

var
  fname, section, key, value: ansistring;
  success: boolean;

begin
  if paramcount<4 then
  begin
    writeln('usage:  iniwriter fname section key value');
    halt(1);
  end;
  fname:=paramstr(1);
  section:=paramstr(2);
  key:=paramstr(3);
  value:=paramstr(4);
  success:=iniwrite(fname,section,key,value);
  if success then writeln('success!')
  else writeln('failure.');
  if success then halt(0)
  else halt(1);
end.
