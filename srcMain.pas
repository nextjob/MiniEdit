{ This file is part of CodeSharkME
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

unit srcMain;

{$I SynEdit.inc}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.IOUtils, IniFiles,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SynEdit, Vcl.Menus, Vcl.StdActns,
  Vcl.ActnList, System.Actions, Vcl.ActnPopup, Vcl.ToolWin, Vcl.ActnMan,
  Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls, SynEditPrint,
  System.ImageList,
  Vcl.ImgList, Vcl.ComCtrls, SynEditSearch, SynEditMiscClasses,
  SynEditRegexSearch, Vcl.ExtCtrls;

type
  TFrmMain = class(TForm)
    ActionManager1: TActionManager;
    ActionMainMenuBar1: TActionMainMenuBar;
    PopupActionBar1: TPopupActionBar;
    FileOpen1: TFileOpen;
    FileSaveAs1: TFileSaveAs;
    FilePrintSetup1: TFilePrintSetup;
    FilePageSetup1: TFilePageSetup;
    FileExit1: TFileExit;
    DialogPrintDlg1: TPrintDlg;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditUndo1: TEditUndo;
    EditDelete1: TEditDelete;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    DialogFontEdit1: TFontEdit;
    ActSave: TAction;
    SynEditPrint1: TSynEditPrint;
    N1: TMenuItem;
    N2: TMenuItem;
    ToolBarMain: TToolBar;
    ToolButtonSearch: TToolButton;
    ToolButtonSeparator2: TToolButton;
    ToolButtonSearchReplace: TToolButton;
    ImageListMain: TImageList;
    ActionListMain: TActionList;
    ActionFileOpen: TAction;
    ActionSearch: TAction;
    ActionSearchNext: TAction;
    ActionSearchPrev: TAction;
    ActionSearchReplace: TAction;
    Statusbar: TStatusBar;
    SynEditSearch: TSynEditSearch;
    ToolButtonSearchNext: TToolButton;
    ToolButtonSearchPrev: TToolButton;
    ToolButtonSep1: TToolButton;
    ToolButtonSep2: TToolButton;
    ToolButtonSep4: TToolButton;
    About: TAction;
    New: TAction;
    ProgramSettings: TAction;
    ToolButtonFileOpen: TToolButton;
    SynEditRegexSearch: TSynEditRegexSearch;
    SynEdit: TSynEdit;
    procedure FileOpen1Accept(Sender: TObject);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure ActSaveExecute(Sender: TObject);
    procedure DialogPrintDlg1Accept(Sender: TObject);
    procedure DialogFontEdit1FontDialogApply(Sender: TObject; Wnd: HWND);
    procedure GutterExecute;
    procedure DialogFontEdit1BeforeExecute(Sender: TObject);

    procedure ActionSearchExecute(Sender: TObject);
    procedure ActionSearchNextExecute(Sender: TObject);
    procedure ActionSearchPrevExecute(Sender: TObject);
    procedure ActionSearchReplaceExecute(Sender: TObject);
    procedure actSearchUpdate(Sender: TObject);
    procedure ActionSearchReplaceUpdate(Sender: TObject);
    procedure SynEditorReplaceText(Sender: TObject;
      const ASearch, AReplace: UnicodeString; Line, Column: Integer;
      var Action: TSynReplaceAction);
    procedure ShowFileName;
    procedure SetDefaultFileExtension;
    Procedure LoadIni(Inif: TCustomIniFile);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    Procedure CNCFileFilter(FileToFilter: STRING);
    procedure FileOpen1BeforeExecute(Sender: TObject);
    procedure NewExecute(Sender: TObject);
    procedure SaveExistingEditSession;
    procedure AboutExecute(Sender: TObject);
    procedure ProgramSettingsExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    Procedure ProcessCommandLine(Sender: TObject);
    procedure SynEditKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
    FSearchFromCaret: Boolean;
    procedure DoSearchReplaceText(AReplace: Boolean; ABackwards: Boolean);
    procedure ShowSearchReplaceDialog(AReplace: Boolean);
  public

    { Public declarations }
    EditFileNameWithPath: String;
    AppDataPath: string;

    DefaultFileExtension: String;
    // Default File Extension used on open / save dialogs
  end;

var
  FrmMain: TFrmMain;
  // flags set in SetFCparms, read from CodeSharkFC.ini
  LicenseRead: Boolean; // if set do not show about screen on startup
  FirstPassOnActive: Boolean;
  // First Pass Flag for On Active Event - for code we only want to execute once.

  // Search / Replace Flags
  // options - to be saved to the registry
  gbSearchBackwards: Boolean;
  gbSearchCaseSensitive: Boolean;
  gbSearchFromCaret: Boolean;
  gbSearchSelectionOnly: Boolean;
  gbSearchTextAtCaret: Boolean;
  gbSearchWholeWords: Boolean;
  gbSearchRegex: Boolean;

  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

const
  MyAppName = 'CodeSharkME';
  AppDataName = PathDelim + MyAppName;
  IniFileName = PathDelim + 'CodeSharkME.ini';

  CurVersion = '0.00';

  DialogFileExtensionFilter =
    'G Code Files (*.G)|*.G|Tape Files (*.T)|*.T|Text Files (*.TXT)|*.TXT|NC Files (*.NC)|*.NC|Program Files (*.PRO)|*.PRO|All Files (*.*)|*.*';
  // ini file sections
  MainSection = 'Window';
  FontSection = 'Font';
  ColorsSection = 'Colors';
  DefaultsSection = 'Defaults';
  SetupSection = 'Setup';
  FilterSection = 'FileFilter';
  NOF = '--nof--';

  STextNotFound = 'Text not found';

implementation

{$R *.DFM}

uses
  ShellAPI, ShlObj,  About, 
  Settings, 
  dlgSearchText, dlgReplaceText, dlgConfirmReplace, plgSearchHighlighter,
  SynEditTypes, SynEditMiscProcs;



procedure TFrmMain.ShowFileName;
begin
  FrmMain.Caption := EditFileNameWithPath + ' - ' + MyAppName;
end;

procedure TFrmMain.GutterExecute;
begin
  SynEdit.Gutter.Visible := FrmSettings.GutterCB.Checked;
  SynEdit.Gutter.ShowLineNumbers := FrmSettings.NbrsOnGutterCB.Checked;
end;

procedure TFrmMain.ActSaveExecute(Sender: TObject);
// save menu item clicked on
begin
  if EditFileNameWithPath = '' then
    FileSaveAs1.Execute
  else
    SynEdit.Lines.SaveToFile(EditFileNameWithPath);
end;

procedure TFrmMain.DialogFontEdit1BeforeExecute(Sender: TObject);
begin
  DialogFontEdit1.Dialog.Font := SynEdit.Font;
end;

procedure TFrmMain.DialogFontEdit1FontDialogApply(Sender: TObject; Wnd: HWND);
begin
  SynEdit.Font.Assign(DialogFontEdit1.Dialog.Font);
end;

procedure TFrmMain.DialogPrintDlg1Accept(Sender: TObject);
begin
  SynEditPrint1.SynEdit := SynEdit;
  SynEditPrint1.Print;
end;

procedure TFrmMain.FileOpen1Accept(Sender: TObject);
Var
  TmpFl: TFileName;

begin
  EditFileNameWithPath := FileOpen1.Dialog.FileName;

  If FrmSettings.FilterOnOpenCB.Checked Then
  Begin
    TmpFl := TPath.GetTempFileName;
    If NOT CopyFile(PChar(EditFileNameWithPath), PChar(TmpFl), FALSE) Then
    Begin
      ShowMessage('File Open - Copy Read only Failed - ' +
        SysErrorMessage(GetLastError));
      exit;
    End;
    //
    // now perform the filefilter
    //
    CNCFileFilter(TmpFl);
    SynEdit.Lines.LoadFromFile(TmpFl);
    DeleteFile(TmpFl)

  End
  Else
    SynEdit.Lines.LoadFromFile(EditFileNameWithPath);
  ShowFileName;
end;

procedure TFrmMain.FileOpen1BeforeExecute(Sender: TObject);
begin
  // is there data in the editor window and has it changed?
  SaveExistingEditSession;
  FileOpen1.Dialog.FileName := '';
end;

procedure TFrmMain.FileSaveAs1Accept(Sender: TObject);
begin
  EditFileNameWithPath := FileSaveAs1.Dialog.FileName;
  SynEdit.Lines.SaveToFile(EditFileNameWithPath);
end;

procedure TFrmMain.SaveExistingEditSession;
//
// do we have an existing edit session that should be saved?
Begin
  if SynEdit.Modified then
    if EditFileNameWithPath = '' then
      FileSaveAs1.Execute
    else
      case MessageDlg('Save changes to "' +
        ExtractFileName(EditFileNameWithPath) + '"?', mtConfirmation,
        mbYesNoCancel, 0) of
        mrYes:
          SynEdit.Lines.SaveToFile(EditFileNameWithPath);
      end

End;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Inif: TCustomIniFile;
  ParityStr: String; // string reprentaton of com values for com port
  Swflow, HwFlow: String;

begin

  SaveExistingEditSession;

  try
    Inif := TMemIniFile.Create(AppDataPath + IniFileName);
    // setup section
    Inif.WriteBool(SetupSection, 'LicenseRead', LicenseRead);

    // save general settings
    Inif.WriteInteger(MainSection, 'Width', Width);
    Inif.WriteInteger(MainSection, 'Height', Height);
    Inif.WriteInteger(MainSection, 'Top', Top);
    Inif.WriteInteger(MainSection, 'Left', Left);
    Inif.WriteInteger(MainSection, 'State', ord(WindowState));
       // maxamized or sized window at close of app

    // synedt settings
    Inif.WriteString(FontSection, 'Type', SynEdit.Font.name);
    Inif.WriteInteger(FontSection, 'Size', SynEdit.Font.Size);
    Inif.WriteInteger(FontSection, 'Color', SynEdit.Font.Color);

    // FileFiler
    Inif.WriteBool(FilterSection, 'FilterOnOpen',
      FrmSettings.FilterOnOpenCB.Checked);
    Inif.WriteBool(FilterSection, 'FilterOnReceive',
      FrmSettings.FilterOnReceiveCB.Checked);
    Inif.WriteBool(FilterSection, 'FilterOnSend',
      FrmSettings.FilterOnSendCB.Checked);
    Inif.WriteBool(FilterSection, 'AddPercent',
      FrmSettings.AddPercentCB.Checked);
    Inif.WriteBool(FilterSection, 'Clear1stBlock',
      FrmSettings.Clear1stBlockCB.Checked);
    Inif.WriteBool(FilterSection, 'RemoveSpaces',
      FrmSettings.RemoveSpacesCB.Checked);

    // defaults
    Inif.WriteString(DefaultsSection, 'DfltFileExt', DefaultFileExtension);
    Inif.WriteBool(DefaultsSection, 'GutterVisible',
      FrmSettings.GutterCB.Checked);
    Inif.WriteBool(DefaultsSection, 'NbrsOnGutter',
      FrmSettings.NbrsOnGutterCB.Checked);
    Inif.WriteBool(DefaultsSection, 'ForceUpperCase',FrmSettings.ForceUpperCaseCB.Checked);
  Finally
    Inif.UpdateFile;
    Inif.Free;
    // Except
    // ShowMessage('error updating ' + AppDataPath + IniFileName);
  end;

end;

procedure TFrmMain.FormCreate(Sender: TObject);

begin
  // get the location of the ini file
  AppDataPath := TPath.GetCachePath;

  if AppDataPath = NOF then
  Begin
    AppDataPath := ExtractFilePath(ParamStr(0));
    ShowMessage('Unable to Locate CSIDL_APPDATA , This is not Good! Using ' +
      AppDataPath);
  end;

  AppDataPath := AppDataPath + '\' + MyAppName;
  // does the application's data directory exist?
  if not TDirectory.Exists(AppDataPath) then
  Begin
    ShowMessage(AppDataPath + ' Does not exist, Creating');
    TDirectory.CreateDirectory(AppDataPath);
  End;

    //
  EditFileNameWithPath := ''; // just started, set to empty

  // setup the highlighter
  with TSearchTextHightlighterSynEditPlugin.Create(SynEdit) do
  begin
    Attribute.Background := $0078AAFF;
  end;


end;

Procedure TFrmMain.FormShow(Sender: TObject);
var
  Inif: TCustomIniFile;
  MyAbout: TForm;

begin
  LicenseRead := FALSE; // license acceptance?

  try
    Inif := TMemIniFile.Create(AppDataPath + IniFileName);
    // note: a TMemIniFile is believed to be more efficient than TIniFile

    LicenseRead := Inif.ReadBool(SetupSection, 'LicenseRead', FALSE);

    if not(LicenseRead) then
      AboutBox.ShowModal;
    LoadIni(Inif);
  finally
    Inif.Free;
  end;
  //
  if not(LicenseRead) then
  begin
    ShowMessage('License Not Accepted, Terminating Appliation');
    Application.Terminate;
  end;
  //
  SetDefaultFileExtension;
  GutterExecute;
  ProcessCommandLine(self);
 end;

Procedure TFrmMain.ProcessCommandLine(Sender: TObject);
var
 Cline,LicFl,Cvalue:string;
 clx,fvalue:integer;
 OpenFileName : TFileName;

Begin
  OpenFileName := '';
//  get command line parameters
 if ParamCount <> 0 then
  begin
    clx:= 1;    // command line parameter index
    While clx + 1 <= ParamCount do
// look for form positioning
    begin
      CLine:=Paramstr(clx);      //get command line parameter name
      CLine:=UpperCase(CLine);
      inc(clx);
      CValue:=Paramstr(clx);     //get command line parameter value
      if Cline <> 'FILENAME' then
        try
          fvalue := StrToint(Cvalue);
        except
          ShowMessage('Invalid Command Value ' + Cvalue + 'Command Line Ignored');
          break;
        end;



      if Cline = 'TOP' then
        FrmMain.Top := fvalue
      else if Cline = 'LEFT' then
        FrmMain.Left := fvalue
      else if Cline = 'WIDTH' then
        FrmMain.Width := fvalue
      else if Cline = 'HEIGHT' then
        FrmMain.Height := fvalue
      else if Cline = 'FILENAME' then
        OpenFileName := CValue
      else
        begin
          ShowMessage('Invalid Command Value ' + Cline + 'Command Line Ignored');
          break;
        end;
      inc(clx);
    end; // while clx < paramcount loop
  end; // param <> 0 test
 FrmMain.setfocus;
// FrmMain.GetSource.modified:=false;
// IsRunning:=true;
 if OpenFileName <> '' then
 Begin
   FileOpen1.Dialog.FileName := OpenFileName;
   FileOpen1Accept(self);
 //  Self.Caption := QcTitle+' [' + ODlg.Filename + ']';
 //  CMemo.GetSource.Modified :=false;
 End;

End;


Procedure TFrmMain.LoadIni(Inif: TCustomIniFile);
var

  MyFont: TFont;
  MyFontName: String;
  MyFontSize: Integer;
  MyFontColor: Integer;

Begin

   { load general settings }
  Width := Inif.ReadInteger(MainSection, 'Width', Width);
  Height := Inif.ReadInteger(MainSection, 'Height', Height);
  Top := Inif.ReadInteger(MainSection, 'Top', (Screen.Height - Height) div 2);
  Left := Inif.ReadInteger(MainSection, 'Left', (Screen.Width - Width) div 2);
  WindowState := TWindowState(Inif.ReadInteger(MainSection, 'State',
    ord(wsNormal)));
  
  // synedt settings
  MyFontName := Inif.ReadString(FontSection, 'Type', 'Courier');
  MyFontSize := Inif.ReadInteger(FontSection, 'Size', 12);
  MyFontColor := Inif.ReadInteger(FontSection, 'Color', clBlack);
  MyFont := SynEdit.Font;
  MyFont.Size := MyFontSize;
  MyFont.name := MyFontName;
  MyFont.Color := MyFontColor;
  SynEdit.Font.Assign(MyFont);
  // FileFiler
  FrmSettings.FilterOnOpenCB.Checked := Inif.ReadBool(FilterSection,
    'FilterOnOpen', FrmSettings.FilterOnOpenCB.Checked);
  FrmSettings.FilterOnReceiveCB.Checked := Inif.ReadBool(FilterSection,
    'FilterOnReceive', FrmSettings.FilterOnReceiveCB.Checked);
  FrmSettings.FilterOnSendCB.Checked := Inif.ReadBool(FilterSection,
    'FilterOnSend', FrmSettings.FilterOnSendCB.Checked);
  FrmSettings.AddPercentCB.Checked := Inif.ReadBool(FilterSection, 'AddPercent',
    FrmSettings.AddPercentCB.Checked);
  FrmSettings.Clear1stBlockCB.Checked := Inif.ReadBool(FilterSection,
    'Clear1stBlock', FrmSettings.Clear1stBlockCB.Checked);
  FrmSettings.RemoveSpacesCB.Checked := Inif.ReadBool(FilterSection,
    'RemoveSpaces', FrmSettings.RemoveSpacesCB.Checked);

  // defaults
  DefaultFileExtension := Inif.ReadString(DefaultsSection, 'DfltFileExt', 'T');
  FrmSettings.GutterCB.Checked := Inif.ReadBool(DefaultsSection,
    'GutterVisible', FrmSettings.GutterCB.Checked);
  FrmSettings.NbrsOnGutterCB.Checked := Inif.ReadBool(DefaultsSection,
    'NbrsOnGutter', FrmSettings.NbrsOnGutterCB.Checked);
  FrmSettings.ForceUpperCaseCB.Checked := Inif.ReadBool(DefaultsSection,
    'ForceUpperCase', FrmSettings.ForceUpperCaseCB.Checked);

  If DefaultFileExtension = 'G' Then
    FrmSettings.FileExtLBX.ItemIndex := 0
  Else If DefaultFileExtension = 'T' Then
    FrmSettings.FileExtLBX.ItemIndex := 1
  Else If DefaultFileExtension = 'TXT' Then
    FrmSettings.FileExtLBX.ItemIndex := 2
  Else If DefaultFileExtension = 'NC' Then
    FrmSettings.FileExtLBX.ItemIndex := 3
  Else If DefaultFileExtension = 'PRO' Then
    FrmSettings.FileExtLBX.ItemIndex := 4
  Else
    FrmSettings.FileExtLBX.ItemIndex := 5;

End;

procedure TFrmMain.NewExecute(Sender: TObject);
begin
  // is there data in the editor window and has it changed, if so save it
  SaveExistingEditSession;
  SynEdit.Clear;
  EditFileNameWithPath := '';
  ShowFileName;
end;



procedure TFrmMain.ProgramSettingsExecute(Sender: TObject);
begin
  FrmSettings.ShowModal;
end;




Procedure TFrmMain.SetDefaultFileExtension;

Var
  FilterIndex: Integer;
Begin
  // Set the file dialogs to the predefined filter text and Default extension
  // G Code Files (*.G)|*.G|Tape Files (*.T)|*.T|Text Files (*.TXT)|*.TXT|NC Files (*.NC)|*.NC|Program Files (*.PRO)|*.PRO|All Files (*.*)|*.*
  If FrmMain.DefaultFileExtension = 'G' Then
    FilterIndex := 1
  Else If FrmMain.DefaultFileExtension = 'T' Then
    FilterIndex := 2
  Else If FrmMain.DefaultFileExtension = 'TXT' Then
    FilterIndex := 3
  Else If FrmMain.DefaultFileExtension = 'NC' Then
    FilterIndex := 4
  Else If FrmMain.DefaultFileExtension = 'PRO' Then
    FilterIndex := 5
  Else
    FilterIndex := 6;


  FileOpen1.Dialog.Filter := DialogFileExtensionFilter;
  FileOpen1.Dialog.FilterIndex := FilterIndex;
  // FileOpen1.Dialog.InitialDir := ExtractFilePath(Application.ExeName);
  FileSaveAs1.Dialog.Filter := FileOpen1.Dialog.Filter;
  FileSaveAs1.Dialog.FilterIndex := FilterIndex;
  FileSaveAs1.Dialog.DefaultExt := DefaultFileExtension;

End;

{ event handler }


Procedure TFrmMain.CNCFileFilter(FileToFilter: STRING);
Var
  TmpFl, TmpFl2: TFileName; // temp files used during parse
  F1, F2: textfile;
  ChF1: File Of AnsiChar;
  Attrs, CharCount, StrPtr, lncount, LineLength: Integer;
  TermChar: Integer;
  // terminator character for filtered file (if not crlf terminateed)
  Tmpln, NewLn, LastLn: ANSISTRING;
  comment, Firstln, BOFfound, CrLfFound: Boolean;
  ch: AnsiChar;
  MBPrmpt: PChar;

Begin

  // test for valid file name
  If NOT FileExists(FileToFilter) Then
  Begin
    MBPrmpt := PChar('Filter File: ' + FileToFilter + ' Not Found');
    Application.MessageBox(MBPrmpt, 'CodeShark File Filter',
      MB_OK + MB_ICONWARNING + MB_TASKMODAL);
    exit;
  End
  Else
  Begin
    // if read only we cannot change !
    Attrs := FileGetAttr(FileToFilter);
    If Attrs AND faReadOnly <> 0 Then
    Begin
      MBPrmpt := PChar('FilterFile: ' + FileToFilter +
        ' Read Only, Filter Not Allowed');
      Application.MessageBox(MBPrmpt, 'CodeShark File Filter',
        MB_OK + MB_ICONWARNING + MB_TASKMODAL);
      exit;
    End;
  End;

  // create temp file names

  TmpFl := TPath.GetTempFileName;
  TmpFl2 := TPath.GetTempFileName;

  If NOT CopyFile(PChar(FileToFilter), PChar(TmpFl), FALSE) Then
  Begin
    ShowMessage('FilterFile: Failed To Create Copy ' +
      SysErrorMessage(GetLastError) + ' Filter Not Allowed');
    exit;
  End;
  //
  // pasre the file a single character at a time (looking to see if it is a true text file)
  //
  CrLfFound := FALSE;
  // ascii Cr &  line feed found (valid text file layout)
  System.AssignFile(ChF1, TmpFl); // fl is now file to parse
  Reset(ChF1);
  CharCount := 0; // character count
  TermChar := 0;
  While NOT Eof(ChF1) Do
  Begin
    Read(ChF1, ch);
    Inc(CharCount);
    // test for <cr>
    If ord(ch) = 13 Then
    Begin
      If NOT Eof(ChF1) Then
      Begin
        TermChar := 13;
        Read(ChF1, ch);
        Inc(CharCount);
        // now look for line feed
        If ord(ch) = 10 Then
        Begin
          CrLfFound := True
        End;
      End;
    End
    // it is possible that this is a line feed terminated file, is it?
    // because we have already check for the <cr><lf> pair in the above code, if we
    // hit a <lf> here we are pretty safe assuming a <lf> terminated file.
    Else If ord(ch) = 10 Then // line feed ??
    Begin
      TermChar := 10 // line feed terminated file
    End;

    If CrLfFound Then
    Begin
      Break
    End;
  End;
  //
  // Empty File ??
  If CharCount <= 0 Then
  Begin
    // ShowMessage('FileFilter: Empty File, No Action Taken');
    CloseFile(ChF1);
    DeleteFile(TmpFl);
    DeleteFile(TmpFl2);
    exit;
  End;
  //
  If (NOT CrLfFound) AND (TermChar = 0) AND (CharCount > 0) Then
  Begin
    ShowMessage
      ('FileFilter: Cannot Determine Termination Characer, no action taken');
    CloseFile(ChF1);
    DeleteFile(TmpFl);
    DeleteFile(TmpFl2);
    exit;
  End;
  //
  // if this file is not in standard text file format then ask if user want to convert to standard format (add cr lf)
  //
  If NOT CrLfFound Then
  //
  Begin
    If Application.MessageBox
      ('File is not in standard text file format (lines not CR & LF terminated). Would you like convert to standard text file format?',
      'File Filter Message', MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1 +
      MB_APPLMODAL) = ID_YES Then
    //
    // user wants file converted, do it
    //
    Begin
      AssignFile(F2, TmpFl2); // fl2 will be converted version
      Rewrite(F2);
      Reset(ChF1);
      NewLn := '';
      While NOT Eof(ChF1) Do
      Begin
        Read(ChF1, ch);
        If ord(ch) = TermChar Then
        // when we hit the term character, write out to new file
        Begin
          Writeln(F2, NewLn);
          NewLn := '';
        End
        Else
        Begin
          NewLn := NewLn + ch
        End;
      End; // while not eof loop
      CloseFile(ChF1); // This is TmpFl
      CloseFile(F2); // This is TmpFL2
      If NOT CopyFile(PChar(TmpFl2), PChar(TmpFl), FALSE) Then
      Begin
        ShowMessage('FileFilter Text File Conversion Failed - ' +
          SysErrorMessage(GetLastError));
        exit;
      End;
    End
    Else
    //
    // user does not want file converted, we cannot do a file filter, tell user this, clean up and exit
    //
    Begin
      ShowMessage
        ('Cannot Filter Files in none text file format, no action taken');
      CloseFile(ChF1);
      DeleteFile(TmpFl);
      DeleteFile(TmpFl2);
      exit;
    End
  End

  Else // crlf test

  Begin
    CloseFile(ChF1);
  End;
  //
  // now do the actual file filter procedure
  //
  AssignFile(F1, TmpFl); // fl is now file to parse
  Reset(F1);

  //
  AssignFile(F2, TmpFl2); // fl2 will be the cleaned version
  Rewrite(F2);
  Firstln := True; // First Line Flag
  BOFfound := FALSE; // First % found flag
  LastLn := '';
  lncount := 0; // line count
  // remove nulls, control codes,  spaces and blank lines

  While NOT Eof(F1) Do
  Begin
    Readln(F1, Tmpln);
    Inc(lncount);
    LineLength := Length(Tmpln);
    NewLn := '';
    comment := FALSE; // comment in block flag
    For StrPtr := 1 To LineLength Do // parse each character of the line
    Begin
      ch := Tmpln[StrPtr];
      // do we strip to first % ?

      If FrmSettings.Clear1stBlockCB.Checked Then
      Begin
        If NOT BOFfound Then
        Begin
          If ch = '%' Then
          Begin
            BOFfound := True
          End
          Else If lncount <= 1 Then
          Begin
            continue
          End
        End
      End; // only stirp to % on first line
      Case ch Of
        #0 .. #12:
          Begin
            continue
          End; // strip all ascii control codes except cr (0d)
        // #11..#12: continue;   // strip all ascii control codes except cr (0d)
        #14 .. #31:
          Begin
            continue
          End; // strip all ascii control codes
        #$20:
          Begin
            If comment Then
            Begin
              NewLn := NewLn + ch
            End // keep the spaces in comments
            Else If FrmSettings.RemoveSpacesCB.Checked Then
            Begin
              continue
            End // stip other spaces if option set
            Else
            Begin
              NewLn := NewLn + ch
            End
          End;
        '(':
          Begin
            comment := True; // set flag to not strip comments
            NewLn := NewLn + ch;
          End;
        // good character, save it
      Else
        Begin
          NewLn := NewLn + ch
        End; // this character ok, keep it
      End;
    End;
    If Length(NewLn) <> 0 Then
    Begin
      If Firstln Then
      // are we missing the starting %
      Begin
        If FrmSettings.AddPercentCB.Checked AND (NewLn[1] <> '%') Then
        Begin
          Writeln(F2, '%')
        End;
        Firstln := FALSE;
      End;
      LastLn := NewLn;
      Writeln(F2, NewLn);
    End;
  End;
  // did we end with a % ?
  If Length(LastLn) <> 0 Then
  Begin
    If (LastLn[1] <> '%') AND FrmSettings.AddPercentCB.Checked Then
    Begin
      LastLn := '%';
      Writeln(F2, LastLn);
    End
  End;
  // all done, close the file to allow access by dream memo
  CloseFile(F1);
  CloseFile(F2);
  // copy back to source file
  If NOT CopyFile(PChar(TmpFl2), PChar(FileToFilter), FALSE) Then
  Begin
    ShowMessage('FilterFile: ReWrite of ' + FileToFilter + ' ' +
      SysErrorMessage(GetLastError) + ', Filter Not Allowed');
    exit;
  End;
  DeleteFile(TmpFl);
  DeleteFile(TmpFl2);
End;


Procedure TFrmMain.AboutExecute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TFrmMain.ActionSearchExecute(Sender: TObject);
begin
  ShowSearchReplaceDialog(FALSE);
end;

procedure TFrmMain.ActionSearchNextExecute(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, FALSE);
end;

procedure TFrmMain.ActionSearchPrevExecute(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, True);
end;

procedure TFrmMain.ActionSearchReplaceExecute(Sender: TObject);
begin
  ShowSearchReplaceDialog(True);
end;

procedure TFrmMain.actSearchUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := gsSearchText <> '';
end;

procedure TFrmMain.ActionSearchReplaceUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (gsSearchText <> '') and not SynEdit.ReadOnly;
end;

procedure TFrmMain.DoSearchReplaceText(AReplace: Boolean; ABackwards: Boolean);
var
  Options: TSynSearchOptions;
begin
  Statusbar.SimpleText := '';
  if AReplace then
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not FSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    SynEdit.SearchEngine := SynEditRegexSearch
  else
    SynEdit.SearchEngine := SynEditSearch;
  if SynEdit.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    Statusbar.SimpleText := STextNotFound;
    if ssoBackwards in Options then
      SynEdit.BlockEnd := SynEdit.BlockBegin
    else
      SynEdit.BlockBegin := SynEdit.BlockEnd;
    SynEdit.CaretXY := SynEdit.BlockBegin;
  end;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TFrmMain.ShowSearchReplaceDialog(AReplace: Boolean);
var
  dlg: TTextSearchDialog;
begin
  Statusbar.SimpleText := '';
  if AReplace then
    dlg := TTextReplaceDialog.Create(self)
  else
    dlg := TTextSearchDialog.Create(self);
  with dlg do
    try
      // assign search options
      SearchBackwards := gbSearchBackwards;
      SearchCaseSensitive := gbSearchCaseSensitive;
      SearchFromCursor := gbSearchFromCaret;
      SearchInSelectionOnly := gbSearchSelectionOnly;
      // start with last search text
      SearchText := gsSearchText;
      if gbSearchTextAtCaret then
      begin
        // if something is selected search for that text
        if SynEdit.SelAvail and (SynEdit.BlockBegin.Line = SynEdit.BlockEnd.Line)
        then
          SearchText := SynEdit.SelText
        else
          SearchText := SynEdit.GetWordAtRowCol(SynEdit.CaretXY);
      end;
      SearchTextHistory := gsSearchTextHistory;
      if AReplace then
        with dlg as TTextReplaceDialog do
        begin
          ReplaceText := gsReplaceText;
          ReplaceTextHistory := gsReplaceTextHistory;
        end;
      SearchWholeWords := gbSearchWholeWords;
      if ShowModal = mrOk then
      begin
        gbSearchBackwards := SearchBackwards;
        gbSearchCaseSensitive := SearchCaseSensitive;
        gbSearchFromCaret := SearchFromCursor;
        gbSearchSelectionOnly := SearchInSelectionOnly;
        gbSearchWholeWords := SearchWholeWords;
        gbSearchRegex := SearchRegularExpression;
        gsSearchText := SearchText;
        gsSearchTextHistory := SearchTextHistory;
        if AReplace then
          with dlg as TTextReplaceDialog do
          begin
            gsReplaceText := ReplaceText;
            gsReplaceTextHistory := ReplaceTextHistory;
          end;
        FSearchFromCaret := gbSearchFromCaret;
        if gsSearchText <> '' then
        begin
          DoSearchReplaceText(AReplace, gbSearchBackwards);
          FSearchFromCaret := True;
        end;
      end;
    finally
      dlg.Free;
    end;
end;

procedure TFrmMain.SynEditKeyPress(Sender: TObject; var Key: Char);
begin
if FrmSettings.ForceUpperCaseCB.Checked then
Begin
  if Key IN ['a' .. 'z'] then
    Key := upcase(Key);
End;
end;

procedure TFrmMain.SynEditorReplaceText(Sender: TObject;
  const ASearch, AReplace: UnicodeString; Line, Column: Integer;
  var Action: TSynReplaceAction);
var
  APos: TPoint;
  EditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else
  begin
    APos := SynEdit.ClientToScreen
      (SynEdit.RowColumnToPixels(SynEdit.BufferToDisplayPos(BufferCoord(Column,
      Line))));
    EditRect := ClientRect;
    EditRect.TopLeft := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
      APos.Y + SynEdit.LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes:
        Action := raReplace;
      mrYesToAll:
        Action := raReplaceAll;
      mrNo:
        Action := raSkip;
    else
      Action := raCancel;
    end;
  end;
end;

end.
