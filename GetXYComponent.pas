Function GetIPCBBoard():IPCB_Board;
var
   Project     : IProject;
   Document    : IDocument;
   i,j         : integer;
   Component   : IPCB_Component;
   IComponentID: string;
   text        : String;
   PCB         : IPCB_Board;

Begin
   Result := Nil;
   Project:=GetWorkspace.DM_FocusedProject;

   if Project = NIL Then Exit;
   //Project.DM_Compile;
   For i :=0 To Project.DM_LogicalDocumentCount - 1 do // перебор всех документов проекта
   Begin
      Document := Project.DM_LogicalDocuments(i);

      text := Document.DM_FileName;
      text := Document.DM_DocumentID;

      if ((pos('PcbDoc',Document.DM_FileName) >0) and (Result = Nil))  then
      begin

           Document.DM_OpenAndFocusDocument;
           PCB := PCBServer.GetCurrentPCBBoard;

           Result := PCB;

      end;
   end;
End;


Function GetIdocument(DocName : String;):IDocument;
var
   Project     : IProject;
   Document    : IDocument;
   i,j         : integer;
   Component   : IPCB_Component;
   IComponentID: string;
   text        : String;
   PCB         : IPCB_Board;

Begin
   Result := Nil;
   Project:=GetWorkspace.DM_FocusedProject;

   if Project = NIL Then Exit;
   //Project.DM_Compile;
   For i :=0 To Project.DM_LogicalDocumentCount - 1 do // перебор всех документов проекта
   Begin
      Document := Project.DM_LogicalDocuments(i);

      text := Document.DM_FileName;

      if pos(Document.DM_FileName,DocName) >0  then
      begin

           Result := Document;
      end;
   end;
End;

Procedure GetXYComponentLocation;
Var
    AnObject        : ISch_GraphicalObject;
    AComponent      : ISch_Component;
    Iterator        : ISch_Iterator;
    Doc             : ISch_Document;
    Component       : IPCB_Component;
    TextObject      : ISch_TextFrame;
    LabelObj        : ISch_Label;
    Document        : IDocument;
    Project         : IProject;
    CompX, CompY    : Double;
    board           : IPCB_Board;
    Param           : ISch_Parameter;
Begin
    If SchServer = Nil Then
    begin
     ShowError('Please run the script on a schematic document.');
     Exit;
    end;

    Doc             := SchServer.GetCurrentSchDocument;
    If Doc = Nil Then
     begin
     ShowError('Please run the script on a schematic document.');
     Exit;
    end;

    Document := GetIdocument(Doc.DocumentName);


    // Initialize the robots in Schematic editor.
    SchServer.ProcessControl.PreProcess(Doc, '');
    TextObject := SchServer.SchObjectFactory(eTextObject,eCreate_GlobalCopy);
    //LabelObj := SchServer.SchObjectFactory(elabel,eCreate_GlobalCopy);
    //Param := SchServer.SchObjectFactory(eParameter,eCreate_GlobalCopy);

    If LabelObj = Nil Then Exit;



    Iterator        := Doc.SchIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eSchComponent));
    AComponent := Iterator.FirstSchObject;
        While AComponent <> Nil Do
        Begin
            if AComponent.Selection then
            begin
            board := GetIPCBBoard();
            Component :=  board.GetPcbComponentByRefDes(AComponent.Designator.Text);
            //Component := GetIPCBComponent(AComponent.Designator.Text, AComponent.UniqueId);
            //LabelObj.Location := AComponent.Location;

            Param := AComponent.AddSchParameter;

            CompX := Round(CoordToMMs(Component.x - board.XOrigin) * 1000.0) / 1000.0 ;
            CompY := Round(CoordToMMs(Component.y - board.YOrigin)* 1000.0) / 1000.0 ;;    //floattostr
            //LabelObj.Text := 'X:'+ floattostr(CompX) + ' Y:'+ floattostr(CompY);
            Param.Text :=  'X:'+ floattostr(CompX) + ' Y:'+ floattostr(CompY);
            Param.Name := 'Coord';
            Param.Autoposition := true;
            //Param.EnableDraw := true;
            Param.IsHidden := false;

            AComponent.GraphicallyInvalidate;

            end;
            AComponent := Iterator.NextSchObject;
        End;
     Doc.SchIterator_Destroy(Iterator);
    Document.DM_OpenAndFocusDocument;
    //Doc.RegisterSchObjectInContainer(LabelObj);
    //SchServer.RobotManager.SendMessage(Doc.I_ObjectAddress,c_BroadCast,
                                       //SCHM_PrimitiveRegistration,LabelObj.I_ObjectAddress);

     // Clean up the robots in Schematic editor
    SchServer.ProcessControl.PostProcess(Doc, '');

    // Refresh the screen
    Doc.GraphicallyInvalidate;

end;


