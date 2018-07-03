unit btnunit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, db, FileUtil, PrintersDlgs, Forms, Controls, Graphics,
  Dialogs, DBGrids, DbCtrls, StdCtrls, Buttons, LR_Class, LR_DBSet, LR_E_CSV,
  LR_View, Printers, LR_DSet;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    CBEtab: TComboBox;
    CBCommission: TComboBox;
    CBSerie: TComboBox;
    DataSource1: TDataSource;
    Dbf1: TDbf;
    DBGrid1: TDBGrid;
    frDBDataSet1: TfrDBDataSet;
    frPreview1: TfrPreview;
    frReport1: TfrReport;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    PrintDialog1: TPrintDialog;
    ToggleBox1: TToggleBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure CBCommissionChange(Sender: TObject);
    procedure CBEtabChange(Sender: TObject);
    procedure CBSerieChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure frDBDataSet1CheckEOF(Sender: TObject; var Eof: Boolean);
    procedure ToggleBox1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
{---------Procedures outils---------------}
Procedure RajouteSiAbsent(var Chaine : string; var Combo: TComboBox);
var
  i : integer;
  present : boolean;
begin
  i:=0;
  present:=false;
  while (not present) and (i< Combo.Items.Count) do
  begin
    if Combo.Items[i]=Chaine then present := True;
    inc(i);
  end;
  if not present then Combo.Items.add(Chaine);
end;

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

Procedure LitEtablissements;
var
  Etab : string;
  i : integer;
  present : boolean;
Begin
  Form1.Dbf1.Filtered:=False;
  Form1.Dbf1.first;
  while not Form1.Dbf1.EOF do
  begin
    // en 2018 c'est le champ n° 4 !!!
    //Etab:=Form1.Dbf1.Fields[4].AsString;
    Etab:=Form1.Dbf1.FieldByName('NOM_DU_CEN').AsString;
    RajouteSiAbsent(Etab,Form1.CBEtab);
    Form1.Dbf1.next;
  end;
  Form1.Label1.Caption:=IntToStr(Form1.CBEtab.Items.Count)+' établissements recensés.';
  Form1.Label1.visible:=True;
end;

procedure TForm1.Button1Click(Sender: TObject);

begin
  LitEtablissements;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  frReport1.LoadFromFile('rapportEA.lrf');

  //frReport1.ChangePrinter(1,4);
  frReport1.PrepareReport;
  frReport1.ShowReport;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i : integer;
  ind: Integer;

begin
  for i := 0 to Form1.CBCommission.Items.Count-1 do
  begin
    //frReport1.ChangePrinter(ind, 4);
    Dbf1.Filtered:=False;
    Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
    +' AND NUM_RO_DE_ = "'+CBCommission.Items[i]+'"';
    Dbf1.Filtered:=True;
    frReport1.LoadFromFile('rapportBTN.lrf');
    frReport1.Title:='BAC2018-'+CBCommission.Items[i];
    frReport1.PrepareReport;
    frReport1.PrintPreparedReport('1-99',1);
  end;


end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  LitEtablissements;
  CBEtab.ItemIndex:=0;
  while CBEtab.Text <> 'L P VALERY SETE' do
  begin
    CBEtab.ItemIndex:=CBEtab.ItemIndex+1;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Dbf1.active:=True;
end;

procedure TForm1.Button6Click(Sender: TObject);
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
  Memo1.Lines.Add('réparties en '+IntToStr(CBCommission.Items.Count)+' commissions.');
  Memo1.Lines.Add('');
  somme:=0;
  for i:=0 to CBCommission.Items.Count-1 do
  begin
    Dbf1.Filtered:=False;
    Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
      +' AND NUM_RO_DE_ = "'+CBCommission.Items[i]+'"';
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

procedure TForm1.Button7Click(Sender: TObject);
var
  i,j : integer;
begin
  // impression des bordereaux par série
  for i := 0 to Form1.CBCommission.Items.Count-1 do
    for j := 0 to   Form1.CBSerie.Items.Count-1 do
    begin
      //frReport1.ChangePrinter(ind, 4);
      Dbf1.Filtered:=False;
      Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
      +' AND NUM_RO_DE_ = "'+ CBCommission.Items[i] +'"'
      +' AND S_RIE = "'+ CBSerie.Items[j] +'"'
      ;
      Dbf1.Filtered:=True;
      // on cherche si la table est vide
      Form1.Dbf1.first;
      if not Form1.Dbf1.EOF then
        begin
        frReport1.LoadFromFile('rapportBTN.lrf');
        frReport1.Title:='BAC2018-'+CBCommission.Items[i]+
          '-Serie('+ CBSerie.Items[j] +')';
        frReport1.PrepareReport;
        frReport1.PrintPreparedReport('1-99',1);

        end;
    end;
end;

procedure TForm1.CBCommissionChange(Sender: TObject);
begin
  Dbf1.Filtered:=False;
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
    +' AND NUM_RO_DE_ = "'+CBCommission.Text+'"';
  Dbf1.Filtered:=True;
  Label3.Caption := IntToStr(NbEnregistrements)+' candidats recensés.';
  Label3.visible:=True;
end;



procedure TForm1.BitBtn1Click(Sender: TObject);
var
  Commission, Serie : string;

begin
  Form1.Dbf1.Filtered:=False;
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"';
  Dbf1.Filtered:=True;
  Form1.Dbf1.first;
  while not Form1.Dbf1.EOF do
  begin
    Commission:=Form1.Dbf1.FieldByName('NUM_RO_DE_').AsString;
    Serie:= Form1.Dbf1.FieldByName('S_RIE').AsString;
    RajouteSiAbsent(Commission,CBCommission);
    RajouteSiAbsent(Serie,CBSerie);
    Form1.Dbf1.next;
  end;
  Label2.Caption:=IntToStr(Form1.CBCommission.Items.Count)+' commissions recensées.';
  Label2.visible:=True;
end;

procedure TForm1.CBEtabChange(Sender: TObject);
begin
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"';
  Dbf1.Filtered:=True;
end;

procedure TForm1.CBSerieChange(Sender: TObject);
begin
  Dbf1.Filtered:=False;
  Dbf1.Filter:='NOM_DU_CEN = "'+CBEtab.Text+'"'
    +' AND NUM_RO_DE_ = "'+CBCommission.Text+'"'
    +' AND S_RIE = "'+ CBSerie.Text +'"'
    ;
  Dbf1.Filtered:=True;
  Label3.Caption := IntToStr(NbEnregistrements)+' candidats recensés.';
  Label3.visible:=True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.frDBDataSet1CheckEOF(Sender: TObject; var Eof: Boolean);
begin

end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
begin

end;



end.

