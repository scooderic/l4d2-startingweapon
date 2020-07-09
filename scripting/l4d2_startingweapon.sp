#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

char g_GameMode[24];
bool g_IsCoop = false;
char g_WeaponId[48];

public Plugin myinfo =
{
    name = "L4D2StartingWeapon",
    author = "Lyric",
    description = "L4D2 Starting Weapon",
    version = "2.1",
    url = "https://github.com/scooderic"
};

public void OnPluginStart()
{
}

public void OnMapStart()
{
    g_IsCoop = false;
    GetConVarString(FindConVar("mp_gamemode"), g_GameMode, sizeof(g_GameMode));
    if (StrEqual(g_GameMode, "coop", true))
    {
        g_IsCoop = true;
    }
    if (StrEqual(g_GameMode, "realism", true))
    {
        g_IsCoop = true;
    }
}

public void OnClientPutInServer(int client)
{
    if (!IsFakeClient(client))
    {
        CreateTimer(2.0, Timer_GiveWeapon, client, TIMER_REPEAT);
    }
}

public Action Timer_GiveWeapon(Handle timer, any client)
{
    if (g_IsCoop && IsClientInGame(client))
    {
        int weaponIndex = GetPlayerWeaponSlot(client, 0);
        if (weaponIndex == -1)
        {
            RandomWeapon();
            if (!StrEqual(g_WeaponId, "", true))
            {
                QuickCheat(client, "give", g_WeaponId);
            }
            else
            {
                QuickCheat(client, "give", "rifle_m60");
            }
            return Plugin_Continue;
        }
        else
        {
            return Plugin_Stop;
        }
    }
    PrintToChat(client, "\x04[StartingWeapon]\x03 Failed to give weapon, not in coop mode (see sm_cvar mp_gamemode), or not in game.");
    return Plugin_Stop;
}

// T1 weapon (4): 76%
// T2 weapon (7): 14%
// Grenade Launcher: 3%
// M60: 7%
void RandomWeapon()
{
    int r = GetRandomInt(0, 99);
    if (r < 19)
    {
        g_WeaponId = "smg";
    }
    else if (r < 38)
    {
        g_WeaponId = "smg_silenced";
    }
    else if (r < 57)
    {
        g_WeaponId = "pumpshotgun";
    }
    else if (r < 76)
    {
        g_WeaponId = "shotgun_chrome";
    }
    else if (r < 78)
    {
        g_WeaponId = "rifle";
    }
    else if (r < 80)
    {
        g_WeaponId = "rifle_desert";
    }
    else if (r < 82)
    {
        g_WeaponId = "rifle_ak47";
    }
    else if (r < 84)
    {
        g_WeaponId = "autoshotgun";
    }
    else if (r < 86)
    {
        g_WeaponId = "shotgun_spas";
    }
    else if (r < 88)
    {
        g_WeaponId = "hunting_rifle";
    }
    else if (r < 90)
    {
        g_WeaponId = "sniper_military";
    }
    else if (r < 93)
    {
        g_WeaponId = "weapon_grenade_launcher";
    }
    else
    {
        g_WeaponId = "rifle_m60";
    }
}

void QuickCheat(int client, char[] cmd, char[] arg)
{
    int flags = GetCommandFlags(cmd);
    SetCommandFlags(cmd, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", cmd, arg);
    SetCommandFlags(cmd, flags);
}
