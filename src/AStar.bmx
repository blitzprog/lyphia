SuperStrict

Const ASWEIGHTENED:Int = %0001
Const ASSMOOTHENED:Int = %0010
Const ASHEIGHTENED:Int = %0100
Const ASCLIMBNFALL:Int = %1000

Type TGameMap
	
	'Daten:
	Field Map:Int[1,1,1] 'die Karte: b*h*layer, wobei aus performancegr�nden l,h,w gespeichert wird, da
	Field width:Int 'dann die einzelnen Layerdaten hintereinander im Speicher stehen.
	Field height:Int
	Field layer:Int
	Field _link:TLink
	
	'Globale Daten:
	Global Lmap:TList = New TList
	
	'Funktionen:
	Function Create:TGameMap(w:Int,h:Int,l:Int)
		'erstellt eine neue Karte in den angegebenen Dimensionen. Sie wird in Lmap gespeichert.
		Local instanz:TGameMap = New TGameMap
		instanz.map = New Int[l,h,w]
		instanz.width = w
		instanz.height = h
		instanz.Layer = l 
		instanz._link = lmap.addlast(instanz)
		Return instanz
	End Function
	
	'Methoden:
	Method resize(w:Int,h:Int,l:Int)
		'redimensioniert eine Karte. Der Inhalt wird soweit m�glich erhalten.
		Local copyi:Int,copyj:Int,copyk:Int
		If w >= Self.width Then
			copyi = Self.width
		Else
			copyi = w
		EndIf
		If h >= Self.height Then
			copyj = Self.height
		Else
			copyj = h
		EndIf
		If l >= Self.layer Then
			copyk = Self.layer
		Else
			copyk = l
		EndIf
		Local tempmap:Int[copyk,copyj,copyi]
		
		For Local i:Int = 0 To copyi -1
			For Local j:Int = 0 To copyj -1
				For Local k:Int = 0 To copyk-1
					tempmap[k,j,i]=Self.map[k,j,i]
				Next
			Next
		Next
		
		Self.map = New Int[l,h,w]
		Self.width = w
		Self.height = h
		Self.Layer = l
		
		For Local i:Int = 0 To copyi -1
			For Local j:Int = 0 To copyj -1
				For Local k:Int = 0 To copyk-1
					Self.map[k,j,i]=tempmap[k,j,i]
				Next
			Next
		Next
		
	End Method
	
	Method getvalue:Int(w:Int,h:Int,l:Int)
		'liesst den Wert aus der angegebenen Zelle
		If (w >=0) And (w < Self.width) And (h >=0) And (h <Self.height) And (l >=0) And (l<Self.layer) Then
			Return Self.map[l,h,w]
		Else
			RuntimeError "Unable to perform 'Read' on 'Map':Index out of Bounds"
		EndIf
	
	End Method
	
	Method setvalue(w:Int,h:Int,l:Int,value:Int)
		'setzt den Wert in die angegebene Zelle
		If (w >=0) And (w < Self.width) And (h >=0) And (h <Self.height) And (l >=0) And (l<Self.layer) Then
			Self.map[l,h,w] = value
		Else
			RuntimeError "Unable to perform 'Write' on Map:Index out of Bounds"
		EndIf
	End Method
	
	Method fill(value:Int)
		'f�llt die Map mit einem Wert
		For Local i:Int = 0 To Self.width -1
			For Local j:Int = 0 To Self.height -1
				For Local k:Int = 0 To Self.layer -1
					Self.map[k,j,i] = value
				Next
			Next
		Next
	End Method
	
	Method filllayer(l:Int,value:Int)
		'f�llt einen layer mit einem Wert
		If l < Self.layer Then
			For Local i:Int = 0 To Self.width -1
				For Local j:Int = 0 To Self.height -1
					Self.map[l,j,i]= value
				Next
			Next
		EndIf
	End Method
	
	Method destroy:TGameMap()
		'zerst�rt die aktuelle Karteninstanz
		_link.remove()
		Return Null
	End Method
	
	Rem
	Method draw(numbers:Int = False)
		'vorl�ufige Implementierung f�r Testzwecke Astar
		Local i:Int,j:Int,k:Int
		For i = 0 To Self.width-1
			For j = 0 To Self.height-1
				For k = 0 To Self.layer-1
					If Self.map[k,j,i] = -1 Then
						SetColor 155+10*k,0,0
					Else
						SetColor 10+15*Self.map[k,j,i],10+24*Self.map[k,j,i],10+15*Self.map[k,j,i]
					EndIf
						DrawRect i*30,j*30,25-(k*3),25-(k*3)
					If numbers= True Then
						SetColor 255,255,255
						DrawText Self.map[k,j,i],i*30,j*30
					EndIf
				Next
			Next
		Next
	End Method
	End Rem

End Type
'____________________________________________________________________________________________________

'____________________________________________________________________________________________________
Type TNode

	'Daten:
	Field lastnode:TNode
	Field x:Int,y:Int
	Field cost:Float,aprox:Float
	Field direction:Byte
	Field _link:TLink
	
	'Globale Daten:
	Global LOpen:TList = New TList
	Global LClose:TList = New TList
	
	'Funktionen:
	Function Create:TNode()
		'erstellt einen neuen Knoten.
		Local instanz:TNode = New TNode
		Return instanz
	End Function
	
	Function clear()
		'l�scht die Offene und die geschlossene Liste
		LOpen.Clear()
		LClose.Clear()
	End Function
	
	Rem
	Function draw(ldraw:TList)
		'zeichnet den Weg der gefunden wurde ein. Testimplementierung.
		SetColor 0,0,200
		If ldraw = Null Then Return
		For Local drawnode:TNode = EachIn Ldraw
			DrawRect drawnode.x*30+10,drawnode.y*30+10,10,10
		Next
	End Function
	End Rem
	
	Function AStar:TList(algo:Int,startX:Int,startY:Int,targetX:Int,targetY:Int,map:TGameMap,layer:Int = 0,..
	block:Int = -1,Returnnearest:Int = False,weight:Int=0,hlayer:Int = -1,mode:Int =0)
		'Schnittstelle, erlaubt es alle a* mit einer Function aufzurufen.
		If startX < 0 Or startY < 0 Or startX >= map.width Or startY >= map.height Or targetX < 0 Or targetY < 0 Or targetX >= map.width Or targetY >= map.height
			Return Null
		EndIf
		
		?Debug
		Print "AStar.From: " + startX + ", " + startY
		Print "AStar.To  : " + targetX + ", " + targetY
		?
		
		Local Lreturn:TList = New TList
		
		Select algo
			Case 4
				lreturn = astar4(startX,startY,targetX,targetY,map,layer,block,Returnnearest,weight,hlayer)
			Case 6
				lreturn = astar6(startX,startY,targetX,targetY,map,layer,block,Returnnearest,weight,hlayer,mode)
			Case 8
				lreturn = astar8(startX,startY,targetX,targetY,map,layer,block,Returnnearest,weight,hlayer)
			Default RuntimeError "Unknown Pathfinding Method requested."
		End Select
		
		Return lReturn
	
	End Function
	
	Function AStar8:TList(startX:Int,startY:Int,targetX:Int,targetY:Int,map:TGameMap,layer:Int = 0,..
	block:Int = -1,Returnnearest:Int = False,Weight:Int = 0, hlayer:Int = -1)
		'Der AStar-Algo f�r 8 Richtungen. Block gibt an welcher Karteneintrag f�r blockerte Wege
		'gilt, Map ist die Karte die f�r die Wegfindung benutzt wird.
		'weight: Weightened: Gewichtung der Felder als Kosten
		' smoothened: Diagonalen werden gegl�ttet (sehr viel langsamer!)
		' heightened: H�hendifferenzen gelten als Wegekosten
		' ClimbnFall: s.o., zus�tzlich wird Abstieg nur halb gewertet
		' ist einer der beiden letzten gew�hlt, wird hlayer hinzugezogen, falls gesetzt.
		
		TNode.clear() 'die Listen werden ges�ubert

		Local Start:TNode= TNode.Create() 'Der Startpunkt wird erschaffen
		start.setcoords(startx,starty) 'Die Startkoorinaten werden eingetragen
		start.addopen() 'und der Startpunkt wird auf die offene Liste gesetzt.
		start.cost = 0

		Local Target:TNode = TNode.Create() 'das Ziel wird erschaffen
		Target.setcoords(targetX,targety) 'und mit Koordinaten versehen
		start.aprox = Sqr((target.x-start.x)^2+(target.y-start.y)^2) 'Kostensch�tzung Startfeld
		
		Local search:TNode = start 'nun beginnt der Reigen: Start ist der erste untersuchte Knoten
		Local done:Int = False 'Noch kein Ziel gefunden
		Local donenode:TNode 'Nodeinstanz f�r das Zielfeld
		While (Not done) And (Not LOpen.IsEmpty()) 'solange es noch offene Knoten zum untersuchen gibt
			'DebugStop
			search.close() 'die aktuelle Node wird bearbeitet und ist daher geschlossen
			Local direction:Byte = 0
			For Local x:Int = -1 To 1 'untersuche die umliegenden Felder
				For Local y:Int = -1 To 1
					direction :+ 1
					Local tempx:Int = search.x+x
					Local tempy:Int = search.y+y
					If tempx = target.x And tempy = target.y Then 'Ziel gefunden ?
						done = True 'Ziel gefunden !
						donenode = TNode.Create() 'nun wird donenode erschaffen
						donenode.lastnode=search 'und der letzte schritt dort hin gespeichert
						donenode.setcoords(tempx,tempy)
						donenode.direction = direction
					EndIf
					If (tempx >=0) And (tempx < map.width) And (tempy>=0) And (tempy<map.height) Then 'g�ltige Kartenposition?
						If (x + 2*y) Then 'falls nicht der Mittelpunkt (ist nur 0 wenn beide Komponenten es sind)
						Local tempfound:Int = False 'das untersuchte Feld ist noch nicht in der Liste der offenen Felder ?
						For Local secsearch:TNode = EachIn LOpen
							If (secsearch.x = tempx) And (Secsearch.y=tempy) Then
								tempfound = True 'doch, ist es
							EndIf
						Next
						For Local secsearch:TNode = EachIn LClose 'und bei den geschlossenen vielleicht ?
							If (secsearch.x = tempx) And (Secsearch.y=tempy) Then
								tempfound = True 'doch, ist es
							EndIf
						Next
						If (tempfound = False) And (map.getvalue(tempx,tempy,layer) <> block) Then 'wenn der Knoten noch nicht bekannt war
							Local node:TNode = TNode.Create() 'dann ist er es jetzt
							Node.setcoords(tempx,tempy) 'wo ist er
							node.lastnode = search 'von wo wurde er erreicht ?
							
							node.direction = direction
							Local add:Float
							If direction <> search.direction Then
								add:Float = 0.1
							End If
							node.cost = search.cost +Sqr(Abs(x)+Abs(y)) + add+ (map.getvalue(tempx,tempy,layer)*(weight & ASWEIGHTENED)) 'wie teuer war es her zu kommen (es werden f�r Diagonalen mehr berechnet.) ?
		
							If (weight & ASHEIGHTENED) Then 'H�hendifferenzbestrafung
								If hlayer = -1 Then hlayer = layer
									add = Abs(map.getvalue(node.lastnode.x,node.lastnode.y,hlayer) - map.getvalue(node.x,node.y,hlayer))
									node.cost :+ add
								EndIf
		
								If (weight & ASCLIMBNFALL) Then 'H�hendifferenzbestrafung 2: Anstieg schwerer Abstieg
									If hlayer = -1 Then hlayer = layer
										add = map.getvalue(node.lastnode.x,node.lastnode.y,hlayer) - map.getvalue(node.x,node.y,hlayer)
										If add > 0 Then
											node.cost :+ (add/2)
										Else
											node.cost :- add
										EndIf
									EndIf
		
									node.aprox = Sqr((target.x-node.x)^2+(target.y-node.y)^2) 'wie lautet die Sch�tzung f�r den Rest der Strecke ?
									node.addopen() 'ab auf die Liste der zu bearbeitenden Knoten
									If (weight & ASSMOOTHENED) And (Sqr(Abs(x)+Abs(y)) > 1) Then node.cost :+.5
								EndIf
							EndIf
						EndIf
		
					Next
				Next
			Local mincost:Float =$7fffffff 'setze die Kosten auf ein maximum
			For Local secsearch:TNode = EachIn LOpen'nun suche in der Offenen Liste nach dem Knoten mit den geringsten zu erwartenden Gesamtkosten
				If (secsearch.cost + secsearch.aprox ) < mincost Then
					search = secsearch 'dieser ist dann der n�chste Suchknoten f�r Astar und wird beim n�chsten durchlauf auf die geschlossene gesetzt.
					mincost = (secsearch.cost+secsearch.aprox)
				End If
			Next
		Wend
		'dieser Teil wird abgearbeitet wenn: a) der Zielknoten erreicht wurde oder
		'b) kein offener Knoten mehr existiert, d.h. das Ziel nicht
		'erreicht werden kann.
		If (Returnnearest = True) And (done = False) Then 'soll der n�chstm�glichste Punkt zur�ckgegeben werden ?
			Local mincost:Float= $7fffffff
			For Local secsearch:TNode = EachIn LClose 'dann suche in der geschlossenen Liste den Punkt mit den niedrigsten gesch�tzten Restkosten
				If secsearch.aprox < mincost Then
					donenode = secsearch
					mincost = secsearch.aprox
				End If
			Next
		EndIf
	
		If donenode <> Null Then 'wenn es ein Ziel gibt, erstelle die Liste mit den Wegpunkten
			Local Lreturn:TList = New TList
		Local loop:TNode = donenode
		
		Repeat
			loop._link = LReturn.AddFirst(loop)
			If loop.lastnode <> Null Then loop = loop.lastnode
		Until loop = start
		If Not LReturn.Contains(loop) Then loop._link = LReturn.AddFirst(loop) 'optional, so wird der Startpunkt auch als wegpunkt �bergeben.
			Return LReturn
		Else 'wenn es kein Ziel gibt, gebe eine undefinierte Liste zur�ck
			Return Null
		EndIf
	
	End Function
	
	Function AStar4:TList(startX:Int,startY:Int,targetX:Int,targetY:Int,map:TGameMap,layer:Int = 0,..
	block:Int = -1,Returnnearest:Int = False,weight:Int = 0, hlayer:Int = -1)
		'Der AStar-Algo f�r 4 Richtungen.
		
		TNode.clear()
		Local Start:TNode= TNode.Create()
		start.setcoords(startx,starty)
		start.addopen()
		start.cost = 0
		
		Local Target:TNode = TNode.Create()
		Target.setcoords(targetX,targety)
		start.aprox = Sqr((target.x-start.x)^2+(target.y-start.y)^2)
		
		Local search:TNode = start
		Local done:Int = False
		Local donenode:TNode
		While (Not done) And (Not LOpen.IsEmpty())
			search.close()
			Local direction:Byte = 0
			For Local x:Int = -1 To 1
				For Local y:Int = -1 To 1
					If Sqr(Abs(x)+Abs(y)) = 1 Then
						direction :+ 1
						Local tempx:Int = search.x+x
						Local tempy:Int = search.y+y
						If tempx = target.x And tempy = target.y Then
							done = True
							donenode = TNode.Create()
							donenode.lastnode=search
							donenode.setcoords(tempx,tempy)
							donenode.direction = direction
						EndIf
						If (tempx >=0) And (tempx < map.width) And (tempy>=0) And (tempy<map.height) Then
							If (x + 2*y) Then
								Local tempfound:Int = False
								For Local secsearch:TNode = EachIn LOpen
									If (secsearch.x = tempx) And (Secsearch.y=tempy) Then
										tempfound = True
									EndIf
								Next
								For Local secsearch:TNode = EachIn LClose
									If (secsearch.x = tempx) And (Secsearch.y=tempy) Then
										tempfound = True
									EndIf
								Next
								If (tempfound = False) And (map.getvalue(tempx,tempy,layer) <> block) Then
									Local node:TNode = TNode.Create()
									Node.setcoords(tempx,tempy)
									node.lastnode = search
									node.addopen()
									node.direction = direction
									Local add:Float
									If direction <> search.direction Then
										add:Float = 0.1
									End If
								
									node.cost = search.cost +1 + add + (map.getvalue(tempx,tempy,layer)*(weight & ASWEIGHTENED))
								
									If (weight & ASHEIGHTENED) Then
										If hlayer = -1 Then hlayer = layer
										add = Abs(map.getvalue(node.lastnode.x,node.lastnode.y,hlayer) - map.getvalue(node.x,node.y,hlayer))
										node.cost :+ add
									EndIf
								
									If (weight & ASCLIMBNFALL) Then
										If hlayer = -1 Then hlayer = layer
										add = map.getvalue(node.lastnode.x,node.lastnode.y,hlayer) - map.getvalue(node.x,node.y,hlayer)
										If add > 0 Then
											node.cost :+ (add/2)
										Else
											node.cost :- add
										EndIf
									EndIf
					
									node.aprox = Sqr((target.x-node.x)^2+(target.y-node.y)^2)
								EndIf
							EndIf
						EndIf
					EndIf
				Next
			Next
			Local mincost:Float =$7fffffff
			For Local secsearch:TNode = EachIn LOpen
				If secsearch.cost + secsearch.aprox < mincost Then
					search = secsearch
					mincost = secsearch.cost+secsearch.aprox
				End If
			Next
		Wend
		
		If (Returnnearest = True) And (done = False) Then
			Local mincost:Float= $7fffffff
			For Local secsearch:TNode = EachIn LClose
				If secsearch.aprox < mincost Then
					donenode = secsearch
					mincost = secsearch.aprox
				End If
			Next
		EndIf
		
		If donenode <> Null Then
			Local Lreturn:TList = New TList
			Local loop:TNode = donenode
			
			Repeat
				loop._link = LReturn.AddFirst(loop)
				If loop.lastnode <> Null Then loop = loop.lastnode
			Until loop = start
			If Not Lreturn.contains(loop) Then loop._link=LReturn.AddFirst(loop)
			Return LReturn
		Else
			Return Null
		EndIf
	
	End Function
	
	Function AStar6:TList(startX:Int,startY:Int,targetX:Int,targetY:Int,map:TGameMap,layer:Int = 0,..
	block:Int = -1,Returnnearest:Int = False,weight:Int = 0,hlayer:Int = -1,mode:Int =0)
		'Der AStar-Algo f�r 6 Richtungen.
		'Mode gibt an ob die 0er (mode 1) oder die 1erreihe linksb�ndig steht.
		
		TNode.clear()
		Local Start:TNode= TNode.Create()
		start.setcoords(startx,starty)
		start.addopen()
		start.cost = 0
		
		Local Target:TNode = TNode.Create()
		Target.setcoords(targetX,targety)
		start.aprox = Sqr((target.x-start.x)^2+(target.y-start.y)^2)
		
		Local search:TNode = start
		Local done:Int = False
		Local donenode:TNode
		While (Not done) And (Not LOpen.IsEmpty())
			search.close()
			For Local direction:Byte = 1 To 6
				Local tempx:Int = 0
				Local tempy:Int = 0
				If ((search.y + mode) Mod 2) Then
					Select direction
						Case 1
							tempx=search.x-1
							tempy=search.y-1
						Case 2
							tempx=search.x
							tempy=search.y-1
						Case 3
							tempx=search.x+1
							tempy=search.y
						Case 4
							tempx=search.x
							tempy=search.y+1
						Case 5
							tempx=search.x-1
							tempy=search.y+1
						Case 6
							tempx=search.x-1
							tempy=search.y
					End Select
				Else
					Select direction
						Case 1
							tempx=search.x
							tempy=search.y-1
						Case 2
							tempx=search.x+1
							tempy=search.y-1
						Case 3
							tempx=search.x+1
							tempy=search.y
						Case 4
							tempx=search.x+1
							tempy=search.y+1
						Case 5
							tempx=search.x
							tempy=search.y+1
						Case 6
							tempx=search.x-1
							tempy=search.y
					End Select
				EndIf
	
				If tempx = target.x And tempy = target.y Then
					done = True
					donenode = TNode.Create()
					donenode.lastnode=search
					donenode.setcoords(tempx,tempy)
					donenode.direction = direction
				EndIf
				If (tempx >=0) And (tempx < map.width) And (tempy>=0) And (tempy<map.height) Then
					Local tempfound:Int = False
					For Local secsearch:TNode = EachIn LOpen
						If (secsearch.x = tempx) And (Secsearch.y=tempy) Then
							tempfound = True
						EndIf
					Next
					For Local secsearch:TNode = EachIn LClose
						If (secsearch.x = tempx) And (Secsearch.y=tempy) Then
							tempfound = True
						EndIf
					Next
					If (tempfound = False) And (map.getvalue(tempx,tempy,layer) <> block) Then
						Local node:TNode = TNode.Create()
						Node.setcoords(tempx,tempy)
						node.lastnode = search
						node.addopen()
						node.direction = direction
						Local add:Float
						If direction <> search.direction Then
							add:Float = 0.1
						End If
						node.cost = search.cost + 1 + add + (map.getvalue(tempx,tempy,layer)*(weight & ASWEIGHTENED))
	
						If (weight & ASHEIGHTENED) Then
							If hlayer = -1 Then hlayer = layer
							add = Abs(map.getvalue(node.lastnode.x,node.lastnode.y,hlayer) - map.getvalue(node.x,node.y,hlayer))
							node.cost :+ add
						EndIf
	
						If (weight & ASCLIMBNFALL) Then
							If hlayer = -1 Then hlayer = layer
							add = map.getvalue(node.lastnode.x,node.lastnode.y,hlayer) - map.getvalue(node.x,node.y,hlayer)
							If add > 0 Then
								node.cost :+ (add/2)
							Else
								node.cost :- add
							EndIf
						EndIf
	
						node.aprox = Sqr((target.x-node.x)^2+(target.y-node.y)^2)
					EndIf
				EndIf
			Next
			Local mincost:Float =$7fffffff
			For Local secsearch:TNode = EachIn LOpen
				If secsearch.cost + secsearch.aprox < mincost Then
					search = secsearch
					mincost = secsearch.cost+secsearch.aprox
				End If
			Next
		Wend
	
		If (Returnnearest = True) And (done = False) Then
			Local mincost:Float= $7fffffff
			For Local secsearch:TNode = EachIn LClose
				If secsearch.aprox < mincost Then
					donenode = secsearch
					mincost = secsearch.aprox
				End If
			Next
		EndIf
	
		If donenode <> Null Then
			Local Lreturn:TList = New TList
			Local loop:TNode = donenode
	
			Repeat
				loop._link = LReturn.AddFirst(loop)
				If loop.lastnode <> Null Then loop = loop.lastnode
			Until loop = start
			If Not LReturn.Contains(loop) Then loop._link = LReturn.AddFirst(loop)
			Return LReturn
		Else
			Return Null
		EndIf
	
	End Function
	
	'Methoden:
	Method Addopen()
		'f�gt die Instanz der Suchliste hinzu.
		_link = LOpen.AddLast(Self)
	End Method
	
	Method Close()
		'entfernt die Instanz von der Offenen Liste und setzt sie auf die geschlossene Liste
		If _link <> Null Then
			_link.remove()
			_link = LClose.AddLast(Self)
		EndIf
	End Method
	
	Method setcoords(x:Int,y:Int)
		'Koordinaten einer Node festlegen
		Self.x = x
		Self.y = y
	End Method
	
End Type

'___________________________________________________________________________________________________

Rem TESTCODE
SeedRnd MilliSecs()
Local test:TGameMap = TGameMap.Create(15,15,2)
For Local i:Int = 0 To 14
	For Local j:Int = 0 To 14
		test.setvalue(i,j,0,Rand(10))
	Next
Next
For Local i:Int = 0 To 14
	For Local j:Int = 0 To 14
		test.setvalue(i,j,1,Rand(2))
	Next
Next

AppTitle="A* Demo V1.12 ~~BladeRunner~~"
Graphics 640,480

Local startx:Int = 0
Local starty:Int = 0
Local endx:Int = 14
Local endy:Int = 14

Repeat
	Local zeit2:Int
	Local mx:Int = MouseX()
	Local my:Int = MouseY()
	Local mbl:Int = MouseHit(1)
	Local mbr:Int = MouseHit(2)
	Local shifted:Int
	
	If KeyDown(key_lshift) Or KeyDown(key_rshift) Then
		shifted = 1
	Else
		shifted = 0
	EndIf
	
	If mbl And shifted And test.getvalue(mx/30,my/30,0) > 0 Then
		test.setvalue(mx/30,my/30,0,test.getvalue(mx/30,my/30,0)-1)
	EndIf
	
	If mbr And shifted And test.getvalue(mx/30,my/30,0) < 10 Then
		test.setvalue(mx/30,my/30,0,test.getvalue(mx/30,my/30,0)+1)
	EndIf
	
	If mbl And (shifted = 0) And test.getvalue(mx/30,my/30,1) > -1 Then
		test.setvalue(mx/30,my/30,1,test.getvalue(mx/30,my/30,1)-1)
	EndIf
	
	If mbr And (shifted = 0) And test.getvalue(mx/30,my/30,1) < 2 Then
		test.setvalue(mx/30,my/30,1,test.getvalue(mx/30,my/30,1)+1)
	EndIf
	
	If KeyHit(key_left) Then
		Select shifted
			Case 0
				If startx >0 Then startx :-1
			Case 1
				If endx >0 Then endx :-1
		End Select
	EndIf
	
	If KeyHit(key_right) Then
		Select shifted
			Case 0
				If startx <test.width Then startx :+1
			Case 1
				If endx <test.width Then endx :+1
		End Select
	EndIf
	
	If KeyHit(key_up) Then
		Select shifted
			Case 0
				If starty >0 Then starty :-1
			Case 1
				If endy >0 Then endy :-1
		End Select
	EndIf
	
	If KeyHit(key_down) Then
		Select shifted
			Case 0
				If starty <test.height Then starty :+1
			Case 1
				If endy <test.height Then endy :+1
		End Select
	EndIf
	Local zeit:Int = MilliSecs()
	Local ldraw:TList=TNode.astar8(startx,starty,endx,endy,test,1,-1,True,ASWEIGHTENED|ASSMOOTHENED|ASCLIMBNFALL,0)
	zeit2 = MilliSecs()
	test.draw()
	TNode.draw(ldraw)
	DrawText "LMB: decrease Cost",450,0
	DrawText "RMB: increase Cost",450,20
	DrawText "Shift+ MB: alter Height",450,40
	DrawText "up/down/left/right:",450,80
	DrawText " Move Start",450,100
	DrawText "to move End: hold Shift",450, 130
	DrawText GCMemAlloced(),500,460
	
	DrawText (zeit2-zeit)+" ms",500,300
	Flip
	Cls
Until KeyHit(KEY_ESCAPE) Or AppTerminate()
EndRem
