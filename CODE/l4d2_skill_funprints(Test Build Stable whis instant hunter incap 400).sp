/*
   SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
   SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
   Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
   Source is Copyright (C) Valve Corporation.
   All trademarks are property of their respective owners.
 
   This program is free software: you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation, either version 3 of the License, or (at your
   option) any later version.
 
   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.
 
   You should have received a copy of the GNU General Public License along
   with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/**
  Just a live funny prints.
  Idea got from a HyperV servers, and uses a Tabbernaut's skill detect plugin. A lot of thanx to this people.
https://github.com/Tabbernaut/L4D2-Plugins/blob/master/skill_detect/l4d2_skill_detect.sp
 */
#include <sourcemod>
#include <l4d2_skill_detect>
#include <colors>
#include <sdkhooks>
#include <sdktools>

// Plugin Info
public Plugin:myinfo =
{
    name = "L4D2 Skill fun prints.",
    author = "Rei",
    description = "Prints a fun players skill actions. Got idea from HyperV and based on l4d2_skill_detect Tabbernaut's plugin.",
    version = "0.3",
    url = "-"
};

//#include <l4d2utils>
new Handle:GHCV_TrackSnipers        = INVALID_HANDLE;
new Handle:g_cvarMinVelocityPrint   = INVALID_HANDLE;
 
public OnPluginStart() {
    GHCV_TrackSnipers   = CreateConVar("sm_lsf_track_snipers", "1", "Track snipers kill?", FCVAR_PLUGIN);
    g_cvarMinVelocityPrint = CreateConVar("sm_lsf_min_velocity_print", "250.0", "", FCVAR_PLUGIN);
    AutoExecConfig(true);
    HookEvent("player_death", SFP_EvPlayerDeath);
}
 
public SFP_EvPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) {
    new infected  = GetClientOfUserId(GetEventInt(event, "userid"));
    new survivor = GetClientOfUserId(GetEventInt(event, "survivor"));      
    if(survivor <= 0)
        return;
    if(!IsClientInGame(survivor) || IsFakeClient(survivor))
        return;
    if(infected <= 0 || 3 != GetClientTeam(infected))
        return;
    new zombieclass = GetEntProp(infected, Prop_Send, "m_zombieClass");
    if (zombieclass == 8 || zombieclass == 7) return;//ZC_TANK == 8, ZC_WITCH == 7
    if(GetEventBool(event, "headshot")) {
        PrintCenterText(survivor, "HEADSHOT!");
        if(IsClientConnected(infected) && !IsFakeClient(infected))
            PrintCenterText(infected, "HEADSHOTED!");
    }
   
    //MaybeSniperKill(event, survivor, infected);
}
stock MaybeSniperKill(Handle:event, any:survivor, any:infected) {
    if(!GetConVarBool(GHCV_TrackSnipers))
        return;
    //check a survivor is sniper
    decl String:weapon[255];
    GetClientWeapon(survivor, weapon, sizeof(weapon));
    if(!StrEqual(weapon, "weapon_sniper_scout") && !StrEqual(weapon, "weapon_sniper_awp") && !StrEqual(weapon, "weapon_hunting_rifle"))
        return;
    CPrintToChat(survivor, "Killed with snipe!");
}
public OnSkeetHurt(survivor, hunter, damage, bool:isOverkill) {
    CPrintToChatAll("{green}★{default} Выживший {green}\x05%N\x01{default} убил охотника {red}\x04%N\x01{default} перед прыжком дробовиком.", survivor, hunter);
}
public OnSkeet(survivor, hunter) {
    CPrintToChatAll("{green}★★{default} Выживший {green}\x05%N\x01{default} убил охотника {red}\x04%N\x01{default} в прыжке дробовиком!", survivor, hunter);
}
public OnSkeetGL( survivor, hunter ){
	 CPrintToChatAll("{green}★{default} Выживший {green}\x05%N\x01{default} убил гранатомётом охотника {red}\x04%N\x01{default} в полёте.", survivor, hunter);
}
public OnSkeetSniper(survivor, hunter) {
    CPrintToChatAll("{green}★★★{default} Выживший {green}\x05%N\x01 {default} убил охотника {red}\x04%N\x01{default} в голову в полёте!", survivor, hunter);
}
public OnSkeetMelee(survivor, hunter) {
    CPrintToChatAll("{green}★★★★{default} Выживший {green} \x05%N\x01 {default}убил охотника {red}\x04%N\x01 {default}холодным оружием в полёте!", survivor, hunter);
}
public OnSkeetMeleeHurt(survivor, hunter) {
    CPrintToChatAll("{green}★{default} Выживший {green}\x05%N\x01 {default}убил холодным оружием охотника {red}\x04%N\x01{default} перед прыжком.", survivor, hunter);
}
public OnSkeetSniperHurt(survivor, hunter) {
    CPrintToChatAll("{green}★★{default} Выживший {green}\x05%N\x01 {default} убил выстрелом в голову охотника {red}\x04%N\x01{default} перед прыжком.", survivor, hunter);
}
public OnHunterDeadstop(survivor, hunter) {
    CPrintToChatAll("{green}★{default} Выживший {green}\x05%N\x01 {default}застанил в прыжке охотника {red}\x04%N\x01 {default}.", survivor, hunter);
}
public OnHunterHighPounce(hunter, survivor, actualDamage, Float:calculatedDamage, Float:height, bool:reportedHigh) {
	if (height>400){
		new userflags = GetUserFlagBits(survivor);
		new cmdflags = GetCommandFlags("hurtme");
		SetUserFlagBits(survivor, ADMFLAG_ROOT);
		SetCommandFlags("hurtme", cmdflags & ~FCVAR_CHEAT);
		FakeClientCommand(survivor,"hurtme 120");
		SetCommandFlags("hurtme", cmdflags);
		SetUserFlagBits(survivor, userflags);
		CPrintToChatAll("{green}★★★{default} Охотник {red}\x05%N\x01 {default}прыгнул с огромной высоты (%f) на выжившего {green}\x04%N\x01 {default}, чем вывел его из строя!.", hunter, height, survivor);
		return;
	}	
    if(actualDamage > 15)
        CPrintToChatAll("{green}★{default} Охотник {red}\x05%N\x01 {default}прыгнул с большой высоты (%f) на выжившего {green}\x04%N\x01 {default}.", hunter, height, survivor);
}
public OnBoomerPop(survivor, boomer, shoveCount, Float:timeAlive) {
    CPrintToChatAll("{green}★{default} Выживший {green}\x05%N\x01{default} убил толстяка {red}\x04%N\x01{default} до заблёва команды.", survivor, boomer);
}
public OnChargerLevel(survivor, charger) {
    CPrintToChatAll("{green}★★★{default} Выживший {green}\x04%N\x01{default} убил в разбеге громилу {red}\x05%N\x01{default} перед тем, как был схвачен.", survivor, charger);
}
public OnChargerLevelHurt(survivor, charger, damage) {
    CPrintToChatAll("{green}★★{default} Выживший {green}\x04%N\x01 {default}убил в разбеге громилу {red}\x05%N\x01{default}.", survivor, charger);
}
public OnWitchCrown( survivor, damage ){
	CPrintToChatAll( "{green}★★★ \x04%N\x01{default} мгновенно убил ведьму, не побеспокоив её.", survivor);
}

public OnWitchCrownHurt( survivor, damage, chipdamage ){
	CPrintToChatAll( "{green}★★★★ \x04%N\x01{default} мгновенно убил ведьму, когда она начала охоту!", survivor);
}

public OnJockeyHighPounce( jockey, survivor, Float:height, bool:reportedHigh ){
	if(height > 110)
		CPrintToChatAll( "{green}★★ {default}Жокей {red}\x04%N\x01{default} прыгнул с большой высоты на {green}\x05%N\x01{default}.", jockey, survivor);
}
		
public OnTongueCut(survivor, smoker) {
    CPrintToChatAll("{green}★★{default} Выживший {green}\x04%N\x01{default} разрезал язык курильщика {red}\x05%N\x01{default}!", survivor, smoker);
}

public OnSmokerSelfClear(survivor, smoker, bool:withShove) {
    if(withShove)
        CPrintToChatAll("{green}★★★{default} Выживший {green}\x04%N\x01{default} оглушил курильщика {red}\x05%N\x01{default}, когда был схвачен!", survivor, smoker);
    else
        CPrintToChatAll("{green}★★★{default} Выживший {green}\x04%N\x01{default} убил курильщика {red}\x05%N\x01{default}, когда был схвачен!", survivor, smoker);
}
public OnTankRockSkeeted(survivor, tank) {
    CPrintToChatAll("{green}★★{default} Выживший {green}\x04%N\x01{default} уничтожил камень танка.", survivor);
}

public OnSpecialClear( clearer, pinner, pinvictim, zombieClass, Float:timeA, Float:timeB, bool:withShove ){	
	if (timeA < 1 && clearer != pinvictim && pinvictim != pinner && 2 == GetClientTeam(clearer))	
		CPrintToChatAll("{green}★{default} Выживший {green}\x05%N\x01 {default}мнгновенно спас выжившего {olive}\x06%N\x01 {default}от {red}\x07%N\x01{default}!", clearer, pinvictim, pinner);
}
public OnBoomerVomitLanded(boomer, amount) {
    if(amount == 4)
        CPrintToChatAll("{green}★{default} Толстяк {red}\x05%N\x01 {default}заблевал всех выживших.", boomer);
}
public OnCarAlarmTriggered(survivor, infected, CarAlarmTriggerReason:reason) {
    decl String:announce[255];
    if(survivor <= 0)
        return;
    if(!IsClientInGame(survivor) || IsFakeClient(survivor))
        return;
    switch(reason) {
        case CarAlarmTrigger_Unknown: {
            announce = "Сигнализация сработала по неизветной причине.";
        }
        case CarAlarmTrigger_Hit: {
            Format(announce, sizeof(announce), "{default}Сигнализация сработала из-за выстрела {red}%N{default}.", survivor);
        }
        case CarAlarmTrigger_Touched: {
            if(infected > 0) {
                Format(announce, sizeof(announce), "{green}%N {default} включил скигнализацию из-за {red}%N{default}.", survivor, infected);
            } else {
                Format(announce, sizeof(announce), "{green}%N {default}включил сигнализацию.", survivor);
            }
        }
        case CarAlarmTrigger_Explosion: {
            if(infected > 0) {
                Format(announce, sizeof(announce), "{green}%N {default}включил сигнализацию взрывом из-за {red}%N{default}.", survivor, infected);
            } else {
                Format(announce, sizeof(announce), "{green}%N {default}включил сигнализацию из-за взрыва.", survivor);
            }
        }
        case CarAlarmTrigger_Boomer: {
            if(infected > 0) {
                Format(announce, sizeof(announce), "{green}%N {default}взорвал толстяка {red}%N{default} и включил сигнализацию.", survivor, infected);
            } else {
                Format(announce, sizeof(announce), "{green}%N {default}взорвал толстяка и включил сигнализацию.", survivor);
            }
        }
    }
    CPrintToChatAll("{green}★ %s", announce);
}
public OnBunnyHopStreak(survivor, streak, Float:maxVelocity) {
    if(streak < 3 || maxVelocity <= GetConVarFloat(g_cvarMinVelocityPrint))
        return;
    if(!IsClientConnected(survivor) || IsFakeClient(survivor))
        return;
    CPrintToChatAll("{green}★★ %N {default}сделал {olive}%d {default}раз(а) баннихоп с максимальной скоростью {olive}%.01f{default}.", survivor, streak, maxVelocity);
}
//TODO: Bunnyhop steaks announce!