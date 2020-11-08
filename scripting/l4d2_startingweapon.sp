#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

const int g_CoopGMCount = 17;
char g_CoopGameModes[][] = {
    "coop", // Coop
    "realism", // Realism coop
    "mutation2", // Headshot!
    "mutation3", // Bleed Out
    "mutation4", // Hard Eight
    //"mutation5", // Four Swordsmen
    //"mutation7", // Chainsaw Massacre
    "hardcore", // Ironman realism
    "mutation9", // Last Gnome On Earth
    //"m60s", // Gib Fest
    "mutation16", // Hunting Party
    "mutation20", // Healing Gnome
    "community1", // Special Delivery
    "community2", // Flu Season
    "community5", // Death's Door
    "l4d1coop", // Left 4 Dead 1 Coop
    "holdout", // Holdout
    "dash", // Dash
    "shootzones", // Shootzones
    "tankrun" // Tank Run
    //"rocketdude" // RocketDude
};

char g_GameMode[24];
bool g_IsCoop = false;
char g_WeaponId[48];

public Plugin myinfo =
{
    name = "L4D2StartingWeapon",
    author = "Lyric",
    description = "L4D2 Starting Weapon",
    version = "2.5",
    url = "https://github.com/scooderic"
};

public void OnPluginStart()
{
}

public void OnMapStart()
{
    g_IsCoop = false;
    GetConVarString(FindConVar("mp_gamemode"), g_GameMode, sizeof(g_GameMode));
    for (int i = 0; i < g_CoopGMCount; i ++)
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
    if (!IsFakeClient(client))
    {
        CreateTimer(2.0, Timer_GiveWeapon, client, TIMER_REPEAT);
    }
}

public Action Timer_GiveWeapon(Handle timer, any client)
{
    if (g_IsCoop && IsClientInGame(client))
    {
        if (IsClientObserver(client))
        {
            return Plugin_Continue;
        }
        else
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
                    QuickCheat(client, "give", "weapon_rifle_m60");
                }
                return Plugin_Continue;
            }
            else
            {
                return Plugin_Stop;
            }
        }
    }
    PrintToChat(client, "\x04[StartingWeapon]\x03 Failed to give weapon, not in coop mode (see sm_cvar mp_gamemode), or not in game.");
    return Plugin_Stop;
}

// T1 weapons (5): 64%
//   smg (3): 32%
//     uzi: 13%
//     smg: 13%
//     mp5: 6%
//   shotgun(2): 32%
// T2 weapons (10): 30%
// Grenade Launcher: 3%
// M60: 3%
void RandomWeapon()
{
    int r = GetRandomInt(0, 99);
    if (r < 13)
    {
        g_WeaponId = "weapon_smg";
    }
    else if (r < 26)
    {
        g_WeaponId = "weapon_smg_silenced";
    }
    else if (r < 32)
    {
        g_WeaponId = "weapon_smg_mp5";
    }
    else if (r < 48)
    {
        g_WeaponId = "weapon_pumpshotgun";
    }
    else if (r < 64)
    {
        g_WeaponId = "weapon_shotgun_chrome";
    }
    else if (r < 67)
    {
        g_WeaponId = "weapon_rifle";
    }
    else if (r < 70)
    {
        g_WeaponId = "weapon_rifle_desert";
    }
    else if (r < 73)
    {
        g_WeaponId = "weapon_rifle_ak47";
    }
    else if (r < 76)
    {
        g_WeaponId = "weapon_autoshotgun";
    }
    else if (r < 79)
    {
        g_WeaponId = "weapon_shotgun_spas";
    }
    else if (r < 82)
    {
        g_WeaponId = "weapon_hunting_rifle";
    }
    else if (r < 85)
    {
        g_WeaponId = "weapon_sniper_military";
    }
    else if (r < 88)
    {
        g_WeaponId = "weapon_rifle_sg552";
    }
    else if (r < 91)
    {
        g_WeaponId = "weapon_sniper_awp";
    }
    else if (r < 94)
    {
        g_WeaponId = "weapon_sniper_scout";
    }
    else if (r < 97)
    {
        g_WeaponId = "weapon_grenade_launcher";
    }
    else
    {
        g_WeaponId = "weapon_rifle_m60";
    }
}

void QuickCheat(int client, char[] cmd, char[] arg)
{
    int flags = GetCommandFlags(cmd);
    SetCommandFlags(cmd, flags & ~FCVAR_CHEAT);
    FakeClientCommand(client, "%s %s", cmd, arg);
    SetCommandFlags(cmd, flags);
}
