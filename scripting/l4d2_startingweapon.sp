#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

const int g_CoopGameModeCount = 17;
char g_CoopGameModes[][] = { "coop", "realism", "mutation2", "mutation3", "mutation4", "hardcore", "mutation9", "mutation16", "mutation20", "community1", "community2", "community5", "l4d1coop", "holdout", "dash", "shootzones", "tankrun" };

const int g_WeaponCount = 17;
char g_Weapons[][] = { "pumpshotgun", "shotgun_chrome", "smg", "smg_silenced", "smg_mp5", "autoshotgun", "shotgun_spas", "hunting_rifle", "sniper_military", "rifle", "rifle_desert", "rifle_ak47", "rifle_sg552", "sniper_scout", "sniper_awp", "grenade_launcher", "rifle_m60" };
int g_Weights[] = { 15, 15, 10, 10, 10, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 };
int g_TotalWeight = 0;

char g_GameMode[24];
bool g_IsCoop = false;

public Plugin myinfo =
{
    name = "L4D2StartingWeapon",
    author = "Lyric",
    description = "L4D2 Starting Weapon",
    version = "3.0",
    url = "https://github.com/scooderic"
};

public void OnPluginStart()
{
    int bound = 0;
    for (int i = 0; i < g_WeaponCount; i ++)
    {
        bound += g_Weights[i];
    }
    g_TotalWeight = bound;
}

public void OnMapStart()
{
    g_IsCoop = false;
    GetConVarString(FindConVar("mp_gamemode"), g_GameMode, sizeof(g_GameMode));
    for (int i = 0; i < g_CoopGameModeCount; i ++)
    {
        if (StrEqual(g_GameMode, g_CoopGameModes[i], true))
        {
            g_IsCoop = true;
            break;
        }
    }
}

public void OnClientPutInServer(int client)
{
    if (client >= 1 && IsClientConnected(client) && !IsFakeClient(client))
    {
        CreateTimer(2.0, Timer_GiveWeapon, client, TIMER_REPEAT);
    }
}

public Action Timer_GiveWeapon(Handle timer, any client)
{
    if (g_IsCoop && IsClientInGame(client))
    {
        if (IsClientObserver(client) || !IsPlayerAlive(client))
        {
            return Plugin_Continue;
        }
        else
        {
            int weaponIndex = GetPlayerWeaponSlot(client, 0);
            if (weaponIndex == -1)
            {
                QuickGive(client, g_Weapons[RandomWeaponIndex()]);
                return Plugin_Continue;
            }
            else
            {
                return Plugin_Stop;
            }
        }
    }
    return Plugin_Stop;
}

int RandomWeaponIndex()
{
    int v = GetRandomInt(1, g_TotalWeight);
    for (int i = 0; i < g_WeaponCount; i ++)
    {
        if (v <= g_Weights[i]) {
            return i;
        } else {
            v -= g_Weights[i];
        }
    }
    return g_WeaponCount - 1;
}

void QuickGive(int client, char[] item)
{
    char cmd[] = "give";
    int flags = GetCommandFlags(cmd);
    SetCommandFlags(cmd, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", cmd, item);
    SetCommandFlags(cmd, flags);
}
