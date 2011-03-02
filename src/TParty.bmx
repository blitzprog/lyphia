
' TParty
Type TParty
	Global count:Int = 0
	
	Field id:Int
	Field name:String
	Field members:TList
	
	' Init
	Method Init(nName:String)
		Self.name = nName
		Self.members = CreateList()
		
		Self.id = count
		count :+ 1
	End Method
	
	' Add
	Method Add(nEntity:TEntity)
		nEntity.party = Self
		nEntity.partyLink = Self.members.AddLast(nEntity)
	End Method
	
	' Remove
	Method Remove(nEntity:TEntity)
		If nEntity.partyLink <> Null
			nEntity.partyLink.Remove()
		Else
			Throw "'" + nEntity.GetName() + "' has no party"
		EndIf
	End Method
	
	' Clear
	Method Clear()
		For Local entity:TEntity = EachIn Self.members
			Self.Remove(entity)
		Next
	End Method
	
	' Contains
	Method Contains:Int(nEntity:TEntity)
		If nEntity = Null
			Return False
		EndIf
		Return nEntity.GetParty() = Self
	End Method
	
	' GetByName
	Method GetByName:TEntity(nName:String)
		For Local entity:TEntity = EachIn Self.members
			If entity.GetName() = nName
				Return entity
			EndIf
		Next
	End Method
	
	' RemoveByName
	Method RemoveByName(nName:String)
		For Local entity:TEntity = EachIn Self.members
			If entity.GetName() = nName
				Self.Remove(entity)
				Return
			EndIf
		Next
	End Method
	
	' GetMembersList
	Method GetMembersList:TList()
		Return Self.members
	End Method
	
	' GetNumberOfMembers
	Method GetNumberOfMembers:Int()
		Return Self.members.Count()
	End Method
	
	' ToString
	Method ToString:String()
		Local stri:String = Self.name + ": "
		For Local entity:TEntity = EachIn Self.members
			stri :+ entity.GetName() + ", "
		Next
		Return stri[..stri.length - 2]
	End Method
	
	' Create
	Function Create:TParty(nName:String)
		Local party:TParty = New TParty
		party.Init(nName)
		Return party
	End Function
End Type