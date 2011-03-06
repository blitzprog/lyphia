function init()
	super.SetCharacterName("Mystic")
	super.SetImageFile("Mystic.png")
	super.LoadConfigFile("Mystic.ini")
	
	super.InitStatus(1, 1000, 450)
	super.SetBaseSpeed(0.2)
	
	super.CreateSkillSlots(8)
	
	-- Skills
	super.SetSlotSkill(0, "SwordSlash")
	super.SetSlotSkill(1, "ThunderSphere")
	super.SetSlotSkill(2, "ChainLightning")
	super.SetSlotSkill(3, "SoulStrike")
	super.SetSlotSkill(4, "DarkMatter")
	super.SetSlotSkill(5, "Meteor")
	super.SetSlotSkill(6, "Inferno")
	super.SetSlotSkill(7, "IceWave")
end