{ This file is part of CodeSharkFCs
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
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
