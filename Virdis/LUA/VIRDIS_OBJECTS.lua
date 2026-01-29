//Virdis related objects.

freeslot(
--Objects-- 
"MT_VIRDIS_FEATHERKNIVE",
"MT_VIRDIS_THOK",
"MT_VIRDIS_TORNADO",

--States-- 
"S_VIRDIS_FEATHERKNIVE",
"S_VIRDIS_THOK",
"S_VIRDIS_TORNADO",
"S_PLAY_VIRDIS_DODGE",
"S_PLAY_VIRDIS_AEROTIDE",
"S_PLAY_VIRDIS_VICTORY",
"S_PLAY_VIRDIS_TAUNT",
"S_PLAY_VIRDIS_KNOCKED",
"S_PLAY_VIRDIS_FAIL",
"S_PLAY_VIRDIS_BURN",
"S_PLAY_VIRDIS_ELECUT",

--Sprites--
"SPR_VRDF", -- Feather Knive
"SPR_VRDR", -- Tornado GFX during aerotide charge
"SPR_VRDS", -- Hyperstar (unused)
"SPR_VRDO", -- Custom thok (unused by custom code)

"SPR2_VRDV", -- Victory
"SPR2_VRDD", -- Lucky Dodge
"SPR2_VRDT", -- Taunt
"SPR2_VRDF", -- Aerotide Knockout
"SPR2_SHIT", -- Dead (freesloted just in case)
"SPR2_VRDB", -- Burn
"SPR2_VRDE" -- Electrocute
) 

//Stuff bellow in format: Object-corresponding states
mobjinfo[MT_VIRDIS_FEATHERKNIVE] = {
	radius = 8*FRACUNIT,
	height = 5*FRACUNIT,
    spawnstate = S_VIRDIS_FEATHERKNIVE,
    flags = MF_SCENERY|MF_SPECIAL 
}

states[S_VIRDIS_FEATHERKNIVE] = {
    sprite = SPR_VRDF,
	tics = 125
}

mobjinfo[MT_VIRDIS_THOK] = {
    spawnstate = S_VIRDIS_THOK,
    flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP|MF_SCENERY
}

states[S_VIRDIS_THOK] = {
    sprite = SPR_VRDO,
	frame = A,
	tics = 4
}

mobjinfo[MT_VIRDIS_TORNADO] = {
    spawnstate = S_VIRDIS_TORNADO,
    flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP|MF_SCENERY
}

states[S_VIRDIS_TORNADO] = {
    sprite = SPR_VRDR,
	frame = A|FF_ANIMATE,
	tics = -1,
	var1 = 3,
	var2 = 2
}


states[S_PLAY_VIRDIS_DODGE] = { 
	sprite = SPR_PLAY,
	frame = SPR2_VRDD|A,
	tics = 10,
	nextstate = S_PLAY_FALL
}

states[S_PLAY_VIRDIS_KNOCKED] = { 
	sprite = SPR_PLAY,
	frame = SPR2_VRDF,
	tics = -1,
	var1 = 0,
	var2 = 0
}

states[S_PLAY_VIRDIS_FAIL] = { 
	sprite = SPR_PLAY,
	frame = SPR2_SHIT|A,
	tics = -1
}

states[S_PLAY_VIRDIS_VICTORY] = { 
	sprite = SPR_PLAY,
	frame = SPR2_VRDV|A|FF_ANIMATE,
	tics = -1,
	var1 = 4,
	var2 = 2,
	nextstate = S_PLAY_VIRDIS_VICTORY
}

states[S_PLAY_VIRDIS_TAUNT] = { 
	sprite = SPR_PLAY,
	frame = SPR2_VRDT|A,
	tics = 10,
	nextstate = S_PLAY_FALL
}


states[S_PLAY_VIRDIS_ELECUT] = { 
	sprite = SPR_PLAY,
	frame = SPR2_VRDE|A|FF_ANIMATE,
	tics = 25,
	var1 = 4,
	var2 = 2,
	nextstate = S_PLAY_DEAD
}

states[S_PLAY_VIRDIS_BURN] = { 
	sprite = SPR_PLAY,
	frame = SPR2_VRDB|A,
	tics = 25,
	nextstate = S_PLAY_DEAD
}

//Valid shortcut
local function valid(mo)
    return (mo and mo.valid)
end

//Override property of object with MF_SPECIAL, so it won't die on touch. 
local function ts_overwrite(obj, toucher)
	return true
end

//Why MF_SPECIAL is superior over MF_MISSILE
local function virdis_knivecol(knive,obj)
	local refflip
	if knive.eflags & MFE_VERTICALFLIP
		refflip = 1
	else
		refflip = 0
	end

	if (knive.z-(obj.height*refflip) < obj.z+obj.height-(obj.height*refflip)) 
	and (obj.z-(knive.height*refflip) < knive.z+knive.height-(knive.height*refflip))
	and ((obj.flags & (MF_ENEMY|MF_BOSS|MF_MONITOR|MF_SHOOTABLE)) or obj.type == MT_EGGSHIELD) 
	and obj.health and not (obj.flags2 & MF2_FRET)
	and obj ~= knive.tracer
		if obj.type == MT_EGGSHIELD -- This thing needs different approach
			if obj.target.state == S_EGGGUARD_STND
				obj.target.state = S_EGGGUARD_MAD1
			end
		end
		P_DamageMobj(obj,knive,knive.tracer,1)
		P_RemoveMobj(knive)
		return true
	else
		return false
	end

end

//Virdis Feather Thinker, everything else if above.
local function virdis_knive(mobj)
	if not valid(mobj)
		return
	end

	if P_IsObjectOnGround(mobj) == true
		P_RemoveMobj(mobj)
	end
end

//This is probably placeholder
local function virdis_thok_trail(mobj)
	if not valid(mobj)
		return
	end
	mobj.frame = $ + FF_TRANS10
	
	/*
	if not valid(mobj.target)
		return
	end

	if mobj.target.player.bumpertime >= 106
		if mobj.color ~= SKINCOLOR_JADE
			mobj.color = SKINCOLOR_JADE
			mobj.target = nil
		end
	elseif mobj.target.player.bumpertime >= 71 and mobj.target.player.bumpertime < 106
		if mobj.color ~= SKINCOLOR_BROWN
			mobj.color = SKINCOLOR_BROWN
			mobj.target = nil
		end
	elseif mobj.target.player.bumpertime >= 35 and mobj.target.player.bumpertime < 70
		if mobj.color ~= SKINCOLOR_CRIMSON
			mobj.color = SKINCOLOR_CRIMSON
			mobj.target = nil
		end
	elseif mobj.target.player.bumpertime < 35
		if mobj.color ~= SKINCOLOR_RED
			mobj.color = SKINCOLOR_RED
			mobj.target = nil
		end
	end
	*/
end

local function virdis_tornado(mobj)
	if mobj.target
		P_MoveOrigin(mobj,mobj.target.x,mobj.target.y,mobj.target.z)
	end
	if (mobj.target.player.bumpertime % 14) == 0
		mobj.frame = $ - FF_TRANS10
	end
	
	if mobj.target.player.bumpertime < 35
		if mobj.color ~= SKINCOLOR_CYAN
			mobj.color = SKINCOLOR_CYAN
		else
			mobj.color = SKINCOLOR_JADE
		end
		
		if mobj.target.player.bumpertime == 0
			P_RemoveMobj(mobj)
		end
	end
end


//Hooks

addHook("TouchSpecial",ts_overwrite,MT_VIRDIS_FEATHERKNIVE)
addHook("MobjThinker",virdis_knive,MT_VIRDIS_FEATHERKNIVE)
addHook("MobjThinker",virdis_thok_trail,MT_VIRDIS_THOK)
addHook("MobjThinker",virdis_tornado,MT_VIRDIS_TORNADO)
addHook("MobjMoveCollide",virdis_knivecol,MT_VIRDIS_FEATHERKNIVE)