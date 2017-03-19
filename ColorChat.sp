#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Chat control",
	author = "AK-74",
	description = "Admins can see chat.",
	version = "1.2",
	url = "http://steamcommunity.com/groups/__HRD__"
};

Handle h_Adminseeall;

public void OnPluginStart()
{
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say_Team);
	
	h_Adminseeall = CreateConVar("cc_adminseeall", "0", "0=Disables admin with ADMFLAG_ROOT see all, 1=Enables admin with ADMFLAG_ROOT see all.", FCVAR_SPONLY|FCVAR_NOTIFY);
	
	LoadTranslations("ColorChat.phrases");
}
public Action Command_Say(int client, int args)
{
	int flag;
	if (!client || !IsClientInGame(client) || IsFakeClient(client) || (flag = GetUserFlagBits(client)) == 0) return Plugin_Continue;
	if(flag & (ADMFLAG_RESERVATION|ADMFLAG_CUSTOM1|ADMFLAG_ROOT))
	{
		char sText[256];
		GetCmdArgString(sText, sizeof(sText));
		int startidx;
		if(sText[strlen(sText)-1] == '"')
		{
			sText[strlen(sText)-1] = '\0';
			startidx = 1;
		}
		if (sText[1] == '/') return Plugin_Handled;
		
		char sBuffer[256];
		if (flag & ADMFLAG_ROOT){
			Format(sBuffer, sizeof(sBuffer), "[ADMIN]%N: %s", client, sText[startidx]);}
		else{
			if (flag & ADMFLAG_CUSTOM1){
				Format(sBuffer, sizeof(sBuffer), "[VIP]%N: %s", client, sText[startidx]);}
			else{
				if(flag & ADMFLAG_RESERVATION){
					Format(sBuffer, sizeof(sBuffer), "[RES]%N: %s", client, sText[startidx]);}}}
		PrintToChatAll(sBuffer);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Command_Say_Team(int client, int args)
{
	int flag;
	if (!client || !IsClientInGame(client) || IsFakeClient(client) || (flag = GetUserFlagBits(client)) == 0) return Plugin_Continue;
	if(flag & (ADMFLAG_RESERVATION|ADMFLAG_CUSTOM1|ADMFLAG_ROOT))
	{
		int team = GetClientTeam(client);
		char sText[256];
		GetCmdArgString(sText, sizeof(sText));
		int startidx;
		if(sText[strlen(sText)-1] == '"')
		{
			sText[strlen(sText)-1] = '\0';
			startidx = 1;
		}
		if (sText[1] == '/') return Plugin_Handled;
		
		char sBuffer[256];

		if (flag & ADMFLAG_ROOT){
			Format(sBuffer, sizeof(sBuffer), "[ADMIN]%N: %s", client, sText[startidx]);}
		else{
			if (flag & ADMFLAG_CUSTOM1){
				Format(sBuffer, sizeof(sBuffer), "[VIP]%N: %s", client, sText[startidx]);}
			else{
				if(flag & ADMFLAG_RESERVATION){
					Format(sBuffer, sizeof(sBuffer), "[RES]%N: %s", client, sText[startidx]);}}}
		
		for(int i=1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				if (GetClientTeam(i) == team)
				{
					if (team == 1) Format(sBuffer, sizeof(sBuffer), "%t%s", "Spectate", sBuffer, i);
					if (team == 2) Format(sBuffer, sizeof(sBuffer), "%t%s", "Survivor", sBuffer, i);
					if (team == 3) Format(sBuffer, sizeof(sBuffer), "%t%s", "Infected", sBuffer, i);
					PrintToChat(i, sBuffer);
				}
				else{
					if (GetConVarBool(h_Adminseeall) && (GetUserFlagBits(i) & (ADMFLAG_ROOT | ADMFLAG_CHAT)))
					{
						Format(sBuffer, sizeof(sBuffer), "%t%s", "Admin", sBuffer);
						PrintToChat(i, sBuffer);
					}
				}
			}
		}
		return Plugin_Handled;
	}
	else
	{
		int team = GetClientTeam(client);
		char sText[256];
		GetCmdArgString(sText, sizeof(sText));
		if (sText[1] == '/') return Plugin_Handled;
		char sBuffer[256];
		for(int i=1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				if (GetClientTeam(i) == team)
				{
					if (team == 1) Format(sBuffer, sizeof(sBuffer), "%t%s", "Spectate", sBuffer, i);
					if (team == 2) Format(sBuffer, sizeof(sBuffer), "%t%s", "Survivor", sBuffer, i);
					if (team == 3) Format(sBuffer, sizeof(sBuffer), "%t%s", "Infected", sBuffer, i);
					PrintToChat(i, sBuffer);
				}
				else
				{
					if (GetConVarBool(h_Adminseeall) && (GetUserFlagBits(i) & (ADMFLAG_ROOT | ADMFLAG_CHAT)))
					{
					
						Format(sBuffer, sizeof(sBuffer), "%t%s", "Admin", sBuffer);
						PrintToChat(i, sBuffer);
					}
				}
			}
		}
		return Plugin_Handled;
	}
}