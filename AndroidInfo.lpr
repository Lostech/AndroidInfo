{
AndroidInfo (c) 2014 Lostech
https://github.com/Lostech/AndroidInfo/

AndroidInfo is a small tool which does read out system information from Android devices via ADB.
To compile the binary you need Lazarus/FPC.
The sourcecode is released under the General Public License Version 2.

http://www.gnu.org/licenses/gpl-2.0
}
program AndroidInfo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, Process
  { you can add units after this };

type

  { TAndroidInfo }

  TAndroidInfo = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

const
  Version:   String = '1.1';

var
  Separator: String;

{ TAndroidInfo }

procedure TAndroidInfo.DoRun;
var
  ErrorMsg: String;
  ADB: String;
  Output: String;
  AProcess: TProcess;
  TmpFile: TStringList;
  SuperUser: TStringList;
  Info: TStringList;
  I: Integer;
  Model: String;
  Build: String;
  InfoFile: String;

begin
  //Init
  Separator:=StringOfChar(Chr(250),79);

  //Start
  writeln(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
  writeln('::                                                                           ::');
  writeln('::                    AndroidInfo V'+Version+' (c) 2014 Lostech                      ::');
  writeln('::                                                                           ::');
  writeln('::                 https://github.com/Lostech/AndroidInfo/                   ::');
  writeln('::                                                                           ::');
  writeln(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
  writeln('');

  // quick check parameters
  ErrorMsg:=CheckOptions('ha:o:sr','help adb: output: show root');
  if ErrorMsg<>'' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;

  // parse parameters
  if (HasOption('h','help')) or (ParamCount=0) then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

  { add your program here }
  writeln(Separator);
  writeln('Parameter');
  writeln(Separator);
  WriteLn('');
  if HasOption('a','adb') then
    begin
      ADB:=GetOptionValue('a', 'adb');
      if FileExists(ADB)=false then
        begin
          WriteLn('Fehler: "',ADB,'" nicht gefunden!');
          Terminate;
          Exit;
        end;
      writeln('ADB:           ',ADB);
      write('ADB Version:   ');
      AProcess:=TProcess.Create(nil);
      AProcess.CommandLine:='"'+adb+'" version';
      AProcess.Options:=AProcess.Options + [poWaitOnExit];
      AProcess.Execute;
      AProcess.Free;
    end;

  if HasOption('o','output') then
    begin
      Output:=GetOptionValue('o', 'output');
      writeln('Ausgabeordner: ',Output);
    end;

  if HasOption('r','root') then
    writeln('Root:          nutze ADB Root Funktion')
  else
    writeln('Root:          nutze keine ADB Root Funktion');

  if DirectoryExists(Output)=false then
    begin
      WriteLn('');
      WriteLn('Erstelle Ausgabeordner "',Output,'" neu"');
      MkDir(Output);
    end;

  WriteLn('');
  WriteLn('');
  writeln(Separator);
  writeln('Daten aus Geraet lesen');
  writeln(Separator);
  WriteLn('');
  WriteLn('Hinweis: AndroidInfo kann jederzeit mit STRG+C abgebrochen werden.');
  WriteLn('');
  Write('Warte auf ADB Verbindung...');
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:='"'+adb+'" kill-server';
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:='"'+adb+'" wait-for-device';
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;
  Writeln('hergestellt');

  WriteLn('');
  WriteLn('Kopiere build.prop');
  DeleteFile(Output+'\build.prop.tmp');
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:='"'+adb+'" pull /system/build.prop "'+Output+'\build.prop.tmp"';
  AProcess.Options:=AProcess.Options + [poWaitOnExit];
  AProcess.Execute;
  AProcess.Free;

  TmpFile:=TStringList.Create;

  WriteLn('Lese Ordnerinhalt von /bin');
  DeleteFile(Output+'\bin.tmp');
  TmpFile.Clear;
  TmpFile.Add('"'+adb+'" shell ls /bin >'+Output+'\bin.tmp');
  TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('Lese Ordnerinhalt von /sbin');
  DeleteFile(Output+'\sbin.tmp');
  TmpFile.Clear;
  TmpFile.Add('"'+adb+'" shell ls /sbin >'+Output+'\sbin.tmp');
  TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('Lese Ordnerinhalt von /xbin');
  DeleteFile(Output+'\xbin.tmp');
  TmpFile.Clear;
  TmpFile.Add('"'+adb+'" shell ls /xbin >'+Output+'\xbin.tmp');
  TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('Lese Ordnerinhalt von /system/bin');
  DeleteFile(Output+'\system_bin.tmp');
  TmpFile.Clear;
  TmpFile.Add('"'+adb+'" shell ls /system/bin >'+Output+'\system_bin.tmp');
  TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('Lese Ordnerinhalt von /system/sbin');
  DeleteFile(Output+'\system_sbin.tmp');
  TmpFile.Clear;
  TmpFile.Add('"'+adb+'" shell ls /system/sbin >'+Output+'\system_sbin.tmp');
  TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('Lese Ordnerinhalt von /system/xbin');
  DeleteFile(Output+'\system_xbin.tmp');
  TmpFile.Clear;
  TmpFile.Add('"'+adb+'" shell ls /system/xbin >'+Output+'\system_xbin.tmp');
  TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('');
  WriteLn('');
  writeln(Separator);
  WriteLn('Starte Parsing der Daten');
  writeln(Separator);
  WriteLn('');
  Info:=TStringList.Create;
  SuperUser:=TStringList.Create;
  Info.Add('================');
  Info.Add('AndroidInfo V'+Version);
  Info.Add('================');
  Info.Add('');

  if FileExists(Output+'\build.prop.tmp') then
    begin
      WriteLn('Parse Daten von build.prop');
      Info.Add('build.prop Inhalt:');
      Info.Add('------------------');
      TmpFile.LoadFromFile(Output+'\build.prop.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if AnsiPos('ro.product.model=',LowerCase(TmpFile.Strings[i]))>0 then
            begin
              Model:=StringReplace(TmpFile.Strings[i],'ro.product.model=','',[rfReplaceAll,rfIgnoreCase]);
              writeln('Geraete Modell: ',Model);
            end;
          if AnsiPos('ro.build.display.id=',LowerCase(TmpFile.Strings[i]))>0 then
            begin
              Build:=StringReplace(TmpFile.Strings[i],'ro.build.display.id=','',[rfReplaceAll,rfIgnoreCase]);
              writeln('Software Build: ',Build);
            end;
          if TmpFile.Strings[i]<>'' then
            begin
              Info.Add(TmpFile.Strings[i]);
            end;
        end;
    end;

  if FileExists(Output+'\bin.tmp') then
    begin
      WriteLn('Werte /bin Verzeichnis aus');
      Info.Add('');
      Info.Add('/bin Verzeichnis:');
      Info.Add('------------------------');
      TmpFile.LoadFromFile(Output+'\bin.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if TmpFile.Strings[i]<>'' then
            begin
              if (LeftStr(LowerCase(TmpFile.Strings[i]),2)='su') or (RightStr(LowerCase(TmpFile.Strings[i]),2)='su') then
                begin
                  writeln('Potentielle SuperUser Datei:');
                  writeln('/bin/',TmpFile.Strings[i],' -> ',StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                  SuperUser.Add('/bin/'+TmpFile.Strings[i]+' -> '+StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                end;
              Info.Add('/bin/'+TmpFile.Strings[i]);
            end;
        end;
    end;

  if FileExists(Output+'\sbin.tmp') then
    begin
      WriteLn('Werte /sbin Verzeichnis aus');
      Info.Add('');
      Info.Add('/sbin Verzeichnis:');
      Info.Add('-------------------------');
      TmpFile.LoadFromFile(Output+'\sbin.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if TmpFile.Strings[i]<>'' then
            begin
              if (LeftStr(LowerCase(TmpFile.Strings[i]),2)='su') or (RightStr(LowerCase(TmpFile.Strings[i]),2)='su') then
                begin
                  writeln('Potentielle SuperUser Datei:');
                  writeln('/sbin/',TmpFile.Strings[i],' -> ',StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                  SuperUser.Add('/sbin/'+TmpFile.Strings[i]+' -> '+StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                end;
              Info.Add('/sbin/'+TmpFile.Strings[i]);
            end;
        end;
    end;

  if FileExists(Output+'\xbin.tmp') then
    begin
      WriteLn('Werte /xbin Verzeichnis aus');
      Info.Add('');
      Info.Add('/xbin Verzeichnis:');
      Info.Add('------------------------');
      TmpFile.LoadFromFile(Output+'\xbin.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if TmpFile.Strings[i]<>'' then
            begin
              if (LeftStr(LowerCase(TmpFile.Strings[i]),2)='su') or (RightStr(LowerCase(TmpFile.Strings[i]),2)='su') then
                begin
                  writeln('Potentielle SuperUser Datei:');
                  writeln('/xbin/',TmpFile.Strings[i],' -> ',StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                  SuperUser.Add('/xbin/'+TmpFile.Strings[i]+' -> '+StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                end;
              Info.Add('/xbin/'+TmpFile.Strings[i]);
            end;
        end;
    end;

  if FileExists(Output+'\system_bin.tmp') then
    begin
      WriteLn('Werte /system/bin Verzeichnis aus');
      Info.Add('');
      Info.Add('/system/bin Verzeichnis:');
      Info.Add('------------------------');
      TmpFile.LoadFromFile(Output+'\system_bin.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if TmpFile.Strings[i]<>'' then
            begin
              if (LeftStr(LowerCase(TmpFile.Strings[i]),2)='su') or (RightStr(LowerCase(TmpFile.Strings[i]),2)='su') then
                begin
                  writeln('Potentielle SuperUser Datei:');
                  writeln('/system/bin/',TmpFile.Strings[i],' -> ',StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                  SuperUser.Add('/system/bin/'+TmpFile.Strings[i]+' -> '+StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                end;
              Info.Add('/system/bin/'+TmpFile.Strings[i]);
            end;
        end;
    end;

  if FileExists(Output+'\system_sbin.tmp') then
    begin
      WriteLn('Werte /system/sbin Verzeichnis aus');
      Info.Add('');
      Info.Add('/system/sbin Verzeichnis:');
      Info.Add('-------------------------');
      TmpFile.LoadFromFile(Output+'\system_sbin.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if TmpFile.Strings[i]<>'' then
            begin
              if (LeftStr(LowerCase(TmpFile.Strings[i]),2)='su') or (RightStr(LowerCase(TmpFile.Strings[i]),2)='su') then
                begin
                  writeln('Potentielle SuperUser Datei:');
                  writeln('/system/sbin/',TmpFile.Strings[i],' -> ',StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                  SuperUser.Add('/system/sbin/'+TmpFile.Strings[i]+' -> '+StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                end;
              Info.Add('/system/sbin/'+TmpFile.Strings[i]);
            end;
        end;
    end;

  if FileExists(Output+'\system_xbin.tmp') then
    begin
      WriteLn('Werte /system/xbin Verzeichnis aus');
      Info.Add('');
      Info.Add('/system/xbin Verzeichnis:');
      Info.Add('------------------------');
      TmpFile.LoadFromFile(Output+'\system_xbin.tmp');
      for i:=0 to TmpFile.Count-1 do
        begin
          if TmpFile.Strings[i]<>'' then
            begin
              if (LeftStr(LowerCase(TmpFile.Strings[i]),2)='su') or (RightStr(LowerCase(TmpFile.Strings[i]),2)='su') then
                begin
                  writeln('Potentielle SuperUser Datei:');
                  writeln('/system/xbin/',TmpFile.Strings[i],' -> ',StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                  SuperUser.Add('/system/xbin/'+TmpFile.Strings[i]+' -> '+StringReplace(TmpFile.Strings[i],'su','(su)',[rfReplaceAll,rfIgnoreCase]));
                end;
              Info.Add('/system/xbin/'+TmpFile.Strings[i]);
            end;
        end;
    end;

  if HasOption('r','root') then
    begin
      WriteLn('Starte ADB root (nur bei bereits installiertem root moeglich!)');
      DeleteFile(Output+'\proc_mtd.tmp.tmp');
      AProcess:=TProcess.Create(nil);
      AProcess.CommandLine:='"'+adb+'" kill-server';
      AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      AProcess.Free;
      AProcess:=TProcess.Create(nil);
      AProcess.CommandLine:='"'+adb+'" root';
      AProcess.Options:=AProcess.Options + [poWaitOnExit];
      AProcess.Execute;
      AProcess.Free;
      TmpFile.Clear;

      WriteLn('Lese Partitionen von /proc/mtd (nur bei bereits installiertem root moeglich!)');
      TmpFile.Add('"'+adb+'" shell cat /proc/mtd >'+Output+'\proc_mtd.tmp');
      TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
      AProcess:=TProcess.Create(nil);
      AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
      AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      AProcess.Free;

      WriteLn('Lese Partitionen von /proc/partitions (nur bei bereits installiertem root moeglich!)');
      TmpFile.Add('"'+adb+'" shell cat /proc/partitions >'+Output+'\proc_partitions.tmp');
      TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
      AProcess:=TProcess.Create(nil);
      AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
      AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      AProcess.Free;

      WriteLn('Lese Mounts von /proc/mounts (nur bei bereits installiertem root moeglich!)');
      TmpFile.Add('"'+adb+'" shell cat /proc/mounts >'+Output+'\proc_mounts.tmp');
      TmpFile.SaveToFile(ChangeFileExt(ExeName,'.bat'));
      AProcess:=TProcess.Create(nil);
      AProcess.CommandLine:=ChangeFileExt(ExeName,'.bat');
      AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
      AProcess.Execute;
      AProcess.Free;

    end;

  if SuperUser.Count>0 then
    begin
      Info.Add('');
      Info.Add('Potentielle SuperUser Dateien:');
      Info.Add('------------------------------');
      Info.AddStrings(SuperUser);
    end;

  if HasOption('r','root') then
    begin
      if FileExists(Output+'\proc_mtd.tmp') then
        begin
          WriteLn('Partitionen von /proc/mtd (nur mit ADB Root Unterstuetzung moeglich!)');
          Info.Add('');
          Info.Add('Partitionen von /proc/mtd:');
          Info.Add('--------------------------');
          TmpFile.LoadFromFile(Output+'\proc_mtd.tmp');
          for i:=0 to TmpFile.Count-1 do
            begin
              if TmpFile.Strings[i]<>'' then
                begin
                  Info.Add(TmpFile.Strings[i]);
                  WriteLn(TmpFile.Strings[i]);
                end;
            end;
        end
      else
        begin
          WriteLn('Partitionen von /proc/mtd konnten nicht ausgelesenen werden (kein root)');
          Info.Add('');
        end;
      if FileExists(Output+'\proc_partitions.tmp') then
        begin
          WriteLn('Partitionen von /proc/partitions (nur mit ADB Root Unterstuetzung moeglich!)');
          Info.Add('');
          Info.Add('Partitionen von /proc/partitions:');
          Info.Add('---------------------------------');
          TmpFile.LoadFromFile(Output+'\proc_partitions.tmp');
          for i:=0 to TmpFile.Count-1 do
            begin
              if TmpFile.Strings[i]<>'' then
                begin
                  Info.Add(TmpFile.Strings[i]);
                  WriteLn(TmpFile.Strings[i]);
                end;
            end;
        end
      else
        begin
          WriteLn('Partitionen von /proc/partitions konnten nicht ausgelesenen werden (kein root)');
          Info.Add('');
        end;
      if FileExists(Output+'\proc_mounts.tmp') then
        begin
          WriteLn('Partitionen von /proc/mounts (nur mit ADB Root Unterstuetzung moeglich!)');
          Info.Add('');
          Info.Add('Partitionen von /proc/mounts:');
          Info.Add('-----------------------------');
          TmpFile.LoadFromFile(Output+'\proc_mounts.tmp');
          for i:=0 to TmpFile.Count-1 do
            begin
              if TmpFile.Strings[i]<>'' then
                begin
                  Info.Add(TmpFile.Strings[i]);
                  WriteLn(TmpFile.Strings[i]);
                end;
            end;
        end
      else
        begin
          WriteLn('Partitionen von /proc/mounts konnten nicht ausgelesenen werden (kein root)');
          Info.Add('');
        end;
    end;

  if (Model='') and (Build='') then
    InfoFile:=Output+'\Info.txt'
  else
    InfoFile:=Output+'\'+Model+'_'+Build+'.txt';
  Info.SaveToFile(InfoFile);

  WriteLn('');
  WriteLn('');
  writeln(Separator);
  WriteLn('Loesche temporaere Dateien');
  writeln(Separator);
  WriteLn('');
  if FileExists(ChangeFileExt(ExeName,'.bat')) then
    begin
      DeleteFile(ChangeFileExt(ExeName,'.bat'));

    end;
  if FileExists(Output+'\build.prop.tmp') then
    begin
      DeleteFile(Output+'\build.prop.tmp');
      WriteLn(Output+'\build.prop.tmp');
    end;
  if FileExists(Output+'\bin.tmp') then
    begin
      DeleteFile(Output+'\bin.tmp');
      WriteLn(Output+'\bin.tmp');
    end;
  if FileExists(Output+'\sbin.tmp') then
    begin
      DeleteFile(Output+'\sbin.tmp');
      WriteLn(Output+'\sbin.tmp');
    end;
  if FileExists(Output+'\xbin.tmp') then
    begin
      DeleteFile(Output+'\xbin.tmp');
      WriteLn(Output+'\xbin.tmp');
    end;
  if FileExists(Output+'\system_bin.tmp') then
    begin
      DeleteFile(Output+'\system_bin.tmp');
      WriteLn(Output+'\system_bin.tmp');
    end;
  if FileExists(Output+'\system_sbin.tmp') then
    begin
      DeleteFile(Output+'\system_sbin.tmp');
      WriteLn(Output+'\system_sbin.tmp');
    end;
  if FileExists(Output+'\system_xbin.tmp') then
    begin
      DeleteFile(Output+'\system_xbin.tmp');
      WriteLn(Output+'\system_xbin.tmp');
    end;
  if FileExists(Output+'\proc_mtd.tmp') then
    begin
      DeleteFile(Output+'\proc_mtd.tmp');
      WriteLn(Output+'\proc_mtd.tmp');
    end;
  if FileExists(Output+'\proc_partitions.tmp') then
    begin
      DeleteFile(Output+'\proc_partitions.tmp');
      WriteLn(Output+'\proc_partitions.tmp');
    end;
  if FileExists(Output+'\proc_mounts.tmp') then
    begin
      DeleteFile(Output+'\proc_mounts.tmp');
      WriteLn(Output+'\proc_mounts.tmp');
    end;
  TmpFile.Free;
  SuperUser.Free;
  Info.Free;

  WriteLn('');
  WriteLn('');
  writeln(Separator);
  WriteLn('Beende ADB');
  writeln(Separator);
  WriteLn('');
  AProcess:=TProcess.Create(nil);
  AProcess.CommandLine:='"'+adb+'" kill-server';
  AProcess.Options:=AProcess.Options + [poWaitOnExit, poUsePipes];
  AProcess.Execute;
  AProcess.Free;

  WriteLn('');
  WriteLn('');
  writeln(Separator);
  WriteLn('Beende AndroidInfo V'+Version);
  writeln(Separator);
  WriteLn('');

  if HasOption('s','show') then
    begin
      if FileExists(InfoFile)=true then
        begin
          AProcess:=TProcess.Create(nil);
          AProcess.CommandLine:='Notepad "'+InfoFile+'"';
          AProcess.Options:=AProcess.Options + [];
          AProcess.Execute;
          AProcess.Free;
        end;

    end;

  // stop program loop
  Terminate;
end;

constructor TAndroidInfo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TAndroidInfo.Destroy;
begin
  inherited Destroy;
end;

procedure TAndroidInfo.WriteHelp;
begin
  { add your help code here }
  writeln('AndroidInfo liest Systeminfos aus einem Android Geraet.');
  writeln('');
  writeln('Hilfe:           -h oder --help');
  writeln('ADB:             -a <Pfad_zur_ADB.EXE> oder --adb=<Pfad_zur_ADB.EXE>');
  writeln('Ausgabe:         -o <Ausgabeordner> oder --output=<Ausgabeordner>');
  writeln('Info zeigen:     -s oder --show');
  writeln('ADB Root nutzen: -r oder --root (muss vom Geraet unterstuetzt sein,');
  writeln('                 sonst wird das Programm nicht durchlaufen)');
end;

var
  Application: TAndroidInfo;

{$R *.res}

begin
  Application:=TAndroidInfo.Create(nil);
  Application.Run;
  Application.Free;
end.

