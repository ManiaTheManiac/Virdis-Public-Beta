//Virdis main code - 4M
//Built-in userdata goes brrr~
//birb is the word

local function varbol(bol,var1,var2) --Funny func to turn true-false stuff into anything
	if bol
		return var1
	else
		return var2
	end
end

/*
Table of stuff:
player.charability - switcher between actions (50 - nothing, 51 - jump+jump and so on...)
player.charability2 - switch inside switcher
player.axis1 - points to object
player.bumpertime - used as timer


player.charability

50 - Nothing, initial state, every action end or taking damage comes with changing charability value to this to avoid setting it constantly
51 - Jump+Jump custom float thok with multiple phases under fancy name - Aerotide
52 - Charging diagonal jump forward, or release to throw feather knives and backflip
53 - 


player.charability2
For charability 51.
50 - Charging Aerotide, pressing SPIN activates doublejump.
51 - Early release of jump button, drop down.
52 - Release jump button to thok
53 - Constant InstaThrust at max charge


*/


local function valid(mo)
    return mo and mo.valid
end

//Function to reset stuff
local function VirdisValuesReset(player)
	player.charability = 50
	player.charability2 = 50
	player.bumpertime = 0
	player.actionspd = 0
	player.mindash = 0
	player.mo.spriteroll = 0
	player.mo.axis1 = nil
	player.mo.axis2 = nil
	if (player.pflags & PF_THOKKED)
		player.pflags = ($ & ~PF_THOKKED)
	end
	player.powers[pw_nocontrol] = 0
end

//Same but when switch skins in coop. We only set some built-ins into default state.
local function UnBirb(player)
	player.bumpertime = 0
	player.mo.axis1 = nil
	player.mo.axis2 = nil
	if (player.pflags & PF_THOKKED)
		player.pflags = ($ & ~PF_THOKKED)
	end
	player.powers[pw_nocontrol] = 0
end


//Main playerthink, handle actions
local function virdis_main(player)
	//Check if you're a birb
	if not (player.mo and player.mo.valid and player.mo.skin == "virdis") --Not a birb?
		if player.mo.oldskin == "virdis" --Was a birb? Reset and unbirb.
			UnBirb(player)
			player.mo.oldskin = nil
		end
		return
	end

	if P_PlayerInPain(player) == true or player.playerstate ~= PST_LIVE or player.powers[pw_carry] ~= CR_NONE or player.exiting// General reset on hit, prevent other stuff to work
		if player.mo.deathtype ~= nil
			player.mo.state = player.mo.deathtypev
			player.mo.deathtype = nil
		end
		VirdisValuesReset(player)
		if player.mo.state == S_PLAY_DEAD
			if player.mo.frame == 268435462 --dgaf how it works, just deducting value doesn't do a thing
				player.mo.frame = 268435459
			end
		end
		if player.exiting and player.mo.state ~= S_PLAY_VIRDIS_VICTORY
			player.mo.state = S_PLAY_VIRDIS_VICTORY
		end
		return
	end
	
	local ref = player.mo

	//You're past checkpoint, you are a birb! Set stuff
	if ref.oldskin ~= "virdis" 
		VirdisValuesReset(player)
		ref.oldskin = "virdis"
	end 							//Taunts
if (player.cmd.buttons & BT_CUSTOM1) and not (player.lastbuttons & BT_CUSTOM1) --Pressed a button
   if P_IsObjectOnGround(player.mo) and player.speed < 2 then player.mo.state = S_PLAY_FALL
      if not (player.mo.state == S_PLAY_VIRDIS_TAUNT) or (player.mo.state == S_PLAY_STND) --Not taunting?
        player.mo.state = S_PLAY_VIRDIS_TAUNT --Start taunting
		S_StartSound(ref,sfx_damn)
	end
end
end
	//Jump+Jump custom float thok
	if player.charability == 51
		if P_IsObjectOnGround(ref) == false
			if player.charability2 == 50
				if (player.cmd.buttons & BT_JUMP) and player.bumpertime ~= 0
					P_SetObjectMomZ(ref,0,false)
					//local thokcharge = P_SpawnMobjFromMobj(ref,0,0,0,MT_VIRDIS_THOK)
					//thokcharge.target = ref
				//	thokcharge.colorize = true
					if player.bumpertime == 139
						S_StartSound(ref,sfx_prloop)
					end		
					if player.bumpertime == 105
						S_StartSound(ref,sfx_hoop1)
					end
					if player.bumpertime == 70
						S_StartSound(ref,sfx_hoop2)
					end
					if player.bumpertime == 35
						S_StartSound(ref,sfx_hoop3)
					end
					if (player.cmd.buttons & BT_SPIN) and not (player.lastbuttons & BT_SPIN)
						player.mo.state = S_PLAY_JUMP
						P_SetObjectMomZ(ref,6*FRACUNIT+((70-((player.bumpertime+10)/2))/3*FRACUNIT),false)
						VirdisValuesReset(player)
						player.pflags = $|PF_THOKKED
						player.mo.state = S_PLAY_SPRING
					end
				else
					player.charability2 = 51
				end
			end
			
			if player.charability2 == 51
				if player.actionspd == 0
					player.actionspd = 80-((player.bumpertime+10)/3)
				end
				if player.bumpertime > 105
					VirdisValuesReset(player)
					player.mo.state = S_PLAY_FALL
					player.pflags = $|PF_THOKKED|PF_NOJUMPDAMAGE
					print("https://github.com/ManiaTheManiac/Virdis-Public-Beta/tree/main")
					return
				else
					player.charability2 = 52
				end
			end
			
			if player.charability2 == 52
				if player.bumpertime > 35 
					P_InstaThrust(ref,ref.angle,player.actionspd*FRACUNIT)
					VirdisValuesReset(player)
					player.pflags = $|PF_THOKKED
					player.mo.state = S_PLAY_ROLL
				else
					player.pflags = $|PF_THOKKED
					player.powers[pw_strong] = STR_WALL|STR_ANIM
					player.mo.state = S_PLAY_ROLL
					player.charability2 = 53
				end
			end
			
			if player.charability2 == 53
				P_InstaThrust(ref,ref.angle,player.actionspd*FRACUNIT)
			end
		else
			player.pflags = $|PF_SPINNING
			VirdisValuesReset(player)
			player.mo.state = S_PLAY_ROLL
		end
	end
	
	
	
	if player.charability == 52
		player.powers[pw_nocontrol] = 1
		player.drawangle = ref.angle
		if player.mindash < 45
			player.mindash = $ + 1
		end
		
		if not (player.cmd.buttons & BT_SPIN)
			if player.mindash < 45
				player.drawangle = ref.angle
				for i = 0,7 do
					local knive = P_SpawnMobj(ref.x,ref.y,ref.z+20*FRACUNIT,MT_VIRDIS_FEATHERKNIVE)
					knive.angle = 0+i*ANGLE_45
					knive.tracer = ref
					P_InstaThrust(knive,knive.angle,15*FRACUNIT)
				end
				P_SetObjectMomZ(ref,10*FRACUNIT,false)
				P_Thrust(ref, ref.angle, -17*FRACUNIT)
				S_StartSound(ref,sfx_mswing)
				player.pflags = $|PF_JUMPED
				player.mo.state = S_PLAY_FALL
			else
				P_SetObjectMomZ(ref,15*FRACUNIT,false)
				P_InstaThrust(ref, ref.angle, 40*FRACUNIT)
				player.pflags = $|PF_SPINNING|PF_JUMPED
				player.mo.state = S_PLAY_ROLL
			end
			VirdisValuesReset(player)
			player.powers[pw_nocontrol] = 0
		end
	end
	
	if player.charability == 53
		player.powers[pw_nocontrol] = 1
		if player.charability2 == 51
			ref.state = S_PLAY_VIRDIS_KNOCKED
			player.charability2 = 52
		end
		
		if player.charability2 == 52
			ref.spriteroll = $ + ANG10
			if P_IsObjectOnGround(ref) == true
				player.bumpertime = 35
				player.charability2 = 53
				ref.state = S_PLAY_VIRDIS_FAIL
				ref.spriteroll = 0
			end
		end
		
		if player.charability2 == 53
			if player.bumpertime == 0
				player.charability = 50
				player.charability2 = 50
				player.powers[pw_nocontrol] = 0
				ref.state = S_PLAY_STND
			end
		end
		
	end
	
	
	if (player.mo.state == S_PLAY_ROLL or player.mo.state == S_PLAY_JUMP) and player.mo.momz < 0
		player.powers[pw_strong] = STR_FLOOR|STR_ANIM
	end
end

//Jump+Jump set action
local function virdis_abilspec(player)
	if not (player.mo and player.mo.skin == "virdis")
		return
	end

	if (player.pflags & PF_JUMPED) and P_IsObjectOnGround(player.mo) == false
	and not (player.pflags & PF_THOKKED)
	and player.charability == 50
		player.mo.state = S_PLAY_ROLL
		player.charability = 51
		player.bumpertime = 140 - player.speed/FRACUNIT
		local tornado = P_SpawnMobjFromMobj(player.mo,0,0,0,MT_VIRDIS_TORNADO)
		tornado.target = player.mo
		tornado.frame = $|FF_TRANS10+(((player.bumpertime - 14)/14) * FF_TRANS10)
		tornado.color = SKINCOLOR_WHITE
	end
end


//Spin set action
local function virdis_spinspec(player)
	if not (player.mo and player.mo.valid) or player.mo.skin ~= "virdis"
		return
	end

	if not P_IsObjectOnGround(player.mo)
		return
	end
	
	local ref = player.mo
	
	if player.speed > 10*FRACUNIT
		if player.charability == 50 and not (player.lastbuttons & BT_SPIN) and player.charability2 == 50
			//Spin on ground. People usually call such ability as "Fan of Knives"
			player.drawangle = ref.angle
			for i = 0,7 do
				local knive = P_SpawnMobj(ref.x,ref.y,ref.z+20*FRACUNIT,MT_VIRDIS_FEATHERKNIVE)
				knive.angle = 0+i*ANGLE_45
				knive.tracer = ref
				P_InstaThrust(knive,knive.angle,15*FRACUNIT)
			end
			P_SetObjectMomZ(ref,10*FRACUNIT,false)
			P_Thrust(ref, ref.angle, -17*FRACUNIT)
			S_StartSound(ref,sfx_mswing)
			player.pflags = $|PF_JUMPED
			player.mo.state = S_PLAY_FALL
			VirdisValuesReset(player)
		end
	else
		player.charability = 52
		player.charability2 = 51
	end
end

//5% chance to avoid damage, give 1 second of invulnerability to prevent another instance of damage
local function virdis_passive(target, inflictor, source, damage, damagetype)
	if not (target.player and target.player.valid) or target.skin ~= "virdis"
		return
	end
	
	if (inflictor or source) and target.skin == "virdis"
		local savethrow = P_RandomRange(1,20)
		if savethrow == 20 --NAT 20!
			target.player.powers[pw_flashing] = 35
			S_StartSound(target,sfx_wbreak)
			P_SetObjectMomZ(target,4*FRACUNIT,false)
			P_InstaThrust(target, target.angle, 10*FRACUNIT)
			target.state = S_PLAY_VIRDIS_DODGE
			return true
		end
	end
end


//Copy over from Finitevus
local function virdis_aerocol(mobj,object,line)
	local ref = mobj.player
	if not (mobj and mobj.valid and mobj.skin == "virdis")
		return
	end

	if ref.charability == 51 and ref.charability2 == 53
		if valid(line) or valid(object)
//			local ang = R_PointToAngle2(drf.x,drf.y,line.x,line.y)
//			drf.angle = ang
//			if ref.speed < 17*FRACUNIT //and player.actionspd >= 65
//				glidestrafe = 0
				P_InstaThrust(mobj, mobj.angle-ANGLE_180, 10*FRACUNIT)
				P_SetObjectMomZ(mobj, 13*FRACUNIT)
				ref.pflags = $|PF_THOKKED
				mobj.state = S_PLAY_VIRDIS_KNOCKED
				ref.charability2 = 51
				ref.charability = 53
//				S_StartSound(mobj, sfx_drfbmp)
				return true
//			end
		end
	end
end

local function vird_hud(v,player,camera)
    local ref = player.mo
    if not valid(ref) or ref.skin ~= "virdis"
        return
    end

    if not hud.enabled("lives")
        return
    end
    
    local lifeicon
        
    if player.exiting or player.mo.state == S_PLAY_VIRDIS_DODGE
        lifeicon = v.cachePatch("VRDHUD0")
    elseif P_PlayerInPain(player) == true or player.playerstate ~= PST_LIVE or player.charability == 53
        lifeicon = v.cachePatch("VRDHUD1")
    end
    
    local colormap = v.getColormap(player.mo.skin,player.mo.color)
    
    if lifeicon ~= nil
        v.drawScaled(hudinfo[HUD_LIVES].x*FRACUNIT, hudinfo[HUD_LIVES].y*FRACUNIT, FRACUNIT/2, lifeicon, V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_PERPLAYER,colormap)
    end
end

local function virdis_dead(target, inflictor, source, damagetype)
	if not (target and target.valid and target.skin == "virdis") return end
	
	if target.deathtype == nil and target.state == S_PLAY_DEAD
		if (damagetype == 2)
			target.deathtype = S_PLAY_VIRDIS_BURN
			return
		end

		if (damagetype == 3)
			target.deathtype = S_PLAY_VIRDIS_ELECUT
			return
		end
	end
end


//Hooks
addHook("PlayerThink", virdis_main)
addHook("AbilitySpecial", virdis_abilspec)
addHook("SpinSpecial", virdis_spinspec)
addHook("MobjDamage",virdis_passive,MT_PLAYER)
addHook("MobjMoveBlocked",virdis_aerocol,MT_PLAYER)
addHook("MobjDeath",virdis_dead,MT_PLAYER)
hud.add(vird_hud, player)