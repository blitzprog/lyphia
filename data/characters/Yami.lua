function init()
	super.SetCharacterName("Yami")
	super.SetImageFile("Yami.png")
	super.LoadConfigFile("Yami.ini")
	
	super.InitStatus(1, 1000, 450)
	super.SetBaseSpeed(0.2)
	
	super.CreateSkillSlots(4)
	
	-- Skills
	super.SetSlotSkill(0, "SwordSlash")
	super.SetSlotSkill(1, "DarkMatter")
	super.SetSlotSkill(2, "SoulStrike")
	super.SetSlotSkill(3, "DarkHole")
end