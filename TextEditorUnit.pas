(*

 Name     : TextEditor
 Author   : Matt Murphy
 Contact  : mqm5507@gmail.com
 Created  : 27 January 2017
 Version  : 1.0

 Description: A basic text editor. Allows standard functions such as saving
    files, copying, cutting, and pasting text, and word wrapping. The purpose
    of this project is to demonastrate basic knowledge of Delphi's functions and
    the basics of the Pascal language. The code is based off of that found under
    Embarcadero's tutorials (found here:

    http://docwiki.embarcadero.com/RADStudio/Berlin/en/
    Starting_your_first_RAD_Studio_application_Index_(IDE_Tutorial))

    The procedures within were coded by my own hands, however I do not claim
    ownsership to the code.

 Known Issues: none

 How to Build: The local path of the executable is 'Win32\Debug\'.

*)

unit TextEditorUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Menus, System.Actions,
  FMX.ActnList, FMX.DialogService.Sync, FMX.Memo.Types;

type
  TTextEditorForm = class(TForm)
    ActionList: TActionList;
    MainMenu: TMainMenu;
    StatusBar: TStatusBar;
    Editor: TMemo;
    OpenFileDialog: TOpenDialog;
    SaveFileDialog: TSaveDialog;
    NewAction: TAction;
    OpenAction: TAction;
    SaveAction: TAction;
    SaveAsAction: TAction;
    ExitAction: TAction;
    CutAction: TAction;
    CopyAction: TAction;
    PasteAction: TAction;
    SelectAllAction: TAction;
    UndoAction: TAction;
    DeleteAction: TAction;
    WordWrapAction: TAction;
    FileMenu: TMenuItem;
    EditMenu: TMenuItem;
    FormatMenu: TMenuItem;
    NewItem: TMenuItem;
    OpenItem: TMenuItem;
    SaveItem: TMenuItem;
    SaveAsItem: TMenuItem;
    ExitItem: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    SelectAllItem: TMenuItem;
    UndoItem: TMenuItem;
    DeleteItem: TMenuItem;
    WordWrapItem: TMenuItem;
    LineNumber: TLabel;
    ColumnNumber: TLabel;
    LineCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure NewActionExecute(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure SaveAsActionExecute(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure CutActionExecute(Sender: TObject);
    procedure CopyActionExecute(Sender: TObject);
    procedure PasteActionExecute(Sender: TObject);
    procedure SelectAllActionExecute(Sender: TObject);
    procedure UndoActionExecute(Sender: TObject);
    procedure DeleteActionExecute(Sender: TObject);
    procedure WordWrapActionExecute(Sender: TObject);
    procedure EditorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure EditorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    { Private declarations }
    CurrentFile: String;
    procedure UpdateStatusBar;
  public
    { Public declarations }
  end;

var
  TextEditorForm: TTextEditorForm;

implementation

{$R *.fmx}

(*

   - = -   General Application Procedures   - = -

*)

{ Initializes the text editor upon form creation. }
procedure TTextEditorForm.FormCreate(Sender: TObject);
begin
  { Creates an initial blank line. }
  Editor.Lines.Add('');

  { Updates the staus bar to match the initial position of the cursor. }
  UpdateStatusBar;
end;

{ Updates the status bar whenever a key is released by calling
  UpdateStatusBar. }
procedure TTextEditorForm.EditorKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  { Call the procedure UpdateStatusBar. }
  UpdateStatusBar;
end;

{ Updates the status bar whenever a mouse button is released by calling
  UpdateStatusBar. }
procedure TTextEditorForm.EditorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  { Call the procedure UpdateStatusBar. }
  UpdateStatusBar;
end;

{ Handles the information at the borrom of the status bar. The information
  displayed is the current numerical row and column position of the cursor
  (caret) in the text editor and the number of lines created by the user. }
procedure TTextEditorForm.UpdateStatusBar;
begin
  { Set the position of the cursor in the editor's lines. }
  LineNumber.Text := 'L: ' + (Editor.CaretPosition.Line+1).ToString;
  { Set the position of the cursor in the editor's columns. }
  ColumnNumber.Text := 'C: ' + (Editor.CaretPosition.Pos+1).ToString;
  { Set the number of lines in the editor. }
  LineCount.Text := 'Lines: ' + Editor.Lines.Count.ToString;
end;

(*

   - = -   File Menu Procedures   - = -

*)

{ Handles the creation of a new, blank text editor form when the 'New'
  option in the file menu is selected. ('File' > 'New') }
procedure TTextEditorForm.NewActionExecute(Sender: TObject);
var
  { Integer variable to log the user's response in the dialog box generated by
    this procedure. }
  UserResponse: Integer;
begin
  { Check if the text editor is clear of text. If there is no text, there is
    nothing to do and the procedure ends normally. }
  if not Editor.Text.IsEmpty then
  begin
    { Create a dialog notifying the user that all of their current changes will
      be lost, and give them a yes-or-no option to determine whether to
      continue. If the user selects 'yes', the application proceeds with
      clearing the text editor. }
    UserResponse := TDialogServiceSync.MessageDialog(
      'This will clear the current document. Do you want to continue?',
      TMsgDlgType.mtInformation, mbYesNo, TMsgDlgBtn.mbYes, 0);
    { If the user selects 'Yes', begin clearing the text editor. }
    if UserResponse = mrYes then
    begin
      { Set all of the text in the editor to blank. }
      Editor.Text := '';
      { Initialize a new line. }
      Editor.Lines.Add('');
      {Update the status bar to reflect the cursor's new position. }
      UpdateStatusBar;
      { Clear the current file name and set it to nothing. }
      CurrentFile := '';
    end;
  end;
end;

{ Handles opening a file in the editor when the 'Open' option in the file menu
  is selected. ('File' > 'Open...') }
procedure TTextEditorForm.OpenActionExecute(Sender: TObject);
var
  { String variable to track the name of the file being handled. }
  FileName: String;
begin
  { Check if the open file dialog can be opened .}
  if OpenFileDialog.Execute = True then
  begin
    { Initialize FileName based on the user's choice from the dialog. }
    FileName := OpenFileDialog.FileName;
    { If the file exists and can be opened, then continue normally. }
    if FileExists(FileName) then
    begin
      { Load the chosen fileand display its contents in the editor. }
      Editor.Lines.LoadFromFile(FileName);
      { Set the currently opened file name to that of the file just opened. }
      CurrentFile := FileName;
      { Set the caption at the top of the application to match the file's
        name. }
      Caption := 'Text Editor - ' + ExtractFileName(FileName);
    end;
  end;
end;

{ Handles saving text files when the 'Save' option in the file menu is
  selected.('File' > 'Save') }
procedure TTextEditorForm.SaveActionExecute(Sender: TObject);
begin
  { If there is no current file name (as in, the file is a brand new file),
    then call the Save As procedure to create a new file. }
  if CurrentFile = '' then
    SaveAsAction.Execute()
  { Otherwise, overwrite the contents of the current file. }
  else
    Editor.Lines.SaveToFile(CurrentFile);
end;

{ Handles saving text to a new file when the 'Save As' option in the file menu
  is selected. ('File' > 'Save As...') }
procedure TTextEditorForm.SaveAsActionExecute(Sender: TObject);
var
  { String variable to track the name of the file being handled. }
  FileName: String;
  { Integer variable to log the user's response in the dialog box generated by
    this procedure. }
  UserResponse: TModalResult;
begin
  { Check if the save file dialog can be opened .}
  if SaveFileDialog.Execute = True then
  begin
    { Initialize FileName based on the user's choice from the dialog. }
    FileName := SaveFileDialog.FileName;
    { If the file already exists, then begin a new opteration to determine how
      to handle the file. }
    if FileExists(FileName) then
    begin
      { Create a dialog notifying the user that thename of the file already
        exists, ask if they wish to overwrite the current file, and give them a
        yes-or-no option to determine whether to continue. If the user selects
        'yes', the application proceeds with saving the file. }
      UserResponse := TDialogServiceSync.MessageDialog(
        'File already exists. Do you want to overwrite?',
        TMsgDlgType.mtInformation, mbYesNo, TMsgDlgBtn.mbYes, 0);
      { If the user selects 'no', the process ends and no additional changes
        will be made. }
      if UserResponse = mrNo then
        Exit;
    end;
    { Save the new file. }
    Editor.Lines.SaveToFile(FileName);
    { Set the name of the current file to that of the new one. }
    CurrentFile := FileName;
    { Set the caption at the top of the application to match the file's name. }
    Caption := 'Text Editor - ' + ExtractFileName(FileName);
  end;
end;

{ Handles the termination of the application when the 'Exit' option in the file
  menu is selected. ('File' > 'Exit') }
procedure TTextEditorForm.ExitActionExecute(Sender: TObject);
begin
  { Terminate the application. }
  Application.Terminate;
end;

(*

   - = -   Edit Menu Procedures   - = -

*)

{ Handles cutting text when the 'Cut' option in the edit menu is selected.
  ('Edit' > 'Cut') }
procedure TTextEditorForm.CutActionExecute(Sender: TObject);
begin
  { Cut the selected text to the clipboard. }
  Editor.CutToClipboard;
  { Update the status bar to reflect the cursor's new position. }
  UpdateStatusBar;
end;

{ Handles copying text when the 'Copy' option in the edit menu is selected.
  ('Edit' > 'Copy') }
procedure TTextEditorForm.CopyActionExecute(Sender: TObject);
begin
  { Copy the selected text to the clipboard. }
  Editor.CopyToClipboard;
end;

{ Handles pasting text when the 'Paste option in the edit menu is selected.
  ('Edit' > 'Paste') }
procedure TTextEditorForm.PasteActionExecute(Sender: TObject);
begin
  { Paste text from the clipboard. }
  Editor.PasteFromClipboard;
  { Update the status bar to reflect the cursor's new position. }
  UpdateStatusBar;
end;

{ Handles highlighting all of the text currently in the editor when the 'Select
  All' option in the edit menu is selected. ('Edit' > 'Select All') }
procedure TTextEditorForm.SelectAllActionExecute(Sender: TObject);
begin
  { Select all text in the editor. }
  Editor.SelectAll;
  { Update the status bar to reflect the cursor's new position. }
  UpdateStatusBar;
end;

{ Handles undoing actions amde by the user when the 'Undo' option in the edit
  menu is selected.('Edit' > 'Undo') }
procedure TTextEditorForm.UndoActionExecute(Sender: TObject);
begin
  { Undo the last change made by the user. }
  Editor.UnDo;
  { Update the status bar to reflect the cursor's new position. }
  UpdateStatusBar;
end;

{ Handles deleting highlighted text when the 'Delete' option in the edit menu is
  selected. ('Edit' > 'Delete') }
procedure TTextEditorForm.DeleteActionExecute(Sender: TObject);
begin
  { If there is a selection of text made by the user, then delete that text. }
  if Editor.SelLength > 0 then
    Editor.DeleteSelection
  { Otherwise, delete the item directly before the cursor's current position. }
  else
    Editor.DeleteFrom(Editor.CaretPosition, 1, [TDeleteOption.MoveCaret]);
  { Update the status bar to reflect the cursor's new position. }
  UpdateStatusBar;
end;

(*

-=- Format Menu Procedures -=-

*)

{ Handles proper word wrapping in the text editor when the 'Word Wrap' option in
  the format menu is selected. ('Format' > 'Word Wrap') }
procedure TTextEditorForm.WordWrapActionExecute(Sender: TObject);
begin
  { Toggle the boolean state of the word wrap option. }
  Editor.WordWrap := not Editor.WordWrap;
  { Check off the word wrap option. }
  WordWrapAction.Checked := Editor.WordWrap;
  { Update the status bar to reflect the cursor's new position. }
  UpdateStatusBar;
end;

end.
