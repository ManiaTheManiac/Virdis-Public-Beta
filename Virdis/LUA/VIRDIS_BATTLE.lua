///Battlemod

local function virdis_customguard(player)
	if not (player.mo and player.mo.valid and player.mo.skin == "virdis") return end
	if player.cusguard == nil --Sadly can't use player.guard due to BM always setting it to 0
		player.cusguard = 0
	end
	
	local mo = player.mo
	if mo and mo.valid and mo.cusguardflash --Can't use player.guardflash too
		mo.colorized = false
		mo.color = player.skincolor
		mo.cusguardflash = false
	end
	if not(player.playerstate == PST_LIVE) or (player.spectator) return end
	if P_PlayerInPain(player)
	or player.tumble
	or player.actionstate
	or (CBW_Battle.TagGametype() and not (player.pflags & PF_TAGIT or player.battletagIT)
			and player.actioncooldown > 0 and player.cusguard == 0)
	or player.iseggrobo
	or player.isjettysyn
	or (player.skidtime and player.powers[pw_nocontrol])
	or (player.weapondelay and mo.state == S_PLAY_FIRE)
		if player.cusguard != 0
			if not(P_PlayerInPain(player)) and not(player.pflags&(PF_JUMPED|PF_SPINNING))
				mo.state = S_PLAY_FALL
				mo.coyoteTime = 0
			end
			player.cusguard = 0
		end
		return
	end
	//Neutral
	if (player.cusguard == 0)
		if CBW_Battle.ButtonCheck(player,player.battleconfig_guard) == 1 
			if CBW_Battle.Console.parrytoggle.value and not (player.lastbuttons & player.battleconfig_guard)
				player.pflags = $ &~ PF_JUMPED
				player.skidtime = 0
				if player.powers[pw_flashing] or player.nodamage
					player.powers[pw_flashing] = 0
					player.nodamage = 0
					player.guardbuffer = 2
				end
				player.cusguard = 1
				S_StartSound(mo,sfx_cdfm39)
				player.guardtics = TICRATE*4/7 //20
				player.actionstate = 0
				local i = P_SpawnMobj(mo.x,mo.y,mo.z,MT_INSTASHIELD)
				if i and i.valid
					i.target = mo
				end
				//make runners pay rings and apply cooldown for guard in battle tag
				if CBW_Battle.TagGametype() and not (player.pflags & PF_TAGIT or 
						player.battletagIT)
					CBW_Battle.PayRings(player, 10, true)
					CBW_Battle.ApplyCooldown(player, TICRATE)
				end
			end
		end
	end
	if player.guardbuffer and player.guardbuffer>0
		player.guardbuffer = $-1
	end
	if player.cusguard != 0 and (player.followmobj)
		P_SetMobjStateNF(player.followmobj,S_NULL)
	end

	local guardframe = CBW_Battle.SkinVars[player.skinvars].guard_frame
	
	if player.cusguard == 1
		player.guardtics = $-1
		mo.state = S_PLAY_STND
		mo.sprite2 = CBW_Battle.SkinVars[player.skinvars].guard_sprite or SPR2_TRNS
		mo.frame = guardframe
		player.powers[pw_nocontrol] = 2
		mo.flags = $ & ~MF_NOGRAVITY
		if player.guardtics < 1
			player.guardtics = 20
			player.cusguard = -1
		else
			if (player.guardtics % 2)
				mo.cusguardflash = true
				mo.colorized = true
				mo.color = SKINCOLOR_PITCHWHITE
			end
		end
	end
	if player.cusguard <= -1
		player.guardtics = $-1
		mo.state = S_PLAY_STND
		mo.sprite2 = CBW_Battle.SkinVars[player.skinvars].guard_sprite or SPR2_TRNS
		mo.frame = guardframe
		player.powers[pw_nocontrol] = 2	
		mo.flags = $ & ~MF_NOGRAVITY
		if player.guardtics < 1
			player.cusguard = 0
			mo.sprite2 = SPR2_STND
			mo.frame = 0
		end
	end
	if player.cusguard == 2
		player.guardtics = $-1
-- 		mo.state = S_PLAY_STND
		player.powers[pw_nocontrol] = 0
		mo.sprite2 = CBW_Battle.SkinVars[player.skinvars].guard_sprite or SPR2_TRNS
		mo.frame = min(6,$+1)
--		player.powers[pw_flashing] = TICRATE*3/4
		player.nodamage = TICRATE*3/4
		mo.flags2 = $&~MF2_DONTDRAW
		player.lockmove = true
-- 		if player.cmd.forwardmove or player.cmd.sidemove
-- 			mo.sprite2 = SPR2_STAND
-- 			mo.frame = 0
-- 		end
		if player.guardtics < 1 
			player.cusguard = 0
			mo.frame = 0
			mo.state = S_PLAY_STND
			mo.sprite2 = SPR2_STND
		end
	end
end

local fx = function(mo)
	for n = 0, 16
		local dust = P_SpawnMobj(mo.x,mo.y,mo.z,MT_DUST)
		if dust and dust.valid 
			P_InstaThrust(dust,mo.angle+ANGLE_22h*n,mo.scale*36)
		end
	end
end

local function virdis_parrydam(target, inflictor, source, damage, damagetype)
	if not(target.valid and target.player and target.skin == "virdis")  return false end
	if target.player.guardbuffer 
		CBW_Battle.ResetPlayerProperties(target.player,false,true)
		target.player.cusguard = 0
		S_StopSoundByID(target, sfx_cdfm39)
		S_StartSound(target, sfx_shattr)
		local nega = P_SpawnMobjFromMobj(target,0,0,0,MT_NEGASHIELD)
		nega.target = target
	end
	if target.player.cusguard > 0
		if target.player.cusguard == 1 and inflictor and inflictor.valid 
			CBW_Battle.StartSoundFromNewSource(target, sfx_cdpcm9)
			CBW_Battle.StartSoundFromNewSource(target, sfx_s259)
			target.player.cusguard = 2
			target.player.guardtics = TICRATE/4 //9
			CBW_Battle.ControlThrust(target,FRACUNIT/2)
			//Do graphical effects
			local sh = P_SpawnMobjFromMobj(target,0,0,0,MT_BATTLESHIELD)
			sh.target = target
			fx(target)
			P_SpawnMobjFromMobj(inflictor,0,0,0,MT_EXPLODE)
			//Affect source
			if source and source.valid and source.health and source.player and source.player.powers[pw_flashing]
				source.player.powers[pw_flashing] = 0
				local nega = P_SpawnMobjFromMobj(source,0,0,0,MT_NEGASHIELD)
				nega.target = source
			end
			// Affect projectile's source if within range
			if source and source.valid 
			local parrytumblerange = P_GetPlayerHeight(target.player)*3
			local parrydistance = R_PointToDist2(target.x, target.y, source.x, source.y)
				if parrydistance <= parrytumblerange and source.z <= target.z+parrytumblerange and source.z >= target.z-parrytumblerange 
					inflictor = source // set inflictor to the source for the rest of the parry to effect them
				end
			end
			//Affect attacker
			if inflictor.player
				if inflictor.player.powers[pw_invulnerability]
					inflictor.player.powers[pw_invulnerability] = 0
					P_RestoreMusic(inflictor.player)
				end
				local angle = R_PointToAngle2(target.x-target.momx,target.y-target.momy,inflictor.x-inflictor.momx,inflictor.y-inflictor.momy)
				local thrust = FRACUNIT*10
				if twodlevel  thrust = CBW_Battle.TwoDFactor($) end
				P_SetObjectMomZ(inflictor,thrust)
				CBW_Battle.DoPlayerTumble(inflictor.player, 45, angle, inflictor.scale*3, true, true)	-- prevent stun break
				//reward runners points for parrying taggers
				if CBW_Battle.TagGametype() and (inflictor.player.battletagIT and not 
						target.player.battletagIT)
					P_AddPlayerScore(target.player, 50)
				end
			else
				P_DamageMobj(inflictor,target,target)
			end
		end

		//Even more customized parry - affect every player in radius and smash them down
		for victim in players.iterate do
			if (GTR_FRIENDLY and not (CV_FindVar("friendlyfire").value)) break end --completely discard this if its coop without friendlyfire
			if (GTR_TEAMS and (victim.ctfteam == target.player.ctfteam)) continue end --don't check further if its teammode ally
			if R_PointToDist2(target.x, target.y, victim.mo.x, victim.mo.y) < 200*FRACUNIT
				P_SetObjectMomZ(victim.mo,-10*FRACUNIT)
				local angle = R_PointToAngle2(target.x-target.momx,target.y-target.momy,victim.mo.x-victim.mo.momx,victim.mo.y-victim.mo.momy)
				CBW_Battle.DoPlayerTumble(victim, 45, angle, victim.mo.scale*3, true, true)
			end
		end
		return true 
	end
end

//Parry HUD
local function vird_bmhud(v,player,camera)
	if not (player.mo and player.mo.valid)
		return
    end
	
	if player.mo.skin ~= "virdis" return end --personal parry text
	local ref = player.mo
	
	if player.cusguard ~= 0 return end --Don't show tip during parry
	if P_PlayerInPain(player) or player.tumble return end --Make room for stunbreak
	local xoffset = hudinfo[HUD_RINGS].x -- 16
	local yoffset = hudinfo[HUD_RINGS].y+24
	local flags = V_HUDTRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER
	local patch = v.cachePatch("PARRYBT")
	local text ="\x80 Air Parry"


	if 	CBW_Battle.Console.FindVarString("battleconfig_hud", {"New", "Minimal"}) --for v10 hud, hide if minimal is chosen
		local px = 59
		local py = 174
		flags = V_PERPLAYER|V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTOLEFT
		if CBW_Battle.Console.FindVarString("battleconfig_hud", {"New"})
			v.draw(px-5,py-1,patch,flags)
			v.drawString(px+7,py,text,flags,"thin")
		end
	else --old style or v9 hud
		v.draw(xoffset,yoffset,patch,flags)
		v.drawString(xoffset+10,yoffset,text,flags,"thin")
	end

end


local BMLOAD = 0
local function virdis_battle()
	if BMLOAD == 1 return end
	if not CBW_Battle return end

		BMLOAD = 1
		CBW_Battle.SkinVars["virdis"] = {
			flags = SKINVARS_NOSPINSHIELD,
			weight = 100,
			shields = 1,
//			special = WindMastery,
			guard_frame = 2
		}
		addHook("PlayerThink",virdis_customguard)
		addHook("MobjDamage",virdis_parrydam,MT_PLAYER)
		hud.add(vird_bmhud,"game")
		print("\x82\Virdis' partial BattleMod support has been added!")

end

addHook("AddonLoaded",virdis_battle)