program TextEditor;

uses
  System.StartUpCopy,
  FMX.Forms,
  TextEditorUnit in 'TextEditorUnit.pas' {TextEditorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTextEditorForm, TextEditorForm);
  Application.Run;
end.
