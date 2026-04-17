class GoodOlHUDStatusBar : BaseStatusBar
{
    HUDFont GOHmHUDFont;
    InventoryBarState GOHdiparms0, GOHdiparms1;
    int GOHtheme, GOHcolorscheme;

    const INT_MIN = 0x80000000;
    const INT_MAX = 0x7FFFFFFF;

    const CLASSCOUNT = 8;

    const CLASS_DOOM = 0;
    const CLASS_CHEX = 1;
    const CLASS_HERETIC = 2;
    const CLASS_WOLFEN = 3;
    const CLASS_HEXEN = 4;
    const CLASS_DUKE = 5;
    const CLASS_MARATHON = 6;
    const CLASS_QUAKE = 7;

    // this clearly can't be the most convenient way to do this
    static const Name ColorSchemeDefinitions[] =
    {
        "default",      "[Untranslated]", "[Gold]",
        "doom",         "[Red]",          "[White]",
        "freedoom",     "[Red]",          "[White]",
        "raven",        "[Yellow]",       "[White]",
        "strife",       "[Yellow]",       "[White]",
        "blasphemer",   "[Red]",          "[White]",
        "chex",         "[Yellow]",       "[White]",
        "harmony",      "[MiamiRetro]",   "[WhiteBorder]",
        "hacx",         "[Green]",        "[White]",
        "square",       "[Red]",          "[White]",
        "woolball",     "[White]",        "[Gold]",
        "psxdoom",      "[DarkRed]",      "[White]",
        "psxfinaldoom", "[Red]",          "[White]",
        "rekkr",        "[Yellow]",       "[White]",
        "wolf3d",       "[White]",        "[Gold]",
        "duke3d",       "[Orange]",       "[White]",
        "duke64",       "[LightBlue]",    "[White]",
        "marathon1",    "[Green]",        "[White]",
        "marathon2",    "[Green]",        "[White]",
        "quake1",       "[DarkBrown]",    "[White]"
    };

    String theme;
    String colorschemebase;
    String colorschemetext, colorschemeactivetext;
    String barbase;
    String bar, barblank;
    String timerbase;
    String timerbaseleft, timerbaseright;

    override void Init()
    {
        Super.Init();

        Font fnt;

        // Create the font used for the fullscreen HUD
        fnt = "fonts/goodolhud_font.bmf";

        GOHmHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0") + 2, Mono_CellCenter, 2, 2);

        GOHdiparms0 = InventoryBarState.CreateNoBox(GOHmHUDFont, Font.CR_UNTRANSLATED, 1, (40, 34), "graphics/hud/theme0/icons/goodolhud_icon_inventoryselector.png", (36, 30), "graphics/hud/theme0/icons/goodolhud_icon_inventoryleft.png", "graphics/hud/theme0/icons/goodolhud_icon_inventoryright.png", (44, -38), DI_SCREEN_CENTER_BOTTOM);
        GOHdiparms1 = InventoryBarState.CreateNoBox(GOHmHUDFont, Font.CR_UNTRANSLATED, 1, (40, 34), "graphics/hud/theme1/icons/goodolhud_icon_inventoryselector.png", (36, 30), "graphics/hud/theme1/icons/goodolhud_icon_inventoryleft.png", "graphics/hud/theme1/icons/goodolhud_icon_inventoryright.png", (44, -38), DI_SCREEN_CENTER_BOTTOM);
    }

    override void Draw (int state, double TicFrac)
    {
        Super.Draw (state, TicFrac);

        /*if (state == HUD_StatusBar)
        {
            BeginStatusBar();
            DrawMainBar (TicFrac);
        } else {*/
            if (state == HUD_Fullscreen)
            {
                BeginHUD();
                GOHDrawFullScreenStuff ();
            }
        //}
    }

    int bottomleftvertelements;
    int bottomleftverttimerrows;

    protected void GOHDrawFullScreenStuff ()
    {
        // HUD initialization
        Vector2 coordbase, coordnudge;

        int classnum = CPlayer.CurrentPlayerClass;

        // for powerup/status timer stuff
        bottomleftvertelements = 0; // label
        bottomleftverttimerrows = 0; // theme

        GOHtheme = CVar.FindCVar("goh_theme").GetInt();
        GOHcolorscheme = CVar.FindCVar("goh_colorscheme").GetInt();

        theme = "theme" .. GOHtheme;

        switch (GOHcolorscheme)
        {
          case -2:
            switch (classnum)
            {
              default: GOHcolorscheme = 0; break;
              case CLASS_DOOM: GOHcolorscheme = 1; break;
              case CLASS_CHEX: GOHcolorscheme = 6; break;
              case CLASS_HERETIC: GOHcolorscheme = 3; break;
              case CLASS_WOLFEN: GOHcolorscheme = 14; break;
              case CLASS_HEXEN: GOHcolorscheme = 3; break;
              case CLASS_DUKE: GOHcolorscheme = 15; break;
              case CLASS_MARATHON: GOHcolorscheme = 18; break;
              case CLASS_QUAKE: GOHcolorscheme = 19; break;
            }
            break;

          case -1:
            if (Wads.CheckNumForFullName("graphics/intros/titlefin.png") != -1) { GOHcolorscheme = 12; }
            else { GOHcolorscheme = 11; }
            break;
        }

        GOHcolorscheme = GOHcolorscheme * 3;

        colorschemebase = ColorSchemeDefinitions[GOHcolorscheme];
        colorschemetext = ColorSchemeDefinitions[GOHcolorscheme + 1];
        colorschemeactivetext = ColorSchemeDefinitions[GOHcolorscheme + 2];

        barbase = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_base_" .. colorschemebase .. ".png";
        barblank = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_blank.png";

        timerbase = "graphics/hud/" .. theme .. "/timers/goodolhud_timer_base_" .. colorschemebase .. ".png";
        timerbaseleft = "graphics/hud/" .. theme .. "/timers/goodolhud_timer_basesideleft_" .. colorschemebase .. ".png";
        timerbaseright = "graphics/hud/" .. theme .. "/timers/goodolhud_timer_basesideright_" .. colorschemebase .. ".png";

        let bargradients = CVar.FindCVar("goh_bargradients").GetBool();
        let canshowmaxamounts = CVar.FindCVar("goh_showmaxamounts").GetBool();
        let canalwaysshowinvcounter = CVar.FindCVar("goh_alwaysshowinventorycounter").GetBool();

        // if you're bypassing 255, you're just asking for a crash anyway. let the VM abort serve as a warning
        let teamcolor = !teamplay || CPlayer.GetTeam() == 255 ? Font.CR_UNTRANSLATED : Teams[CPlayer.GetTeam()].GetTextColor();

        // Bottom left.
        coordnudge = (0, 0);
        powerupnudge = (0, 0);

        // Team name
        if (CVar.FindCVar("goh_showteamname").GetBool() && teamplay)
        {
            coordbase = (4 + coordnudge.X, -17 + coordnudge.Y);

            Name teamname = CPlayer.GetTeam() == 255 ? StringTable.Localize("$GOODOLHUD_NOTEAM") : Teams[CPlayer.GetTeam()].mName;

            // only append "Team" to the end of the default team names
            switch (teamname)
            {
              case 'Blue':
              case 'Red':
              case 'Green':
              case 'Gold':
              case 'Black':
              case 'White':
              case 'Orange':
              case 'Purple':
                teamname = teamname .. " " .. StringTable.Localize("$GOODOLHUD_TEAM");
                break;
            }

            DrawString(GOHmHUDFont, (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") .. teamname, coordbase, DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, teamcolor);

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Player name
        if (CVar.FindCVar("goh_showplayername").GetBool() || (CVar.FindCVar("goh_samsara_showcharactername").GetBool() && classnum >= 0 && classnum < CLASSCOUNT))
        {
            GOHDrawPlayerName(4 + coordnudge.X, -17 + coordnudge.Y);

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Mugshot
        let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid();

        if (canshowmugshot)
        {
            GOHDrawMugShot(4 + coordnudge.X, -39 + coordnudge.Y);

            coordnudge.X += 43;
            powerupnudge.X += 43;
        }

        // Stamina and accuracy
        let canshowstamina = CVar.FindCVar("goh_showstamina").GetBool();
        let canshowaccuracy = CVar.FindCVar("goh_showaccuracy").GetBool();

        if (canshowstamina || canshowaccuracy)
        {
            coordbase = (4 + coordnudge.X, -17 + coordnudge.Y);

            DrawString(GOHmHUDFont,
                       (canshowstamina ? "\c[Red]" .. StringTable.Localize("$GOODOLHUD_STAMINA") .. " " .. FormatNumber(CPlayer.mo.Stamina, 1, 3) .. " \c-" : "") ..
                       (canshowaccuracy ? "\c[Yellow]" .. StringTable.Localize("$GOODOLHUD_ACCURACY") .. " " .. FormatNumber(CPlayer.mo.Accuracy, 1, 3) .. " \c-" : ""),
                       coordbase, DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Armor
        let armor = BasicArmor(CPlayer.mo.FindInventory("BasicArmor", true)), hexenarmor = HexenArmor(CPlayer.mo.FindInventory("HexenArmor", true));
        let currenthexenarmor = hexenarmor.Slots[0] + hexenarmor.Slots[1] + hexenarmor.Slots[2] + hexenarmor.Slots[3] + hexenarmor.Slots[4];

        let hasquakepentagram = CVar.FindCVar("goh_samsara_showpentagramarmor").GetBool() && Powerup(CPlayer.mo.FindInventory("QuakePentagram"));

        let swaphealtharmor = CVar.FindCVar("goh_swaphealtharmor").GetBool();

        if ((armor && armor.Amount > 0) || hasquakepentagram)
        {
            if (swaphealtharmor) { coordnudge.Y -= 16; }

            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);
            let totalarmor = 100 + armor.BonusCount;

            let canshowarmortype = CVar.FindCVar("goh_showarmortype").GetBool();

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_green.png";
            DrawBar(bar, barblank, hasquakepentagram ? 666 : armor.Amount, totalarmor, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_armorovermax1.png";
            DrawBar(bar, barblank, (hasquakepentagram ? 666 : armor.Amount) - totalarmor, totalarmor, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_armorovermax2.png";
            DrawBar(bar, barblank, (hasquakepentagram ? 666 : armor.Amount) - (totalarmor * 2), totalarmor, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ARMOR"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_GREEN);

            if (canshowarmortype)
            {
                String armorcolor = "green";

                switch (armor.ArmorType)
                {
                  // Tier 1 armor
                  case 'SilverShield': armorcolor = "silver"; break;
                  //case 'LeatherArmor': armorcolor = "brown"; break; // currently has no replacement

                  case 'QuakeGreenArmor':
                  case 'QGreenArmorNoDrop':
                    armorcolor = "olive";
                    break;

                  case 'MarathonGreenArmor':
                  case 'MGreenArmorNoDrop':
                    armorcolor = "brick";
                    break;

                  // Tier 2 armor
                  case 'YellowArmor':
                  case 'SamsaraYellowArmor':
                  case 'YellowArmorNoDrop':
                  case 'QuakeYellowArmor':
                  case 'QYellowArmorNoDrop':
                    armorcolor = "yellow";
                    break;

                  case 'MarathonYellowArmor':
                  case 'MYellowArmorNoDrop':
                    armorcolor = "orange";
                    break;

                  // Tier 3 armor
                  case 'BasicArmorPickup': // cheat
                  case 'BlueArmor':
                  case 'BlueArmorForMegasphere':
                  case 'SuperChexArmor':
                  case 'PsxBlueArmor':
                  case 'ArmorPack2':
                  case 'BlueArmorNoDrop':
                  case 'HereticArmorPack2':
                  case 'MetalArmor': // currently has no replacement
                  case 'LMSArmor':
                  case 'LMSArmor2':
                  case 'LMSArmor3':
                  case 'FuckArmor':
                    armorcolor = "blue";
                    break;

                  case 'EnchantedShield': armorcolor = "gold"; break;
                  //case 'MetalArmor': armorcolor = "silver"; break;

                  case 'QuakeRedArmor':
                  case 'QRedArmorNoDrop':
                    armorcolor = "red";
                    break;

                  case 'MarathonBlueArmor':
                  case 'MBlueArmorNoDrop':
                    armorcolor = "yellow";
                    break;

                  // Tier 4 armor
                  case 'RedArmor':
                  case 'ArmorPack3':
                  case 'RedArmorNoDrop':
                    armorcolor = "red";
                    break;

                  case 'SamsaraSilverArmor':
                  case 'SilverArmorNoDrop':
                    armorcolor = "silver";
                    break;

                  case 'MarathonRedArmor':
                  case 'MRedArmorNoDrop':
                    armorcolor = "pink";
                    break;

                  // Other armor
                  case 'NoArmor': armorcolor = "white"; break; // just in case
                }

                DrawImage(hasquakepentagram ? "PENTICON_HUDT" : "graphics/hud/" .. theme .. "/icons/goodolhud_icon_armor" .. armorcolor .. ".png", (coordbase.X + 83, coordbase.Y - 2), DI_SCREEN_LEFT_BOTTOM);
            }

            DrawString(GOHmHUDFont,
                       FormatNumber(hasquakepentagram ? 666 : armor.Amount, 1, 4) .. (canshowmaxamounts ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(totalarmor, 1, 4) : "") ..
                       (CVar.FindCVar("goh_showarmorsavepercent").GetBool() ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. String.Format("%.1f", (hasquakepentagram ? 1.0 : armor.SavePercent) * 100) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE") .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                       (coordbase.X + 77 + (canshowarmortype ? 16 : 0), coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;

            if (swaphealtharmor) { coordnudge.Y += 16; }
        }

        if (currenthexenarmor > 0)
        {
            if (swaphealtharmor) { coordnudge.Y -= 16; }

            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);

            let canshowarmorclass = CVar.FindCVar("goh_showarmorclass").GetBool();

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_green.png";
            DrawBar(bar, barblank, currenthexenarmor, 100, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ARMORCLASS"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_GREEN);

            DrawString(GOHmHUDFont, FormatNumber(currenthexenarmor / (canshowarmorclass ? 5 : 1), 1, 3) .. (canshowmaxamounts ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(100 / (canshowarmorclass ? 5 : 1), 1, 3) : ""), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;

            if (swaphealtharmor) { coordnudge.Y += 16; }
        }

        // Health
        if (swaphealtharmor) { coordnudge.Y += 16 * (0 + ((armor && armor.Amount > 0) || hasquakepentagram) + (currenthexenarmor > 0)); }

        coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);

        let canshowberserk = CVar.FindCVar("goh_showberserk").GetInt() && (Powerup(CPlayer.mo.FindInventory("PowerStrength")) || Powerup(CPlayer.mo.FindInventory("PsxPowerStrength")));
        let cancolorhealth = CVar.FindCVar("goh_colorhealthoninvuln").GetBool() && (isInvulnerable() || Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")) || Powerup(CPlayer.mo.FindInventory("SamsaraPowerInvulnerableNormal")) ||
                                                                                    Powerup(CPlayer.mo.FindInventory("SamsaraPowerInvulnerableGoldMap")) || Powerup(CPlayer.mo.FindInventory("QuakePentagram")));
        let canshownegativehealth = !CVar.FindCVar("goh_lowerhealthcap").GetBool() && CPlayer.mo.Health < 0;

        String invulnbarcolor = "white";
        let invulntextcolor = Font.CR_WHITE;

        DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

        bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_" .. (cancolorhealth ? invulnbarcolor : "red") .. ".png";
        DrawBar(bar, barblank, CPlayer.Health, CPlayer.mo.GetMaxHealth(true), (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

        if (!cancolorhealth) // do not overlap with multiple bars if invulned
        {
            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_healthovermax1.png";
            DrawBar(bar, barblank, CPlayer.Health - CPlayer.mo.GetMaxHealth(true), CPlayer.mo.GetMaxHealth(true), (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_healthovermax2.png";
            DrawBar(bar, barblank, CPlayer.Health - (CPlayer.mo.GetMaxHealth(true) * 2), CPlayer.mo.GetMaxHealth(true), (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);
        }

        DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_HEALTH"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, cancolorhealth ? invulntextcolor : Font.CR_RED);

        if (canshowberserk)
        {
            int berserkicon = (CVar.FindCVar("goh_showberserk").GetInt() - 1) * 2;

            Name BerserkIconDefinitions[] =
            {
                "crossred",    "",
                "crossgreen",  "",
                "crossblue",   "",
                "pillleftred", "pillrightwhite"
            };

            String berserkiconleft, berserkiconright;

            if (BerserkIconDefinitions[berserkicon] != "") { berserkiconleft = BerserkIconDefinitions[berserkicon]; }
            if (BerserkIconDefinitions[berserkicon + 1] != "") { berserkiconright = BerserkIconDefinitions[berserkicon + 1]; }

            DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_berserk_" .. berserkiconleft .. ".png", (coordbase.X + 83 - (berserkiconright != "" ? 3 : 0), coordbase.Y - 2), DI_SCREEN_LEFT_BOTTOM);
            if (berserkiconright != "") { DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_berserk_" .. berserkiconright .. ".png", (coordbase.X + 86, coordbase.Y - 2), DI_SCREEN_LEFT_BOTTOM); }
        }

        DrawString(GOHmHUDFont, FormatNumber(canshownegativehealth ? CPlayer.mo.Health : CPlayer.Health, 1, 4 + canshownegativehealth) .. (canshowmaxamounts ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(CPlayer.mo.GetMaxHealth(true), 1, 4) : ""), (coordbase.X + 77 + (canshowberserk ? 16 : 0), coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, cancolorhealth ? invulntextcolor : Font.CR_RED);

        coordnudge.Y -= 16;
        powerupnudge.Y -= 16;

        if (swaphealtharmor) { coordnudge.Y -= 16 * (0 + ((armor && armor.Amount > 0) || hasquakepentagram) + (currenthexenarmor > 0)); }

        // Powerup timers
        haspowerup = false;

        if (CVar.FindCVar("goh_showpoweruptimers").GetBool()) { GOHDrawPowerupTimers(20 + coordnudge.X, -17 + coordnudge.Y); }

        if (haspowerup) { bottomleftvertelements += 2; }

        coordnudge.Y -= 32 * haspowerup;
        powerupnudge.Y -= 32 * haspowerup;

        // Status timers
        hasstatus = false;

        if (CVar.FindCVar("goh_showstatustimers").GetBool()) { GOHDrawStatusTimers(20 + coordnudge.X, -17 + coordnudge.Y); }

        if (hasstatus) { bottomleftvertelements += 2; }

        coordnudge.Y -= 32 * hasstatus;
        powerupnudge.Y -= 32 * hasstatus;

        // Hazard count
        if (CVar.FindCVar("goh_showhazardcount").GetBool() && CPlayer.HazardCount > 0)
        {
            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);
            int hazardcountamt = CPlayer.HazardCount, hazardcountmaxamt = 16 * TICRATE;

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_darkgreen.png";
            DrawBar(bar, barblank, hazardcountamt, hazardcountmaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_hazardovermax1.png";
            DrawBar(bar, barblank, hazardcountamt - hazardcountmaxamt, hazardcountmaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_hazardovermax2.png";
            DrawBar(bar, barblank, hazardcountamt - (hazardcountmaxamt * 2), hazardcountmaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_HAZARD" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_DARKGREEN);

            DrawString(GOHmHUDFont, String.Format("%.1f", hazardcountamt * 100.0 / hazardcountmaxamt) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE"), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_DARKGREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Bottom right.
        coordnudge = (0, 0);

        // Weapon name
        weaponnameamount = 0;

        if (CVar.FindCVar("goh_showweaponname").GetBool()) { GOHDrawWeaponName(-6 + coordnudge.X, -17 + coordnudge.Y); }

        coordnudge.Y -= 16 * weaponnameamount;

        // Maximum amounts nudger
        if (canshowmaxamounts) { coordnudge.X -= 24; }

        // Ammo
        foundammotypes = 0;

        GOHDrawAmmo(-131 + coordnudge.X, -4 + coordnudge.Y);

        coordnudge.Y -= 16 * foundammotypes;

        // Ammo capacities
        foundammocapacities = 0;

        if (CVar.FindCVar("goh_showammocapacities").GetBool()) { GOHDrawAmmoCapacities(-210 + coordnudge.X, -17 + coordnudge.Y); }

        coordnudge.Y -= 16 * foundammocapacities;

        // Currencies
        if (CVar.FindCVar("goh_showcoincounter").GetBool())
        {
            coordbase = (-226 + coordnudge.X, -17 + coordnudge.Y);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_MONEY") .. FormatNumber(GetAmount("Coin"), 1, 10), coordbase, DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN);
        }

        // reset nudging at this point
        coordnudge = (0 - (24 * canshowmaxamounts), 0 - (16 * weaponnameamount));

        // Selected inventory
        coordbase = (-250 + coordnudge.X, -4 + coordnudge.Y);

        let showingcurrentitem = !isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel;

        if (showingcurrentitem)
        {
            DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_inventory_" .. colorschemebase .. ".png", coordbase, DI_SCREEN_RIGHT_BOTTOM);

            DrawInventoryIcon(CPlayer.mo.InvSel, (coordbase.X, coordbase.Y - 17), DI_DIMDEPLETED|DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_CENTER, 1, (36, 30));

            DrawString(GOHmHUDFont, CPlayer.mo.InvSel.Amount > 1 || canalwaysshowinvcounter ? "\c" .. colorschemetext .. FormatNumber(CPlayer.mo.InvSel.Amount, 1, 5) : "", (coordbase.X - 1, coordbase.Y - 50), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_CENTER);
        }

        // Weapon bar
        if (CVar.FindCVar("goh_showweaponbar").GetBool()) { GOHDrawWeaponBar(-382 + coordnudge.X, -17 + coordnudge.Y); }

        // Cooldown timers
        GOHDrawCooldownTimers((-250 - 1) + coordnudge.X, (-4 + 3) - (showingcurrentitem ? 37 + (CPlayer.mo.InvSel.Amount > 1 || canalwaysshowinvcounter ? 16 : 0) : 0) + coordnudge.Y, (-382 + 4) + coordnudge.X, -17 + coordnudge.Y);

        // Top center.
        coordnudge = (0, 0);

        // Oxygen
        if (CVar.FindCVar("goh_showairtimer").GetBool() && CPlayer.mo.waterlevel >= 3)
        {
            coordbase = (0 + coordnudge.X, 20 + coordnudge.Y);

            coordbase.Y += 16 * (con_centernotify * con_notifylines);

            DrawImage(barbase, coordbase, DI_SCREEN_CENTER_TOP);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_blue.png";
            DrawBar(bar, barblank, CPlayer.air_finished - Level.maptime, Level.airsupply, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_CENTER_TOP);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_OXYGEN"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_CENTER_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_BLUE);

            DrawString(GOHmHUDFont, FormatNumber(clamp((CPlayer.air_finished - Level.maptime + (TICRATE - 1)) / TICRATE, 0, INT_MAX), 1, 4), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_CENTER_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_BLUE);
        }

        // Top right.
        coordnudge = (0, 0);

        // Map/hub timer
        let canshowtimer = CVar.FindCVar("goh_showtimer").GetInt();

        if (canshowtimer >= 1)
        {
            coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);
            let timerflags = DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT;

            if (canshowtimer >= 2 && deathmatch && timelimit)
            {
                int timeleft = int(timelimit * TICRATE * 60) - Level.maptime;
                int hours, minutes, seconds;

                if (timeleft < 0) { timeleft = 0; }

                hours = timeleft / (TICRATE * 3600);
                timeleft -= hours * TICRATE * 3600;
                minutes = timeleft / (TICRATE * 60);
                timeleft -= minutes * TICRATE * 60;
                seconds = timeleft / TICRATE;

                DrawString(GOHmHUDFont, "\c" .. colorschemetext .. String.Format("%02d:%02d:%02d", hours, minutes, seconds), coordbase, timerflags);
            } else {
                int hubsec = Level.time / 35;
                int mapsec = Level.maptime / 35;
                int parsec = Level.partime;

                DrawString(GOHmHUDFont, "\c" .. (CVar.FindCVar("goh_colortimerunderpar").GetBool() && mapsec < parsec && !deathmatch ? colorschemeactivetext : colorschemetext) .. String.Format("%02d:%02d:%02d", hubsec / 3600, (hubsec % 3600) / 60, hubsec % 60), coordbase, timerflags);
            }

            coordnudge.Y += 16;
        }

        // Total timer
        if (CVar.FindCVar("goh_showtimertotal").GetBool())
        {
            coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);

            int totalsec = Level.totaltime / 35;

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. String.Format("%02d:%02d:%02d", totalsec / 3600, (totalsec % 3600) / 60, totalsec % 60), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT);

            coordnudge.Y += 16;
        }

        // Kill counts
        coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);
        let killcountflags = DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT;

        if (CPlayer.mo.FindInventory("ChickenModeOn"))
        {
            // Chicken kill count
            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. FormatNumber(GetAmount("ChickenKillCount"), 1, 10), coordbase, killcountflags);
        } else {
            if (deathmatch)
            {
                // Individual frag count
                DrawString(GOHmHUDFont, "\c" .. colorschemetext .. FormatNumber(CPlayer.FragCount, 1, 10 + (CPlayer.FragCount < 0)), coordbase, killcountflags);

                // Team frag count
                if (teamplay)
                {
                    coordnudge.Y += 16;

                    coordbase = (-6 + coordnudge.X, 3 + coordnudge.Y);

                    int count = 0;

                    for (uint i = 0; i < MAXPLAYERS; ++i)
                    {
                        if (PlayerInGame[i] && players[i].GetTeam() == CPlayer.GetTeam()) { count += players[i].FragCount; }
                    }

                    DrawString(GOHmHUDFont, (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") .. FormatNumber(count, 1, 10 + (count < 0)), coordbase, killcountflags, teamcolor);
                }
            } else {
                // Kill count
                DrawString(GOHmHUDFont, "\c" .. colorschemetext .. FormatNumber(GetAmount("KillCountAmountTrue"), 1, 10), coordbase, killcountflags);
            }
        }

        coordnudge.Y += 16;

        // Level stats and keys
        if (!deathmatch)
        {
            let showmonstercounter = CVar.FindCVar("goh_showmonstercounter").GetBool();
            let showsecretcounter = CVar.FindCVar("goh_showsecretcounter").GetBool();
            let showitemcounter = CVar.FindCVar("goh_showitemcounter").GetBool();
            let swapitemssecrets = CVar.FindCVar("goh_swapitemssecrets").GetBool() && showsecretcounter && showitemcounter;

            // Monsters
            if (showmonstercounter)
            {
                coordbase = (-102 + coordnudge.X, 3 + coordnudge.Y);

                DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_" .. (CVar.FindCVar("goh_monstercounterlabel").GetBool() ? "KILLS" : "MONSTERS")), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_BRICK);

                DrawString(GOHmHUDFont, FormatNumber(Level.killed_monsters, 1, 5) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_BRICK);
                DrawString(GOHmHUDFont, FormatNumber(Level.total_monsters, 1, 5), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_BRICK);

                coordnudge.Y += 16;
            }

            // Secrets
            if (showsecretcounter)
            {
                if (swapitemssecrets) { coordnudge.Y += 16; }

                coordbase = (-102 + coordnudge.X, 3 + coordnudge.Y);

                DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_SECRETS"), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_YELLOW);

                DrawString(GOHmHUDFont, FormatNumber(Level.found_secrets, 1, 5) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_YELLOW);
                DrawString(GOHmHUDFont, FormatNumber(Level.total_secrets, 1, 5), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_YELLOW);

                coordnudge.Y += 16;

                if (swapitemssecrets) { coordnudge.Y -= 16; }
            }

            // Items
            if (showitemcounter)
            {
                if (swapitemssecrets) { coordnudge.Y -= 16; }

                coordbase = (-102 + coordnudge.X, 3 + coordnudge.Y);

                DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ITEMS"), coordbase, DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_LIGHTBLUE);

                DrawString(GOHmHUDFont, FormatNumber(Level.found_items, 1, 5) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT, Font.CR_LIGHTBLUE);
                DrawString(GOHmHUDFont, FormatNumber(Level.total_items, 1, 5), (coordbase.X + 56, coordbase.Y), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_LEFT, Font.CR_LIGHTBLUE);

                coordnudge.Y += 16;

                if (swapitemssecrets) { coordnudge.Y += 16; }
            }

            // Keys
            GOHDrawFullscreenKeys(-4 + coordnudge.X, 4 + coordnudge.Y);

            // no vertical nudging done here; miscellaneous inventory is left of the key display
        }

        // Miscellaneous inventory
        GOHDrawMiscItems(-62 + coordnudge.X, 34 + coordnudge.Y);

        // Top priority.
        coordnudge = (0, 0);

        // Inventory bar
        if (isInventoryBarVisible())
        {
            let GOHdiparms = GOHdiparms0;

            switch (GOHtheme)
            {
              case 1: GOHdiparms = GOHdiparms1; break;
            }

            GOHDrawInventoryBar(GOHdiparms, (-13, 30), 7, DI_SCREEN_CENTER_BOTTOM|(canalwaysshowinvcounter ? DI_ALWAYSSHOWCOUNTERS : 0));
        }
    }

    protected virtual void GOHDrawPlayerName(int coordbasex, int coordbasey)
    {
        int classnum = CPlayer.CurrentPlayerClass;

        let canshowcharactername = CVar.FindCVar("goh_samsara_showcharactername").GetBool() && classnum >= 0 && classnum < CLASSCOUNT;

        // if you're bypassing 255, you're just asking for a crash anyway. let the VM abort serve as a warning
        let teamcolor = !CVar.FindCVar("goh_playernameteamcolor").GetBool() || !teamplay || CPlayer.GetTeam() == 255 ? Font.CR_UNTRANSLATED : Teams[CPlayer.GetTeam()].GetTextColor();

        static const Name CharacterNameDefinitions[] =
        {
            "DOOMGUY", "[Green]",
            "CHEX",    "[Blue]",
            "CORVUS",  "[DarkGreen]",
            "BJ",      "[White]",
            "PARIAS",  "[Red]",
            "DUKE",    "[MetalGold]",
            "SO",      "[LightBlue]",
            "RANGER",  "[DarkBrown]"
        };

        DrawString(GOHmHUDFont,
                   (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") ..
                   (canshowcharactername && CVar.FindCVar("goh_samsara_characternamecolor").GetBool() ? "\c" .. CharacterNameDefinitions[(classnum * 2) + 1] : "") ..
                   (canshowcharactername ? StringTable.Localize("$GOODOLHUD_CHARACTER_SAMSARA_" .. CharacterNameDefinitions[classnum * 2]) : CPlayer.GetUserName()),
                   (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, teamcolor);
    }

    protected virtual void GOHDrawMugShot(int coordbasex, int coordbasey)
    {
        int classnum = CPlayer.CurrentPlayerClass;

        static const Name CharacterMugShotDefinitions[] =
        {
          "DGY",
          "CHX",
          "CRV",
          "BJF",
          "PRS",
          "DKN",
          "MAR",
          "RNG"
        };

        bool hasinvuln = Powerup(CPlayer.mo.FindInventory("SamsaraPowerInvulnerableNormal"));
        bool hasdoomsphere = Powerup(CPlayer.mo.FindInventory("PowerQuadDamage"));

        switch (classnum)
        {
          case CLASS_HERETIC: hasinvuln = Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")); break;
          case CLASS_HEXEN: hasinvuln = Powerup(CPlayer.mo.FindInventory("PowerInvulnerable")); break;
          case CLASS_DUKE: hasinvuln = Powerup(CPlayer.mo.FindInventory("SamsaraPowerInvulnerableGoldMap")); break;
          case CLASS_QUAKE: hasinvuln = Powerup(CPlayer.mo.FindInventory("QuakePentagram")); break;
        }

        DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_mugshot_" .. colorschemebase .. ".png", (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

        if (classnum == CLASS_QUAKE)
        {
            bool hasquakequad = Powerup(CPlayer.mo.FindInventory("QuadDamagePower"));

            if (CPlayer.mo.FindInventory("QuakeInvisTimer"))
            {
                DrawImage(CharacterMugShotDefinitions[classnum] .. "NVSB0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31));
                if (hasdoomsphere) { DrawImage(CharacterMugShotDefinitions[classnum] .. "NVSD0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
                if (hasinvuln) { DrawImage(CharacterMugShotDefinitions[classnum] .. "NVSG0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
                if (hasquakequad) { DrawImage(CharacterMugShotDefinitions[classnum] .. "NVSQ0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
            } else {
                if (hasquakequad) { DrawImage(CharacterMugShotDefinitions[classnum] .. "QUAD0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
                else
                {
                    if (hasinvuln) { DrawImage(CharacterMugShotDefinitions[classnum] .. "GOD0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
                    else { DrawTexture(GetMugShot(5), (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
                }
            }
        } else {
            if (hasinvuln && classnum >= 0 && classnum < CLASSCOUNT) { DrawImage(CharacterMugShotDefinitions[classnum] .. "GOD0", (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
            else { DrawTexture(GetMugShot(5), (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
        }
    }

    bool haspowerup;

    protected virtual void GOHDrawPowerupTimers(int coordbasex, int coordbasey)
    {
        int maxpowerups = 30 * 3;

        static const Name PowerupDefinitions[] =
        {
            "PowerInvulnerable",               "white",    "[White]",
            "PsxPowerInvulnerable",            "white",    "[White]",
            "PowerFakeInvulnerable",           "white",    "[White]",
            "SamsaraPowerInvulnerableNormal",  "white",    "[White]",
            "SamsaraPowerInvulnerableGoldMap", "white",    "[White]",
            "PowerQuarterDamage",              "tan",      "[Tan]",
            "PowerWolfLifeProtection",         "sapphire", "[BlueBorder]", // that text color will do for now
            "PowerMask",                       "green",    "[EmeraldOre]", // can be used outside of strife via give all; different text color for strife coexistence
            "PowerIronFeet",                   "green",    "[Green]",
            "PowerQuadDamage",                 "darkred",  "[DarkRed]",
            "PowerLesserTome",                 "red",      "[Red]",
            "PowerQuackQuarterDamage",         "cyan",     "[Cyan]",
            "PowerHereticTome",                "red",      "[RubyOre]", // different text color for heretic coexistence
            "PowerHereticTomeCoOp",            "red",      "[RubyOre]", // different text color for heretic coexistence
            "PowerTimeFreezer",                "gold",     "[Gold]",
            "PowerTurbo",                      "orange",   "[Orange]",
            "PowerScanner",                    "black",    "[Black]",
            "PowerLightAmp",                   "brick",    "[Brick]",
            "PsxPowerLightAmp",                "brick",    "[Brick]",
            "SamsaraPowerLightAmpNormal",      "brick",    "[Brick]",
            "SamsaraPowerLightAmpBlueMap",     "brick",    "[Brick]",
            "PowerTorch",                      "fire",     "[Fire]",
            "PowerGhost",                      "gray",     "[Gray]",
            "SamsaraPowerInvisibilityGhost",   "gray",     "[Gray]",
            "PowerTranslucency",               "darkgray", "[DarkGray]",
            "PowerShadow",                     "gray",     "[MetalSilver]", // different text color for strife coexistence
            "SamsaraPowerInvisibilityShadow",  "gray",     "[MetalSilver]", // different text color for strife coexistence
            "PowerInvisibility",               "gray",     "[Gray]",
            "PsxPowerInvisibility",            "gray",     "[Gray]",
            "SamsaraPowerInvisibilityNormal",  "gray",     "[Gray]"
        };

        int classnum = CPlayer.CurrentPlayerClass;

        int checkedpowerups = 0, activepowerups = 0;

        for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
        {
            let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

            switch (PowerupDefinitions[checkedpowerups])
            {
              default:
                if (!currentpowerup) { continue; }
                break;

              case 'PowerFlight':
              case 'PowerFlight2':
                if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                break;

              case 'PowerLightAmp':
                if (!currentpowerup || classnum == CLASS_DUKE) { continue; }
                break;
            }

            activepowerups++;
        }

        if (activepowerups > 0)
        {
            Vector2 powerup = (coordbasex + 6, coordbasey);

            int currentpowerupnum = 0;

            bottomleftverttimerrows++;

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid();

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_POWERUPS" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
            {
                let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

                switch (PowerupDefinitions[checkedpowerups])
                {
                  default:
                    if (!currentpowerup) { continue; }
                    break;

                  case 'PowerFlight':
                  case 'PowerFlight2':
                    if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                    break;

                  case 'PowerLightAmp':
                    if (!currentpowerup || classnum == CLASS_DUKE) { continue; }
                    break;
                }

                currentpowerupnum++;

                DrawImage(bottomleftverttimerrows == 1 && ((currentpowerupnum <= 1 && TexMan.CheckForTexture(timerbaseleft).IsValid()) || (currentpowerupnum == 7 && TexMan.CheckForTexture(timerbaseright).IsValid())) ? (currentpowerupnum <= 1 ? timerbaseleft : timerbaseright) : timerbase, powerup, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawImage("graphics/hud/" .. theme .. "/timers/goodolhud_timer_" .. PowerupDefinitions[checkedpowerups + 1] .. ".png", (powerup.X + 2, powerup.Y + 2), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawString(GOHmHUDFont, "\c" .. PowerupDefinitions[checkedpowerups + 2] .. FormatNumber(currentpowerup.EffectTics / TICRATE, 1, 4), (powerup.X + 6, powerup.Y - 16), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_CENTER);

                powerup.X += 22 + (!(currentpowerupnum % 4) ? 1 : 0); // !(currentpowerupnum % 4) is a lazy hack to make the powerups align with each 22.25 addition while following int rules
            }

            haspowerup = true;
        }
    }

    bool hasstatus;

    protected virtual void GOHDrawStatusTimers(int coordbasex, int coordbasey)
    {
        int maxstatuses = 3 * 3;

        static const Name StatusDefinitions[] =
        {
            "PoisonCount",   "darkgreen", "[DarkGreen]",
            "NothingSpeed",  "white",     "[WhiteBorder]",
            "ChickenPlayer", "white",     "[White]" // Morphs don't have a Powerup actor; handle them differently as a result
        };

        let morphclass = CPlayer.mo.GetClass();

        int checkedstatuses = 0, activestatuses = 0;

        for (checkedstatuses = 0; checkedstatuses < maxstatuses; checkedstatuses += 3)
        {
            let currentstatus = Powerup(CPlayer.mo.FindInventory(StatusDefinitions[checkedstatuses]));

            switch (StatusDefinitions[checkedstatuses])
            {
              default:
                if (!currentstatus) { continue; }
                break;

              // special check for poison
              case 'PoisonCount':
                if (CPlayer.PoisonCount <= 0) { continue; }
                break;

              // special check for morphs
              case 'ChickenPlayer':
              case 'PigPlayer':
                if (!(morphclass is StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }
                break;
            }

            activestatuses++;
        }

        if (activestatuses > 0)
        {
            Vector2 status = (coordbasex + 6, coordbasey);

            int currentstatusnum = 0;

            bottomleftverttimerrows++;

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid();

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_STATUS" .. (canshowmugshot && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            for (checkedstatuses = 0; checkedstatuses < maxstatuses; checkedstatuses += 3)
            {
                let currentstatus = Powerup(CPlayer.mo.FindInventory(StatusDefinitions[checkedstatuses]));

                bool checkingpoison = false, checkingmorph = false;

                switch (StatusDefinitions[checkedstatuses])
                {
                  default:
                    if (!currentstatus) { continue; }
                    break;

                  // special check for poison
                  case 'PoisonCount':
                    if (CPlayer.PoisonCount <= 0) { continue; }

                    checkingpoison = true;
                    break;

                  // special check for morphs
                  case 'ChickenPlayer':
                  case 'PigPlayer':
                    if (!(morphclass is StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }

                    checkingmorph = true;
                    break;
                }

                currentstatusnum++;

                DrawImage(bottomleftverttimerrows == 1 && ((currentstatusnum <= 1 && TexMan.CheckForTexture(timerbaseleft).IsValid()) || (currentstatusnum == 7 && TexMan.CheckForTexture(timerbaseright).IsValid())) ? (currentstatusnum <= 1 ? timerbaseleft : timerbaseright) : timerbase, status, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawImage("graphics/hud/" .. theme .. "/timers/goodolhud_timer_" .. StatusDefinitions[checkedstatuses + 1] .. ".png", (status.X + 2, status.Y + 2), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawString(GOHmHUDFont, "\c" .. StatusDefinitions[checkedstatuses + 2] .. FormatNumber(checkingpoison && CPlayer.PoisonCount > 0 ? (CPlayer.PoisonCount - 5) / 10 : checkingmorph && CPlayer.MorphTics > 0 ? CPlayer.MorphTics / TICRATE : currentstatus.EffectTics / TICRATE, 1, 4), (status.X + 6, status.Y - 16), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_CENTER);

                status.X += 22 + (!(currentstatusnum % 4) ? 1 : 0); // !(currentstatusnum % 4) is a lazy hack to make the statuses align with each 22.25 addition while following int rules
            }

            hasstatus = true;
        }
    }

    Vector2 powerupnudge;

    override void DrawPowerups ()
    {
        // The AltHUD specific adjustments have been removed here, because the AltHUD uses its own variant of this function
        // that can obey AltHUD rules - which this cannot.
        let fullscreenhudactive = screenblocks == 11 && !(automapactive && !viewactive);

        Vector2 pos = fullscreenhudactive ? (20 + powerupnudge.X, -6 + powerupnudge.Y) : (-20, POWERUPICONSIZE * 5 / 4);
        double maxpos = screen.GetWidth() / 2;

        for (let iitem = CPlayer.mo.Inv; iitem; iitem = iitem.Inv)
        {
            let item = Powerup(iitem);

            if (item)
            {
                let icon = item.GetPowerupIcon();

                if (icon.IsValid() && !item.IsBlinking())
                {
                    // Each icon gets a 32x32 block.
                    DrawTexture(icon, pos, fullscreenhudactive ? DI_SCREEN_LEFT_BOTTOM : DI_SCREEN_RIGHT_TOP, 1, (POWERUPICONSIZE, POWERUPICONSIZE));

                    pos.x += fullscreenhudactive ? POWERUPICONSIZE : -POWERUPICONSIZE;

                    if (fullscreenhudactive ? pos.x > maxpos : pos.x < -maxpos)
                    {
                        pos.x = fullscreenhudactive ? 20 + powerupnudge.X : -20;
                        pos.y += fullscreenhudactive ? -POWERUPICONSIZE : POWERUPICONSIZE * 3 / 2;
                    }
                }
            }
        }
    }

    int weaponnameamount;

    protected virtual void GOHDrawWeaponName(int coordbasex, int coordbasey)
    {
        Vector2 coordnudge;

        let vanillaquake = CPlayer.mo.FindInventory("QuakeModeOn");

        Name weaponname;

        String weaponmode;

        Inventory currentmode;
        bool usingspectralweapon;

        let canshowpendingweapon = CVar.FindCVar("goh_showpendingweapon").GetBool() && CPlayer.PendingWeapon != WP_NOCHANGE;

        if (canshowpendingweapon || CPlayer.ReadyWeapon)
        {
            weaponname = canshowpendingweapon ? CPlayer.PendingWeapon.GetClassName() : CPlayer.ReadyWeapon.GetClassName();

            switch (weaponname)
            {
              case 'StrifeCrossbow':
              case 'StrifeCrossbow2':
              case 'StrifeGrenadeLauncher':
              case 'StrifeGrenadeLauncher2':
              case 'Mauler':
              case 'Mauler2':
              case 'Sigil':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. weaponname .. (weaponname == "Sigil" ? FormatNumber(canshowpendingweapon ? CPlayer.PendingWeapon.Health : CPlayer.ReadyWeapon.Health) : "");
                break;

              // Dual wieldable weapons
              case 'Steel Knuckles':
              case '.44 Magnum Mega Class A1':
              case 'WSTE-M5 Combat Shotgun':
                switch (weaponname)
                {
                  case 'Steel Knuckles': currentmode = CPlayer.mo.FindInventory("DOUBLEFISTING"); break;
                  default: currentmode = CPlayer.mo.FindInventory("UsingDual" .. (weaponname == "WSTE-M5 Combat Shotgun" ? "Shotguns" : "Pistols")); break;
                }

                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (currentmode ? "DUAL" : "SINGLE");
                break;

              // The others
              case ' Staff ':
              case 'Elven Wand':
              //case 'Gauntlets of the Necromancer': // currently not affected
              case ' Firemace ':
              case 'Ethereal Crossbow':
              case 'Dragon Claw':
              case 'Phoenix Rod':
              case 'Hellstaff':
                usingspectralweapon = Powerup(CPlayer.mo.FindInventory("SpectralFiring"));
                break;

              case 'Grenade Launcher':
              case 'Spectral GL':
              case 'Nailgun':
              case 'Spectral NG':
              case '  Rocket Launcher  ':
              case 'Spectral RL':
              case 'Super Nailgun':
              case 'Spectral SNG':
                if (!vanillaquake) { weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_RANGER_"; }

                switch (weaponname)
                {
                  case 'Grenade Launcher':
                  case 'Spectral GL':
                    if (weaponmode != "") { weaponmode = weaponmode .. (CPlayer.mo.FindInventory("UsingMultiNades") ? "MULTI" : "") .. "GRENADES"; }
                    break;

                  case 'Nailgun':
                  case 'Spectral NG':
                    if (weaponmode != "") { weaponmode = weaponmode .. (CPlayer.mo.FindInventory("FiredLavaNails") ? "LAVA" : "") .. "NAILS"; }
                    break;

                  case '  Rocket Launcher  ':
                  case 'Spectral RL':
                    if (weaponmode != "") { weaponmode = weaponmode .. (CPlayer.mo.FindInventory("UsingMultiRockets") ? "MULTI" : "") .. "ROCKETS"; }
                    break;

                  case 'Super Nailgun':
                  case 'Spectral SNG':
                    if (weaponmode != "") { weaponmode = weaponmode .. (CPlayer.mo.FindInventory("FiredSLNails") ? "LAVA" : "") .. "NAILS"; }
                    break;
                }
                break;
            }

            DrawString(GOHmHUDFont,
                       "\c" .. colorschemetext ..
                       (usingspectralweapon ? StringTable.Localize("$GOODOLHUD_WEAPON_SAMSARA_SPECTRAL") .. " " : "") .. (canshowpendingweapon ? CPlayer.PendingWeapon.GetTag() : CPlayer.ReadyWeapon.GetTag()) ..
                       (weaponmode != "" ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize(weaponmode) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                       (coordbasex, coordbasey), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            weaponnameamount++;
        }
    }

    int foundammotypes;

    Ammo, Ammo, int, int GetPendingAmmo() const
    {
        Ammo ammo1, ammo2;

        if (CPlayer.PendingWeapon != WP_NOCHANGE)
        {
            ammo1 = CPlayer.PendingWeapon.Ammo1;
            ammo2 = CPlayer.PendingWeapon.Ammo2;

            if (ammo1 == null)
            {
                ammo1 = ammo2;
                ammo2 = null;
            }
        }
        else { ammo1 = ammo2 = null; }

        let ammocount1 = ammo1 != null ? ammo1.Amount : 0;
        let ammocount2 = ammo2 != null ? ammo2.Amount : 0;

        return ammo1, ammo2, ammocount1, ammocount2;
    }

    protected virtual void GOHDrawAmmo(int coordbasex, int coordbasey)
    {
        int maxammos = 32 * 3; // some of these are magazines or counters (charge/overheating/etc.)

        static const Name AmmoDefinitions[] = // have to use Name for switch/case and DECORATE purposes
        {
            // Doom/Chex Quest
            "Clip",       "yellow",    "[Yellow]",
            "Shell",      "red",       "[Red]",
            "RocketAmmo", "brown",     "[Brown]",
            "Cell",       "lightblue", "[LightBlue]",
            "ID24Fuel",   "fire",      "[Fire]",
            // Heretic
            "GoldWandAmmo",   "yellow", "[Yellow]",
            "CrossbowAmmo",   "green",  "[Green]",
            "BlasterAmmo",    "blue",   "[Blue]",
            "SkullRodAmmo",   "red",    "[Red]",
            "PhoenixRodAmmo", "fire",   "[Fire]",
            "MaceAmmo",       "gray",   "[Gray]",
            // Hexen
            "Mana1", "blue",  "[Blue]",
            "Mana2", "green", "[Green]",
            // Strife
            "ClipOfBullets",           "yellow",    "[Yellow]",
            "PoisonBolts",             "green",     "[Green]",
            "ElectricBolts",           "blue",      "[Blue]",
            "HEGrenadeRounds",         "orange",    "[Orange]",
            "PhosphorusGrenadeRounds", "fire",      "[Fire]",
            "MiniMissiles",            "brown",     "[Brown]",
            "EnergyPod",               "lightblue", "[LightBlue]",
            // Duke Nukem
            "DukePistolReload",    "white",         "[White]",
            "DukePipebombSpeed",   "blueyellowred", "BlueYellowRed",
            "DukeGoldEagleReload", "white",         "[White]",
            // Security Officer
            "UnknownResonator1", "rainbow",        "Rainbow",
            "UnknownAmmo",       "rainbow",        "Rainbow",
            "UnknownResonator2", "rainbowreverse", "RainbowReverse",
            "UnknownAmmo2",      "rainbowreverse", "RainbowReverse",
            "KnifeAmmo",         "darkgray",       "[DarkGray]",
            "MagnumBullet",      "white",          "[White]",
            "Spanker2Ammo",      "white",          "[White]",
            // Ranger
            "LavaNails",       "orange",    "[Orange]",
            "MultiRocketAmmo", "darkbrown", "[DarkBrown]"
        };

        Vector2 coordnudge;

        let pistolammo = CPlayer.mo.FindInventory("PistolModeOn");
        let vanillaquake = CPlayer.mo.FindInventory("QuakeModeOn");

        let canshowpendingweapon = CVar.FindCVar("goh_showpendingweapon").GetBool() && CPlayer.PendingWeapon != WP_NOCHANGE;

        Inventory ammotype1, ammotype2, ammotype3, ammotype4;

        if (canshowpendingweapon) { [ammotype1, ammotype2] = GetPendingAmmo(); }
        else { [ammotype1, ammotype2] = GetCurrentAmmo(); }

        bool showammo1perc = false, showammo2perc = false, showammo3perc = false, showammo4perc = false;

        bool usingreloadpri = false, usingreloadsec = false;

        Inventory currentmode;
        bool usingdual = false;

        let usingclip = Ammo(CPlayer.mo.FindInventory("Clip"));
        let usingshell = Ammo(CPlayer.mo.FindInventory("Shell"));
        let usingrocketammo = Ammo(CPlayer.mo.FindInventory("RocketAmmo"));
        let usingcell = Ammo(CPlayer.mo.FindInventory("Cell"));

        if (canshowpendingweapon || CPlayer.ReadyWeapon)
        {
            Name weaponname = canshowpendingweapon ? CPlayer.PendingWeapon.GetClassName() : CPlayer.ReadyWeapon.GetClassName();

            bool usingaltammo = false;

            switch (weaponname)
            {
              case 'StrifeCrossbow':
              case 'StrifeCrossbow2':
                usingaltammo = weaponname == "StrifeCrossbow2";

                ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("PoisonBolts")); // not the most efficient way to handle it, but it's something
                if (usingaltammo) { ammotype1 = Ammo(CPlayer.mo.FindInventory("ElectricBolts")); }
                break;

              case 'StrifeGrenadeLauncher':
              case 'StrifeGrenadeLauncher2':
                usingaltammo = weaponname == "StrifeGrenadeLauncher2";

                ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("PhosphorusGrenadeRounds"));
                if (usingaltammo) { ammotype1 = Ammo(CPlayer.mo.FindInventory("HEGrenadeRounds")); }
                break;

              // Pistol ammo
              case ' Pistol ':
              case 'Mini-Zorcher':
              case 'Luger':
              case 'Single Shotgun':
                if (pistolammo) { ammotype1 = weaponname == "Single Shotgun" ? usingshell : usingclip; }
                break;

              // Reloadables
              case 'Glock 17':
              case 'Golden Desert Eagle':
              case 'KKV-7 SMG Flechette':
              case 'Fusion Pistol':
              case 'SPNKR-XP SSM Launcher':
              case 'TOZT-7 Napalm Unit':
              case 'SPNKR-25 Auto Cannon':
                switch (weaponname)
                {
                  case 'Glock 17':
                  case 'KKV-7 SMG Flechette':
                    if (weaponname != "Glock 17" || pistolammo) { ammotype2 = usingclip; }
                    break;

                  case 'Fusion Pistol':
                  case 'TOZT-7 Napalm Unit':
                    ammotype2 = usingcell;
                    break;

                  case 'SPNKR-XP SSM Launcher': ammotype2 = usingrocketammo; break;
                }

                usingreloadpri = true;
                break;

              // Reloadables with more than one magazine
              case 'MA-75B Assault Rifle':
              case 'ONI-71 Wave Motion Cannon':
                ammotype3 = weaponname == "ONI-71 Wave Motion Cannon" ? usingcell : usingclip;
                ammotype4 = usingrocketammo;

                usingreloadpri = true;
                usingreloadsec = true;
                break;

              // Reloadables that dual wield
              case '.44 Magnum Mega Class A1':
                if (pistolammo) { ammotype2 = usingclip; }

                usingdual = CPlayer.mo.FindInventory("UsingDualPistols");

                if (usingdual)
                {
                    ammotype3 = ammotype2 ? ammotype2 : null;
                    ammotype2 = Ammo(CPlayer.mo.FindInventory(ammotype1.GetClassName() .. "Right"));
                }

                usingreloadpri = true;
                usingreloadsec = usingdual;
                break;

              // Throwables/chargeables
              case 'Pipebombs':
                ammotype2 = CPlayer.mo.FindInventory("DukePipebombSpeed");
                showammo2perc = true;
                break;

              // The others
              case 'Elven Wand':
              case ' Firemace ':
              case 'Ethereal Crossbow':
              case 'Dragon Claw':
              case 'Phoenix Rod':
              case 'Hellstaff':
                if (Powerup(CPlayer.mo.FindInventory("SpectralFiring"))) { ammotype1 = null; }
                else
                {
                    if (weaponname == "Elven Wand" && pistolammo) { ammotype1 = usingclip; }
                }
                break;

              case 'Alien Weapon':
              case ' Alien Weapon ':
                if (CVar.FindCVar("goh_samsara_showalienweaponammo").GetBool()) { ammotype1 = Ammo(CPlayer.mo.FindInventory("UnknownAmmo" .. (weaponname == " Alien Weapon " ? "2" : ""))); }
                break;

              case 'Grenade Launcher':
              case 'Nailgun':
              case '  Rocket Launcher  ':
              case 'Super Nailgun':
                if (vanillaquake) { ammotype2 = null; }
                break;
            }
        }

        for (int checkedammotypes = 1; checkedammotypes <= 4; checkedammotypes++)
        {
            Inventory ammotype, ammotypereload;
            Name ammobarcolor;
            Name ammotextcolor;
            String ammostring;
            bool showammoperc = false;

            let showingmagazinelabel = CVar.FindCVar("goh_reloadableammolabel").GetBool();

            switch (checkedammotypes)
            {
              case 1:
                if (!ammotype1) { continue; }

                ammotype = ammotype1;

                if (usingreloadpri || usingreloadsec)
                {
                    if (usingreloadsec)
                    {
                        if (ammotype3) { ammotypereload = ammotype3; }
                    } else {
                        if (ammotype2) { ammotypereload = ammotype2; }
                    }
                }

                ammobarcolor = "yellow";
                ammotextcolor = "[Yellow]";
                ammostring = "$GOODOLHUD_" .. (usingreloadpri || usingreloadsec ? (showingmagazinelabel ? "MAGAZINE" : "CLIP") : "AMMO") .. "1";
                showammoperc = showammo1perc;
                break;

              case 2:
                if (!ammotype2 || ammotype2 == ammotype1) { continue; }

                ammotype = ammotype2;

                if (usingreloadpri && usingreloadsec)
                {
                    if (ammotype4) { ammotypereload = ammotype4; }
                    else if (ammotype3) { ammotypereload = ammotype3; }
                    else if (ammotype1) { ammotypereload = ammotype1; } // fallback ranged dual wielding (samsara_pistolammo 0)
                }

                ammobarcolor = "orange";
                ammotextcolor = "[Orange]";
                ammostring = "$GOODOLHUD_" .. (usingreloadpri && usingreloadsec ? (showingmagazinelabel ? "MAGAZINE" : "CLIP") .. "2" : "AMMO" .. (usingreloadpri || usingreloadsec ? "1" : "2"));
                showammoperc = showammo2perc;
                break;

              case 3:
                if (!ammotype3) { continue; }

                ammotype = ammotype3;
                ammobarcolor = "yellow";
                ammotextcolor = "[Yellow]";
                ammostring = "$GOODOLHUD_AMMO" .. (usingreloadpri && usingreloadsec ? "1" : (usingreloadpri || usingreloadsec ? "2" : "3"));
                showammoperc = showammo3perc;
                break;

              case 4:
                if (!ammotype4 || ammotype4 == ammotype3) { continue; }

                ammotype = ammotype4;
                ammobarcolor = "orange";
                ammotextcolor = "[Orange]";
                ammostring = "$GOODOLHUD_AMMO" .. (usingreloadpri && usingreloadsec ? "2" : (usingreloadpri || usingreloadsec ? "3" : "4"));
                showammoperc = showammo4perc;
                break;
            }

            DrawImage(barbase, (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM);

            for (int checkedammos = 0; checkedammos < maxammos; checkedammos += 3)
            {
                if (ammotypereload)
                {
                    if (ammotypereload is AmmoDefinitions[checkedammos])
                    {
                        ammobarcolor = AmmoDefinitions[checkedammos + 1];
                        ammotextcolor = AmmoDefinitions[checkedammos + 2];
                        break;
                    }
                } else {
                    if (ammotype is AmmoDefinitions[checkedammos])
                    {
                        ammobarcolor = AmmoDefinitions[checkedammos + 1];
                        ammotextcolor = AmmoDefinitions[checkedammos + 2];
                        break;
                    }
                }
            }

            Name ammoname = ammotype.GetClassName();

            switch (ammoname)
            {
              case 'DukePipebombSpeed': ammostring = "$GOODOLHUD_THROWPOWER"; break;
            }

            switch (ammobarcolor)
            {
              case 'blueyellowred':
              case 'rainbow':
              case 'rainbowreverse':
              case 'redyellowblue':
                ammobarcolor = ammobarcolor .. (CVar.FindCVar("goh_bargradients").GetBool() ? "_gradient" : "");
                break;
            }

            switch (ammotextcolor)
            {
              case 'BlueYellowRed':
              case 'RedYellowBlue':
                if (ammotype.Amount <= ammotype.MaxAmount / 5) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Red" : "Blue") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 2.5) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Orange" : "LightBlue") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.66666) { ammotextcolor = "[Yellow]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.25) { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "LightBlue" : "Orange") .. "]"; }
                else { ammotextcolor = "[" .. (ammotextcolor == "RedYellowBlue" ? "Blue" : "Red") .. "]"; }
                break;

              case 'Rainbow':
              case 'RainbowReverse':
                if (ammotype.Amount <= ammotype.MaxAmount / 8) { ammotextcolor = "[Red]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 4) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Orange" : "Purple") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 2.66666) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Yellow" : "Blue") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 2) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Green" : "Cyan") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.6) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Cyan" : "Green") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.33333) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Blue" : "Yellow") .. "]"; }
                else if (ammotype.Amount <= ammotype.MaxAmount / 1.14285) { ammotextcolor = "[" .. (ammotextcolor == "RainbowReverse" ? "Purple" : "Orange") .. "]"; }
                else { ammotextcolor = "[Red]"; }
                break;
            }

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_" .. ammobarcolor .. ".png";
            DrawBar(bar, barblank, ammotype.Amount, ammotype.MaxAmount, (coordbasex, (coordbasey + coordnudge.Y) - 1), 0, SHADER_HORZ, DI_SCREEN_RIGHT_BOTTOM);

            DrawString(GOHmHUDFont, "\c" .. ammotextcolor .. StringTable.Localize(ammostring), (coordbasex - 79, (coordbasey + coordnudge.Y) - 14), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            DrawString(GOHmHUDFont, "\c" .. ammotextcolor .. (showammoperc ? (String.Format("%.1f", ammotype.Amount * 100.0 / ammotype.MaxAmount) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE")) : (FormatNumber(ammotype.Amount, 1, 4) .. (CVar.FindCVar("goh_showmaxamounts").GetBool() ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(ammotype.MaxAmount, 1, 4) : ""))), (coordbasex + 77, (coordbasey + coordnudge.Y) - 14), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            coordnudge.Y -= 16;

            foundammotypes++;
        }
    }

    int foundammocapacities;

    protected virtual void GOHDrawAmmoCapacities(int coordbasex, int coordbasey)
    {
        int maxammocapacities = 6 * 2;

        static const Name AmmoCapacityDefinitions[] =
        {
            // Ammo 1A
            "Clip", "[Yellow]",
            // Ammo 1B
            "LavaNails", "[Orange]",
            // Ammo 2
            "Shell", "[Red]",
            // Ammo 3A
            "RocketAmmo", "[Brown]",
            // Ammo 3B
            "MultiRocketAmmo", "[DarkBrown]",
            // Ammo 4
            "Cell", "[LightBlue]"
        };

        Vector2 coordnudge;

        int classnum = CPlayer.CurrentPlayerClass;

        let vanillaquake = CPlayer.mo.FindInventory("QuakeModeOn");

        int currentammo, currentammomax;
        String ammoidentifier;

        for (int checkedammocapacities = maxammocapacities - 1; checkedammocapacities >= 0; checkedammocapacities -= 2)
        {
            Name ammocapacity = AmmoCapacityDefinitions[checkedammocapacities - 1];

            // do not show for incompatible classes/settings
            switch (ammocapacity)
            {
              case 'Shell':
                switch (classnum)
                {
                  case CLASS_WOLFEN:
                  case CLASS_HEXEN:
                    continue;
                }
                break;

              case 'RocketAmmo':
                switch (classnum)
                {
                  case CLASS_HEXEN: continue;
                }
                break;

              case 'LavaNails':
              case 'MultiRocketAmmo':
                switch (classnum)
                {
                  case CLASS_QUAKE:
                    if (!vanillaquake) { break; }

                  default: continue;
                }
                break;
            }

            // adjust identifiers
            switch (ammocapacity)
            {
              case 'Clip':
                ammoidentifier = "1";

                switch (classnum)
                {
                  case CLASS_QUAKE:
                    if (!vanillaquake) { ammoidentifier = ammoidentifier .. "A"; }
                    break;
                }
                break;

              case 'LavaNails': ammoidentifier = "1B"; break;
              case 'Shell': ammoidentifier = "2"; break;

              case 'RocketAmmo':
                ammoidentifier = "3";

                switch (classnum)
                {
                  case CLASS_QUAKE:
                    if (!vanillaquake) { ammoidentifier = ammoidentifier .. "A"; }
                    break;
                }
                break;

              case 'MultiRocketAmmo': ammoidentifier = "3B"; break;
              case 'Cell': ammoidentifier = "4"; break;
            }

            [currentammo, currentammomax] = GetAmount(ammocapacity);

            Name ammocapacitycolor = AmmoCapacityDefinitions[checkedammocapacities];

            switch (ammocapacitycolor)
            {
              case 'BlueYellowRed':
              case 'RedYellowBlue':
                if (currentammo <= currentammomax / 5) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "Red" : "Blue") .. "]"; }
                else if (currentammo <= currentammomax / 2.5) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "Orange" : "LightBlue") .. "]"; }
                else if (currentammo <= currentammomax / 1.66666) { ammocapacitycolor = "[Yellow]"; }
                else if (currentammo <= currentammomax / 1.25) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "LightBlue" : "Orange") .. "]"; }
                else { ammocapacitycolor = "[" .. (ammocapacitycolor == "RedYellowBlue" ? "Blue" : "Red") .. "]"; }
                break;

              case 'Rainbow':
              case 'RainbowReverse':
                if (currentammo <= currentammomax / 8) { ammocapacitycolor = "[Red]"; }
                else if (currentammo <= currentammomax / 4) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Orange" : "Purple") .. "]"; }
                else if (currentammo <= currentammomax / 2.66666) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Yellow" : "Blue") .. "]"; }
                else if (currentammo <= currentammomax / 2) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Green" : "Cyan") .. "]"; }
                else if (currentammo <= currentammomax / 1.6) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Cyan" : "Green") .. "]"; }
                else if (currentammo <= currentammomax / 1.33333) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Blue" : "Yellow") .. "]"; }
                else if (currentammo <= currentammomax / 1.14285) { ammocapacitycolor = "[" .. (ammocapacitycolor == "RainbowReverse" ? "Purple" : "Orange") .. "]"; }
                else { ammocapacitycolor = "[Red]"; }
                break;
            }

            DrawString(GOHmHUDFont, "\c" .. ammocapacitycolor .. StringTable.Localize("$GOODOLHUD_AMMOCAPACITY_SAMSARA_AMMO" .. ammoidentifier), (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            DrawString(GOHmHUDFont, "\c" .. ammocapacitycolor .. FormatNumber(currentammo, 1, 4) .. StringTable.Localize("$GOODOLHUD_SEPARATOR"), (coordbasex + 48, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);
            DrawString(GOHmHUDFont, "\c" .. ammocapacitycolor .. FormatNumber(currentammomax, 1, 4), (coordbasex + 48, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            coordnudge.Y -= 16;

            foundammocapacities++;
        }
    }

    protected virtual void GOHDrawWeaponBar(int coordbasex, int coordbasey)
    {
        int classnum = CPlayer.CurrentPlayerClass;

        Name weaponname;

        let canshowpendingweapon = CVar.FindCVar("goh_showpendingweapon").GetBool() && CPlayer.PendingWeapon != WP_NOCHANGE;

        if (canshowpendingweapon) { weaponname = CPlayer.PendingWeapon.GetClassName(); }
        else if (CPlayer.ReadyWeapon) { weaponname = CPlayer.ReadyWeapon.GetClassName(); }

        bool hasslot1 = CPlayer.mo.FindInventory("GotWeapon0");

        bool hasslot2 = (classnum == CLASS_WOLFEN && (CPlayer.mo.FindInventory("GotWeapon2") || CPlayer.mo.FindInventory("GotWeapon3"))) ||
                        (classnum != CLASS_WOLFEN && CPlayer.mo.FindInventory("GotWeapon2"));

        bool hasslot3 = classnum != CLASS_WOLFEN && CPlayer.mo.FindInventory("GotWeapon3");
        bool hasslot4 = CPlayer.mo.FindInventory("GotWeapon4");
        bool hasslot5 = CPlayer.mo.FindInventory("GotWeapon5");
        bool hasslot6 = CPlayer.mo.FindInventory("GotWeapon6");
        bool hasslot7 = CPlayer.mo.FindInventory("GotWeapon7");

        bool usingslot1 = (classnum == CLASS_DOOM && weaponname == " Chainsaw ") ||
                          (classnum == CLASS_CHEX && weaponname == "Super Bootspork") ||
                          (classnum == CLASS_HERETIC && weaponname == "Gauntlets of the Necromancer") ||
                          (classnum == CLASS_WOLFEN && weaponname == "Knife" && CPlayer.mo.FindInventory("BJSuperKnife")) ||
                          (classnum == CLASS_HEXEN && CPlayer.mo.FindInventory("DiscOfRepulsionCooldown") && CPlayer.mo.FindInventory("DiscOfRepulsionCooldown").Amount >= 9) ||
                          (classnum == CLASS_DUKE && weaponname == "Pipebombs") ||
                          (classnum == CLASS_MARATHON && weaponname == "KKV-7 SMG Flechette") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Mjolnir" || weaponname == "Spectral Mjolnir"));

        bool usingslot2 = (classnum == CLASS_DOOM && weaponname == " Shotgun ") ||
                          (classnum == CLASS_CHEX && weaponname == "Large Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == " Firemace ") ||
                          (classnum == CLASS_WOLFEN && weaponname == "Machine Gun") ||
                          (classnum == CLASS_HEXEN && weaponname == "Frost Shards") ||
                          (classnum == CLASS_DUKE && weaponname == "  Shotgun  ") ||
                          (classnum == CLASS_MARATHON && weaponname == "WSTE-M5 Combat Shotgun") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Double Shotgun" || weaponname == "Spectral DSG"));

        bool usingslot3 = (classnum == CLASS_DOOM && weaponname == "Super Shotgun") ||
                          (classnum == CLASS_CHEX && weaponname == "Super Large Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == "Ethereal Crossbow") ||
                          (classnum == CLASS_HEXEN && weaponname == "Timon's Axe") ||
                          (classnum == CLASS_DUKE && weaponname == "Explosive Shotgun") ||
                          (classnum == CLASS_MARATHON && weaponname == "Fusion Pistol") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Grenade Launcher" || weaponname == "Spectral GL"));

        bool usingslot4 = (classnum == CLASS_DOOM && weaponname == " Chaingun ") ||
                          (classnum == CLASS_CHEX && weaponname == "Rapid Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == "Dragon Claw") ||
                          (classnum == CLASS_WOLFEN && weaponname == "  Chaingun  ") ||
                          (classnum == CLASS_HEXEN && weaponname == "Serpent Staff") ||
                          (classnum == CLASS_DUKE && weaponname == "Chaingun Cannon") ||
                          (classnum == CLASS_MARATHON && weaponname == "MA-75B Assault Rifle") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Nailgun" || weaponname == "Spectral NG"));

        bool usingslot5 = (classnum == CLASS_DOOM && weaponname == "Rocket Launcher") ||
                          (classnum == CLASS_CHEX && weaponname == "Zorch Propulsor") ||
                          (classnum == CLASS_HERETIC && weaponname == "Phoenix Rod") ||
                          (classnum == CLASS_WOLFEN && weaponname == " Rocket Launcher ") ||
                          (classnum == CLASS_HEXEN && weaponname == "Hammer of Retribution") ||
                          (classnum == CLASS_DUKE && weaponname == "RPG") ||
                          (classnum == CLASS_MARATHON && weaponname == "SPNKR-XP SSM Launcher") ||
                          (classnum == CLASS_QUAKE && (weaponname == "  Rocket Launcher  " || weaponname == "Spectral RL"));

        bool usingslot6 = (classnum == CLASS_DOOM && weaponname == "Plasma Rifle") ||
                          (classnum == CLASS_CHEX && weaponname == "Phasing Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == "Hellstaff") ||
                          (classnum == CLASS_WOLFEN && weaponname == " Flamethrower ") ||
                          (classnum == CLASS_HEXEN && weaponname == "Firestorm") ||
                          (classnum == CLASS_DUKE && weaponname == "Freezethrower") ||
                          (classnum == CLASS_MARATHON && weaponname == "TOZT-7 Napalm Unit") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Super Nailgun" || weaponname == "Spectral SNG"));

        bool usingslot7 = (classnum == CLASS_DOOM && (weaponname == "B.F.G. 9000" || weaponname == "Spectral B.F.G. 9000")) ||
                          (classnum == CLASS_CHEX && (weaponname == "LAZ Device" || weaponname == "Spectral LAZ Device")) ||
                          (classnum == CLASS_HERETIC && Powerup(CPlayer.mo.FindInventory("PowerHereticTome"))) ||
                          (classnum == CLASS_WOLFEN && (weaponname == "Spear of Destiny" || weaponname == "Spear of Eternity")) ||
                          (classnum == CLASS_HEXEN && (weaponname == "Wraithverge" || weaponname == "Spectral Wraithverge")) ||
                          (classnum == CLASS_DUKE && (weaponname == "Devastator Weapon" || weaponname == "Spectral Devastator Weapon")) ||
                          (classnum == CLASS_MARATHON && (weaponname == "ONI-71 Wave Motion Cannon" || weaponname == "Spectral ONI-71 Wave Motion Cannon")) ||
                          (classnum == CLASS_QUAKE && (weaponname == "Thunderbolt" || weaponname == "Spectral LG"));

        let weaponbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT;

        for (int slotnum = 1; slotnum <= 7; slotnum++)
        {
            bool hasslot = false, usingslot = false;

            switch (slotnum)
            {
                case 1:
                  hasslot = hasslot1;
                  usingslot = usingslot1;
                  break;

                case 2:
                  hasslot = hasslot2;
                  usingslot = usingslot2;
                  break;

                case 3:
                  hasslot = hasslot3;
                  usingslot = usingslot3;
                  break;

                case 4:
                  hasslot = hasslot4;
                  usingslot = usingslot4;
                  break;

                case 5:
                  hasslot = hasslot5;
                  usingslot = usingslot5;
                  break;

                case 6:
                  hasslot = hasslot6;
                  usingslot = usingslot6;
                  break;

                case 7:
                  hasslot = hasslot7;
                  usingslot = usingslot7;
                  break;
            }

            DrawString(GOHmHUDFont, hasslot || usingslot ? "\c" .. (usingslot ? colorschemeactivetext : colorschemetext) .. FormatNumber(slotnum, 1, 1) : "", (coordbasex + (10 * ((slotnum == 0 ? 10 : slotnum) - 1)), coordbasey), weaponbarflags);
        }
    }

    protected virtual void GOHDrawCooldownTimers(int invcoordbasex, int invcoordbasey, int wepcoordbasex, int wepcoordbasey)
    {
        int maxcooldowns = 3 * 2;

        static const Name CooldownDefinitions[] =
        {
            "TomeOfPowerCooldown",              "[Black]",
            "DiscOfRepulsionCooldown",          "[DarkGreen]",
            "SamsaraQuadDamageCooldownDisplay", "[Ice]"
        };

        Vector2 coordbase = (0, 0);

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        let canshowweaponbar = CVar.FindCVar("goh_showweaponbar").GetBool();

        int CurrentCooldownAmounts[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

        for (int checkedcooldowns = 0; checkedcooldowns < maxcooldowns; checkedcooldowns += 2)
        {
            let currentcooldown = CPlayer.mo.FindInventory(CooldownDefinitions[checkedcooldowns]);
            let currentcooldowncolor = CooldownDefinitions[checkedcooldowns + 1];

            if (currentcooldown)
            {
                Name cooldownname = currentcooldown.GetClassName();

                int cooldownslot = -1;

                switch (cooldownname)
                {
                  case 'TomeOfPowerCooldown': cooldownslot = 7; break;

                  case 'DiscOfRepulsionCooldown':
                    if (classnum == CLASS_DUKE) { currentcooldowncolor = "[Gray]"; }
                    else { cooldownslot = 1; }
                    break;
                }

                if (!canshowweaponbar) { cooldownslot = -1; }

                if (cooldownslot >= 0)
                {
                    int slotincrement = 0;

                    if (cooldownslot > 9) { cooldownslot = 9; }

                    CurrentCooldownAmounts[cooldownslot + 1]++;
                    slotincrement = CurrentCooldownAmounts[cooldownslot + 1];

                    coordbase = (wepcoordbasex + (10 * ((cooldownslot == 0 ? 10 : cooldownslot) - 1)), wepcoordbasey - (16 * slotincrement));
                } else {
                    CurrentCooldownAmounts[cooldownslot + 1]++;

                    coordbase = (invcoordbasex, invcoordbasey - (16 * CurrentCooldownAmounts[cooldownslot + 1]));
                }

                DrawString(GOHmHUDFont, "\c" .. currentcooldowncolor .. FormatNumber(currentcooldown.Amount - 1, 1, 4), coordbase, DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_CENTER);
            }
        }
    }

    protected virtual void GOHDrawFullscreenKeys(int coordbasex, int coordbasey)
    {
        Vector2 keypos = (coordbasex, coordbasey);

        for (let i = CPlayer.mo.Inv; i; i = i.Inv)
        {
            if (i is "Key" && i.Icon.IsValid())
            {
                DrawTexture(i.Icon, keypos, DI_ITEM_RIGHT_TOP);

                Vector2 size = TexMan.GetScaledSize(i.Icon);

                keypos.Y += size.Y + 2;
            }
        }
    }

    protected virtual void GOHDrawMiscItems(int coordbasex, int coordbasey)
    {
        int maxmiscitems = 5 * 4;

        static const Name MiscItemDefinitions[] =
        {
            "DukeBootserk",    "DMBPA0_HUDT", "", "",
            "NuclearKicks",    "UNIQN0",      "", "",
            "WolfExtraLife",   "WFLFA0",      "", "[Sapphire]",
            "DukeJetpackFuel", "DKJTA0",      "", "[Gray]",
            "DukeVisionFuel",  "ARTINIVI",    "", "[DarkGray]"
        };

        Vector2 coordnudge;

        int checkedmiscitems = 0, activemiscitems = 0;

        for (checkedmiscitems = 0; checkedmiscitems < maxmiscitems; checkedmiscitems += 4)
        {
            let currentmiscitem = CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems]);

            switch (MiscItemDefinitions[checkedmiscitems])
            {
              default:
                if (!currentmiscitem) { continue; }
                break;

              case 'SigilSplinter':
                int sigilpieces = 0;

                for (int sigilpiececheck = 1; sigilpiececheck <= 5; sigilpiececheck++)
                {
                    if (CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems] .. sigilpiececheck)) { sigilpieces++; }
                }

                if (sigilpieces <= 0) { continue; }
                break;
            }

            activemiscitems++;
        }

        if (activemiscitems > 0)
        {
            for (checkedmiscitems = 0; checkedmiscitems < maxmiscitems; checkedmiscitems += 4)
            {
                let currentmiscitem = CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems]);
                let currentmiscitemicon = MiscItemDefinitions[checkedmiscitems + 1], currentmiscitemcolor = MiscItemDefinitions[checkedmiscitems + 3];

                bool hascounter = false, counterpercentage = false;
                bool ispowerup = false;
                bool showcooldowntimer = true;

                switch (MiscItemDefinitions[checkedmiscitems])
                {
                  default:
                    if (!currentmiscitem) { continue; }
                    break;

                  case 'Sigil':
                    if (!currentmiscitem) { continue; }

                    switch (currentmiscitem.Health)
                    {
                      case 1: currentmiscitemicon = currentmiscitemicon .. "A"; break;
                      case 2: currentmiscitemicon = currentmiscitemicon .. "B"; break;
                      case 3: currentmiscitemicon = currentmiscitemicon .. "C"; break;
                      case 4: currentmiscitemicon = currentmiscitemicon .. "D"; break;
                      default: currentmiscitemicon = currentmiscitemicon .. "E"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";
                    break;

                  case 'SigilSplinter':
                    int sigilpieces = 0;

                    for (int sigilpiececheck = 1; sigilpiececheck <= 5; sigilpiececheck++)
                    {
                        if (CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems] .. sigilpiececheck)) { sigilpieces++; }
                    }

                    if (sigilpieces <= 0) { continue; }

                    switch (sigilpieces)
                    {
                      case 1: currentmiscitemicon = currentmiscitemicon .. "A"; break;
                      case 2: currentmiscitemicon = currentmiscitemicon .. "B"; break;
                      case 3: currentmiscitemicon = currentmiscitemicon .. "C"; break;
                      case 4: currentmiscitemicon = currentmiscitemicon .. "D"; break;
                      default: currentmiscitemicon = currentmiscitemicon .. "E"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";
                    break;

                  case 'WolfExtraLife':
                    if (!currentmiscitem) { continue; }

                    hascounter = true;
                    break;

                  case 'DukeJetpackFuel':
                  case 'DukeVisionFuel':
                    if (!currentmiscitem) { continue; }

                    hascounter = true;
                    counterpercentage = true;
                    break;
                }

                if (TexMan.CheckForTexture(currentmiscitemicon).IsValid())
                {
                    DrawImage(currentmiscitemicon, (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_TOP|DI_ITEM_CENTER);

                    if (hascounter)
                    {
                        int miscitemamt, miscitemmaxamt;

                        [miscitemamt, miscitemmaxamt] = GetAmount(MiscItemDefinitions[checkedmiscitems]);

                        DrawString(GOHmHUDFont, "\c" .. currentmiscitemcolor .. (counterpercentage ? (FormatNumber(miscitemamt * 100.0 / miscitemmaxamt, 1, 3) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE")) : FormatNumber(miscitemamt, 1, 4)), (coordbasex, (coordbasey + coordnudge.Y) + 24), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_CENTER);
                    }

                    if (showcooldowntimer)
                    {
                        if (ispowerup)
                        {
                            let currentmiscitempoweruptimer = Powerup(CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems + 2]));

                            if (currentmiscitempoweruptimer) { DrawString(GOHmHUDFont, "\c" .. currentmiscitemcolor .. FormatNumber(currentmiscitempoweruptimer.EffectTics / TICRATE, 1, 4), (coordbasex - 16, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT); }
                        } else {
                            let currentmiscitemtimer = CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems + 2]);

                            if (currentmiscitemtimer) { DrawString(GOHmHUDFont, "\c" .. currentmiscitemcolor .. FormatNumber(GetAmount(MiscItemDefinitions[checkedmiscitems + 2]) - 1, 1, 4), (coordbasex - 16, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_RIGHT); }
                        }
                    }

                    coordnudge.Y += 44 + (hascounter ? 24 : 0);
                }
            }
        }
    }

    // [tv50] yeah I know these changes aren't the best method, but they needed to be done
    void GOHDrawInventoryBar(InventoryBarState parms, Vector2 position, int numfields, int flags = 0, double bgalpha = 1.)
    {
        double width = parms.boxsize.X * numfields;
        [position, flags] = AdjustPosition(position, flags, width, parms.boxsize.Y);

        CPlayer.mo.InvFirst = ValidateInvFirst(numfields);

        if (!CPlayer.mo.InvFirst) { return; } // Player has no listed inventory items.

        Vector2 boxsize = parms.boxsize;
        int boxseparator = 11;

        // First draw all the boxes
        for (int i = 0; i < numfields; i++) { DrawTexture(TexMan.CheckForTexture("graphics/hud/" .. theme .. "/icons/goodolhud_icon_inventory_" .. colorschemebase .. ".png"), position + ((boxsize.X + boxseparator) * i, 0), flags, bgalpha); }

        // now the items and the rest
        Vector2 itempos = position + boxsize / 2;
        itempos += (-20, -34);

        Vector2 textpos = position + boxsize - (1, 1 + parms.amountfont.mFont.GetHeight());
        textpos += (-40, -70);

        parms.selectofs = (-9, -61);

        int i = 0;

        Inventory item;

        for (item = CPlayer.mo.InvFirst; item && i < numfields; item = item.NextInv())
        {
            for (int j = 0; j < 2; j++)
            {
                if (j ^ !!(flags & DI_DRAWCURSORFIRST))
                {
                    if (item == CPlayer.mo.InvSel)
                    {
                        double flashAlpha = bgalpha;

                        if (flags & DI_ARTIFLASH) { flashAlpha *= itemflashFade; }

                        if (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS)) { parms.selectofs.Y -= 15; }

                        DrawTexture(parms.selector, position + parms.selectofs + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_OFFSETS, flashAlpha);
                    }
                }
                else { DrawInventoryIcon(item, itempos + ((boxsize.X + boxseparator) * i, 0), flags|DI_DIMDEPLETED|DI_ITEM_CENTER, 1, (36, 30)); }
            }

            if (parms.amountfont && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS))) { DrawString(parms.amountfont, "\c" .. colorschemetext .. FormatNumber(item.Amount, 1, 5), textpos + ((boxsize.X + boxseparator) * i, 0), flags|DI_TEXT_ALIGN_CENTER, parms.cr, parms.itemalpha); }

            i++;
        }

        // Is there something to the left?
        if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst) { DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags|DI_ITEM_OFFSETS); }

        // Is there something to the right?
        if (item) { DrawTexture(parms.right, position + (parms.arrowoffset.X + 7, parms.arrowoffset.Y) + (width, 0), flags|DI_ITEM_OFFSETS); }
    }
}
