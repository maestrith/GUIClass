#SingleInstance,Force
TVKeep:={1:[],2:[]}
global DefaultTVText:="Press F2 To Clear"
MainWin:=New GUIClass(2,{MarginX:2,MarginY:2})
MakeWin(MainWin)
MainWin:=New GUIClass(1,{MarginX:2,MarginY:2,Background:0,Color:"0xAAAAAA"})
MakeWin(MainWin)
/*
	The Add Method works the same way as any Gui command without Gui,Add,
	Normally the first Text control would look like{
		Gui,Add,Text,w500,Press F1 or resize the window to make something happen
	}it gets changed to{
		Text,w500,Press F1 or resize the window to make something happen
	}
*/
Count:=36
OnExit,1Close
MakeWin(MainWin){
	global TVKeep
	Ver:=FixIE(12)
	/*
		Having either a v or g value will be the "Name" of the Control but if you have both it will default to the v Name
	*/
	MainWin.Add("Text,w500 vMyStatic1"
			 ,"Edit,w500 h200 vMyEdit1 gReport,This would be default if I wasn't changing it below,h"
			 ,"Edit,x+m w200 h200 vMyEdit2 gReport,This control will have focus by default thanks to MainWin.Focus(),h"
			 ,"TreeView,x+m w300 h200 vMyTreeView Checked gReport AltSubmit,,wh"
			 ,"ActiveX,vwb x+m w200 h200,mshtml,x"
			 ,"Hotkey,xm vMyHotkey gReport,,y"
			 ,"ComboBox,x+m vMyCombobox gReport,Items|Go|Here,y"
			 ,"DDL,x+m vMyDDL gReport,DDL|Items|Go|Here,y"
			 ,"DateTime,x+m vMyDateTime gReport,yyyy-MM-dd HH:mm:ss tt,y"
			 ,"ListView,xm w500 r4 vMyListView1 gReport AltSubmit,Column 1|Column 2,yw"
			 ,"ListView,x+m w" 500+MainWin.MarginX " r4 vMyListView2 gReport AltSubmit,Column 1|Column 2,yx"
			 ,"Text,xm,&All Values: (Press Alt+A to get to the Edit below),y"
			 ,"Edit,xm w" 772+MainWin.MarginX*2 " h300 vOutput,,wy"
			 ,"MonthCal,x+m vMyMonthCal gReport,,xy"
			 ,"Radio,gReport vRadio1,First Radio,xy"
			 ,"Radio,gReport vRadio2,Second Radio,xy"
			 ,"Checkbox,gReport vMyCheckBox,My CheckBox,xy"
			 ,"ListBox,gReport vMyListBox +Multi,My|List|Box,xy"
			 ,"Slider,gReport vMySlider AltSubmit,,xy"
			 ,"StatusBar")
	FixIE(Ver)
	;~ MainWin.Full("MyTreeView")		;Add if you want the full tree reported rather than just Selected and/or Checked
	MainWin.Show("My Window")		;Show the Window with the Title of "My Window"
	MainWin.Focus("MyEdit2")			;Set the Focus to "MyEdit2"
	MainWin.SetLV("MyListView1",[{"Column 1":"Row 1","Column 2":"Text"},{"Column 1":"Row 2 A Slightly wider row","Column 2":"More Text"}],,"AutoHDR")	;Add 2 Rows into the Left ListView
	MainWin.SetLV("MyListView2",[{Col1:"Text",Col2:"Here"}],"Col2|Col1","AutoHDR")															;Add 2 Rows into the Right ListView and changes the order of the Columns
	MainWin.SetText("MyEdit1","This is MyEdit1")																						;Change the Text of "MyEdit1"
	MainWin.SetText("MyStatic1","Press F1, F2, F3, F4, Drop Files, Select Items or resize the window to make something happen")						;Change the Text of "MyStatic1"
	TVKeep[MainWin.Win].Push(MainWin.SetTV({Text:DefaultTVText,Options:"Select Vis Focus"}))
	wb:=MainWin.ActiveX.wb
	wb.Navigate("about:" (MainWin.Background=0?"<Body Style='Background-Color:black;Color:Grey'>":"") "IE Window")
	while(wb.ReadyState!=4)
		Sleep,10
}
return
/*
	The G-Label that I gave most of the controls above reports here
*/
Report(){
	MainWin:=GUIClass.Table[A_Gui]	;Gets the MainWin Object from the Class Table
	All:=MainWin[]					;Gets all values from the window
	for a,b in All{				;for loop through all the values
		if(b="")
			Continue
		Try
			if(a!="Output"&&((!IsObject(b)&&b)||(IsObject(b)&&b.Count())))
				Msg.=a ":`n"(IsObject(b)?Obj2String(b):b) "`r`n"
	}
	MainWin.SetText("Output","This will be an object with all of the values from the controls you gave a v value to:`r`n" Trim(Msg,"`r`n"))	;Display the values within the Output Control
}
/*
	Required if you want to save the position data of the Window somewhere other than Settings.ini
	You need to save at least the Pos.Text value or you can store Pos.X, Pos.Y...etc separately if you need to
	SavePos(Win,Pos){
		Win will be the Name of the Window
		Pos will be an Object{
			Pos.X:=<X Position>
			Pos.Y:=<Y Position>
			Pos.W:=<Width>
			Pos.H:=<Height>
			Pos.Text:=X<X> Y<Y> W<W> H<H>
		}
	}
	Save the data however you like, either XML, INI, Database...etc
*/
SavePos(Win,Pos){
	if(Pos.Max=0){
		IniWrite,% Pos.Text,Settings.ini,%Win%,Text
		IniDelete,Settings.ini,%Win%,Max
	}else if(Pos.Max=1)
		IniWrite,1,Settings.ini,%Win%,Max
}
/*
	Required if you use SavePos()
	Show(Win){
		Win will be the name of the Window
		
		You need to return an Object
		Pos:="x" <X> " y" <Y> " w" <W> " h" <H>
		Max:=<Maximized State as either a 0 or 1>
		return {Pos:Pos,Max:Max}
	}
*/
Show(Win){
	IniRead,Pos,Settings.ini,%Win%,Text,0
	Pos:=Pos?Pos:(Win=1?"X0":"X" A_ScreenWidth/2)
	IniRead,Max,Settings.ini,%Win%,Max,0
	return {Pos:(Pos?Pos:0),Max:Max}
}
/*
	<Name Of The GUI>ContextMenu()
	Required if you want to monitor the Right Click of most Controls or the GUI Window
*/
1ContextMenu(Control,EventInfo,IsRightClick,X,Y){
	t(Control,EventInfo,IsRightClick,X,Y)
	Sleep,2000
	t()
}
/*
	<Name Of The GUI>Close()
	Fires when someone hits the X of a Window
*/
1Close(){
	global
	1Close:
	MainWin.Exit() ;Exits the script and saves the position of the Window
	return
}
/*
	<Name Of The GUI>Escape()
	Fires when someone hits Escape with the GUI Focused
*/
1Escape(){
	global
	m("You pressed escape on the Dark Themed Window")
	MainWin.Exit()
	ExitApp
}
2Escape(){
	m("You pressed Escape on the Light Themed Window")
	ExitApp
}
/*
	Required if you want to monitor the Dropped Files
	DropFiles(Files,Control){
		Files{
			Array of Files that were Dropped
		}
		Control:=The name of the Control that the files were Dropped into (Optional)
	}
*/
DropFiles(Files,Control){
	global MainWin
	m(Control,Files)
}
F1::
Count++
for a,MainWin in GUIClass.Table{
	MainWin.SetText("MyEdit1",A_TickCount)
	MainWin.SetText("MyEdit2",A_TickCount)
	MainWin.DisableAll()
	MainWin.SetLV("MyListView1",[["MyListView1",A_TickCount]],,"AutoHDR,Clear")
	Add:=""
	while(StrLen(Add)<Count){
		for a,b in StrSplit("This will Auto-Widen and won't clear "){
			Add.=b
		}Until StrLen(Add)>=Count
	}
	MainWin.SetLV("MyListView2",[{Changed:Add,Headers:A_TickCount}],"Changed|Headers","AutoHDR")
	Random,Random,1,% TV_GetCount()
	TVKeep[MainWin.Win].Push(MainWin.SetTV({Text:A_TickCount,Options:"Select Vis Focus",Parent:TVKeep[MainWin.Win,Random]}))
	MainWin.EnableAll()
}
return
F2::
for a,MainWin IN GUIClass.Table{
	TVKeep[MainWin.Win]:=[]
	MainWin.DisableAll()
	TVKeep[MainWin.Win].Push(MainWin.SetTV({Control:"MyTreeView",Clear:1,Text:DefaultTVText}))
	MainWin.SetLV({Control:"MyListView1",Clear:1})
	MainWin.SetLV({Control:"MyListView2",Clear:1,Headers:["Column 1","Column 2"],AutoHDR:1})
	Count:=37
	MainWin.SetText("MyEdit1","This is MyEdit1")
	MainWin.SetText("MyEdit2","This is MyEdit2")
	TV:=0
	MainWin.EnableAll()
}
return
F3::
for a,b in ["http://www.google.com","https://www.autohotkey.com/assets/images/ahk-logo-no-text241x78-180.png"]{
	wb:=GUIClass.Table[a].ActiveX.wb
	wb.Navigate(b)
	while(wb.ReadyState!=4)
		Sleep,10
	wb.Document.Body.Style.OverFlow:="Auto"
}
return
F4::
m(MainWin.StoredLV.MyListView2,"",MainWin.Get("MyEdit1"))
return
m(x*){
	for a,b in x
		Msg.=IsObject(b)?Obj2String(b):b "`n"
	MsgBox,%Msg%
}
t(x*){
	for a,b in x
		Msg.=IsObject(b)?Obj2String(b):b "`n"
	ToolTip,%Msg%
}
Obj2String(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
		String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		for a,b in Obj{
			if(IsObject(b)&&b.OuterHtml)
				String.=FullPath "." a " = " b.OuterHtml
			else if(IsObject(b)&&!b.XML)
				Obj2String(b,FullPath "." a,BottomBlank)
			else{
				if(BottomBlank=0)
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else if(b!="")
					String.=FullPath "." a " = " (b.XML?b.XML:b) "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
	}}
	return String Blank
}
FixIE(Version=0){
	static Key:="Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION",Versions:={7:7000,8:8888,9:9999,10:10001,11:11001} ;Thanks GeekDude
	Version:=Versions[Version]?Versions[Version]:Version
	if(A_IsCompiled)
		ExeName:=A_ScriptName
	else
		SplitPath,A_AhkPath,ExeName
	RegRead,PreviousValue,HKCU,%Key%,%ExeName%
	if(!Version)
		RegDelete,HKCU,%Key%,%ExeName%
	else
		RegWrite,REG_DWORD,HKCU,%Key%,%ExeName%,%Version%
	return PreviousValue
}
Class GUIClass{
	static Table:=[],ShowList:=[]
	__Get(x*){
		if(x.1)
			return this.Var[x.1]
		return this.Add()
	}__New(Win:=1,Info:=""){
		static Defaults:={Color:0,Size:10,MarginX:5,MarginY:5}
		for a,b in Defaults
			if(Info[a]="")
				Info[a]:=b
		SetWinDelay,-1
		Gui,%Win%:Destroy
		if(!Info.HWND){
			Gui,%Win%:+HWNDHWND -DPIScale
		}
		this.MarginX:=Info.MarginX,this.MarginY:=Info.MarginY
		HWND:=Info.HWND?Info.HWND:HWND
		Gui,%Win%:Margin,% this.MarginX,% this.MarginY
		Gui,%Win%:Font,% "s" Info.Size " c" Info.Color,Courier New
		if(Info.Background!="")
			Gui,%Win%:Color,% Info.Background,% Info.Background
		this.All:=[],this.GUI:=[],this.HWND:=HWND,this.Con:=[],this.ID:="ahk_id" HWND,this.Win:=Win,GUIClass.Table[Win]:=this,this.Var:=[],this.LookUp:=[],this.ActiveX:=[],this.StoredLV:=[],this.Background:=Info.Background,this.Color:=Info.Color,this.SC:=[],this.Headers:=[],this.FN:=A_ScriptDir "\Settings.ini"
		for a,b in {Border:A_OSVersion~="^10"?3:0,Caption:DllCall("GetSystemMetrics",Int,4,Int)}
			this[a]:=b
		Gui,%Win%:+LabelGUIClass.
		Gui,%Win%:Default
		return this
	}Add(Info*){
		static
		if(Info.1=""||Info.1.Get){
			Var:=[],Get:=Info.1.Get!=""?{(Info.1.Get):this.Var[Info.1.Get]}:this.Var
			Gui,% this.Win ":Submit",Nohide
			Try
				for a,b in Get{
					if(b.Type="s")
						Var[a]:=b.sc.GetUNI()
					else if(b.Type="ListView"){
						Var[a]:=[],this.Default(a)
						while(Next:=LV_GetNext(Next)){
							Obj:=Var[a,Next]:=[]
							Loop,% LV_GetCount("Columns")
								LV_GetText(Text,Next,A_Index),Obj.Push(Text)
						}
					}else if(b.Type="TreeView"){
						Var[a]:=[],this.Default(a),TV:=TV_GetSelection()
						while(Next:=TV_GetNext(Next,(this.All[a].Full?"F":"C")))
							Var[a].Push({TV:Next,Checked:(TV_Get(Next,"Checked")?1:0),Expand:(TV_Get(Next,"Expand")?1:0),Bold:(TV_Get(Next,"Bold")?1:0),Selected:(TV=Next)}),Found:=Found?Found:TV=Next
						if(!Found)
							Var[a].Push({TV:TV,Checked:0,Expand:(TV_Get(TV,"Expand")?1:0),Bold:(TV_Get(TV,"Bold")?1:0),Selected:1})
					}else
						Var[a]:=%a%
				}return Var,Found:=""
		}for a,b in Info{
			i:=StrSplit(b,","),RegExMatch(i.2,"OU)\bv(.*)\b",Var)
			if(i.1="ComboBox")
				WinGet,ControlList,ControlList,% this.ID
			if(i.1="s")
				Pos:=RegExReplace(i.2,"OU)\s*\b(v.+)\b"),sc:=New S(this.Win,{Pos:Pos}),HWND:=sc.sc,this.SC[Var.1]:=sc
			else if(i.1="HWND"){
				HWND:=i.3
			}else
				Gui,% this.Win ":Add",% i.1,% i.2 " HWNDHWND",% i.3
			if(RegExMatch(i.2,"OU)\bg(.*)\b",Label))
				Label:=Label.1
			if(Var.1)
				this.Var[Var.1]:={HWND:HWND,Type:i.1,sc:sc}
			this.Con[HWND]:=[],Name:=Var.1?Var.1:Label,this.Con[HWND,"Name"]:=Name,Name:=Var.1?Var.1:Label?Label:"Control" A_TickCount A_MSec
			if(i.4!="")
				this.Con[HWND,"Pos"]:=i.4,this.Resize:=1
			this.All[Name]:={HWND:HWND,Name:Name,Label:Label,Type:i.1,ID:"ahk_id" HWND,sc:sc},sc:=""
			if(i.1="ComboBox"){
				WinGet,ControlList2,ControlList,% this.ID
				Obj:=StrSplit(ControlList2,"`n"),LeftOver:=[]
				for a,b in Obj
					LeftOver[b]:=1
				for a,b in Obj2:=StrSplit(ControlList,"`n")
					LeftOver.Delete(b)
				for a in LeftOver{
					if(!InStr(a,"ComboBox")){
						ControlGet,Married,HWND,,%a%,% this.ID
						this.LookUp[Name]:={HWND:HWND,Married:Married,ID:"ahk_id" Married+0,Name:Name,Type:"Edit"}
			}}}if(!this.LookUp[Name]&&Name)
				this.LookUp[Name]:={HWND:HWND,ID:"ahk_id" HWND,Name:Name,Label:Label,Type:i.1}
			if(i.1="ActiveX")
				VV:=Var.1,this.ActiveX[Name]:=%VV%
			Name:=""
	}}Close(a:=""){
		(this:=IsObject(this)?this:GUIClass.Table[A_Gui]),(Func:=Func("SavePos"))?Func.Call(this.Win,this.WinPos()):this.SavePos(),(Func:=Func(A_Gui "Close"))?Func.Call():""
		Gui,% this.Win ":Destroy"
		this.DisableAll()
	}ContextMenu(x*){
		this:=GUIClass.Table[A_Gui],x.1:=this.GetName(x.1),(Function:=Func(A_Gui "ContextMenu"))?Function.Call(x*)
	}Default(Control){
		Gui,% this.Win ":Default"
		Obj:=this.LookUp[Control]
		if(Obj.Type~="TreeView|ListView")
			Gui,% this.Win ":" Obj.Type,% Obj.HWND
	}Disable(Control){
		Obj:=this.All[Control]
		if(Obj.Label)
			GuiControl,1:+g,% Obj.HWND
		GuiControl,1:-Redraw,% Obj.HWND
	}DisableAll(Redraw:=1,Control:=""){
		for a,b in (Control?[this.All[Control]]:this.All){
			if(b.Label)
				GuiControl,% this.Win ":+g",% b.HWND
			if(Redraw)
				GuiControl,% this.Win ":-Redraw",% b.HWND
	}}DropFiles(Info*){
		this:=GUIClass.Table[A_Gui],Info.2:=this.GetName(Info.2),(Fun:=Func("DropFiles"))?Fun.Call(Info*)
	}Enable(Control){
		Obj:=this.All[Control]
		if(Obj.Label)
			GuiControl,% "1:+g" b.Label,% Obj.HWND
		GuiControl,1:+Redraw,% Obj.HWND
	}EnableAll(Redraw:=1,Control:=""){
		for a,b in (Control?[this.All[Control]]:this.All){
			if(b.Label)
				GuiControl,% this.Win ":+g" b.Label,% b.HWND
			if(Redraw)
				GuiControl,% this.Win ":+Redraw",% b.HWND
	}}Escape(){
		KeyWait,Escape,U
		this:=GUIClass.Table[A_Gui],(Func:=Func("SavePos"))?Func.Call(this.Win,this.WinPos()):this.SavePos(),(Esc:=Func(A_Gui "Escape"))?Esc.Call()
		if(IsLabel(Label:=A_Gui "Escape"))
			SetTimer,%Label%,-1
		return 
	}Exit(){
		Exit:
		(Save:=Func("SavePos"))?Save.Call(this.Win,this.WinPos(this.HWND)):this.SavePos()
		ExitApp
		return
	}Focus(Control){
		this.Default(Control)
		ControlFocus,,% this.LookUp[Control].ID
	}Full(Control,Enable:=1){
		this.All[Control].Full:=Enable
	}Get(Control){
		return this.Add({Get:Control})
	}GetFocus(){
		ControlGetFocus,Focus,% this.ID
		ControlGet,HWND,HWND,,%Focus%,% this.ID
		return this.Con[HWND].Name
	}GetName(HWND){
		return this.Con[HWND].Name
	}GetPos(){
		Detect:=A_DetectHiddenWindows
		DetectHiddenWindows,On
		Gui,% this.Win ":Show",AutoSize Hide
		WinGet,CL,ControlListHWND,% this.ID
		Pos:=This.Winpos(),WW:=Pos.W,WH:=Pos.H,Flip:={X:"WW",Y:"WH"}
		for Index,HWND In StrSplit(CL,"`n"){
			Obj:=this.GUI[HWND]:=[]
			ControlGetPos,x,y,w,h,,ahk_id%hwnd%
			for c,d in StrSplit(this.Con[HWND].Pos)
				d~="w|h"?(obj[d]:=%d%-w%d%):d~="x|y"?(Obj[d]:=%d%-(d="y"?WH+this.Caption+this.Border:WW+this.Border))
		}DetectHiddenWindows,%Detect%
	}GetLV(Control){
		this.Default(Control),Obj:=[]
		while(Next:=LV_GetNext(Next)){
			Obj.Push(OO:=[])
			Loop,% LV_GetCount("Columns")
				LV_GetText(Text,Next,A_Index),OO.Push(Text)
		}
		return Obj
	}GetTV(Control){
		this.Default(Control)
		return TV_GetSelection()
	}Hotkeys(Keys){
		Hotkey,IfWinActive,% this.ID
		for a,b in Keys
			Hotkey,%a%,%b%,On
	}LoadPos(){
		IniRead,Pos,% this.FN,% this.Win,Text,0
		IniRead,Max,% this.FN,% this.Win,Max,0
		return {Pos:(Pos?Pos:""),Max:Max}
	}ResetHeaders(Info){
		this.Headers[Info.Control]:=[]
		while(LV_GetCount("Columns"))
			LV_DeleteCol(1)
		for a,b in Info.Headers
			LV_InsertCol(a,"",b),this.Headers[Info.Control,b]:=1
	}SavePos(){
		Pos:=this.WinPos()
		if(Pos.Max=0){
			IniWrite,% Pos.Text,% this.FN,% this.Win,Text
			IniRead,Max,% this.FN,% this.Win,Max,0
			if(Max)
				IniDelete,% this.FN,% this.Win,Max
		}else if(Pos.Max=1)
			IniWrite,1,% this.FN,% this.Win,Max
	}SetLV(Control,Data,HeaderOrder:="",Options:=""){
		(!Control)?return:"",this.Default(Control),Headers:=[],Head:=1,this.Disable(Control),HeaderList:=[],CurrentHeaders:=[],OO:=[]
		for a,b in StrSplit(Options,",")
			OO[b]:=1
		if(!IsObject(this.StoredLV[Control]))
			this.StoredLV[Control]:=[]
		for a,b in Data
			for c,d in b
				Headers[c]:=1
		while(Head)
			LV_GetText(Head,0,A_Index),(Head?CurrentHeaders.Push(Head):"")
		if(HeaderOrder){
			HH:=StrSplit(HeaderOrder,"|")
			for a,b in CurrentHeaders
				if(HH[a]!=b){
					Clear:=1,CurrentHeaders:=HH
					Break
				}
		}else{
			for a,b in CurrentHeaders
				if(!Headers[b]){
					Clear:=1
					Break
				}
			Clear:=Clear?Clear:CurrentHeaders.Count()!=Headers.Count()
		}if(OO.Clear)
			LV_Delete()
		if(Clear){
			LV_Delete(),this.StoredLV[Control]:=[]
			while(LV_GetCount("Columns"))
				LV_DeleteCol(1)
			for a,b in (HeaderOrder?StrSplit(HeaderOrder,"|"):Headers)
				LV_InsertCol(A_Index,"",(Head:=HeaderOrder?b:a)),HeaderList.Push(Head)
		}HeaderList:=HeaderList.1?HeaderList:CurrentHeaders
		for a,b in Data{
			Row:=[]
			for c,d in HeaderList
				Row.Push(b[d])
			LV_Add("",Row*)
			this.StoredLV[Control].Push(Row)
		}if(OO.AutoHDR){
			Loop,% LV_GetCount("Columns")
				LV_ModifyCol(A_Index,"AutoHDR")
		}CurrentHeaders:=StrSplit(HeaderOrder,"|")
		this.Enable(Control)
	}SetText(Control,Text:=""){
		this.Default(Control)
		if((sc:=this.Var[Control].sc).sc)
			sc.2181(0,Text)
		else
			GuiControl,% this.Win ":",% this.Lookup[Control].HWND,%Text%
	}SetTV(Info){
		this.Default(Info.Control),(Info.Clear)?TV_Delete():"",(Info.Delete)?TV_Delete(Info.Delete):"",(Info.Text)?(TV:=TV_Add(Info.Text,(Info.Parent=1?TV_GetSelection():Info.Parent),Info.Options)):"",(Info.Text&&Info.Options&&Info.TV)?TV_Modify(Info.TV,Info.Options,Info.Text):""
		return TV
	}Show(name){
		this.GetPos(),Pos:=this.Resize=1?"":"AutoSize",this.name:=name
		if(this.Resize=1)
			Gui,% this.Win ":+Resize"
		GUIClass.ShowList.Push(this)
		this.ShowWindow()
	}ShowWindow(){
		while(this:=GUIClass.Showlist.Pop()){
			if(Show:=Func("Show"))
				Pos:=Show.Call(this.Win)
			else
				Pos:=this.LoadPos()
			Gui,% this.Win ":Show",Hide
			Pos1:=this.WinPos(),MinW:=Pos1.W,MinH:=Pos1.H
			Gui,% this.Win ":Show",% Pos.Pos,% this.Name
			if(this.Resize!=1)
				Gui,% this.Win ":Show",AutoSize
			if(Pos.Max)
				WinMaximize,% this.ID
			Gui,% this.Win ":+MinSize" MinW "x" MinH
			WinActivate,% this.id
		}
	}Size(a*){
		this:=IsObject(this)?this:GUIClass.Table[A_Gui],Pos:=this.Winpos()
		((Func:=Func(A_Gui "Size"))?Func.Call(Pos):"")
		for a,b in this.GUI
			for c,d in b
				GuiControl,% this.Win ":" (this.All[this.Con[a].Name].Type="ActiveX"?"Move":"MoveDraw"),%a%,% c (c~="y|h"?Pos.h:Pos.w)+d
	}WinPos(HWND:=0){
		VarSetCapacity(Rect,16),DllCall("GetClientRect",Ptr,(HWND?HWND:this.HWND),Ptr,&Rect)
		WinGetPos,X,Y,,,% (HWND?"ahk_id" HWND:this.AhkID)
		W:=NumGet(Rect,8,Int),H:=NumGet(Rect,12,Int),Text:=(X!=""&&Y!=""&&W!=""&&H!="")?"X" X " Y" Y " W" W " H" H:""
		WinGet,Max,MinMax,% this.ID
		return {X:X,Y:Y,W:W,H:H,Text:Text,Max:Max}
	}
}