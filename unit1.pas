unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, db, FileUtil, PrintersDlgs, Forms, Controls, Graphics,
  Dialogs, DBGrids, DbCtrls, StdCtrls, Buttons, LR_Class, LR_DBSet, LR_E_CSV,
  LR_View, Printers;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    CBEtab: TComboBox;
    CBCommission: TComboBox;
    DataSource1: TDataSource;
    Dbf1: TDbf;
    DBGrid1: TDBGrid;
    frCSVExport1: TfrCSVExport;
    frDBDataSet1: TfrDBDataSet;
    frPreview1: TfrPreview;
    frReport1: TfrReport;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    PrintDialog1: TPrintDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

    procedure CBCommissionChange(Sender: TObject);
    procedure CBEtabChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
Function NbEnregistrements : LongInt;
var i : LongInt;
begin
  Form1.Dbf1.First;
  i:=0;
  while not Form1.Dbf1.Eof do
  begin
    inc(i);
    Form1.Dbf1.Next;
  end;
  NbEnregistrements:=i;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Etab : string;
  i : integer;
  present : boolean;
begin
  Form1.Dbf1.Filtered:=False;
  Form1.Dbf1.first;
  while not Form1.Dbf1.EOF do
  begin
    Etab:=Form1.Dbf1.Fields[4].AsString;
    i:=0;
    present:=false;
    while (not present) and (i< Form1.CBEtab.Items.Capacity) do
    begin
      if Form1.CBEtab.Items[i]=Etab then present := True;
      inc(i);
    end;
    if not present then Form1.CBEtab.Items.add(Etab);
    Form1.Dbf1.next;
  end;
  Label1.Caption:=IntToStr(Form1.CBEtab.Items.Capacity)+' établissements recensés.';
  Label1.visible:=True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  frReport1.LoadFromFile('rapport1.lrf');

  frReport1.ChangePrinter(1,4);
  frReport1.PrepareReport;
  frReport1.ShowReport;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i : integer;
  ind: Integer;

begin
  {ind:= Printer.PrinterIndex;
  with PrintDialog1 do
  begin
    Options:=[poPageNums ]; // allows selecting pages/page numbers
    Copies:=1;
    Collate:=true; // ordened copies
    FromPage:=1; // start page
    ToPage:=frReport1.EMFPages.Count; // last page
    MaxPage:=frReport1.EMFPages.Count; // maximum allowed number of pages
    if Execute then // show dialog; if succesful, process user feedback
    begin
      if (Printer.PrinterIndex <> ind ) // verify if selected printer has changed
        or frReport1.CanRebuild // ... only makes sense if we can reformat the report
        or frReport1.ChangePrinter(ind, Printer.PrinterIndex) //... then change printer
        then
        frReport1.PrepareReport //... and reformat for new printer
      else
        exit; // we couldn't honour the printer change
    end;
  end;
  if frReport1.ChangePrinter(ind, Printer.PrinterIndex) then
    label3.caption:='Imprimante : '+printer.binName+'('+intToStr(printer.PrinterIndex)+')'
  else
  label3.caption:='Désolé, imprimante non changée.';
  label3.visible:=True;}
  for i := 0 to Form1.CBCommission.Items.Count-1 do
  begin
    //frReport1.ChangePrinter(ind, 0);
    Dbf1.Filtered:=False;
    Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
      +' AND N__DE_LA_C = "'+CBCommission.Items[i]+'"';
    Dbf1.Filtered:=True;
    frReport1.LoadFromFile('rapport1.lrf');
    frReport1.Title:='BAC2018-EA-'+CBCommission.Items[i];
    frReport1.PrepareReport;
    frReport1.PrintPreparedReport('1-99',1);
  end;


end;

procedure TForm1.Button4Click(Sender: TObject);
var
  Etab : String;
  i : integer;
  present : boolean;
begin
  Form1.Dbf1.Filtered:=False;
  Form1.Dbf1.first;
  while not Form1.Dbf1.EOF do
  begin
    Etab:=Form1.Dbf1.Fields[4].AsString;
    i:=0;
    present:=false;
    while (not present) and (i< Form1.CBEtab.Items.Capacity) do
    begin
      if Form1.CBEtab.Items[i]=Etab then present := True;
      inc(i);
    end;
    if not present then Form1.CBEtab.Items.add(Etab);
    Form1.Dbf1.next;
  end;
  Label1.Caption:=IntToStr(Form1.CBEtab.Items.Capacity)+' établissements recensés.';
  Label1.visible:=True;
  Dbf1.Filter:='NOM_DU_CEN = "L PAUL VALERY SETE"';
  Dbf1.Filtered:=True;
  CBEtab.ItemIndex:=0;
  while CBEtab.Text <> 'L PAUL VALERY SETE' do
  begin
    CBEtab.ItemIndex:=CBEtab.ItemIndex+1;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i,n, somme : integer;
begin
  Memo1.Lines.Add('HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH');
  Memo1.Lines.Add('H         Académie de montpellier          H');
  Memo1.Lines.Add('HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(IntToStr(CBEtab.Items.count)+' centres d''examen.');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH');
  Memo1.Lines.Add('H            Lycée Paul Valéry             H');
  Memo1.Lines.Add('');
  Dbf1.Filtered:=False;
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"';
  Dbf1.Filtered:=True;
  n:= NbEnregistrements;
  Memo1.Lines.Add(IntToStr(n)+' convocations,');
  Memo1.Lines.Add('répartis en '+IntToStr(CBCommission.Items.Count)+' commissions.');
  Memo1.Lines.Add('');
  somme:=0;
  for i:=0 to CBCommission.Items.Count-1 do
  begin
    Dbf1.Filtered:=False;
    Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
      +' AND N__DE_LA_C = "'+CBCommission.Items[i]+'"';
    Dbf1.Filtered:=True;
    Memo1.Lines.Add('  Commission  : '+CBCommission.Items[i]+' --> '
      +IntToStr(nbEnregistrements)+' candidats.');
    somme := somme + nbEnregistrements;
  end;
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH');
  Memo1.Lines.Add('somme de contrôle : '+intToStr(somme));

end;


procedure TForm1.CBCommissionChange(Sender: TObject);
begin
  Dbf1.Filtered:=False;
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
    +' AND N__DE_LA_C = "'+CBCommission.Text+'"';
  Dbf1.Filtered:=True;
  Label3.Caption := IntToStr(NbEnregistrements)+' candidats recensés.';
  Label3.visible:=True;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  Commission : string;
  i : integer;
  present : boolean;
begin
  Form1.Dbf1.Filtered:=False;
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"';
  Dbf1.Filtered:=True;
  Form1.Dbf1.first;
  while not Form1.Dbf1.EOF do
  begin
    Commission:=Form1.Dbf1.Fields[6].AsString;
    i:=0;
    present:=false;
    while (not present) and (i< Form1.CBCommission.Items.Capacity) do
    begin
      if Form1.CBCommission.Items[i]=Commission then present := True;
      inc(i);
    end;
    if not present then Form1.CBCommission.Items.add(Commission);
    Form1.Dbf1.next;
  end;
  Label2.Caption:=IntToStr(Form1.CBCommission.Items.Capacity)+' commissions recensées.';
  Label2.visible:=True;
end;

procedure TForm1.CBEtabChange(Sender: TObject);


begin



end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;



end.

