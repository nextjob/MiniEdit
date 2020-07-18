// JCL_DEBUG_EXPERT_GENERATEJDBG ON
// JCL_DEBUG_EXPERT_INSERTJDBG ON
// JCL_DEBUG_EXPERT_DELETEMAPFILE ON
program MiniEdit;

uses
  Vcl.Forms,
  srcMain in 'srcMain.pas' {FrmMain},
  About in 'About.pas' {AboutBox},
  srcExceptionDialog in 'srcExceptionDialog.pas' {ExceptionDialog},
  Settings in 'Settings.pas' {FrmSettings},
  dlgConfirmReplace in 'dlgConfirmReplace.pas' {ConfirmReplaceDialog},
  dlgReplaceText in 'dlgReplaceText.pas',
  dlgSearchText in 'dlgSearchText.pas' {TextSearchDialog};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TFrmSettings, FrmSettings);
  Application.CreateForm(TConfirmReplaceDialog, ConfirmReplaceDialog);
  Application.Run;

end.
