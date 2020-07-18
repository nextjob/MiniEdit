{ This file is part of CodeSharkFCs

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,Boston, MA 02110 USA
}

unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TFrmSettings = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    FileExtLBL: TLabel;
    GutterCB: TCheckBox;
    NbrsOnGutterCB: TCheckBox;
    FilterPanel: TPanel;
    FilterOnOpenCB: TCheckBox;
    FilterOnSendCB: TCheckBox;
    FilterOnReceiveCB: TCheckBox;
    RemoveSpacesCB: TCheckBox;
    Clear1stBlockCB: TCheckBox;
    AddPercentCB: TCheckBox;
    FileExtLBX: TListBox;
    ForceUpperCaseCB: TCheckBox;

    procedure FileExtLBXClick(Sender: TObject);
    procedure GutterCBClick(Sender: TObject);
    procedure NbrsOnGutterCBClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSettings: TFrmSettings;

implementation

Uses
  srcMain;

{$R *.dfm}

procedure TFrmSettings.FileExtLBXClick(Sender: TObject);
begin
  case FileExtLBX.ItemIndex of
    0:
      FrmMain.DefaultFileExtension := 'G';
    1:
      FrmMain.DefaultFileExtension := 'T';
    2:
      FrmMain.DefaultFileExtension := 'TXT';
    3:
      FrmMain.DefaultFileExtension := 'NC';
    4:
      FrmMain.DefaultFileExtension := 'PRO';
    5:
      FrmMain.DefaultFileExtension := '';
  end;
end;


procedure TFrmSettings.GutterCBClick(Sender: TObject);
begin
  FrmMain.GutterExecute;
end;

procedure TFrmSettings.NbrsOnGutterCBClick(Sender: TObject);
begin
  FrmMain.GutterExecute;
end;


End.
