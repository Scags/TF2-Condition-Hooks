#pragma semicolon 1
#pragma newdecls required

#include <tf2>
#include <sdktools>
#include <dhooks>
#include <tf2addcond>

#define ptr 				Address
#define nullptr 			Address_Null
#define int(%1) 			view_as< int >(%1)
#define Address(%1) 		view_as< Address >(%1)

public Plugin myinfo = 
{
	name = "[TF2] AddCond", 
	author = "Scag", 
	description = "CTFPlayerShared::AddCond control for developers", 
	version = "1.0.0", 
	url = "https://github.com/Scags/"
};

GlobalForward hAddCond;

public APLRes AskPluginLoad2(Handle self, bool late, char[] error, int max)
{
	hAddCond = new GlobalForward("TF2_OnAddCond", ET_Hook, Param_Cell, Param_CellByRef, Param_FloatByRef, Param_CellByRef);
	RegPluginLibrary("tf2addcond");
	return APLRes_Success;
}

public void OnPluginStart()
{
	GameData conf = new GameData("tf2.addcond");
	Handle h = DHookCreateDetourEx(conf, "CTFPlayerShared::AddCond", CallConv_THISCALL, ReturnType_Void, ThisPointer_Address);
	DHookAddParam(h, HookParamType_Int);
	DHookAddParam(h, HookParamType_Float);
	DHookAddParam(h, HookParamType_CBaseEntity);
	if (!DHookEnableDetour(h, false, CTFPlayerShared_AddCond))
		SetFailState("Could not load hook for CTFPlayerShared::AddCond!");

	delete conf;
}

public MRESReturn CTFPlayerShared_AddCond(Address pThis, Handle hParams)
{
	ptr m_pOuter = ptr(FindSendPropInfo("CTFPlayer", "m_nHalloweenBombHeadStage") - FindSendPropInfo("CTFPlayer", "m_Shared") + 4);
	int client = GetEntityFromAddress(pThis + m_pOuter);
	TFCond cond = DHookGetParam(hParams, 1);
	float time = DHookGetParam(hParams, 2);
	int provider = DHookIsNullParam(hParams, 3) ? -1 : DHookGetParam(hParams, 3);
	Action action;

	Call_StartForward(hAddCond);
	Call_PushCell(client);
	Call_PushCellRef(cond);
	Call_PushFloatRef(time);
	Call_PushCellRef(provider);
	Call_Finish(action);

	if (action == Plugin_Changed)
	{
		DHookSetParam(hParams, 1, cond);
		DHookSetParam(hParams, 2, time);
		DHookSetParam(hParams, 3, provider);
		return MRES_ChangedHandled;
	}
	else if (action >= Plugin_Handled)
		return MRES_Supercede;

	return MRES_Ignored;
}

stock Handle DHookCreateDetourEx(GameData conf, const char[] name, CallingConvention callConv, ReturnType returntype, ThisPointerType thisType)
{
	Handle h = DHookCreateDetour(Address_Null, callConv, returntype, thisType);
	if (h)
		if (!DHookSetFromConf(h, conf, SDKConf_Signature, name))
			LogError("Could not set %s from config!", name);
	return h;
}

// Props to nosoop
stock int GetEntityFromAddress(ptr pEntity)
{
	return Dereference(pEntity, FindDataMapInfo(0, "m_angRotation") + 12) & 0xFFF;
}

stock int ReadInt(ptr pAddr)
{
	if (pAddr == nullptr)
		return -1;
	
	return LoadFromAddress(pAddr, NumberType_Int32);
}
stock ptr Transpose(ptr pAddr, int iOffset)
{
	return ptr(int(pAddr) + iOffset);
}
stock int Dereference(ptr pAddr, int iOffset = 0)
{
	if (pAddr == nullptr)
		return -1;

	return ReadInt(Transpose(pAddr, iOffset));
}