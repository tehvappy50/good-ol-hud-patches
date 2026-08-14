class GoodOlHUDStatusBar : BaseStatusBar
{
    HUDFont GOHmHUDFont;
    InventoryBarState GOHdiparms0, GOHdiparms1;
    int GOHtheme, GOHcolorscheme;

    const INT_MIN = 0x80000000;
    const INT_MAX = 0x7FFFFFFF;

    const CLASSCOUNT = 37;
    const ALTCLASSCOUNT = 5;

    const CLASS_DOOM = 0;
    const CLASS_CHEX = 1;
    const CLASS_HERETIC = 2;
    const CLASS_WOLFEN = 3;
    const CLASS_HEXEN = 4;
    const CLASS_DUKE = 5;
    const CLASS_MARATHON = 6;
    const CLASS_QUAKE = 7;
    const CLASS_ROTT = 8;
    const CLASS_BLAKE = 9;
    const CLASS_CALEB = 10;
    const CLASS_STRIFE = 11;
    const CLASS_ERAD = 12;
    const CLASS_C7 = 13;
    const CLASS_RMR = 14;
    const CLASS_KATARN = 15;
    const CLASS_POGREED = 16;
    const CLASS_DISRUPTOR = 17;
    const CLASS_WITCHAVEN = 18;
    const CLASS_HALFLIFE = 19;
    const CLASS_SW = 20;
    const CLASS_CM = 21;
    const CLASS_JON = 22;
    const CLASS_RR = 23;
    const CLASS_BITTERMAN = 24;
    const CLASS_DEMONESS = 25;
    const CLASS_BOND = 26;
    const CLASS_CATACOMB = 27;
    const CLASS_PAINKILLER = 28;
    const CLASS_UNREAL = 29;
    const CLASS_RTCW = 30;
    const CLASS_QUAKE3 = 31;
    const CLASS_DESCENT = 32;
    const CLASS_DEUSEX = 33;
    const CLASS_KINGPIN = 34;
    const CLASS_SOF = 35;
    const CLASS_OUTLAWS = 36;

    static const Name AltClassTokenDefinitions[] =
    {
        "DoomClassMode",
        "",
        "",
        "WolfenClassMode",
        "HexenClassMode",
        "DukeClassMode",
        "",
        "",
        "RottMode",
        "",
        "",
        "",
        "EradMode",
        "",
        "",
        "",
        "IpogMode",
        "",
        "",
        "HalfLifeOpposingForce",
        "",
        "",
        "",
        "",
        "",
        "",
        "BondClassMode",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
    };

    // this clearly can't be the most convenient way to do this
    static const Name ColorSchemeDefinitions[] =
    {
        "default",      "[Untranslated]", "[Gold]",        "[Blue]",
        "doom",         "[Red]",          "[White]",       "[Blue]",
        "freedoom",     "[Red]",          "[White]",       "[Blue]",
        "raven",        "[Yellow]",       "[White]",       "[Blue]",
        "strife",       "[Yellow]",       "[White]",       "[Blue]",
        "blasphemer",   "[Red]",          "[White]",       "[Blue]",
        "chex",         "[Yellow]",       "[White]",       "[Blue]",
        "harmony",      "[MiamiRetro]",   "[WhiteBorder]", "[BlueBorder]",
        "hacx",         "[Green]",        "[White]",       "[Blue]",
        "square",       "[Red]",          "[White]",       "[Blue]",
        "woolball",     "[White]",        "[Gold]",        "[Blue]",
        "psxdoom",      "[DarkRed]",      "[White]",       "[Blue]",
        "psxfinaldoom", "[Red]",          "[White]",       "[Blue]",
        "rekkr",        "[Yellow]",       "[White]",       "[Blue]",
        "wolf3d",       "[White]",        "[Gold]",        "[Blue]",
        "duke3d",       "[Orange]",       "[White]",       "[Blue]",
        "duke64",       "[LightBlue]",    "[White]",       "[Blue]",
        "marathon1",    "[Green]",        "[White]",       "[Blue]",
        "marathon2",    "[Green]",        "[White]",       "[Blue]",
        "quake1",       "[DarkBrown]",    "[White]",       "[Blue]"
    };

    String theme;
    String colorschemebase;
    String colorschemetext, colorschemeactivetext, colorschemeskulltagactivetext;
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

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

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

              case CLASS_DOOM:
                if (altclassnum == 2) { GOHcolorscheme = 12; } // use this for a darker base color for now
                else { GOHcolorscheme = 1; } // use this for doom 64's base as well, since the HUD in that game only had numbers to work with
                break;

              case CLASS_CHEX: GOHcolorscheme = 6; break;
              case CLASS_HERETIC: GOHcolorscheme = 3; break;

              case CLASS_WOLFEN:
                if (altclassnum == 2) { GOHcolorscheme = 1; } // similar; use that for now
                else { GOHcolorscheme = 14; }
                break;

              case CLASS_HEXEN: GOHcolorscheme = 3; break;

              case CLASS_DUKE:
                if (altclassnum == 2) { GOHcolorscheme = 16; }
                else { GOHcolorscheme = 15; }
                break;

              case CLASS_MARATHON: GOHcolorscheme = 18; break;
              case CLASS_QUAKE: GOHcolorscheme = 19; break;
              // the following reuse existing ones for now
              case CLASS_ROTT: GOHcolorscheme = 8; break;
              case CLASS_BLAKE: GOHcolorscheme = 14; break;
              case CLASS_CALEB: GOHcolorscheme = 1; break;
              case CLASS_STRIFE: GOHcolorscheme = 4; break;

              case CLASS_ERAD: // nothing made yet
              case CLASS_C7: // nothing made yet
              case CLASS_RMR: // nothing made yet
                GOHcolorscheme = 0;
                break;

              case CLASS_KATARN: GOHcolorscheme = 18; break;
              case CLASS_POGREED: GOHcolorscheme = 16; break;
              case CLASS_DISRUPTOR: GOHcolorscheme = 8; break;
              case CLASS_WITCHAVEN: GOHcolorscheme = 4; break;

              case CLASS_HALFLIFE:
                if (altclassnum == 1) { GOHcolorscheme = 8; }
                else { GOHcolorscheme = 15; }
                break;

              case CLASS_SW: GOHcolorscheme = 8; break;
              case CLASS_CM: GOHcolorscheme = 0; break; // nothing made yet
              case CLASS_JON: GOHcolorscheme = 15; break;
              case CLASS_RR: GOHcolorscheme = 19; break;
              case CLASS_BITTERMAN: GOHcolorscheme = 0; break; // nothing made yet
              case CLASS_DEMONESS: GOHcolorscheme = 3; break;
              case CLASS_BOND: GOHcolorscheme = 0; break; // nothing made yet
              case CLASS_CATACOMB: GOHcolorscheme = 4; break;
              case CLASS_PAINKILLER: GOHcolorscheme = 19; break;
              case CLASS_UNREAL: GOHcolorscheme = 18; break;

              case CLASS_RTCW: // nothing made yet
              case CLASS_QUAKE3: // nothing made yet
                GOHcolorscheme = 0;
                break;

              case CLASS_DESCENT: GOHcolorscheme = 18; break;

              case CLASS_DEUSEX: // nothing made yet
              case CLASS_KINGPIN: // nothing made yet
              case CLASS_SOF: // nothing made yet
              case CLASS_OUTLAWS: // nothing made yet
                GOHcolorscheme = 0;
                break;
            }
            break;

          case -1: GOHcolorscheme = 4; break;
        }

        GOHcolorscheme = GOHcolorscheme * 4;

        colorschemebase = ColorSchemeDefinitions[GOHcolorscheme];
        colorschemetext = ColorSchemeDefinitions[GOHcolorscheme + 1];
        colorschemeactivetext = ColorSchemeDefinitions[GOHcolorscheme + 2];
        colorschemeskulltagactivetext = ColorSchemeDefinitions[GOHcolorscheme + 3];

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

        // HUD hiding
        if (CPlayer.mo.FindInventory("BondWatchToken"))
        {
            if (isInventoryBarVisible())
            {
                let GOHdiparms = GOHdiparms0;

                switch (GOHtheme)
                {
                  case 1: GOHdiparms = GOHdiparms1; break;
                }

                GOHDrawInventoryBar(GOHdiparms, (-13, 30), 7, DI_SCREEN_CENTER_BOTTOM|(canalwaysshowinvcounter ? DI_ALWAYSSHOWCOUNTERS : 0));
            }

            return;
        }

        // "Background".
        coordnudge = (0, 0);

        // Katarn mask
        if (classnum == CLASS_KATARN && Powerup(CPlayer.mo.FindInventory("PowerIronFeetNoColor")))
        {
            coordbase = (-3 + coordnudge.X, 4 + coordnudge.Y);

            DrawImage("KYLEMSK1", coordbase, DI_SCREEN_CENTER_BOTTOM, 1, (-1, -1), (3.19791, 3.83333));
        }

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

        // Mugshot and character portrait
        let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid() && (classnum < 0 || classnum >= CLASSCOUNT);
        let canshowcharacterportrait = CVar.FindCVar("goh_samsara_showcharacterportrait").GetBool() && classnum >= 0 && classnum < CLASSCOUNT;

        if (canshowmugshot || canshowcharacterportrait)
        {
            GOHDrawMugShot(4 + coordnudge.X, -39 + coordnudge.Y);

            coordnudge.X += 43;
            powerupnudge.X += 43;
        }

        // Player stats
        let canshowstamina = CVar.FindCVar("goh_showstamina").GetBool() || classnum == CLASS_STRIFE;
        let canshowaccuracy = CVar.FindCVar("goh_showaccuracy").GetBool() || classnum == CLASS_STRIFE;

        if (canshowstamina || canshowaccuracy || classnum == CLASS_RR || classnum == CLASS_DEMONESS)
        {
            coordbase = (4 + coordnudge.X, -17 + coordnudge.Y);

            String rralcoholcolor = "[Yellow]", rrgutcolor = "[Yellow]";

            int rralcoholamt = GetAmount("RRDrunkAmount"), rrgutamt = GetAmount("RRFoodAmount");

            if (rralcoholamt >= 80) { rralcoholcolor = "[Red]"; }
            else if (rralcoholamt >= 70) { rralcoholcolor = "[Orange]"; }
            else if (rralcoholamt >= 40) { rralcoholcolor = "[Green]"; }

            if (rrgutamt >= 80) { rrgutcolor = "[Red]"; }
            else if (rrgutamt >= 70) { rrgutcolor = "[Orange]"; }
            else if (rrgutamt >= 40) { rrgutcolor = "[Green]"; }

            DrawString(GOHmHUDFont,
                       (canshowstamina ? "\c[Red]" .. StringTable.Localize("$GOODOLHUD_STAMINA") .. " " .. FormatNumber(classnum == CLASS_STRIFE ? GetAmount("StaminaUpgradeDamage") : CPlayer.mo.Stamina, 1, 3) .. " \c-" : "") ..
                       (canshowaccuracy ? "\c[Yellow]" .. StringTable.Localize("$GOODOLHUD_ACCURACY") .. " " .. FormatNumber(classnum == CLASS_STRIFE ? GetAmount("AccuracyUpgrade2") : CPlayer.mo.Accuracy, 1, 3) .. " \c-" : "") ..
                       (classnum == CLASS_RR ? "\c" .. rralcoholcolor .. StringTable.Localize("$GOODOLHUD_SAMSARA_RRALCOHOL") .. " " .. FormatNumber(rralcoholamt, 1, 3) .. " \c-" : "") ..
                       (classnum == CLASS_RR ? "\c" .. rrgutcolor .. StringTable.Localize("$GOODOLHUD_SAMSARA_RRGUT") .. " " .. FormatNumber(rrgutamt, 1, 3) .. " \c-" : "") ..
                       (classnum == CLASS_DEMONESS ? "\c[Yellow]" .. StringTable.Localize("$GOODOLHUD_SAMSARA_DEMONESSINTELLIGENCE") .. " " .. FormatNumber(GetAmount("Hexen2Intelligence"), 1, 3) .. " \c-" : "") ..
                       (classnum == CLASS_DEMONESS ? "\c[Green]" .. StringTable.Localize("$GOODOLHUD_SAMSARA_DEMONESSWISDOM") .. " " .. FormatNumber(GetAmount("Hexen2Wisdom"), 1, 3) .. " \c-" : "") ..
                       (classnum == CLASS_DEMONESS ? "\c[LightBlue]" .. StringTable.Localize("$GOODOLHUD_SAMSARA_DEMONESSDEXTERITY") .. " " .. FormatNumber(GetAmount("Hexen2Dexterity"), 1, 3) .. " \c-" : "") ..
                       (classnum == CLASS_DEMONESS ? "\c[Red]" .. StringTable.Localize("$GOODOLHUD_SAMSARA_DEMONESSSTRENGTH") .. " " .. FormatNumber(GetAmount("Hexen2Strength"), 1, 3) .. " \c-" : ""),
                       coordbase, DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Energy
        if (classnum == CLASS_DEUSEX)
        {
            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);
            int bioenergyamt, bioenergymaxamt;

            [bioenergyamt, bioenergymaxamt] = GetAmount("DeusEx_BioEnergy");

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_lightblue.png";
            DrawBar(bar, barblank, bioenergyamt, bioenergymaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_energyovermax1.png";
            DrawBar(bar, barblank, bioenergyamt - bioenergymaxamt, bioenergymaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_energyovermax2.png";
            DrawBar(bar, barblank, bioenergyamt - (bioenergymaxamt * 2), bioenergymaxamt, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_ENERGY"), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_LIGHTBLUE);

            DrawString(GOHmHUDFont, FormatNumber(bioenergyamt, 1, 4) .. (canshowmaxamounts ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(bioenergymaxamt, 1, 4) : ""), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_LIGHTBLUE);

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
            let totalarmor = 100 + GetAmount("SamsaraHasMaxArmor");

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
                String armorcolor = "brown";

                switch (armor.ArmorType)
                {
                  // Tier 1 armor
                  case 'BasicArmorBonus': // ArtiBoostArmor
                  case 'ArmorBonus':
                  case 'SlimeRepellent':
                  case 'ArmorScrapArmorNormal':
                  case 'ArmorScrap100':
                  case 'ArmorScrap200':
                  case 'InfiniteArmorBonus':
                  case 'MaxArmorScrapArmorNormal':
                  case 'ArmorScrapDumpArmorNormal':
                  case 'ArmorPackBonusLightArmorNormal':
                  case 'ArmorPackBonusHeavyArmorNormal':
                  case 'GreenArmor':
                  case 'ChexArmor':
                  case 'ArmorPack1ArmorNormal':
                  case 'StrifeArmorPack1ArmorNormal':
                    armorcolor = "green";
                    break;

                  case 'ArmorScrapArmorHeretic':
                  case 'MaxArmorScrapArmorHeretic':
                  case 'ArmorScrapDumpArmorHeretic':
                  case 'ArmorPackBonusLightArmorHeretic':
                  case 'ArmorPackBonusHeavyArmorHeretic':
                  case 'SilverShield':
                  case 'ArmorPack1ArmorHeretic':
                  case 'StrifeArmorPack1ArmorHeretic':
                    armorcolor = "silver";
                    break;

                  case 'ArmorScrapArmorQuake':
                  case 'MaxArmorScrapArmorQuake':
                  case 'ArmorScrapDumpArmorQuake':
                  case 'ArmorPackBonusLightArmorQuake':
                  case 'ArmorPackBonusHeavyArmorQuake':
                  case 'ArmorPack1ArmorQuake':
                  case 'StrifeArmorPack1ArmorQuake':
                    armorcolor = "olive";
                    break;

                  case 'ArmorScrapArmorMarathon':
                  case 'MaxArmorScrapArmorMarathon':
                  case 'ArmorScrapDumpArmorMarathon':
                  case 'ArmorPackBonusLightArmorMarathon':
                  case 'ArmorPackBonusHeavyArmorMarathon':
                  case 'ArmorPack1ArmorMarathon':
                  case 'StrifeArmorPack1ArmorMarathon':
                    armorcolor = "red";
                    break;

                  // Tier 2 armor
                  case 'ArmorScrapArmorQuakePlus':
                  case 'MaxArmorScrapArmorQuakePlus':
                  case 'ArmorScrapDumpArmorQuakePlus':
                  case 'ArmorPackBonusLightArmorQuakePlus':
                  case 'ArmorPackBonusHeavyArmorQuakePlus':
                  case 'YellowArmor':
                  case 'ArmorPack2ArmorNormal':
                  case 'ArmorPack2ArmorQuake':
                  case 'StrifeArmorPack3ArmorQuakeTier2Inactive':
                  case 'StrifeArmorPack1ArmorQuakePlus':
                  case 'ArmorPack2ArmorHeretic':
                    armorcolor = "yellow";
                    break;

                  case 'ArmorPack2ArmorMarathon': armorcolor = "orange"; break;

                  // Tier 3 armor
                  case 'BlueArmor':
                  case 'BlueArmorForMegasphere':
                  case 'SuperChexArmor':
                  case 'ArmorPack3ArmorNormal':
                  case 'StrifeArmorPack3ArmorNormal':
                  case 'FuckArmor':
                    armorcolor = "blue";
                    break;

                  case 'EnchantedShield': armorcolor = "gold"; break;

                  case 'BasicArmorPickup': // cheat
                  case 'MetalArmor':
                    armorcolor = "silver";
                    break;

                  case 'ArmorPack3ArmorQuake':
                  case 'StrifeArmorPack3ArmorQuakeTier2Active':
                  case 'StrifeArmorPack3ArmorQuakePlusTier2Inactive':
                    armorcolor = "red";
                    break;

                  case 'ArmorPack3ArmorMarathon':
                  case 'StrifeArmorPack3ArmorMarathon':
                    armorcolor = "yellow";
                    break;

                  case 'ArmorPack3ArmorHeretic':
                  case 'StrifeArmorPack3ArmorHeretic':
                    armorcolor = "orange";
                    break;

                  // Tier 4 armor
                  case 'RedArmor':
                  case 'ArmorPack4ArmorNormal':
                  case 'ArmorPack4ArmorHeretic':
                    armorcolor = "red";
                    break;

                  case 'ArmorPack4ArmorQuake':
                  case 'StrifeArmorPack3ArmorQuakePlusTier2Active':
                    armorcolor = "silver";
                    break;

                  case 'ArmorPack4ArmorMarathon': armorcolor = "brick"; break;

                  // Tier 5 armor
                  case 'SilverArmor':
                  case 'ArmorPack5ArmorNormal':
                    armorcolor = "silver";
                    break;

                  case 'ArmorPack5ArmorMarathon': armorcolor = "pink"; break;
                  case 'ArmorPack5ArmorHeretic': armorcolor = "brick"; break;

                  // Other armor
                  case 'TotenkopfPowerArmorKeeper':
                  case 'TotenkopfPowerArmorPickup':
                    armorcolor = "cyan";
                    break;

                  case 'DukeArmorArmor': armorcolor = "darkgray"; break;
                  case 'WHAdamantineRingArmor': armorcolor = "gray"; break;
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

        let canshowberserk = CVar.FindCVar("goh_showberserk").GetInt() && Powerup(CPlayer.mo.FindInventory("PowerStrength"));
        let cancolorhealth = CVar.FindCVar("goh_colorhealthoninvuln").GetBool() && (isInvulnerable() || Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")) || Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerableCleric")) ||
                                                                                    Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerableMage")) || Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerableFighter")) || Powerup(CPlayer.mo.FindInventory("QuakePentagram")) ||
                                                                                    Powerup(CPlayer.mo.FindInventory("PowerGodProtection")) || Powerup(CPlayer.mo.FindInventory("PowerDoggyMorph")) || Powerup(CPlayer.mo.FindInventory("Painkiller_IronWill_Protection")) ||
                                                                                    Powerup(CPlayer.mo.FindInventory("PainkillerDemonMorphInvulnerability")));
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

        // Level and experience
        if (classnum == CLASS_WITCHAVEN || classnum == CLASS_DEMONESS)
        {
            coordbase = (99 + coordnudge.X, -4 + coordnudge.Y);
            int currentlevel, maxlevel;
            int experienceamount, experiencereqamount, experienceoffset;

            switch (classnum)
            {
              case CLASS_WITCHAVEN:
                [currentlevel, maxlevel] = GetAmount("WTLevel");
                experienceamount = GetAmount("WTExperience");

                if (currentlevel >= maxlevel) { experiencereqamount = 10000 * (currentlevel - 1); }
                else
                {
                    experiencereqamount = 10000 * currentlevel;
                    if (currentlevel > 1) { experienceoffset = 10000 * (currentlevel - 1); }
                }
                break;

              case CLASS_DEMONESS:
                [currentlevel, maxlevel] = GetAmount("Hexen2Level");
                experienceamount = GetAmount("Hexen2Experience");

                int Hexen2XPRequirementAmounts[] =
                {
                    871,
                    2060,
                    4822,
                    9319,
                    19278,
                    36626,
                    66804,
                    110494,
                    141334,
                    192700,
                    385400
                };

                if (currentlevel >= maxlevel) { experiencereqamount = Hexen2XPRequirementAmounts[10] + (192700 * (currentlevel - 12)); }
                else if (currentlevel >= 12)
                {
                    experiencereqamount = Hexen2XPRequirementAmounts[10] + (192700 * (currentlevel - 11));
                    experienceoffset = Hexen2XPRequirementAmounts[10] + (192700 * (currentlevel - 12));
                } else {
                    experiencereqamount = Hexen2XPRequirementAmounts[currentlevel - 1];
                    if (currentlevel > 1) { experienceoffset = Hexen2XPRequirementAmounts[currentlevel - 2]; }
                }
                break;
            }

            int experiencenextamount = clamp(-(experiencereqamount - experienceamount), INT_MIN, 0);

            DrawImage(barbase, coordbase, DI_SCREEN_LEFT_BOTTOM);

            bar = "graphics/hud/" .. theme .. "/bars/goodolhud_bar_teal.png";
            DrawBar(bar, barblank, experienceamount - experienceoffset, experiencereqamount - experienceoffset, (coordbase.X, coordbase.Y - 1), 0, SHADER_HORZ, DI_SCREEN_LEFT_BOTTOM);

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_EXPERIENCE" .. ((canshowmugshot || canshowcharacterportrait) && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_TEAL);

            DrawString(GOHmHUDFont,
                       FormatNumber(CVar.FindCVar("goh_showxptonextlevel").GetBool() ? experiencenextamount : experienceamount, 1, 10) .. (canshowmaxamounts && currentlevel < maxlevel ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(experiencereqamount, 1, 10) : "") ..
                       " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. FormatNumber(currentlevel, 1, 4) .. StringTable.Localize("$GOODOLHUD_EXTRA_END"),
                       (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_TEAL);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

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

            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_HAZARD" .. ((canshowmugshot || canshowcharacterportrait) && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbase.X - 79, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_DARKGREEN);

            DrawString(GOHmHUDFont, String.Format("%.1f", hazardcountamt * 100.0 / hazardcountmaxamt) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE"), (coordbase.X + 77, coordbase.Y - 14), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_DARKGREEN);

            bottomleftvertelements++;

            coordnudge.Y -= 16;
            powerupnudge.Y -= 16;
        }

        // Bottom center.
        coordnudge = (0, 0);

        // Descent missile camera
        if (classnum == CLASS_DESCENT)
        {
            if (isInventoryBarVisible() && CPlayer.mo.InvSel) { coordnudge.Y -= 80; }

            coordbase = (0 + coordnudge.X, -4 + coordnudge.Y);
            Vector2 camerascale = (3.046875, 2.578125);

            String cameraname;

            if (CPlayer.mo.FindInventory("DescentMissileCamera")) { cameraname = "DSMISCAM"; }
            else if (CPlayer.mo.FindInventory("DescentMissileStaticToken")) { cameraname = "DESSTAT1"; }

            if (cameraname != "") { DrawImage(cameraname, coordbase, DI_SCREEN_CENTER_BOTTOM, 1, (-1, -1), camerascale); }
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
        coordbase = (-226 + coordnudge.X, -17); // coordnudge.Y handled in the display

        if (classnum == CLASS_PAINKILLER)
        {
            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_GOLD") .. FormatNumber(GetAmount("Painkiller_GoldAmount"), 1, 10), (coordbase.X, (coordbase.Y + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GOLD);

            coordnudge.Y -= 16;
        }

        if (classnum == CLASS_KINGPIN)
        {
            DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_SAMSARA_KINGPINCASH") .. FormatNumber(GetAmount("Kingpin_Cash"), 1, 10), (coordbase.X, (coordbase.Y + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_DARKGREEN);

            coordnudge.Y -= 16;
        }

        if (CVar.FindCVar("goh_showcoincounter").GetBool()) { DrawString(GOHmHUDFont, StringTable.Localize("$GOODOLHUD_MONEY") .. FormatNumber(GetAmount("Coin"), 1, 10), (coordbase.X, (coordbase.Y + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT, Font.CR_GREEN); }

        // reset nudging at this point
        coordnudge = (0 - (24 * canshowmaxamounts), 0 - (16 * weaponnameamount));

        // Selected inventory
        coordbase = (-250 + coordnudge.X, -4 + coordnudge.Y);

        let showingcurrentitem = !isInventoryBarVisible() && !Level.NoInventoryBar && CPlayer.mo.InvSel;
        bool showingitempercentage = false;

        if (showingcurrentitem)
        {
            switch (CPlayer.mo.InvSel.GetClassName())
            {
              case 'CalebDoctorsBag':
              case 'RRCheapasswhiskey':
                showingitempercentage = true;
                break;
            }

            DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_inventory_" .. colorschemebase .. ".png", coordbase, DI_SCREEN_RIGHT_BOTTOM);

            DrawInventoryIcon(CPlayer.mo.InvSel, (coordbase.X, coordbase.Y - 17), DI_DIMDEPLETED|DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_CENTER, 1, (36, 30));

            DrawString(GOHmHUDFont, CPlayer.mo.InvSel.Amount > 1 || canalwaysshowinvcounter || showingitempercentage ? "\c" .. colorschemetext .. (showingitempercentage ? (FormatNumber(CPlayer.mo.InvSel.Amount * 100.0 / CPlayer.mo.InvSel.MaxAmount, 1, 3) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE")) : FormatNumber(CPlayer.mo.InvSel.Amount, 1, 5)) : "", (coordbase.X - 1, coordbase.Y - 50), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_CENTER);
        }

        // Weapon bar
        if (CVar.FindCVar("goh_showweaponbar").GetBool()) { GOHDrawWeaponBar(-382 + coordnudge.X, -17 + coordnudge.Y); }

        // Cooldown timers
        GOHDrawCooldownTimers((-250 - 1) + coordnudge.X, (-4 + 3) - (showingcurrentitem ? 37 + (CPlayer.mo.InvSel.Amount > 1 || canalwaysshowinvcounter || showingitempercentage ? 16 : 0) : 0) + coordnudge.Y, (-382 + 4) + coordnudge.X, -17 + coordnudge.Y);

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

        // New fullscreen HUD warning
        switch (classnum)
        {
          case CLASS_ROTT:
          case CLASS_HALFLIFE:
          case CLASS_BOND:
          case CLASS_PAINKILLER:
          case CLASS_QUAKE3:
          case CLASS_DESCENT:
          case CLASS_DEUSEX:
          case CLASS_KINGPIN:
          case CLASS_SOF:
          case CLASS_OUTLAWS:
            coordbase = (0 + coordnudge.X, 0 + coordnudge.Y);

            if (CPlayer.mo.FindInventory("SamsaraUsingNewFullscreenHUD")) { DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_WARNING_SAMSARA_NEWFULLSCREENHUD"), coordbase, DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER); }
            break;
        }
    }

    protected virtual void GOHDrawPlayerName(int coordbasex, int coordbasey)
    {
        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        let canshowcharactername = CVar.FindCVar("goh_samsara_showcharactername").GetBool() && classnum >= 0 && classnum < CLASSCOUNT;

        // if you're bypassing 255, you're just asking for a crash anyway. let the VM abort serve as a warning
        let teamcolor = !CVar.FindCVar("goh_playernameteamcolor").GetBool() || !teamplay || CPlayer.GetTeam() == 255 ? Font.CR_UNTRANSLATED : Teams[CPlayer.GetTeam()].GetTextColor();

        static const Name CharacterNameDefinitions[] =
        {
            "DOOMGUY_BASE",      "DOOMGUY", "DOOMGUY_BASE", "DOOMGUY64",     "DOOMGUY_BASE", "DOOMGUYSTR", "",                 "", "",           "",
            "CHEX",              "",        "",             "",              "",             "",           "",                 "", "",           "",
            "CORVUS",            "",        "",             "",              "",             "",           "",                 "", "",           "",
            "BJ_BASE",           "BJ",      "BJ_BASE",      "BJLOST",        "BJ_BASE",      "BJCTK",      "",                 "", "",           "",
            "PARIAS_BASE",       "PARIAS",  "PARIAS_BASE",  "PARIASCLASSIC", "DAEDOLON",     "",           "BARATUS",          "", "",           "",
            "DUKE_BASE",         "DUKE",    "DUKE_BASE",    "DUKELAB",       "DUKE_BASE",    "DUKE64",     "",                 "", "",           "",
            "SO",                "",        "",             "",              "",             "",           "",                 "", "",           "",
            "RANGER",            "",        "",             "",              "",             "",           "",                 "", "",           "",
            "FREELEY",           "",        "CASSATT",      "",              "BARRETT",      "",           "NI",               "", "WENDT",      "",
            "BLAKE",             "",        "",             "",              "",             "",           "",                 "", "",           "",
            "CALEB",             "",        "",             "",              "",             "",           "",                 "", "",           "",
            "STRIFEGUY",         "",        "",             "",              "",             "",           "",                 "", "",           "",
            "ELEENA",            "",        "KAMCHAK",      "",              "DANBLAZE",     "",           "ALLIANCECOMMANDO", "", "",           "",
            "SPACESEAL",         "",        "",             "",              "",             "",           "",                 "", "",           "",
            "REBELMOONCOMMANDO", "",        "",             "",              "",             "",           "",                 "", "",           "",
            "KATARN",            "",        "",             "",              "",             "",           "",                 "", "",           "",
            "MOOMAN",            "",        "CYBORG",       "",              "LIZARDMAN",    "",           "MUTANT",           "", "DOMINATRIX", "",
            "DISRUPTOR",         "",        "",             "",              "",             "",           "",                 "", "",           "",
            "GRONDOVAL",         "",        "",             "",              "",             "",           "",                 "", "",           "",
            "FREEMAN",           "",        "SHEPHARD",     "",              "",             "",           "",                 "", "",           "",
            "WANG",              "",        "",             "",              "",             "",           "",                 "", "",           "",
            "CM",                "",        "",             "",              "",             "",           "",                 "", "",           "",
            "JON",               "",        "",             "",              "",             "",           "",                 "", "",           "",
            "RR",                "",        "",             "",              "",             "",           "",                 "", "",           "",
            "Q2",                "",        "",             "",              "",             "",           "",                 "", "",           "",
            "DEMONESS",          "",        "",             "",              "",             "",           "",                 "", "",           "",
            "BOND_BASE",         "BOND",    "BOND_BASE",    "BONDGF",        "",             "",           "",                 "", "",           "",
            "PETTON",            "",        "",             "",              "",             "",           "",                 "", "",           "",
            "DANIEL",            "",        "",             "",              "",             "",           "",                 "", "",           "",
            "PRISONER",          "",        "",             "",              "",             "",           "",                 "", "",           "",
            "RTCW_BASE",         "RTCW",    "",             "",              "",             "",           "",                 "", "",           "",
            "SARGE",             "",        "",             "",              "",             "",           "",                 "", "",           "",
            "PYROGX",            "",        "",             "",              "",             "",           "",                 "", "",           "",
            "JCDENTON",          "",        "",             "",              "",             "",           "",                 "", "",           "",
            "KINGPIN",           "",        "",             "",              "",             "",           "",                 "", "",           "",
            "SOF",               "",        "",             "",              "",             "",           "",                 "", "",           "",
            "ANDERSON",          "",        "",             "",              "",             "",           "",                 "", "",           ""
        };

        String charactername, altcharactername;

        if (canshowcharactername)
        {
            if (CharacterNameDefinitions[((classnum * ALTCLASSCOUNT) * 2) + (altclassnum * 2)] != "") { charactername = "$GOODOLHUD_CHARACTER_SAMSARA_" .. CharacterNameDefinitions[((classnum * ALTCLASSCOUNT) * 2) + (altclassnum * 2)]; }
            if (CharacterNameDefinitions[((classnum * ALTCLASSCOUNT) * 2) + (altclassnum * 2 + 1)] != "") { altcharactername = "$GOODOLHUD_CHARACTER_SAMSARA_" .. CharacterNameDefinitions[((classnum * ALTCLASSCOUNT) * 2) + (altclassnum * 2 + 1)]; }
        }

        DrawString(GOHmHUDFont,
                   (teamcolor == Font.CR_UNTRANSLATED ? "\c" .. colorschemetext : "") ..
                   (canshowcharactername ? StringTable.Localize(charactername) .. (altcharactername != "" ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize(altcharactername) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : "") : CPlayer.GetUserName()),
                   (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT, teamcolor);
    }

    protected virtual void GOHDrawMugShot(int coordbasex, int coordbasey)
    {
        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        let canshowcharacterportrait = CVar.FindCVar("goh_samsara_showcharacterportrait").GetBool() && classnum >= 0 && classnum < CLASSCOUNT;

        static const Name CharacterPortraitDefinitions[] =
        {
          "DOOM", "DG64", "DOOM", "",     "",
          "CHEX", "",     "",     "",     "",
          "CORV", "",     "",     "",     "",
          "WOLF", "WOL2", "WOL3", "",     "",
          "HEXN", "HEXN", "HEXM", "HEXF", "",
          "DUKE", "DLAB", "DUKE", "",     "",
          "MARA", "",     "",     "",     "",
          "QUAK", "",     "",     "",     "",
          "ROTT", "TCAS", "TBAR", "LLNI", "DOUG",
          "BSTN", "",     "",     "",     "",
          "BLOD", "",     "",     "",     "",
          "STRF", "",     "",     "",     "",
          "ERAD", "ERA2", "ERA3", "ERA4", "",
          "COR7", "",     "",     "",     "",
          "RMR",  "",     "",     "",     "",
          "KYLE", "",     "",     "",     "",
          "IPOG", "IPO2", "IPO3", "IPO4", "IPO5",
          "JACK", "",     "",     "",     "",
          "WTCH", "",     "",     "",     "",
          "FREE", "SHEP", "",     "",     "",
          "WANG", "",     "",     "",     "",
          "CMDA", "",     "",     "",     "",
          "PSEX", "",     "",     "",     "",
          "LEON", "",     "",     "",     "",
          "BITT", "",     "",     "",     "",
          "HEX2", "",     "",     "",     "",
          "BOND", "FING", "",     "",     "",
          "EVER", "",     "",     "",     "",
          "PAIN", "",     "",     "",     "",
          "P849", "",     "",     "",     "",
          "RTCW", "",     "",     "",     "",
          "Q3SG", "",     "",     "",     "",
          "PYRO", "",     "",     "",     "",
          "DENT", "",     "",     "",     "",
          "THUG", "",     "",     "",     "",
          "JMUL", "",     "",     "",     "",
          "JAME", "",     "",     "",     ""
        };

        DrawImage("graphics/hud/" .. theme .. "/icons/goodolhud_icon_mugshot_" .. colorschemebase .. ".png", (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

        if (canshowcharacterportrait)
        {
            String characterportrait = "TPCH" .. CharacterPortraitDefinitions[(classnum * ALTCLASSCOUNT) + altclassnum];

            let [portraitw, portraith] = TexMan.GetSize(TexMan.CheckForTexture(characterportrait));

            DrawImage(characterportrait, (coordbasex + 19.5, coordbasey + 33), DI_SCREEN_LEFT_BOTTOM, 1, (-1, -1), (35.0 / portraitw, 31.0 / portraith));
        }
        else { DrawTexture(GetMugShot(5), (coordbasex + 19.6, coordbasey + 17.5), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_CENTER, 1, (35, 31)); }
    }

    bool haspowerup;

    protected virtual void GOHDrawPowerupTimers(int coordbasex, int coordbasey)
    {
        int maxpowerups = 60 * 3;

        static const Name PowerupDefinitions[] =
        {
            "PowerInvulnerable",                     "white",     "[White]", // respawn protection
            "PowerFakeInvulnerable",                 "white",     "[White]",
            "PowerFakeInvulnerableCleric",           "white",     "[White]",
            "PowerFakeInvulnerableMage",             "white",     "[White]",
            "PowerFakeInvulnerableFighter",          "white",     "[White]",
            "PowerGodProtection",                    "white",     "[White]",
            "PowerDoggyMorph",                       "white",     "[White]",
            "WTSuperProtection",                     "tan",       "[TanBorder]",
            "WTSuperProtection_Coop",                "tan",       "[TanBorder]",
            "PowerSamsaraDefenseBooster",            "tan",       "[Tan]",
            "PowerWolfLifeProtection",               "sapphire",  "[BlueBorder]", // that text color will do for now
            "BStoneProtection",                      "sapphire",  "[BlueBorder]", // that text color will do for now
            "PowerIPOGCharge",                       "lightblue", "[BlueBorder]",
            "PowerBulletProofVest",                  "lightblue", "[BlueBorder]",
            "PowerWTFireProof",                      "orange",    "[OrangeBorder]",
            "PowerAsbestosArmor",                    "darkgray",  "[Inversion]",
            "PowerMask",                             "green",     "[EmeraldOre]", // different text color for strife coexistence
            "PowerIronFeet",                         "green",     "[Green]",
            "PowerIronFeetNoColor",                  "green",     "[Green]",
            "PowerReversoPillGain",                  "white",     "[WhiteBorder]",
            "PowerSamsaraDamageBooster",             "darkred",   "[DarkRed]",
            "PowerSamsaraBloodGunsAkimboQuadDamage", "darkgray",  "[Inversion]",
            "PowerSheriffsBadgePower",               "darkgray",  "[Inversion]", // also gives damage resistance
            "PowerSamsaraLesserTome",                "red",       "[Red]",
            "PowerQ2DoubleDamage",                   "yellow",    "[YellowBorder]",
            "WTStrength",                            "green",     "[GreenBorder]",
            "PowerQuackQuarterDamage",               "cyan",      "[Cyan]",
            "PowerCatacomb_FireRing",                "cyan",      "[BlueBorder]", // that text color will do for now
            "PowerSamsaraDoomguyStrWeaponPower",     "red",       "[RubyOre]", // different text color for heretic coexistence
            "PowerHereticTome",                      "red",       "[RubyOre]", // different text color for heretic coexistence
            "PowerSamsaraHexenWeaponLevel2",         "red",       "[RubyOre]", // different text color for heretic coexistence
            "PowerSamsaraBloodGunsAkimbo",           "red",       "[RubyOre]", // different text color for heretic coexistence
            "PowerEradEnWP",                         "red",       "[RubyOre]", // different text color for heretic coexistence
            "PowerHexen2WeaponLevel2",               "red",       "[RubyOre]", // different text color for heretic coexistence
            "PowerCatacomb_SpreadShot",              "green",     "[GreenBorder]",
            "PowerDoubleFiringSpeed",                "tan",       "[TanBorder]",
            "PowerCatacomb_RapidFire",               "purple",    "[PurpleBorder]",
            "PowerCatacomb_BounceShot",              "orange",    "[OrangeBorder]",
            "PowerTimeFreezer",                      "gold",      "[Gold]",
            "PowerCatacomb_TimeFreeze",              "gold",      "[Gold]",
            "PowerSamsaraFlight",                    "yellow",    "[Yellow]",
            "PowerSamsaraFlightRaven",               "yellow",    "[Yellow]",
            "PowerRMRFlyAbilityHack",                "yellow",    "[Yellow]",
            "PowerWTSpellFlyHack",                   "yellow",    "[Yellow]",
            "PowerSamsaraSpeedBoots",                "orange",    "[Orange]",
            "PowerSamsaraSpeedBootsRaven",           "orange",    "[Orange]",
            "PowerSamsaraSpeedBooster",              "purple",    "[Purple]",
            "PowerScanner",                          "black",     "[Black]",
            "PowerLightAmp",                         "brick",     "[Brick]",
            "PowerTorch",                            "fire",      "[Fire]",
            "PowerSilencer",                         "darkgray",  "[Inversion]",
            "PowerFrightener",                       "lightblue", "[LightBlue]", // also used for a mixer item
            "PowerSamsaraFullInvisibilityGhost",     "darkgray",  "[DarkGray]",
            "PowerGhost",                            "gray",      "[Gray]",
            "PowerSamsaraFullInvisibilityShadow",    "darkgray",  "[Meteallic]", // different text color for strife coexistence
            "PowerShadow",                           "gray",      "[MetalSilver]", // different text color for strife coexistence
            "PowerSamsaraFullInvisibility",          "darkgray",  "[DarkGray]",
            "PowerInvisibility",                     "gray",      "[Gray]",
            "PowerTargeter",                         "yellow",    "[MetalGold]", // different text color for strife coexistence
            "PowerMinotaur",                         "darkbrown", "[DarkBrown]"
        };

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        int checkedpowerups = 0, activepowerups = 0;

        for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
        {
            let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

            switch (PowerupDefinitions[checkedpowerups])
            {
              default:
                if (!currentpowerup) { continue; }
                break;

              case 'PowerFakeInvulnerable':
                if (!currentpowerup || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")))) { continue; }
                break;

              case 'PowerIronFeetNoColor':
                if (!currentpowerup || classnum == CLASS_QUAKE3) { continue; }
                break;

              case 'PowerQ2DoubleDamage':
                if (!currentpowerup || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")) && !Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")) && !Powerup(CPlayer.mo.FindInventory("PowerDoubleFiringSpeed")))) { continue; }
                break;

              case 'PowerDoubleFiringSpeed':
                if (!currentpowerup || classnum != CLASS_BITTERMAN || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")) && !Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")))) { continue; }
                break;

              case 'PowerTimeFreezer':
                if (!currentpowerup || (classnum == CLASS_RR && CPlayer.mo.FindInventory("BubbaGivesYouMotorcycle")) || (classnum == CLASS_BOND && CPlayer.mo.FindInventory("BondWatchActivate") && !multiplayer && !deathmatch)) { continue; }
                break;

              case 'PowerFlight':
                if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                break;

              case 'PowerSamsaraFlight':
              case 'PowerSamsaraFlightRaven':
                if (!currentpowerup || Powerup(CPlayer.mo.FindInventory("PowerSamsaraFlightInfiniteHUDDummy"))) { continue; }
                break;

              case 'PowerLightAmp':
                if (!currentpowerup || classnum == CLASS_DUKE || classnum == CLASS_CALEB) { continue; }
                break;

              case 'PowerSilencer':
                if (!currentpowerup || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")) && !Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")) && !Powerup(CPlayer.mo.FindInventory("PowerDoubleFiringSpeed")) &&
                                                                       !Powerup(CPlayer.mo.FindInventory("PowerQ2DoubleDamage"))))
                { continue; }
                break;
            }

            activepowerups++;
        }

        if (activepowerups > 0)
        {
            Vector2 powerup = (coordbasex + 6, coordbasey);

            int currentpowerupnum = 0;

            bottomleftverttimerrows++;

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid() && (classnum < 0 || classnum >= CLASSCOUNT);
            let canshowcharacterportrait = CVar.FindCVar("goh_samsara_showcharacterportrait").GetBool() && classnum >= 0 && classnum < CLASSCOUNT;

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_POWERUPS" .. ((canshowmugshot || canshowcharacterportrait) && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

            for (checkedpowerups = 0; checkedpowerups < maxpowerups; checkedpowerups += 3)
            {
                let currentpowerup = Powerup(CPlayer.mo.FindInventory(PowerupDefinitions[checkedpowerups]));

                switch (PowerupDefinitions[checkedpowerups])
                {
                  default:
                    if (!currentpowerup) { continue; }
                    break;

                  case 'PowerFakeInvulnerable':
                    if (!currentpowerup || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")))) { continue; }
                    break;

                  case 'PowerIronFeetNoColor':
                    if (!currentpowerup || classnum == CLASS_QUAKE3) { continue; }
                    break;

                  case 'PowerQ2DoubleDamage':
                    if (!currentpowerup || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")) && !Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")) && !Powerup(CPlayer.mo.FindInventory("PowerDoubleFiringSpeed")))) { continue; }
                    break;

                  case 'PowerDoubleFiringSpeed':
                    if (!currentpowerup || classnum != CLASS_BITTERMAN || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")) && !Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")))) { continue; }
                    break;

                  case 'PowerTimeFreezer':
                    if (!currentpowerup || (classnum == CLASS_RR && CPlayer.mo.FindInventory("BubbaGivesYouMotorcycle")) || (classnum == CLASS_BOND && CPlayer.mo.FindInventory("BondWatchActivate") && !multiplayer && !deathmatch)) { continue; }
                    break;

                  case 'PowerFlight':
                    if (!currentpowerup || (!multiplayer && Level.infinite_flight)) { continue; }
                    break;

                  case 'PowerSamsaraFlight':
                  case 'PowerSamsaraFlightRaven':
                    if (!currentpowerup || Powerup(CPlayer.mo.FindInventory("PowerSamsaraFlightInfiniteHUDDummy"))) { continue; }
                    break;

                  case 'PowerLightAmp':
                    if (!currentpowerup || classnum == CLASS_DUKE || classnum == CLASS_CALEB) { continue; }
                    break;

                  case 'PowerSilencer':
                    if (!currentpowerup || (classnum == CLASS_BITTERMAN && !Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage")) && !Powerup(CPlayer.mo.FindInventory("PowerFakeInvulnerable")) && !Powerup(CPlayer.mo.FindInventory("PowerDoubleFiringSpeed")) &&
                                                                           !Powerup(CPlayer.mo.FindInventory("PowerQ2DoubleDamage"))))
                    { continue; }
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
        int maxstatuses = 11 * 3;

        static const Name StatusDefinitions[] =
        {
            "PoisonCount",                              "darkgreen", "[DarkGreen]",
            "PowerHieroWeaken",                         "cyan",      "[Cyan]",
            "PowerHieroAmpDMG",                         "red",       "[Red]",
            "PowerDeusEx_StunDamage",                   "tan",       "[TanBorder]",
            "PowerHieroSlow",                           "yellow",    "[Yellow]",
            "NothingSpeed",                             "white",     "[WhiteBorder]",
            "PowerSamsaraDoomguyStrStunnerSpeedDebuff", "purple",    "[PurpleBorder]",
            "ChickenPlayer",                            "white",     "[White]", // Morphs don't have a Powerup actor; handle them differently as a result
            "PigPlayer",                                "brown",     "[Brown]",
            "Hexen2SheepPlayer",                        "gray",      "[Gray]",
            "ShrunkPlayer",                             "green",     "[Green]"
        };

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

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
              case 'Hexen2SheepPlayer':
                if (!(morphclass is StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }
                break;

              case 'ShrunkPlayer':
                if (!CPlayer.mo.FindInventory(StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }
                break;
            }

            activestatuses++;
        }

        if (activestatuses > 0)
        {
            Vector2 status = (coordbasex + 6, coordbasey);

            int currentstatusnum = 0;

            bottomleftverttimerrows++;

            let canshowmugshot = CVar.FindCVar("goh_showmugshot").GetBool() && GetMugShot(5).IsValid() && (classnum < 0 || classnum >= CLASSCOUNT);
            let canshowcharacterportrait = CVar.FindCVar("goh_samsara_showcharacterportrait").GetBool() && classnum >= 0 && classnum < CLASSCOUNT;

            DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize("$GOODOLHUD_STATUS" .. ((canshowmugshot || canshowcharacterportrait) && bottomleftvertelements >= 2 ? "" : "_SHORT")), (coordbasex, coordbasey), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

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
                  case 'Hexen2SheepPlayer':
                    if (!(morphclass is StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }

                    checkingmorph = true;
                    break;

                  case 'ShrunkPlayer':
                    if (!CPlayer.mo.FindInventory(StatusDefinitions[checkedstatuses]) || CPlayer.MorphTics <= 0) { continue; }

                    checkingmorph = true;
                    break;
                }

                currentstatusnum++;

                DrawImage(bottomleftverttimerrows == 1 && ((currentstatusnum <= 1 && TexMan.CheckForTexture(timerbaseleft).IsValid()) || (currentstatusnum == 7 && TexMan.CheckForTexture(timerbaseright).IsValid())) ? (currentstatusnum <= 1 ? timerbaseleft : timerbaseright) : timerbase, status, DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawImage("graphics/hud/" .. theme .. "/timers/goodolhud_timer_" .. StatusDefinitions[checkedstatuses + 1] .. ".png", (status.X + 2, status.Y + 2), DI_SCREEN_LEFT_BOTTOM|DI_ITEM_OFFSETS);

                DrawString(GOHmHUDFont, "\c" .. StatusDefinitions[checkedstatuses + 2] .. FormatNumber(checkingpoison && CPlayer.PoisonCount > 0 ? (CPlayer.PoisonCount - 5) / 10 : checkingmorph && CPlayer.MorphTics > 0 ? (CPlayer.MorphTics - (StatusDefinitions[checkedstatuses] == "ShrunkPlayer" ? TICRATE * 3 : 0)) / TICRATE : currentstatus.EffectTics / TICRATE, 1, 4), (status.X + 6, status.Y - 16), DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_CENTER);

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

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        let vanillaquake = CPlayer.mo.FindInventory("QuakeModeOn");

        Name weaponname;

        String weaponalttag, weaponmode;
        String descentweapon1, descentweapon2;

        Inventory currentmode;
        bool usingdualweapon, usingsilencedweapon;

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

              // Weapons with levels
              case ' Unmaker ':
              case 'Unreal_DispersionPistol':
                switch (weaponname)
                {
                  case ' Unmaker ': currentmode = CPlayer.mo.FindInventory("SamsaraDoom64UnmakerArtifact"); break;
                  case 'Unreal_DispersionPistol': currentmode = CPlayer.mo.FindInventory("UDPistolUpgradePreferred"); break;
                }

                weaponmode = FormatNumber((currentmode ? clamp(currentmode.Amount, 0, currentmode.MaxAmount) : 0) + 1, 1, 10, 0, StringTable.Localize("$GOODOLHUD_WEAPON_MODE_LEVEL") .. " ");
                break;

              // Dual wieldable weapons
              case 'Steel Knuckles':
              case '.44 Magnum Mega Class A1':
              case 'WSTE-M5 Combat Shotgun':
              case 'SWUzi':
              case 'Goldeneye_Klobb':
              case 'Goldeneye_DD44':
              case 'Goldeneye_ThrowingKnives':
              case 'Goldeneye_HuntingKnife':
              case 'Goldeneye_KF7Soviet':
              case 'Goldeneye_AutoShotgun':
              case 'Goldeneye_Shotgun':
              case 'Goldeneye_AR33':
              case 'Goldeneye_Phantom':
              case 'Goldeneye_RocketLauncher':
              case 'Goldeneye_GrenadeLauncher':
              case 'Goldeneye_RCP90':
              case 'Goldeneye_Cougar':
              case 'Goldeneye_SilverPP7':
              case 'Goldeneye_ArabahViper':
              case 'Goldeneye_Moonraker':
              case 'Goldeneye_GoldenGun':
              case 'Goldeneye_SniperRifle':
              case 'Goldeneye_ZMG':
              case 'Goldeneye_GoldPP7':
              case 'Goldfinger_ColtM1911':
              case 'Goldfinger_LugerP08':
              case 'Goldfinger_WaltherP38':
              case 'Goldfinger_GolfClub':
              case 'Goldfinger_MP40':
              case 'Goldfinger_Shotgun':
              case 'Goldfinger_OverUnder':
              case 'Goldfinger_AK47':
              case 'Goldfinger_SuperBazooka':
              case 'Goldfinger_M79':
              case 'Goldfinger_M1Carbine':
              case 'Goldfinger_M1Garand':
              case 'Goldfinger_Kar98k':
              case 'Goldfinger_Laser':
              case 'Goldfinger_M14':
              case 'Goldfinger_AR7':
              case 'Goldfinger_UZI':
              case 'Goldfinger_SmithWesson22':
              case 'Goldfinger_SmithWesson36':
              case 'Goldfinger_GoldMagnum':
              case 'RTCW_Colt':
                switch (weaponname)
                {
                  case 'Steel Knuckles': currentmode = CPlayer.mo.FindInventory("DOUBLEFISTING"); break;

                  case '.44 Magnum Mega Class A1':
                  case 'WSTE-M5 Combat Shotgun':
                    currentmode = CPlayer.mo.FindInventory("UsingDual" .. (weaponname == "WSTE-M5 Combat Shotgun" ? "Shotguns" : "Pistols"));
                    break;

                  case 'SWUzi': currentmode = CPlayer.mo.FindInventory("UziCheck"); break;

                  default:
                    if (!canshowpendingweapon) { currentmode = CPlayer.mo.FindInventory("BondDualWieldToken"); }
                    break;

                  case 'RTCW_Colt': currentmode = CPlayer.mo.FindInventory(weaponname .. "DualWield"); break;
                }

                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (currentmode ? "DUAL" : "SINGLE");
                break;

              // The others
              case ' Fist ':
              case ' BFG10K ':
                if ((altclassnum == 1 && weaponname == " Fist ") ||
                    (altclassnum == 2 && weaponname == " BFG10K "))
                { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_DOOMGUY" .. (altclassnum == 2 ? "STR" : "64") .. "_" .. (weaponname == " BFG10K " ? "SLOT7S" : "FALLBACKMELEE"); }
                break;

              case 'Mini-Zorcher':
              case 'Micro-Zorcher':
              case 'Dual Mini-Zorchers':
              case 'Dual Micro-Zorchers':
                usingdualweapon = weaponname == "Dual Mini-Zorchers" || weaponname == "Dual Micro-Zorchers";

                if (usingdualweapon) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_CHEX_FALLBACKRANGED" .. (weaponname == "Dual Micro-Zorchers" ? "_LOADOUT1" : ""); }
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (usingdualweapon ? "DUAL" : "SINGLE");
                break;

              case 'DSparilStaff':
              case 'DSparilStaffMinion':
                weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_CORVUS_SLOT7";
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_CORVUS_" .. (weaponname == "DSparilStaffMinion" ? "SUMMON" : "LIGHTNING");
                break;

              case '  Chaingun  ':
              case '  Dual Chainguns  ':
                usingdualweapon = weaponname == "  Dual Chainguns  ";

                if (usingdualweapon) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_BJ_SLOT4S"; }
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (usingdualweapon ? "DUAL" : "SINGLE");
                break;

              case 'Totenkopf_Pistol':
              case 'Totenkopf_PistolDual':
              case 'Totenkopf_Mauser':
              case 'Totenkopf_MauserDual':
              case 'Totenkopf_Kar98k':
              case 'Totenkopf_MP40':
              case 'Totenkopf_MP40Dual':
              case 'Totenkopf_Sniper':
                weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_BJCTK_";
                weaponmode = "$GOODOLHUD_WEAPON_MODE_";

                switch (weaponname)
                {
                  case 'Totenkopf_Pistol':
                  case 'Totenkopf_PistolDual':
                    weaponalttag = weaponalttag .. "FALLBACKRANGED";
                    weaponmode = weaponmode .. (weaponname == "Totenkopf_PistolDual" ? "DUAL" : "SINGLE");
                    break;

                  case 'Totenkopf_Mauser':
                  case 'Totenkopf_MauserDual':
                    weaponalttag = weaponalttag .. "SLOT1";
                    weaponmode = weaponmode .. (weaponname == "Totenkopf_MauserDual" ? "DUAL" : "SINGLE");
                    break;

                  default:
                    let usingscope = weaponname == "Totenkopf_Sniper";

                    weaponalttag = weaponalttag .. (usingscope ? "UNIQUE3" : "SLOT2");
                    weaponmode = weaponmode .. "SAMSARA_BJCTK_" .. (usingscope ? "" : "UN") .. "SCOPED";
                    break;

                  case 'Totenkopf_MP40':
                  case 'Totenkopf_MP40Dual':
                    weaponalttag = weaponalttag .. "SLOT4";
                    weaponmode = weaponmode .. (weaponname == "Totenkopf_MP40Dual" ? "DUAL" : "SINGLE");
                    break;
                }
                break;

              case 'Mighty Boot':
              case 'Glock 17':
              case 'Pipebombs':
              case '  Shotgun  ':
              case 'Explosive Shotgun':
              case 'Chaingun Cannon':
              case 'Duke3D_M16':
              case 'Golden Desert Eagle':
              case 'RPG':
              case 'Duke3D_Incinerator':
              case 'Freezethrower':
              case 'Expander':
              case 'Shrinker':
              case 'Devastator Weapon':
              case 'Duke3D_X3000':
                let sharedname64 = weaponname == "Mighty Boot" || weaponname == "Pipebombs" || weaponname == "  Shotgun  ";

                let nocounterpart64 = weaponname == "Duke3D_M16" || weaponname == "Golden Desert Eagle" || weaponname == "Duke3D_Incinerator" ||
                                      weaponname == "Expander" || weaponname == "Shrinker" || weaponname == "Duke3D_X3000";

                if (altclassnum == 1 ||
                    (altclassnum == 2 && !sharedname64))
                { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_DUKE"; }

                if (weaponalttag != "")
                {
                    switch (altclassnum)
                    {
                      case 1: weaponalttag = weaponalttag .. "LAB"; break;
                      case 2: weaponalttag = weaponalttag .. (!nocounterpart64 ? "64" : "LAB"); break;
                    }

                    weaponalttag = weaponalttag .. "_";

                    switch (weaponname)
                    {
                      case 'Mighty Boot':
                      case 'Glock 17':
                        weaponalttag = weaponalttag .. "FALLBACK" .. (weaponname == "Glock 17" ? "RANGED" : "MELEE");
                        break;

                      case 'Pipebombs': weaponalttag = weaponalttag .. "SLOT1"; break;
                      case '  Shotgun  ': weaponalttag = weaponalttag .. "SLOT2"; break;
                      case 'Explosive Shotgun': weaponalttag = weaponalttag .. "SLOT3"; break;

                      case 'Chaingun Cannon':
                      case 'Duke3D_M16':
                        weaponalttag = weaponalttag .. "SLOT4" .. (weaponname == "Duke3D_M16" ? "_LOADOUT1" : "");
                        break;

                      case 'Golden Desert Eagle': weaponalttag = weaponalttag .. "SLOT4S"; break;
                      case 'RPG': weaponalttag = weaponalttag .. "SLOT5"; break;
                      case 'Duke3D_Incinerator': weaponalttag = weaponalttag .. "SLOT5S"; break;
                      case 'Freezethrower': weaponalttag = weaponalttag .. "SLOT6" .. (altclassnum == 2 ? "_" .. (CPlayer.mo.FindInventory("Duke64UsingShrinker") ? "SHRINKER" : "EXPANDER") : ""); break;

                      case 'Expander':
                      case 'Shrinker':
                        weaponalttag = weaponalttag .. "SLOT6S";
                        break;

                      case 'Devastator Weapon': weaponalttag = weaponalttag .. "SLOT7"; break;
                      case 'Duke3D_X3000': weaponalttag = weaponalttag .. "SLOT7S"; break;
                      default: weaponalttag = weaponalttag .. "UNIQUE" .. (weaponname == "Expander" ? "3" : "2"); break;
                    }
                }

                let hasaltmodelab = weaponname == "Expander" || weaponname == "Shrinker";
                let hasaltmode64 = weaponname == "Glock 17" || weaponname == "  Shotgun  " || weaponname == "RPG" ||
                                   hasaltmodelab; // slot 6 handled in weaponalttag

                if ((altclassnum == 1 && hasaltmodelab) ||
                    (altclassnum == 2 && hasaltmode64))
                { weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_DUKE"; }

                if (weaponmode != "")
                {
                    switch (altclassnum)
                    {
                      case 1: weaponmode = weaponmode .. "LAB"; break;
                      case 2: weaponmode = weaponmode .. (!nocounterpart64 ? "64" : "LAB"); break;
                    }

                    weaponmode = weaponmode .. "_";

                    switch (weaponname)
                    {
                      case 'Glock 17': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("Duke64UsingDumDums") ? "DUMDUMS" : "BULLETS"); break;
                      case '  Shotgun  ': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("Duke64UsingExplosiveShells") ? "EXPLOSIVE" : "") .. "SHELLS"; break;
                      case 'RPG': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("Duke64UsingHeatSeeking") ? "HEATSEEKING" : "") .. "ROCKETS"; break;
                      default: weaponmode = weaponmode .. weaponname; break;
                    }
                }
                break;

              case 'Grenade Launcher':
              case 'Grenade Launcher DOE':
              case 'Nailgun':
              case 'Nailgun DOE':
              case '  Rocket Launcher  ':
              case '  Rocket Launcher DOE  ':
              case 'Super Nailgun':
              case 'Super Nailgun DOE':
              case 'Thunderbolt':
              case 'Thunderbolt DOE':
                weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_RANGER_SLOT";
                if (!vanillaquake) { weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_RANGER_"; }

                switch (weaponname)
                {
                  case 'Grenade Launcher':
                  case 'Grenade Launcher DOE':
                    weaponalttag = weaponalttag .. "3";
                    if (weaponmode != "") { weaponmode = weaponmode .. (weaponname == "Grenade Launcher DOE" ? "MULTI" : "") .. "GRENADES"; }
                    break;

                  case 'Nailgun':
                  case 'Nailgun DOE':
                    weaponalttag = weaponalttag .. "4";
                    if (weaponmode != "") { weaponmode = weaponmode .. (weaponname == "Nailgun DOE" ? "LAVA" : "") .. "NAILS"; }
                    break;

                  case '  Rocket Launcher  ':
                  case '  Rocket Launcher DOE  ':
                    weaponalttag = weaponalttag .. "5";
                    if (weaponmode != "") { weaponmode = weaponmode .. (weaponname == "  Rocket Launcher DOE  " ? "MULTI" : "") .. "ROCKETS"; }
                    break;

                  case 'Super Nailgun':
                  case 'Super Nailgun DOE':
                    weaponalttag = weaponalttag .. "6";
                    if (weaponmode != "") { weaponmode = weaponmode .. (weaponname == "Super Nailgun DOE" ? "LAVA" : "") .. "NAILS"; }
                    break;

                  case 'Thunderbolt':
                  case 'Thunderbolt DOE':
                    weaponalttag = weaponalttag .. "7";
                    if (weaponmode != "") { weaponmode = weaponmode .. (weaponname == "Thunderbolt DOE" ? "PLASMA" : "LIGHTNING"); }
                    break;
                }
                break;

              case 'RPistol':
              case 'Double Pistols':
                usingdualweapon = weaponname == "Double Pistols";

                if (usingdualweapon) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_ROTT_SLOT1"; }
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (usingdualweapon ? "DUAL" : "SINGLE");
                break;

              case '   Revolver   ':
              case 'Flaregun':
              case 'Sawedoff':
              case 'Tommygun':
              case 'BloodGreaseGun':
              case 'NapalmLauncher':
              case 'TeslaCannon':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (Powerup(CPlayer.mo.FindInventory("PowerSamsaraBloodGunsAkimbo")) || CPlayer.mo.FindInventory("SamsaraBloodGunsAkimboToggled")  ? "DUAL" : "SINGLE");
                break;

              case '  Crossbow  ':
              case '  Crossbow Poison  ':
              case ' Grenade Launcher ':
              case ' Grenade Launcher WP ':
              case ' Grenade Launcher Gas ':
              case ' Mauler ':
              case ' Mauler Torpedo ':
              case ' Sigil ':
                if (weaponname != " Sigil ") { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_STRIFEGUY_SLOT"; }
                weaponmode = "$GOODOLHUD_WEAPON_MODE_";

                switch (weaponname)
                {
                  case '  Crossbow  ':
                  case '  Crossbow Poison  ':
                    weaponalttag = weaponalttag .. "2";
                    weaponmode = weaponmode .. "STRIFECROSSBOW" .. (weaponname == "  Crossbow Poison  " ? "2" : "");
                    break;

                  case ' Grenade Launcher ':
                  case ' Grenade Launcher WP ':
                  case ' Grenade Launcher Gas ':
                    weaponalttag = weaponalttag .. "5";
                    weaponmode = weaponmode .. (weaponname == " Grenade Launcher Gas " ? "SAMSARA_STRIFEGUY_GASGRENADES" : "STRIFEGRENADELAUNCHER" .. (weaponname == " Grenade Launcher WP " ? "2" : ""));
                    break;

                  case ' Mauler ':
                  case ' Mauler Torpedo ':
                    weaponalttag = weaponalttag .. "7";
                    weaponmode = weaponmode .. "MAULER" .. (weaponname == " Mauler Torpedo " ? "2" : "");
                    break;

                  case ' Sigil ':
                    currentmode = CPlayer.mo.FindInventory("StrifeSigilPiecePreferred");

                    weaponmode = weaponmode .. FormatNumber(currentmode ? clamp(currentmode.Amount, 1, currentmode.MaxAmount) : 1, 0, 0, 0, "SIGIL");
                    break;
                }
                break;

              case '  Claw  ':
              case '  Ripper Disc  ':
                if (altclassnum >= 1) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_"; }

                if (weaponalttag != "")
                {
                    switch (altclassnum)
                    {
                      case 1: weaponalttag = weaponalttag .. "KAMCHAK"; break;
                      case 2: weaponalttag = weaponalttag .. "DANBLAZE"; break;
                      case 3: weaponalttag = weaponalttag .. "ALLIANCECOMMANDO"; break;
                    }

                    weaponalttag = weaponalttag .. "_FALLBACK" .. (weaponname == "  Ripper Disc  " ? "RANGED" : "MELEE");
                }
                break;

              case ' Arachnicator ':
              case 'EradRovingMine':
              case 'EradMiniTankDetonator':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_ERAD_" .. (CPlayer.mo.FindInventory("EradicatorPipAllowControl")  ? "GUIDED" : "HOMING");
                break;

              case ' Tazer ':
              case ' Aldus Pistol ':
                if (altclassnum >= 2) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_"; }

                if (weaponalttag != "")
                {
                    switch (altclassnum)
                    {
                      case 2: weaponalttag = weaponalttag .. "LIZARDMAN"; break;
                      case 3: weaponalttag = weaponalttag .. "MUTANT"; break;
                      case 4: weaponalttag = weaponalttag .. "DOMINATRIX"; break;
                    }

                    weaponalttag = weaponalttag .. "_FALLBACK" .. (weaponname == " Aldus Pistol " ? "RANGED" : "MELEE");
                }
                break;

              case ' Super Plasma Annihilator ':
                currentmode = CPlayer.mo.FindInventory("SamsaraIPOGSuperPlasmaAnnihilatorMode");

                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_IPOG_";

                if (!currentmode) { weaponmode = weaponmode .. "HITSCAN"; }
                else switch (currentmode.Amount)
                {
                  case 1: weaponmode = weaponmode .. "SCATTER"; break;
                  case 2: weaponmode = weaponmode .. "SPLASH"; break;
                  default: weaponmode = weaponmode .. "RIPPER"; break;
                }
                break;

              case ' 18mm Semi ':
                if (CPlayer.mo.FindInventory("SamsaraDisruptorHas18mmAuto")) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_DISRUPTOR_SLOT1"; }
                break;

              case ' Phase Rifle ':
              case 'Phase Repeater':
              case ' Lock-on Cannon ':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_DISRUPTOR_";

                switch (weaponname)
                {
                  default: weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SamsaraDisruptorPhase" .. (weaponname == "Phase Repeater" ? "Repeater" : "Rifle") .. "Mode") ? "HIFREQ" : "STANDARD"); break;
                  case ' Lock-on Cannon ': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SamsaraDisruptorLockOnCannonMode") ? "BINARY" : "STANDARD"); break;
                }
                break;

              case 'Spellbook':
              case 'Bow and Arrows':
              case 'Shortsword':
              case 'Battle Axe':
              case 'Ice Halberd':
              case 'Fire Mace':
              case 'Broad Sword':
              case 'Frozen Two-Hand Sword':
              case 'Pike Axe':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_GRONDOVAL_";

                switch (weaponname)
                {
                  case 'Spellbook': currentmode = CPlayer.mo.FindInventory("WTSpellCounter"); break;
                  case 'Bow and Arrows': currentmode = CPlayer.mo.FindInventory("WTBowUpgrade"); break;

                  case 'Shortsword':
                  case 'Broad Sword':
                    currentmode = CPlayer.mo.FindInventory("WTSlotIClip");
                    break;

                  case 'Battle Axe': currentmode = CPlayer.mo.FindInventory("WTSlotIIClip"); break;
                  case 'Ice Halberd': currentmode = CPlayer.mo.FindInventory("WTSlotIVClip"); break;
                  case 'Fire Mace': currentmode = CPlayer.mo.FindInventory("WTSlotVClip"); break;
                  case 'Frozen Two-Hand Sword': currentmode = CPlayer.mo.FindInventory("WTSlotVIIClip"); break;
                  case 'Pike Axe': currentmode = CPlayer.mo.FindInventory("WTSlotIIIClip"); break;
                }

                switch (weaponname)
                {
                  case 'Spellbook':
                    if (!currentmode) { weaponmode = weaponmode .. "FISTS"; }
                    else switch (currentmode.Amount)
                    {
                      case 1: weaponmode = weaponmode .. "SCARE"; break;
                      case 2: weaponmode = weaponmode .. "NIGHTVISION"; break;
                      case 3: weaponmode = weaponmode .. "FREEZE"; break;
                      case 4: weaponmode = weaponmode .. "MAGICARROW"; break;
                      case 5: weaponmode = weaponmode .. "FLY"; break;
                      case 6: weaponmode = weaponmode .. "FIREBALL"; break;
                      default: weaponmode = weaponmode .. "NUKE"; break;
                    }
                    break;

                  case 'Bow and Arrows': weaponmode = weaponmode .. (currentmode ? "" : "UN") .. "ENCHANTED"; break;
                  default: weaponmode = weaponmode .. (!currentmode ? "" : "UN") .. "ENCHANTED"; break;
                }
                break;

              case 'SWRiotgun':
              case 'SWMissileLauncher':
              case 'SWGuardianHead':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_" .. (weaponname == "SWMissileLauncher" || weaponname == "SWGuardianHead" ? "SAMSARA_WANG_" : "");

                switch (weaponname)
                {
                  case 'SWRiotgun': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SWRiotMode") ? "BURST" : "SEMIAUTO"); break;

                  case 'SWMissileLauncher':
                    currentmode = CPlayer.mo.FindInventory("MissileMode");

                    if (currentmode)
                    {
                        switch (currentmode.Amount)
                        {
                          case 1: weaponmode = weaponmode .. "HEATSEEKING"; break;
                          default: weaponmode = weaponmode .. "NUCLEAR"; break;
                        }
                    }

                    weaponmode = weaponmode .. "MISSILES";
                    break;

                  case 'SWGuardianHead':
                    currentmode = CPlayer.mo.FindInventory("SWGuardianHeadMode");

                    if (!currentmode) { weaponmode = weaponmode .. "STREAM"; }
                    else switch (currentmode.Amount)
                    {
                      case 1: weaponmode = weaponmode .. "CIRCLE"; break;
                      default: weaponmode = weaponmode .. "WALL"; break;
                    }
                    break;
                }
                break;

              case 'MagicFist':
                currentmode = CPlayer.mo.FindInventory("usingmagicfisttype");

                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_CM_";

                if (!currentmode) { weaponmode = weaponmode .. "STARBOLT"; }
                else switch (currentmode.Amount)
                {
                  case 1: weaponmode = weaponmode .. "ELECTROSCHISM"; break;
                  case 2: weaponmode = weaponmode .. "MAGNARIP"; break;
                  case 3: weaponmode = weaponmode .. "PAINWAVE"; break;
                  default: weaponmode = weaponmode .. "NOVA"; break;
                }
                break;

              case ' RR Hunting Crossbow ':
              case ' RR Dynomite Crossbow ':
              case ' Chicken Crossbow ':
                if (weaponname != " RR Hunting Crossbow ") { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_RR_SLOT2"; }
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_RR_" .. (weaponname == " Chicken Crossbow " ? "CHICKEN" : (weaponname == " RR Dynomite Crossbow " ? "DYNOMITE" : "ARROWS"));
                break;

              case 'Goldeneye_PP7Silenced':
              case 'Goldeneye_PP7SpecialIssue':
              case 'Goldeneye_SilencedD5K':
              case 'Goldeneye_D5KDeutsche':
              case 'Goldfinger_PPKSilenced':
              case 'Goldfinger_PPK':
                usingsilencedweapon = weaponname == "Goldeneye_PP7Silenced" || weaponname == "Goldeneye_SilencedD5K" || weaponname == "Goldfinger_PPKSilenced";

                if (usingsilencedweapon)
                {
                    weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_BOND" .. (weaponname == "Goldfinger_PPKSilenced" ? "GF" : "") .. "_";

                    switch (weaponname)
                    {
                      case 'Goldeneye_PP7Silenced':
                      case 'Goldfinger_PPKSilenced':
                        weaponalttag = weaponalttag .. "FALLBACKRANGED";
                        break;

                      case 'Goldeneye_SilencedD5K': weaponalttag = weaponalttag .. "UNIQUE2"; break;
                    }
                }

                weaponmode = StringTable.Localize("$GOODOLHUD_WEAPON_MODE_" .. (usingsilencedweapon ? "" : "UN") .. "SILENCED") .. StringTable.Localize("$GOODOLHUD_EXTRA_END") ..
                             " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize("$GOODOLHUD_WEAPON_MODE_" .. (CPlayer.mo.FindInventory("BondDualWieldToken") && !canshowpendingweapon ? "DUAL" : "SINGLE"));
                break;

              case 'Goldeneye_WatchMagnet':
              case 'Goldeneye_WatchLaser':
              case 'Goldeneye_WatchDetonator':
              case 'Goldeneye_TimedMines':
              case 'Goldeneye_ProximityMines':
              case 'Goldeneye_RemoteMines':
              case 'Goldfinger_WatchDetonator':
                bool goldfingerweapon = weaponname == "Goldfinger_WatchDetonator";

                weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_BOND" .. (goldfingerweapon ? "GF" : "") .. "_UNIQUE3";
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_BOND" .. (goldfingerweapon ? "GF" : "") .. "_";

                switch (weaponname)
                {
                  case 'Goldeneye_WatchMagnet':
                    weaponalttag = weaponalttag .. "A";
                    weaponmode = weaponmode .. "MAGNET";
                    break;

                  case 'Goldeneye_WatchLaser':
                    weaponalttag = weaponalttag .. "B";
                    weaponmode = weaponmode .. "LASER";
                    break;

                  case 'Goldeneye_WatchDetonator':
                  case 'Goldfinger_WatchDetonator':
                    weaponalttag = weaponalttag .. (goldfingerweapon ? "A" : "C");
                    weaponmode = weaponmode .. "DETONATOR";
                    break;

                  case 'Goldeneye_TimedMines':
                    weaponalttag = weaponalttag .. "D";
                    weaponmode = weaponmode .. "TIMED";
                    break;

                  case 'Goldeneye_ProximityMines':
                    weaponalttag = weaponalttag .. "E";
                    weaponmode = weaponmode .. "PROXIMITY";
                    break;

                  case 'Goldeneye_RemoteMines':
                    weaponalttag = weaponalttag .. "F";
                    weaponmode = weaponmode .. "REMOTE";
                    break;
                }
                break;

              case 'Goldfinger_ThompsonDrum':
              case 'Goldfinger_Thompson':
                let usingdrummagweapon = weaponname == "Goldfinger_ThompsonDrum";

                if (usingdrummagweapon) { weaponalttag = "$GOODOLHUD_WEAPON_SAMSARA_BONDGF_SLOT4S"; }
                weaponmode = StringTable.Localize("$GOODOLHUD_WEAPON_MODE_SAMSARA_BONDGF_" .. (usingdrummagweapon ? "DRUM" : "STICK")) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") ..
                             " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize("$GOODOLHUD_WEAPON_MODE_" .. (CPlayer.mo.FindInventory("BondDualWieldToken") && !canshowpendingweapon ? "DUAL" : "SINGLE"));
                break;

              case 'RTCW_Luger':
              case 'RTCW_StG44':
              case 'RTCW_K43':
              case 'RTCW_M1Garand':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_";

                switch (weaponname)
                {
                  case 'RTCW_Luger': weaponmode = weaponmode .. (CPlayer.mo.FindInventory(weaponname .. "SilencerAttached") ? "" : "UN") .. "SILENCED"; break;
                  case 'RTCW_StG44': weaponmode = weaponmode .. (CPlayer.mo.FindInventory(weaponname .. "Alt") ? "SEMI" : "FULL") .. "AUTO"; break;
                  default: weaponmode = weaponmode .. "SAMSARA_RTCW_" .. (CPlayer.mo.FindInventory(weaponname .. "GrenadeModeSelected") ? "GRENADES" : "RIFLEROUNDS"); break;
                }
                break;

              case 'DescentWeapon':
              case 'DescentWeaponPadUp':
              case 'DescentWeaponPadDown':
              case 'DescentLaser':
              case 'DescentSuperLaser':
              case 'DescentVulcan':
              case 'DescentGauss':
              case 'DescentSpreadFire':
              case 'DescentFusion':
              case 'DescentHelix':
              case 'DescentOmega':
              case 'DescentPlasma':
              case 'DescentPhoenix':
                // Primary
                currentmode = CPlayer.mo.FindInventory("DescentLaserLevel");

                descentweapon1 = "$GOODOLHUD_WEAPON_SAMSARA_PYROGX_";

                let descentweapon1counter = CPlayer.mo.FindInventory("DescentPrimaryCounter");

                if (!descentweapon1counter)
                {
                    descentweapon1 = descentweapon1 .. "FALLBACKRANGED";
                    weaponmode = FormatNumber((currentmode ? clamp(currentmode.Amount, 0, currentmode.MaxAmount) : 0) + 1, 1, 10, 0, StringTable.Localize("$GOODOLHUD_WEAPON_MODE_LEVEL") .. " ");
                } else {
                    let curweapon1 = clamp(descentweapon1counter.Amount, 1, descentweapon1counter.MaxAmount);

                    descentweapon1 = descentweapon1 .. (curweapon1 >= 8 ? "UNIQUE" : "SLOT") .. curweapon1 - (curweapon1 >= 8 ? 7 : 0);
                    if (curweapon1 == 1) { weaponmode = FormatNumber((currentmode ? clamp(currentmode.Amount, 0, currentmode.MaxAmount) : 0) + 1, 1, 10, 0, StringTable.Localize("$GOODOLHUD_WEAPON_MODE_LEVEL") .. " "); }
                }

                descentweapon1 = descentweapon1 .. "A";

                // Secondary
                descentweapon2 = "$GOODOLHUD_WEAPON_SAMSARA_PYROGX_";

                let descentweapon2counter = CPlayer.mo.FindInventory("DescentSecondaryCounter");

                if (!descentweapon2counter) { descentweapon2 = descentweapon2 .. "FALLBACKRANGED"; }
                else
                {
                    let curweapon2 = clamp(descentweapon2counter.Amount, 1, descentweapon2counter.MaxAmount);

                    descentweapon2 = descentweapon2 .. (curweapon2 >= 8 ? "UNIQUE" : "SLOT") .. curweapon2 - (curweapon2 >= 8 ? 7 : 0);
                }

                descentweapon2 = descentweapon2 .. "B";
                break;

              case 'DeusEx_MiniCrossbow':
              case 'DeusEx_Shotgun':
              case 'DeusEx_AssaultShotgun':
              case 'DeusEx_AssaultRifle':
              case 'DeusEx_GEPGun':
              case 'DeusEx_MJ12PlasmaRifle':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_SAMSARA_JCDENTON_";

                switch (weaponname)
                {
                  case 'DeusEx_MiniCrossbow':
                    currentmode = CPlayer.mo.FindInventory("SamsaraDeusExMiniXBowAmmoType");

                    if (!currentmode) { weaponmode = weaponmode .. "TRANQ"; }
                    else switch (currentmode.Amount)
                    {
                      case 1: weaponmode = weaponmode .. "DARTS"; break;
                      default: weaponmode = weaponmode .. "FLARE"; break;
                    }
                    break;

                  default: weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SamsaraDeusEx" .. (weaponname == "DeusEx_AssaultShotgun" ? "AssaultShotgun" : "Shotgun") .. "AmmoType") ? "SABOT" : "BUCKSHOT"); break;
                  case 'DeusEx_AssaultRifle': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SamsaraDeusExAssaultRifleAmmoType") ? "GRENADE" : "BULLET"); break;
                  case 'DeusEx_GEPGun': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SamsaraDeusExGEPGunAmmoType") ? "WP" : "") .. "ROCKETS"; break;
                  case 'DeusEx_MJ12PlasmaRifle': weaponmode = weaponmode .. (CPlayer.mo.FindInventory("SamsaraDeusExPlasmaRifleAmmoType") ? "NANOPHAGE" : "PLASMA"); break;
                }
                break;

              case 'Kingpin_Pistol':
              case 'Kingpin_Bazooka':
                weaponmode = "$GOODOLHUD_WEAPON_MODE_";

                switch (weaponname)
                {
                  case 'Kingpin_Pistol': weaponmode = weaponmode .. (CPlayer.mo.FindInventory(weaponname .. "_SilencerActive") ? "" : "UN") .. "SILENCED"; break;
                  case 'Kingpin_Bazooka': weaponmode = weaponmode .. "SAMSARA_KINGPIN_" .. (CPlayer.mo.FindInventory(weaponname .. "_BigBubbaActive") ? "BIGBUBBA" : "") .. "ROCKETS"; break;
                }
                break;
            }

            if (descentweapon1 != "")
            {
                DrawString(GOHmHUDFont,
                           "\c" .. colorschemetext ..
                           StringTable.Localize(descentweapon1) ..
                           (weaponmode != "" ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize(weaponmode) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                           (coordbasex, coordbasey), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

                weaponnameamount++;

                if (descentweapon2 != "")
                {
                    coordnudge.Y -= 16;

                    DrawString(GOHmHUDFont, "\c" .. colorschemetext .. StringTable.Localize(descentweapon2), (coordbasex, (coordbasey + coordnudge.Y)), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

                    weaponnameamount++;
                }
            } else {
                DrawString(GOHmHUDFont,
                           "\c" .. colorschemetext ..
                           (weaponalttag != "" ? StringTable.Localize(weaponalttag) : (canshowpendingweapon ? CPlayer.PendingWeapon.GetTag() : CPlayer.ReadyWeapon.GetTag())) ..
                           (weaponmode != "" ? " " .. StringTable.Localize("$GOODOLHUD_EXTRA_START") .. StringTable.Localize(weaponmode) .. StringTable.Localize("$GOODOLHUD_EXTRA_END") : ""),
                           (coordbasex, coordbasey), DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT);

                weaponnameamount++;
            }
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
        int maxammos = 120 * 3; // some of these are magazines or counters (charge/overheating/etc.)

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
            // Doomguy (Stronghold)
            "DoomguyStrMines", "cyan",     "[Cyan]",
            "DoomguyStrGas",   "deeppink", "[Bijou]",
            // B.J. Blazkowicz (Castle Totenkopf SDL)
            "Totenkopf_FlameThrowerFuel", "deeppink", "[Bijou]",
            // Duke Nukem (Original/Life's a Beach)
            "ShrinkerAmmo",      "teal",          "[Teal]",
            "DukePistolReload",  "white",         "[White]",
            "DukePipebombSpeed", "blueyellowred", "BlueYellowRed",
            // Duke Nukem (Duke Nukem 64)
            "Duke64DumDums",            "orange",        "[Orange]",
            "Duke64ExplosiveShells",    "brick",         "[Brick]",
            "Duke64HeatSeekingRockets", "darkbrown",     "[DarkBrown]",
            "Duke64ShrinkerAmmo",       "teal",          "[Teal]",
            "Duke64PlasmaCharge",       "blueyellowred", "BlueYellowRed",
            // Security Officer
            "UnknownResonator1", "rainbow",        "Rainbow",
            "UnknownAmmo",       "rainbow",        "Rainbow",
            "UnknownResonator2", "rainbowreverse", "RainbowReverse",
            "UnknownAmmo2",      "rainbowreverse", "RainbowReverse",
            "KnifeAmmo",         "darkgray",       "[DarkGray]",
            "MagnumBullet",      "white",          "[White]",
            "Tech50Ammo",        "gray",           "[Gray]",
            // Ranger
            "LavaNails",       "orange",    "[Orange]",
            "MultiRocketAmmo", "darkbrown", "[DarkBrown]",
            "PlasmaCell",      "teal",      "[Teal]",
            // H.U.N.T. Team Members
            "RottMissiles", "yellow",    "[Yellow]",
            "HSMissiles",   "red",       "[Red]",
            "FBMissiles",   "brown",     "[Brown]",
            "DMissiles",    "lightblue", "[LightBlue]",
            "SMissiles",    "purple",    "[Purple]",
            "DMMissiles",   "cyan",      "[Cyan]",
            "FWMissiles",   "deeppink",  "[Bijou]",
            "BMissiles",    "cream",     "[Cream]",
            "DSEnergy",     "gray",      "[Gray]",
            // Caleb
            "SprayCanAmmo", "deeppink",      "[Bijou]",
            "Voodoo",       "cream",         "[Cream]",
            "ThrowPower",   "blueyellowred", "BlueYellowRed",
            // Strifeguy
            "StrifePoisonAmmo",     "brick",     "[Brick]",
            "WhitePhosGrenade",     "darkbrown", "[DarkBrown]",
            "StrifeGasGrenadeAmmo", "darkgreen", "[DarkGreen]",
            // Space Seal
            "C7ProxyMineAmmo", "olive", "[Olive]",
            // Kyle Katarn
            "SamsaraDarkForcesThermalDetonatorThrowPower", "blueyellowred", "BlueYellowRed",
            // Jack Curtis
            "DisruptorHiFreq",       "orange",    "[Orange]",
            "DisruptorBinaryLockOn", "darkbrown", "[DarkBrown]",
            // Grondoval
            "WTShieldCounter", "darkgray", "[DarkGray]",
            // Half-Life Characters
            "HornetGunAmmo",  "darkred",  "[DarkRed]",
            "ShockRoachAmmo", "sapphire", "[Sapphire]",
            "HLSqueakAmmo",   "cream",    "[Cream]",
            "HL9mmCounter",   "white",    "[White]",
            // Lo Wang
            "HeartAmmo", "darkred", "[DarkRed]",
            // Jon P.
            "PSMagnumReload",         "white",         "[White]",
            "PS_AMUNHOLD",            "blueyellowred", "BlueYellowRed",
            "PSSacredManacleCharges", "blueyellowred", "BlueYellowRed",
            // Leonard
            "MotoGunAmmo",         "green", "[Green]",
            "ChickenAmmo",         "cyan",  "[Cyan]",
            "LeonardPistolReload", "white", "[White]",
            // Bitterman
            "Q2Flechettes", "green", "[Green]",
            // James Bond (GoldenEye 007)
            "Goldeneye_ThrowingKnivesAmmo",  "purple", "[Purple]",
            "Goldeneye_GoldenGunRounds",     "cyan",   "[Cyan]",
            "Goldeneye_PP7SilencedMagazine", "white",  "[White]",
            "Goldeneye_KlobbMagazine",       "white",  "[White]",
            "Goldeneye_PP7Magazine",         "white",  "[White]",
            "Goldeneye_DD44Magazine",        "white",  "[White]",
            // James Bond (Goldfinger 64)
            "Goldfinger_OddjobHatAmmo",       "darkgray", "[DarkGray]",
            "Goldfinger_PPKSilencedMagazine", "white",    "[White]",
            "Goldfinger_PPKMagazine",         "white",    "[White]",
            "Goldfinger_ColtM1911Magazine",   "white",    "[White]",
            "Goldfinger_LugerP08Magazine",    "white",    "[White]",
            "Goldfinger_WaltherP38Magazine",  "white",    "[White]",
            // Petton Everhail
            "Catacomb_Waves",        "yellow",        "[Yellow]",
            "Catacomb_XTerminators", "red",           "[Red]",
            "Catacomb_Nukes",        "brown",         "[Brown]",
            "Catacomb_Bolts",        "lightblue",     "[LightBlue]",
            "Catacomb_Zappers",      "green",         "[Green]",
            "Catacomb_Bursts",       "purple",        "[Purple]",
            "Catacomb3D_ChargeTime", "blueyellowred", "BlueYellowRed",
            // Daniel Garner
            "Painkiller_FlamerAmmo",  "orange",    "[Orange]",
            "Painkiller_FreezerAmmo", "brick",     "[Brick]",
            "Painkiller_HeaterAmmo",  "darkbrown", "[DarkBrown]",
            "Painkiller_ElectroAmmo", "teal",      "[Teal]",
            // Prisoner 849
            "DPistolAmmo",       "darkgray", "[DarkGray]",
            "UnrealAutomagClip", "white",    "[white]",
            // B.J. Blazkowicz (Return to Castle Wolfenstein)
            "RTCW_AlliedAmmo1",   "green",         "[Green]",
            "RTCW_AlliedAmmo2",   "purple",        "[Purple]",
            "RTCW_AlliedAmmo3",   "cyan",          "[Cyan]",
            "RTCW_AlliedAmmo4",   "deeppink",      "[Bijou]",
            "RTCW_LugerMagazine", "white",         "[White]",
            "RTCW_VenomHeat",     "blueyellowred", "BlueYellowRed",
            "RTCW_MG42Heat",      "blueyellowred", "BlueYellowRed",
            "RTCW_StenHeat",      "blueyellowred", "BlueYellowRed",
            "RTCW_ColtMagazine",  "white",         "[White]",
            "RTCW_BrowningHeat",  "blueyellowred", "BlueYellowRed",
            // Sarge
            "Q3ChaingunAmmo",        "green", "[Green]",
            "Q3GrenadeLauncherAmmo", "cyan",  "[Cyan]",
            // JC Denton
            "DeusEx_LAWAmmo",         "olive",    "[Olive]",
            "DeusEx_ProdAmmo",        "darkgray", "[DarkGray]",
            "DeusEx_GlockMagazine",   "white",    "[White]",
            "DeusEx_StealthMagazine", "white",    "[White]",
            // Thug
            "Kingpin_PistolMagazine", "white", "[White]",
            // John Mullins
            "SoF_Knives",          "gray",  "[Gray]",
            "SoF_Pistol1Magazine", "white", "[White]",
            // James Anderson
            "Outlaws_Knives",           "darkgray",      "[DarkGray]",
            "Outlaws_RevolverMagazine", "white",         "[White]",
            "Outlaws_ThrowCounter",     "blueyellowred", "BlueYellowRed"
        };

        Vector2 coordnudge;

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        let reloadmode = CPlayer.mo.FindInventory("SamsaraReloadMode"), canreload = false;
        let pistolammo = CPlayer.mo.FindInventory("PistolModeOn");
        let vanillaquake = CPlayer.mo.FindInventory("QuakeModeOn");

        if (reloadmode)
        {
            int reloadmodeamount = reloadmode.Amount;

            canreload = reloadmodeamount >= 2;
        }

        let canshowpendingweapon = CVar.FindCVar("goh_showpendingweapon").GetBool() && CPlayer.PendingWeapon != WP_NOCHANGE;

        Inventory ammotype1, ammotype2, ammotype3, ammotype4;

        if (canshowpendingweapon) { [ammotype1, ammotype2] = GetPendingAmmo(); }
        else { [ammotype1, ammotype2] = GetCurrentAmmo(); }

        bool alwaysshowammo1 = false, alwaysshowammo2 = false, alwaysshowammo3 = false, alwaysshowammo4 = false;
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
              case ' Rifle ':
              case 'Mini-Zorcher':
              case 'Micro-Zorcher':
              case 'Dual Mini-Zorchers':
              case 'Dual Micro-Zorchers':
              case 'Elven Wand':
              case 'Luger':
              case 'Totenkopf_Pistol':
              case 'Totenkopf_PistolDual':
              case 'Single Shotgun':
              case '   Revolver   ':
              case '   Pistol   ':
              case '  Ripper Disc  ':
              case ' Laser Pistol ':
              case 'Bryar Pistol':
              case ' 18mm Semi ':
              case 'SWShuriken':
              case 'CMLaserPistol':
              case 'Q3Machinegun':
                if (pistolammo) { ammotype1 = weaponname == "Single Shotgun" ? usingshell : usingclip; }
                break;

              // Reloadables
              case 'Automatic Shotgun':
              case 'Gigazorcher 2100':
              case 'Duke3D_M16':
              case 'Golden Desert Eagle':
              case 'KKV-7 SMG Flechette':
              case 'Fusion Pistol':
              case 'SPNKR-XP SSM Launcher':
              case 'TOZT-7 Napalm Unit':
              case 'SPNKR-25 Auto Cannon':
              case 'Tech.50 Pacifier':
              case '9mm Pistol':
              case 'Assault Shotgun':
              case '.357 Python':
              case 'Desert Eagle':
              case 'HLUzi':
              case ' RPG ':
              case 'Spore Launcher':
              case 'M249 Squad Automatic Weapon':
              case 'HL Crossbow':
              case 'M40A1 Sniper Rifle':
              case 'PSMagnum':
              case 'ExShotgun':
              case 'PSM60':
              case ' .454 Casull Pistol ':
              case 'Unreal_AutoMag':
              case 'RTCW_Luger':
              case 'RTCW_MP40':
              case 'RTCW_Mauser':
              case 'RTCW_FG42':
              case 'RTCW_StG44':
              case 'RTCW_Panzerfaust':
              case 'RTCW_Winchester':
              case 'RTCW_Thompson':
              case 'RTCW_Snooper':
              case 'RTCW_BAR':
              case 'DeusEx_10mmPistol':
              case 'DeusEx_StealthPistol':
              case 'DeusEx_MiniCrossbow':
              case 'DeusEx_Shotgun':
              case 'DeusEx_AssaultShotgun':
              case 'DeusEx_GEPGun':
              case 'DeusEx_FlameThrower':
              case 'DeusEx_MJ12PlasmaRifle':
              case 'DeusEx_SniperRifle':
              case 'DeusEx_RiotProd':
              case 'Kingpin_Pistol':
              case 'Kingpin_Shotgun':
              case 'Kingpin_GrenadeLauncher':
              case 'Kingpin_TommyGun':
              case 'Kingpin_Bazooka':
              case 'Kingpin_HMG':
              case 'SoF_Pistol1':
              case 'SoF_Pistol2':
              case 'SoF_AssaultRifle':
              case 'SoF_Shotgun':
              case 'SoF_Machinegun':
              case 'SoF_Rocket':
              case 'SoF_Flamegun':
              case 'SoF_Slugger':
              case 'SoF_MPG':
              case 'SoF_MPistol':
              case 'SoF_SniperRifle':
              case 'Outlaws_Revolver':
              case 'Outlaws_Shotgun':
              case 'Outlaws_SawedOffShotgun':
              case 'Outlaws_DoubleBarrelShotgun':
              case 'Outlaws_Rifle':
              case 'Outlaws_Cannon':
              case 'Outlaws_OrganGun':
                switch (weaponname)
                {
                  case '9mm Pistol':
                  case 'PSMagnum':
                  case ' .454 Casull Pistol ':
                  case 'Unreal_AutoMag':
                  case 'RTCW_Luger':
                  case 'DeusEx_10mmPistol':
                  case 'DeusEx_StealthPistol':
                  case 'Kingpin_Pistol':
                  case 'SoF_Pistol1':
                  case 'Outlaws_Revolver':
                    if (pistolammo) { ammotype2 = usingclip; }
                    break;
                }

                if (canreload) { usingreloadpri = true; }
                else
                {
                    ammotype1 = ammotype2 ? ammotype2 : null;
                    if (ammotype2) { ammotype2 = null; }
                }
                break;

              // Reloadables that overheat
              case 'RTCW_Venom':
              case 'RTCW_MG42':
              case 'RTCW_Sten':
              case 'RTCW_Browning':
                if (canreload) { usingreloadpri = true; }
                else
                {
                    ammotype1 = ammotype2 ? ammotype2 : null;
                    if (ammotype2) { ammotype2 = null; }
                }

                Inventory usingheat;

                switch (weaponname)
                {
                  default: usingheat = CPlayer.mo.FindInventory(weaponname .. "Heat"); break;
                }

                if (usingheat)
                {
                    if (!ammotype2)
                    {
                        ammotype2 = usingheat;
                        showammo2perc = true;
                    } else {
                        ammotype3 = usingheat;
                        showammo3perc = true;
                    }
                }
                break;

              // Reloadables with grenade launchers
              case 'MP5':
              case 'DeusEx_AssaultRifle':
                ammotype3 = usingrocketammo;

                if (canreload) { usingreloadpri = true; }
                else
                {
                    ammotype1 = ammotype2 ? ammotype2 : null;
                    ammotype2 = ammotype3 ? ammotype3 : null;
                    if (ammotype3) { ammotype3 = null; }
                }
                break;

              // Reloadables with more than one magazine
              case 'MA-75B Assault Rifle':
              case 'ONI-71 Wave Motion Cannon':
              case 'Mercury Class Fusion Rifle':
              case 'RTCW_K43':
              case 'RTCW_M1Garand':
                switch (weaponname)
                {
                  case 'MA-75B Assault Rifle':
                  case 'ONI-71 Wave Motion Cannon':
                    ammotype3 = weaponname == "ONI-71 Wave Motion Cannon" ? usingcell : usingclip;
                    ammotype4 = usingrocketammo;
                    break;

                  case 'Mercury Class Fusion Rifle':
                    ammotype3 = usingcell;
                    break;

                  default:
                    ammotype3 = ammotype2;
                    ammotype2 = Ammo(CPlayer.mo.FindInventory(weaponname .. "Grenade"));
                    ammotype4 = weaponname == "RTCW_M1Garand" ? Ammo(CPlayer.mo.FindInventory("RTCW_AlliedAmmo3")) : usingrocketammo;
                    break;
                }

                if (canreload)
                {
                    usingreloadpri = true;
                    usingreloadsec = true;
                } else {
                    ammotype1 = ammotype3 ? ammotype3 : null;
                    ammotype2 = ammotype4 ? ammotype4 : null;
                    if (ammotype3) { ammotype3 = null; }
                    if (ammotype4) { ammotype4 = null; }
                }
                break;

              // Reloadables that dual wield
              case '.44 Magnum Mega Class A1':
              case 'WSTE-M5 Combat Shotgun':
              case 'SWUzi':
              case 'RTCW_Colt':
                switch (weaponname)
                {
                  default:
                    if (weaponname == ".44 Magnum Mega Class A1" && pistolammo) { ammotype2 = usingclip; }

                    usingdual = CPlayer.mo.FindInventory("UsingDual" .. (weaponname == "WSTE-M5 Combat Shotgun" ? "Shotguns" : "Pistols"));
                    break;

                  case 'SWUzi': usingdual = CPlayer.mo.FindInventory("UziCheck"); break;

                  case 'RTCW_Colt':
                    if (pistolammo) { ammotype2 = Ammo(CPlayer.mo.FindInventory("RTCW_AlliedAmmo1")); }

                    usingdual = CPlayer.mo.FindInventory("RTCW_ColtDualWield");
                    break;
                }

                if (usingdual)
                {
                    ammotype3 = ammotype2 ? ammotype2 : null;

                    switch (weaponname)
                    {
                      default: ammotype2 = Ammo(CPlayer.mo.FindInventory(ammotype1.GetClassName() .. "Right")); break;
                      case 'SWUzi': ammotype2 = Ammo(CPlayer.mo.FindInventory(ammotype1.GetClassName() .. "Dual")); break;
                      case 'RTCW_Colt': ammotype2 = Ammo(CPlayer.mo.FindInventory(ammotype1.GetClassName() .. "2")); break;
                    }
                }

                if (canreload)
                {
                    usingreloadpri = true;
                    usingreloadsec = usingdual;
                } else {
                    ammotype1 = usingdual ? (ammotype3 ? ammotype3 : null) : (ammotype2 ? ammotype2 : null);
                    if (ammotype2) { ammotype2 = null; }
                    if (ammotype3) { ammotype3 = null; }
                }
                break;

              // Throwables/chargeables
              case 'Pipebombs':
              case 'Dynamite':
              case 'BloodProximityTNT':
              case 'BloodRemoteTNT':
              case 'BloodFlamethrower':
              case 'SprayCan':
              case 'Thermal Detonator':
              case ' Anubis Mine ':
              case 'Sacred Manacle':
              case 'Outlaws_Knife':
              case 'Outlaws_Dynamite':
                switch (weaponname)
                {
                  case 'Pipebombs': ammotype2 = CPlayer.mo.FindInventory("DukePipebombSpeed"); break;
                  case 'Thermal Detonator': ammotype2 = CPlayer.mo.FindInventory("SamsaraDarkForcesThermalDetonatorThrowPower"); break;
                  case ' Anubis Mine ': ammotype2 = CPlayer.mo.FindInventory("PS_AMUNHOLD"); break;
                  case 'Sacred Manacle': ammotype2 = CPlayer.mo.FindInventory("PSSacredManacleCharges"); break;

                  case 'Outlaws_Knife':
                  case 'Outlaws_Dynamite':
                    let throwcounter = CPlayer.mo.FindInventory("Outlaws_ThrowCounter");

                    if (throwcounter && !canshowpendingweapon) { ammotype2 = throwcounter; }
                    break;

                  default:
                    let throwpower = Ammo(CPlayer.mo.FindInventory("ThrowPower"));

                    if (throwpower)
                    {
                        int throwpoweramount = throwpower.Amount;

                        if (throwpoweramount > 0 && !canshowpendingweapon) { ammotype2 = throwpower; } // check if at least 1 due to inheriting from Ammo
                    }
                    break;
                }

                showammo2perc = true;
                break;

              // The others
              case ' Railgun ':
                if (altclassnum != 2 && canreload) { usingreloadpri = true; }
                else
                {
                    ammotype1 = ammotype2 ? ammotype2 : null;
                    if (ammotype2) { ammotype2 = null; }
                }
                break;

              case 'Glock 17':
                switch (altclassnum)
                {
                  default:
                    if (pistolammo) { ammotype2 = usingclip; }

                    if (canreload) { usingreloadpri = true; }
                    else
                    {
                        ammotype1 = ammotype2 ? ammotype2 : null;
                        if (ammotype2) { ammotype2 = null; }
                    }
                    break;

                  case 2:
                    ammotype2 = Ammo(CPlayer.mo.FindInventory("DukePistolDumDumReload"));
                    ammotype3 = Ammo(CPlayer.mo.FindInventory("Duke64DumDums"));

                    if (pistolammo)
                    {
                        ammotype4 = ammotype3 ? ammotype3 : null;
                        ammotype3 = usingclip;
                    }

                    if (canreload)
                    {
                        usingreloadpri = true;
                        usingreloadsec = true;
                    } else {
                        ammotype1 = ammotype3 ? ammotype3 : null;
                        ammotype2 = ammotype4 ? ammotype4 : null;
                        if (ammotype3) { ammotype3 = null; }
                        if (ammotype4) { ammotype4 = null; }
                    }
                    break;
                }
                break;

              case '  Shotgun  ':
              case 'RPG':
              case 'Freezethrower':
              case 'Devastator Weapon':
                if (altclassnum == 2)
                {
                    switch (weaponname)
                    {
                      case '  Shotgun  ': ammotype2 = Ammo(CPlayer.mo.FindInventory("Duke64ExplosiveShells")); break;
                      case 'RPG': ammotype2 = Ammo(CPlayer.mo.FindInventory("Duke64HeatSeekingRockets")); break;
                      case 'Freezethrower': ammotype2 = Ammo(CPlayer.mo.FindInventory("Duke64ShrinkerAmmo")); break;

                      case 'Devastator Weapon':
                        ammotype2 = CPlayer.mo.FindInventory("Duke64PlasmaCharge");
                        showammo2perc = true;
                        break;
                    }
                }
                break;

              case 'Expander':
              case 'Shrinker':
                usingaltammo = weaponname == "Shrinker";

                ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("ShrinkerAmmo"));
                if (usingaltammo) { ammotype1 = usingcell; }
                break;

              case 'Alien Weapon':
              case ' Alien Weapon ':
                if (CVar.FindCVar("goh_samsara_showalienweaponammo").GetBool()) { ammotype1 = Ammo(CPlayer.mo.FindInventory("UnknownAmmo" .. (weaponname == " Alien Weapon " ? "2" : ""))); }
                break;

              case 'Grenade Launcher':
              case 'Grenade Launcher DOE':
              case '  Rocket Launcher  ':
              case '  Rocket Launcher DOE  ':
                usingaltammo = weaponname == "Grenade Launcher DOE" || weaponname == "  Rocket Launcher DOE  ";

                if (!vanillaquake) { ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("MultiRocketAmmo")); }
                if (usingaltammo) { ammotype1 = usingrocketammo; }
                break;

              case 'Nailgun':
              case 'Nailgun DOE':
              case 'Super Nailgun':
              case 'Super Nailgun DOE':
                usingaltammo = weaponname == "Nailgun DOE" || weaponname == "Super Nailgun DOE";

                if (!vanillaquake) { ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("LavaNails")); }
                if (usingaltammo) { ammotype1 = usingclip; }
                break;

              case 'Thunderbolt':
              case 'Thunderbolt DOE':
                usingaltammo = weaponname == "Thunderbolt DOE";

                if (!vanillaquake) { ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("PlasmaCell")); }
                if (usingaltammo) { ammotype1 = usingcell; }
                break;

              case '  Crossbow  ':
              case '  Crossbow Poison  ':
                usingaltammo = weaponname == "  Crossbow Poison  ";

                ammotype2 = Ammo(usingaltammo ? ammotype1 : CPlayer.mo.FindInventory("StrifePoisonAmmo"));
                if (usingaltammo) { ammotype1 = usingshell; }
                break;

              case ' Grenade Launcher ':
              case ' Grenade Launcher WP ':
              case ' Grenade Launcher Gas ':
                let usingwpammo = weaponname == " Grenade Launcher WP ";
                let usinggasammo = weaponname == " Grenade Launcher Gas ";

                ammotype3 = Ammo(usinggasammo ? ammotype1 : CPlayer.mo.FindInventory("StrifeGasGrenadeAmmo"));
                ammotype2 = Ammo(usingwpammo ? ammotype1 : CPlayer.mo.FindInventory("WhitePhosGrenade"));
                if (usingwpammo || usinggasammo) { ammotype1 = usingrocketammo; }
                break;

              case ' Tazer ':
              case ' Aldus Pistol ':
              case ' Aldus Flamethrower ':
              case ' Plasma Shotgun ':
              case ' Fast Chaingun ':
              case ' Gatling Gun ':
              case ' Fast Rocket Launcher ':
              case ' Laser Cannon ':
                if (weaponname == " Aldus Pistol " && pistolammo) { ammotype1 = usingclip; }

                if (CPlayer.mo.FindInventory("IPOGGrenadeToken"))
                {
                    if (!ammotype1) { ammotype1 = usingrocketammo; }
                    else
                    {
                        ammotype2 = usingrocketammo;
                        alwaysshowammo2 = weaponname == " Fast Rocket Launcher ";
                    }
                }
                break;

              case 'Witchaven_Dagger':
              case 'Shortsword':
              case 'Broad Sword':
                currentmode = weaponname != "Witchaven_Dagger" ? CPlayer.mo.FindInventory("WTSlotIClip") : null;

                if (currentmode) { ammotype1 = null; }

                if (CPlayer.mo.FindInventory("WTShieldActive"))
                {
                    let usingshield = CPlayer.mo.FindInventory("WTShieldCounter");

                    if (!ammotype1) { ammotype1 = usingshield; }
                    else { ammotype2 = usingshield; }
                } else {
                    if (weaponname == "Broad Sword" && Weapon(CPlayer.mo.FindInventory("Fire Mace")) && !currentmode)
                    {
                        if (!ammotype1) { ammotype1 = usingrocketammo; }
                        else { ammotype2 = usingrocketammo; }
                    }
                }
                break;

              case 'Spellbook':
                currentmode = CPlayer.mo.FindInventory("WTSpellCounter");

                if (currentmode)
                {
                    switch (currentmode.Amount)
                    {
                      case 1:
                        ammotype1 = usingclip;
                        ammotype2 = usingshell;
                        break;

                      case 2: ammotype1 = usingcell; break;

                      case 3:
                        ammotype1 = usingrocketammo;
                        ammotype2 = usingcell;
                        break;

                      case 4:
                        ammotype1 = usingclip;
                        ammotype2 = usingshell;
                        ammotype3 = usingcell;
                        break;

                      case 5:
                        ammotype1 = usingclip;
                        ammotype2 = usingshell;
                        ammotype3 = usingrocketammo;
                        break;

                      case 6:
                        ammotype1 = usingclip;
                        ammotype2 = usingrocketammo;
                        break;

                      default:
                        ammotype1 = usingclip;
                        ammotype2 = usingshell;
                        ammotype3 = usingrocketammo;
                        ammotype4 = usingcell;
                        break;
                    }
                }
                break;

              case 'Bow and Arrows':
              case 'Battle Axe':
              case 'Ice Halberd':
              case 'Fire Mace':
              case 'Frozen Two-Hand Sword':
              case 'Pike Axe':
                switch (weaponname)
                {
                  case 'Bow and Arrows': currentmode = CPlayer.mo.FindInventory("WTBowUpgrade"); break;
                  case 'Battle Axe': currentmode = CPlayer.mo.FindInventory("WTSlotIIClip"); break;
                  case 'Ice Halberd': currentmode = CPlayer.mo.FindInventory("WTSlotIVClip"); break;
                  case 'Fire Mace': currentmode = CPlayer.mo.FindInventory("WTSlotVClip"); break;
                  case 'Frozen Two-Hand Sword': currentmode = CPlayer.mo.FindInventory("WTSlotVIIClip"); break;
                  case 'Pike Axe': currentmode = CPlayer.mo.FindInventory("WTSlotIIIClip"); break;
                }

                switch (weaponname)
                {
                  case 'Bow and Arrows':
                    if (!currentmode) { ammotype1 = null; }
                    break;

                  default:
                    if (currentmode) { ammotype1 = null; }
                    break;
                }
                break;

              case 'MagicFist':
                currentmode = CPlayer.mo.FindInventory("usingmagicfisttype");

                if (currentmode)
                {
                    switch (currentmode.Amount)
                    {
                      case 1: ammotype1 = usingclip; break;
                      case 2: ammotype1 = usingshell; break;
                      case 3: ammotype1 = usingrocketammo; break;
                      default: ammotype1 = usingcell; break;
                    }
                }
                break;

              case ' RR Hunting Crossbow ':
              case ' RR Dynomite Crossbow ':
              case ' Chicken Crossbow ':
                let chickenammo = Ammo(CPlayer.mo.FindInventory("ChickenAmmo"));

                let usingdynomiteammo = weaponname == " RR Dynomite Crossbow ";
                let usingchickenammo = weaponname == " Chicken Crossbow ";

                if (Weapon(CPlayer.mo.FindInventory(" Dyn 'O' Mites ")))
                {
                    ammotype3 = usingchickenammo ? Ammo(ammotype1) : chickenammo;
                    ammotype2 = usingdynomiteammo ? Ammo(ammotype1) : usingrocketammo;
                }
                else { ammotype2 = usingchickenammo ? Ammo(ammotype1) : chickenammo; }

                if (usingdynomiteammo || usingchickenammo) { ammotype1 = usingshell; }
                break;

              case 'Goldeneye_PP7Silenced':
              case 'Goldeneye_Klobb':
              case 'Goldeneye_PP7SpecialIssue':
              case 'Goldeneye_DD44':
              case 'Goldeneye_KF7Soviet':
              case 'Goldeneye_AutoShotgun':
              case 'Goldeneye_Shotgun':
              case 'Goldeneye_AR33':
              case 'Goldeneye_Phantom':
              case 'Goldeneye_RocketLauncher':
              case 'Goldeneye_GrenadeLauncher':
              case 'Goldeneye_RCP90':
              case 'Goldeneye_Cougar':
              case 'Goldeneye_SilverPP7':
              case 'Goldeneye_ArabahViper':
              case 'Goldeneye_GoldenGun':
              case 'Goldeneye_SniperRifle':
              case 'Goldeneye_SilencedD5K':
              case 'Goldeneye_ZMG':
              case 'Goldeneye_D5KDeutsche':
              case 'Goldeneye_GoldPP7':
              case 'Goldeneye_TankWeapon':
              case 'Goldfinger_PPKSilenced':
              case 'Goldfinger_PPK':
              case 'Goldfinger_ColtM1911':
              case 'Goldfinger_LugerP08':
              case 'Goldfinger_WaltherP38':
              case 'Goldfinger_MP40':
              case 'Goldfinger_Shotgun':
              case 'Goldfinger_OverUnder':
              case 'Goldfinger_AK47':
              case 'Goldfinger_ThompsonDrum':
              case 'Goldfinger_Thompson':
              case 'Goldfinger_SuperBazooka':
              case 'Goldfinger_M79':
              case 'Goldfinger_M1Carbine':
              case 'Goldfinger_M1Garand':
              case 'Goldfinger_Kar98k':
              case 'Goldfinger_M14':
              case 'Goldfinger_AR7':
              case 'Goldfinger_UZI':
              case 'Goldfinger_SmithWesson22':
              case 'Goldfinger_SmithWesson36':
              case 'Goldfinger_GoldMagnum':
                switch (weaponname)
                {
                  case 'Goldeneye_PP7Silenced':
                  case 'Goldeneye_Klobb':
                  case 'Goldeneye_PP7SpecialIssue':
                  case 'Goldeneye_DD44':
                  case 'Goldfinger_PPKSilenced':
                  case 'Goldfinger_PPK':
                  case 'Goldfinger_ColtM1911':
                  case 'Goldfinger_LugerP08':
                  case 'Goldfinger_WaltherP38':
                    if (pistolammo) { ammotype2 = usingclip; }
                    break;
                }

                usingdual = weaponname != "Goldeneye_TankWeapon" && !canshowpendingweapon ? CPlayer.mo.FindInventory("BondDualWieldToken") : null;

                if (usingdual)
                {
                    ammotype3 = ammotype2 ? ammotype2 : null;

                    switch (weaponname)
                    {
                      default: ammotype2 = Ammo(CPlayer.mo.FindInventory(weaponname .. "DualMagazine")); break;
                      case 'Goldeneye_PP7SpecialIssue': ammotype2 = Ammo(CPlayer.mo.FindInventory("Goldeneye_PP7DualMagazine")); break;
                      case 'Goldeneye_KF7Soviet': ammotype2 = Ammo(CPlayer.mo.FindInventory("Goldeneye_KF7DualMagazine")); break;
                      case 'Goldeneye_SniperRifle': ammotype2 = Ammo(CPlayer.mo.FindInventory("Goldeneye_SniperDualMagazine")); break;
                      case 'Goldeneye_SilencedD5K': ammotype2 = Ammo(CPlayer.mo.FindInventory("Goldeneye_D5KSilencedDualMagazine")); break;
                      case 'Goldeneye_D5KDeutsche': ammotype2 = Ammo(CPlayer.mo.FindInventory("Goldeneye_D5KDualMagazine")); break;
                    }
                }

                if (canreload)
                {
                    usingreloadpri = true;
                    usingreloadsec = usingdual;
                } else {
                    ammotype1 = usingdual ? (ammotype3 ? ammotype3 : null) : (ammotype2 ? ammotype2 : null);
                    if (ammotype2) { ammotype2 = null; }
                    if (ammotype3) { ammotype3 = null; }
                }
                break;

              case 'Catacomb3D_MagicMissile':
              case 'Catacomb_WavesQuickSpell':
              case 'Catacomb_XTerminatorsQuickSpell':
              case 'Catacomb_BurstsQuickSpell':
              case 'Catacomb_ZappersQuickSpell':
              case 'Catacomb_NukesQuickSpell':
              case 'Catacomb_BoltsQuickSpell':
              case 'Catacomb_AtomicQuickSpell':
                let chargetime = CPlayer.mo.FindInventory("Catacomb3D_ChargeTime");

                if (chargetime && !canshowpendingweapon)
                {
                    if (!ammotype1)
                    {
                        ammotype1 = chargetime;
                        showammo1perc = true;
                    } else if (!ammotype2) {
                        ammotype2 = chargetime;
                        showammo2perc = true;
                    } else {
                        ammotype3 = chargetime;
                        showammo3perc = true;
                    }
                }
                break;

              case 'DescentWeapon':
              case 'DescentWeaponPadUp':
              case 'DescentWeaponPadDown':
              case 'DescentLaser':
              case 'DescentSuperLaser':
              case 'DescentVulcan':
              case 'DescentGauss':
              case 'DescentSpreadFire':
              case 'DescentFusion':
              case 'DescentHelix':
              case 'DescentOmega':
              case 'DescentPlasma':
              case 'DescentPhoenix':
                // Primary
                if (ammotype1) { ammotype1 = null; }

                let descentweapon1counter = CPlayer.mo.FindInventory("DescentPrimaryCounter");

                if (!descentweapon1counter)
                {
                    if (pistolammo) { ammotype1 = usingclip; }
                } else {
                    let descentweapon1counteramount = descentweapon1counter.Amount;

                    switch (descentweapon1counteramount)
                    {
                      case 1:
                      case 2:
                      case 3:
                      case 4:
                      case 6:
                      case 8:
                        if (descentweapon1counteramount != 1 || pistolammo) { ammotype1 = usingclip; }
                        break;

                      default: ammotype1 = usingcell; break;
                    }
                }

                // Secondary
                if (ammotype2) { ammotype2 = null; }

                let descentweapon2counter = CPlayer.mo.FindInventory("DescentSecondaryCounter");

                if (!descentweapon2counter)
                {
                    if (pistolammo)
                    {
                        if (!ammotype1) { ammotype1 = usingshell; }
                        else { ammotype2 = usingshell; }
                    }
                } else {
                    let descentweapon2counteramount = descentweapon2counter.Amount;

                    switch (descentweapon2counteramount)
                    {
                      default:
                        if (!ammotype1) { ammotype1 = usingshell; }
                        else { ammotype2 = usingshell; }
                        break;

                      case 5:
                      case 7:
                        if (!ammotype1) { ammotype1 = usingrocketammo; }
                        else { ammotype2 = usingrocketammo; }
                        break;
                    }
                }
                break;
            }
        }

        for (int checkedammotypes = 1; checkedammotypes <= 4; checkedammotypes++)
        {
            Name weaponname;

            if (canshowpendingweapon) { weaponname = CPlayer.PendingWeapon.GetClassName(); }
            else if (CPlayer.ReadyWeapon) { weaponname = CPlayer.ReadyWeapon.GetClassName(); }

            Inventory ammotype, ammotypereload;
            Name ammobarcolor;
            Name ammotextcolor;
            String ammostring;
            bool showammoperc = false;

            let showingmagazinelabel = CVar.FindCVar("goh_reloadableammolabel").GetBool();

            switch (checkedammotypes)
            {
              case 1:
                if (!ammotype1 && !alwaysshowammo1) { continue; }

                ammotype = ammotype1;

                if ((usingreloadpri || usingreloadsec) && !(weaponname == "Glock 17" && altclassnum == 2 && !pistolammo))
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
                if ((!ammotype2 || ammotype2 == ammotype1) && !alwaysshowammo2) { continue; }

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
                if (!ammotype3 && !alwaysshowammo3) { continue; }

                ammotype = ammotype3;
                ammobarcolor = "yellow";
                ammotextcolor = "[Yellow]";
                ammostring = "$GOODOLHUD_AMMO" .. (usingreloadpri && usingreloadsec ? "1" : (usingreloadpri || usingreloadsec ? "2" : "3"));
                showammoperc = showammo3perc;
                break;

              case 4:
                if ((!ammotype4 || ammotype4 == ammotype3) && !alwaysshowammo4) { continue; }

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
              case 'DukePipebombSpeed':
              case 'ThrowPower':
              case 'SamsaraDarkForcesThermalDetonatorThrowPower':
              case 'PS_AMUNHOLD':
              case 'Outlaws_ThrowCounter':
                ammostring = "$GOODOLHUD_" .. (ammoname == "ThrowPower" && weaponname == "BloodFlamethrower" ? "CHARGE" : "THROWPOWER");
                break;

              case 'Duke64PlasmaCharge':
              case 'PSSacredManacleCharges':
              case 'Catacomb3D_ChargeTime':
                ammostring = "$GOODOLHUD_CHARGE";
                break;

              case 'RTCW_VenomHeat':
              case 'RTCW_MG42Heat':
              case 'RTCW_StenHeat':
              case 'RTCW_BrowningHeat':
                ammostring = "$GOODOLHUD_HEAT";
                break;

              case 'C7ProxyMineAmmo': ammostring = "$GOODOLHUD_AMMO_SAMSARA_" .. ammoname; break;

              case 'RocketAmmo':
                switch (weaponname)
                {
                  case ' Tazer ':
                  case ' Aldus Pistol ':
                  case ' Aldus Flamethrower ':
                  case ' Plasma Shotgun ':
                  case ' Fast Chaingun ':
                  case ' Gatling Gun ':
                  case ' Fast Rocket Launcher ':
                  case ' Laser Cannon ':
                    if (weaponname != " Fast Rocket Launcher " || (weaponname == " Fast Rocket Launcher " && checkedammotypes == 2)) { ammostring = "$GOODOLHUD_AMMO_SAMSARA_IPOGGRENADES"; }
                    break;
                }
                break;

              case 'WTShieldCounter': ammostring = "$GOODOLHUD_SAMSARA_WITCHAVENSHIELD"; break;
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
        int maxammocapacities = 49 * 2;

        static const Name AmmoCapacityDefinitions[] =
        {
            // Ammo 1A
            "Clip",           "[Yellow]",
            "RottMissiles",   "[Yellow]",
            "Catacomb_Waves", "[Yellow]",
            // Ammo 1B
            "Duke64DumDums",         "[Orange]",
            "LavaNails",             "[Orange]",
            "DisruptorHiFreq",       "[Orange]",
            "Painkiller_FlamerAmmo", "[Orange]",
            // Ammo 2A
            "Shell",                 "[Red]",
            "HSMissiles",            "[Red]",
            "Catacomb_XTerminators", "[Red]",
            // Ammo 2B
            "Duke64ExplosiveShells",  "[Brick]",
            "StrifePoisonAmmo",       "[Brick]",
            "Painkiller_FreezerAmmo", "[Brick]",
            // Ammo 3A
            "RocketAmmo",     "[Brown]",
            "FBMissiles",     "[Brown]",
            "Catacomb_Nukes", "[Brown]",
            // Ammo 3B
            "Duke64HeatSeekingRockets", "[DarkBrown]",
            "MultiRocketAmmo",          "[DarkBrown]",
            "WhitePhosGrenade",         "[DarkBrown]",
            "DisruptorBinaryLockOn",    "[DarkBrown]",
            "Painkiller_HeaterAmmo",    "[DarkBrown]",
            // Ammo 3C
            "StrifeGasGrenadeAmmo", "[DarkGreen]",
            // Ammo 4A
            "Cell",           "[LightBlue]",
            "DMissiles",      "[LightBlue]",
            "Catacomb_Bolts", "[LightBlue]",
            // Ammo 4B
            "ShrinkerAmmo",           "[Teal]",
            "Duke64ShrinkerAmmo",     "[Teal]",
            "PlasmaCell",             "[Teal]",
            "Painkiller_ElectroAmmo", "[Teal]",
            // Ammo 5
            "MotoGunAmmo",      "[Green]",
            "Q2Flechettes",     "[Green]",
            "Catacomb_Zappers", "[Green]",
            "RTCW_AlliedAmmo1", "[Green]",
            "Q3ChaingunAmmo",   "[Green]",
            // Ammo 6
            "SMissiles",                    "[Purple]",
            "Goldeneye_ThrowingKnivesAmmo", "[Purple]",
            "Catacomb_Bursts",              "[Purple]",
            "RTCW_AlliedAmmo2",             "[Purple]",
            // Ammo 7
            "DoomguyStrMines",           "[Cyan]",
            "DMMissiles",                "[Cyan]",
            "ChickenAmmo",               "[Cyan]",
            "Goldeneye_GoldenGunRounds", "[Cyan]",
            "RTCW_AlliedAmmo3",          "[Cyan]",
            "Q3GrenadeLauncherAmmo",     "[Cyan]",
            // Ammo 8
            "DoomguyStrGas",              "[Bijou]",
            "Totenkopf_FlameThrowerFuel", "[Bijou]",
            "FWMissiles",                 "[Bijou]",
            "SprayCanAmmo",               "[Bijou]",
            "RTCW_AlliedAmmo4",           "[Bijou]"
        };

        Vector2 coordnudge;

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        let vanillaquake = CPlayer.mo.FindInventory("QuakeModeOn");

        int currentammo, currentammomax;
        String ammoidentifier;

        for (int checkedammocapacities = maxammocapacities - 1; checkedammocapacities >= 0; checkedammocapacities -= 2)
        {
            Name ammocapacity = AmmoCapacityDefinitions[checkedammocapacities - 1];

            // do not show for incompatible classes/settings
            switch (ammocapacity)
            {
              case 'Clip':
              case 'Cell':
                switch (classnum)
                {
                  case CLASS_ROTT:
                  case CLASS_CATACOMB:
                    continue;
                }
                break;

              case 'Shell':
                switch (classnum)
                {
                  case CLASS_WOLFEN:
                    if (classnum == CLASS_WOLFEN && altclassnum == 2) { break; }

                  case CLASS_HEXEN:
                  case CLASS_ROTT:
                  case CLASS_DEMONESS:
                  case CLASS_CATACOMB:
                    continue;
                }
                break;

              case 'RocketAmmo':
                switch (classnum)
                {
                  case CLASS_HEXEN:
                  case CLASS_ROTT:
                  case CLASS_DEMONESS:
                  case CLASS_CATACOMB:
                    continue;
                }
                break;

              case 'DoomguyStrMines':
              case 'DoomguyStrGas':
                switch (classnum)
                {
                  case CLASS_DOOM:
                    if (classnum == CLASS_DOOM && altclassnum == 2) { break; }

                  default: continue;
                }
                break;

              case 'Totenkopf_FlameThrowerFuel':
                switch (classnum)
                {
                  case CLASS_WOLFEN:
                    if (classnum == CLASS_WOLFEN && altclassnum == 2) { break; }

                  default: continue;
                }
                break;

              case 'ShrinkerAmmo':
                switch (classnum)
                {
                  case CLASS_DUKE:
                    if (classnum == CLASS_DUKE && altclassnum != 2) { break; }

                  default: continue;
                }
                break;

              case 'Duke64DumDums':
              case 'Duke64ExplosiveShells':
              case 'Duke64HeatSeekingRockets':
              case 'Duke64ShrinkerAmmo':
                switch (classnum)
                {
                  case CLASS_DUKE:
                    if (classnum == CLASS_DUKE && altclassnum == 2) { break; }

                  default: continue;
                }
                break;

              case 'LavaNails':
              case 'MultiRocketAmmo':
              case 'PlasmaCell':
                switch (classnum)
                {
                  case CLASS_QUAKE:
                    if (!vanillaquake) { break; }

                  default: continue;
                }
                break;

              case 'RottMissiles':
              case 'HSMissiles':
              case 'FBMissiles':
              case 'DMissiles':
              case 'SMissiles':
              case 'DMMissiles':
              case 'FWMissiles':
                switch (classnum)
                {
                  case CLASS_ROTT: break;
                  default: continue;
                }
                break;

              case 'SprayCanAmmo':
                switch (classnum)
                {
                  case CLASS_CALEB: break;
                  default: continue;
                }
                break;

              case 'StrifePoisonAmmo':
              case 'WhitePhosGrenade':
              case 'StrifeGasGrenadeAmmo':
                switch (classnum)
                {
                  case CLASS_STRIFE: break;
                  default: continue;
                }
                break;

              case 'DisruptorHiFreq':
              case 'DisruptorBinaryLockOn':
                switch (classnum)
                {
                  case CLASS_DISRUPTOR: break;
                  default: continue;
                }
                break;

              case 'MotoGunAmmo':
              case 'ChickenAmmo':
                switch (classnum)
                {
                  case CLASS_RR: break;
                  default: continue;
                }
                break;

              case 'Q2Flechettes':
                switch (classnum)
                {
                  case CLASS_BITTERMAN: break;
                  default: continue;
                }
                break;

              case 'Goldeneye_ThrowingKnivesAmmo':
                switch (classnum)
                {
                  case CLASS_BOND:
                    if (classnum == CLASS_BOND && altclassnum == 0) { break; }

                  default: continue;
                }
                break;

              case 'Goldeneye_GoldenGunRounds':
                switch (classnum)
                {
                  case CLASS_BOND: break;
                  default: continue;
                }
                break;

              case 'Catacomb_Waves':
              case 'Catacomb_XTerminators':
              case 'Catacomb_Nukes':
              case 'Catacomb_Bolts':
              case 'Catacomb_Zappers':
              case 'Catacomb_Bursts':
                switch (classnum)
                {
                  case CLASS_CATACOMB: break;
                  default: continue;
                }
                break;

              case 'Painkiller_FlamerAmmo':
              case 'Painkiller_FreezerAmmo':
              case 'Painkiller_HeaterAmmo':
              case 'Painkiller_ElectroAmmo':
                switch (classnum)
                {
                  case CLASS_PAINKILLER: break;
                  default: continue;
                }
                break;

              case 'RTCW_AlliedAmmo1':
              case 'RTCW_AlliedAmmo2':
              case 'RTCW_AlliedAmmo3':
              case 'RTCW_AlliedAmmo4':
                switch (classnum)
                {
                  case CLASS_RTCW: break;
                  default: continue;
                }
                break;

              case 'Q3ChaingunAmmo':
              case 'Q3GrenadeLauncherAmmo':
                switch (classnum)
                {
                  case CLASS_QUAKE3: break;
                  default: continue;
                }
                break;
            }

            // adjust identifiers
            switch (ammocapacity)
            {
              case 'Clip':
              case 'RottMissiles':
              case 'Catacomb_Waves':
                ammoidentifier = "1";

                if (ammocapacity != "Clip") { break; }

                switch (classnum)
                {
                  case CLASS_DUKE:
                    if (classnum == CLASS_DUKE && altclassnum != 2) { break; }

                  case CLASS_QUAKE:
                    if (vanillaquake) { break; }

                  case CLASS_DISRUPTOR:
                  case CLASS_PAINKILLER:
                    ammoidentifier = ammoidentifier .. "A";
                    break;
                }
                break;

              case 'Duke64DumDums':
              case 'LavaNails':
              case 'DisruptorHiFreq':
              case 'Painkiller_FlamerAmmo':
                ammoidentifier = "1B";
                break;

              case 'Shell':
              case 'HSMissiles':
              case 'Catacomb_XTerminators':
                ammoidentifier = "2";

                if (ammocapacity != "Shell") { break; }

                switch (classnum)
                {
                  case CLASS_DUKE:
                    if (classnum == CLASS_DUKE && altclassnum != 2) { break; }

                  case CLASS_STRIFE:
                  case CLASS_PAINKILLER:
                    ammoidentifier = ammoidentifier .. "A";
                    break;
                }
                break;

              case 'Duke64ExplosiveShells':
              case 'StrifePoisonAmmo':
              case 'Painkiller_FreezerAmmo':
                ammoidentifier = "2B";
                break;

              case 'RocketAmmo':
              case 'FBMissiles':
              case 'Catacomb_Nukes':
                ammoidentifier = "3";

                if (ammocapacity != "RocketAmmo") { break; }

                switch (classnum)
                {
                  case CLASS_DUKE:
                    if (classnum == CLASS_DUKE && altclassnum != 2) { break; }

                  case CLASS_QUAKE:
                    if (vanillaquake) { break; }

                  case CLASS_STRIFE:
                  case CLASS_DISRUPTOR:
                  case CLASS_PAINKILLER:
                    ammoidentifier = ammoidentifier .. "A";
                    break;
                }
                break;

              case 'Duke64HeatSeekingRockets':
              case 'MultiRocketAmmo':
              case 'WhitePhosGrenade':
              case 'DisruptorBinaryLockOn':
              case 'Painkiller_HeaterAmmo':
                ammoidentifier = "3B";
                break;

              case 'StrifeGasGrenadeAmmo':
                ammoidentifier = "3C";
                break;

              case 'Cell':
              case 'DMissiles':
              case 'Catacomb_Bolts':
                ammoidentifier = "4";

                if (ammocapacity != "Cell") { break; }

                switch (classnum)
                {
                  case CLASS_QUAKE:
                    if (vanillaquake) { break; }

                  case CLASS_DUKE:
                  case CLASS_PAINKILLER:
                    ammoidentifier = ammoidentifier .. "A";
                    break;
                }
                break;

              case 'ShrinkerAmmo':
              case 'Duke64ShrinkerAmmo':
              case 'PlasmaCell':
              case 'Painkiller_ElectroAmmo':
                ammoidentifier = "4B";
                break;

              case 'MotoGunAmmo':
              case 'Q2Flechettes':
              case 'Catacomb_Zappers':
              case 'RTCW_AlliedAmmo1':
              case 'Q3ChaingunAmmo':
                ammoidentifier = "5";
                break;

              case 'SMissiles':
              case 'Goldeneye_ThrowingKnivesAmmo':
              case 'Catacomb_Bursts':
              case 'RTCW_AlliedAmmo2':
                ammoidentifier = "6";
                break;

              case 'DoomguyStrMines':
              case 'DMMissiles':
              case 'ChickenAmmo':
              case 'Goldeneye_GoldenGunRounds':
              case 'RTCW_AlliedAmmo3':
              case 'Q3GrenadeLauncherAmmo':
                ammoidentifier = "7";
                break;

              case 'DoomguyStrGas':
              case 'Totenkopf_FlameThrowerFuel':
              case 'FWMissiles':
              case 'SprayCanAmmo':
              case 'RTCW_AlliedAmmo4':
                ammoidentifier = "8";
                break;
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
        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        Name weaponname;

        let canshowpendingweapon = CVar.FindCVar("goh_showpendingweapon").GetBool() && CPlayer.PendingWeapon != WP_NOCHANGE;

        if (canshowpendingweapon) { weaponname = CPlayer.PendingWeapon.GetClassName(); }
        else if (CPlayer.ReadyWeapon) { weaponname = CPlayer.ReadyWeapon.GetClassName(); }

        let descentsecondaryactive = CPlayer.mo.FindInventory("DescentSecondaryTrigger");

        bool hasslot1 = (classnum == CLASS_WOLFEN && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon0")) ||
                        (classnum == CLASS_WOLFEN && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon0") || Weapon(CPlayer.mo.FindInventory("Totenkopf_MauserDual")))) ||
                        (classnum == CLASS_MARATHON && (CPlayer.mo.FindInventory("GotWeapon0") || CPlayer.mo.FindInventory("CanDualPistols"))) ||
                        (classnum == CLASS_WITCHAVEN && CPlayer.mo.FindInventory("WTShieldTrigger")) ||
                        (classnum == CLASS_CATACOMB && Weapon(CPlayer.mo.FindInventory("Catacomb_WavesQuickSpell"))) ||
                        (classnum == CLASS_RTCW && (CPlayer.mo.FindInventory("GotWeapon0") || Weapon(CPlayer.mo.FindInventory("RTCW_Pineapple")))) ||
                        (classnum == CLASS_DESCENT && ((!descentsecondaryactive && CPlayer.mo.FindInventory("DescentLaserLevel") && CPlayer.mo.FindInventory("DescentLaserLevel").Amount >= 4) || (descentsecondaryactive && CPlayer.mo.FindInventory("GotWeapon0")))) ||
                        (classnum != CLASS_WOLFEN && classnum != CLASS_MARATHON && classnum != CLASS_WITCHAVEN && classnum != CLASS_CATACOMB && classnum != CLASS_RTCW && classnum != CLASS_DESCENT && CPlayer.mo.FindInventory("GotWeapon0"));

        bool hasslot2 = (classnum == CLASS_WOLFEN && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon2")) ||
                        (classnum == CLASS_WOLFEN && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon2") || Weapon(CPlayer.mo.FindInventory("Totenkopf_Sniper")))) ||
                        (classnum == CLASS_CATACOMB && Weapon(CPlayer.mo.FindInventory("Catacomb_XTerminatorsQuickSpell"))) ||
                        (classnum == CLASS_RTCW && (CPlayer.mo.FindInventory("GotWeapon2") || Weapon(CPlayer.mo.FindInventory("RTCW_Thompson")))) ||
                        (classnum != CLASS_WOLFEN && classnum != CLASS_CATACOMB && classnum != CLASS_RTCW && CPlayer.mo.FindInventory("GotWeapon2"));

        bool hasslot3 = (classnum == CLASS_DOOM && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon3")) ||
                        (classnum == CLASS_DOOM && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon3") || Weapon(CPlayer.mo.FindInventory("Automatic Shotgun")))) ||
                        (classnum == CLASS_CATACOMB && Weapon(CPlayer.mo.FindInventory("Catacomb_BurstsQuickSpell"))) ||
                        (classnum == CLASS_RTCW && (CPlayer.mo.FindInventory("GotWeapon3") || Weapon(CPlayer.mo.FindInventory("RTCW_Snooper")))) ||
                        (classnum != CLASS_DOOM && classnum != CLASS_CATACOMB && classnum != CLASS_RTCW && CPlayer.mo.FindInventory("GotWeapon3"));

        bool hasslot4 = (classnum == CLASS_DOOM && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon4")) ||
                        (classnum == CLASS_DOOM && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon4") || Weapon(CPlayer.mo.FindInventory(" Flamer ")))) ||
                        (classnum == CLASS_WOLFEN && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon4")) ||
                        (classnum == CLASS_WOLFEN && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon4") || Weapon(CPlayer.mo.FindInventory("Totenkopf_MP40Dual")))) ||
                        (classnum == CLASS_CATACOMB && Weapon(CPlayer.mo.FindInventory("Catacomb_ZappersQuickSpell"))) ||
                        (classnum != CLASS_DOOM && classnum != CLASS_WOLFEN && classnum != CLASS_CATACOMB && CPlayer.mo.FindInventory("GotWeapon4"));

        bool hasslot4skulltag = (classnum == CLASS_DOOM && Weapon(CPlayer.mo.FindInventory(" Minigun "))) ||
                                (classnum == CLASS_CHEX && Weapon(CPlayer.mo.FindInventory("Ultra Rapid Zorcher"))) ||
                                (classnum == CLASS_WOLFEN && altclassnum != 2 && Weapon(CPlayer.mo.FindInventory("  Dual Chainguns  "))) ||
                                (classnum == CLASS_DUKE && altclassnum != 2 && Weapon(CPlayer.mo.FindInventory("Golden Desert Eagle"))) ||
                                (classnum == CLASS_QUAKE && Weapon(CPlayer.mo.FindInventory("Q1AssaultCannon"))) ||
                                (classnum == CLASS_ROTT && Weapon(CPlayer.mo.FindInventory("RoTTM60"))) ||
                                (classnum == CLASS_BLAKE && Weapon(CPlayer.mo.FindInventory("Gatling Fusion Devastator"))) ||
                                (classnum == CLASS_CALEB && Weapon(CPlayer.mo.FindInventory("BloodGreaseGun"))) ||
                                (classnum == CLASS_ERAD && altclassnum == 0 && Weapon(CPlayer.mo.FindInventory("EradEnergywhip"))) ||
                                (classnum == CLASS_ERAD && altclassnum == 1 && Weapon(CPlayer.mo.FindInventory("EradNitrofogger"))) ||
                                (classnum == CLASS_ERAD && altclassnum >= 2 && Weapon(CPlayer.mo.FindInventory("EradFlamethrower"))) ||
                                (classnum == CLASS_KATARN && Weapon(CPlayer.mo.FindInventory("DLT-19 Heavy Blaster Rifle"))) ||
                                (classnum == CLASS_POGREED && Weapon(CPlayer.mo.FindInventory(" Gatling Gun "))) ||
                                (classnum == CLASS_HALFLIFE && Weapon(CPlayer.mo.FindInventory("HLUzi"))) ||
                                (classnum == CLASS_BITTERMAN && Weapon(CPlayer.mo.FindInventory("Q2ETFRifle"))) ||
                                (classnum == CLASS_BOND && altclassnum == 0 && Weapon(CPlayer.mo.FindInventory("Goldeneye_Phantom"))) ||
                                (classnum == CLASS_BOND && altclassnum == 1 && (Weapon(CPlayer.mo.FindInventory("Goldfinger_ThompsonDrum")) || Weapon(CPlayer.mo.FindInventory("Goldfinger_Thompson")))) ||
                                (classnum == CLASS_RTCW && (Weapon(CPlayer.mo.FindInventory("RTCW_StG44")) || Weapon(CPlayer.mo.FindInventory("RTCW_BAR")))) ||
                                (classnum == CLASS_QUAKE3 && Weapon(CPlayer.mo.FindInventory("Q3HeavyMachineGun")));

        bool hasslot5 = (classnum == CLASS_DOOM && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon5")) ||
                        (classnum == CLASS_DOOM && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon5") || Weapon(CPlayer.mo.FindInventory("Land Mine Layer")))) ||
                        (classnum == CLASS_CATACOMB && Weapon(CPlayer.mo.FindInventory("Catacomb_NukesQuickSpell"))) ||
                        (classnum != CLASS_DOOM && classnum != CLASS_CATACOMB && CPlayer.mo.FindInventory("GotWeapon5"));

        bool hasslot5skulltag = (classnum == CLASS_DOOM && Weapon(CPlayer.mo.FindInventory(" GrenadeLauncher "))) ||
                                (classnum == CLASS_CHEX && Weapon(CPlayer.mo.FindInventory("Zorch Launcher"))) ||
                                (classnum == CLASS_DUKE && altclassnum != 2 && Weapon(CPlayer.mo.FindInventory("Duke3D_Incinerator"))) ||
                                (classnum == CLASS_ROTT && Weapon(CPlayer.mo.FindInventory("Doomstick"))) ||
                                (classnum == CLASS_CALEB && (Weapon(CPlayer.mo.FindInventory("BloodProximityTNT")) || Weapon(CPlayer.mo.FindInventory("BloodRemoteTNT")))) ||
                                (classnum == CLASS_KATARN && Weapon(CPlayer.mo.FindInventory("I.M. Mines"))) ||
                                (classnum == CLASS_WITCHAVEN && Weapon(CPlayer.mo.FindInventory("Broad Sword"))) ||
                                (classnum == CLASS_BITTERMAN && Weapon(CPlayer.mo.FindInventory("Q2Phalanx"))) ||
                                (classnum == CLASS_BOND && altclassnum == 0 && Weapon(CPlayer.mo.FindInventory("Goldeneye_GrenadeLauncher"))) ||
                                (classnum == CLASS_BOND && altclassnum == 1 && Weapon(CPlayer.mo.FindInventory("Goldfinger_M79"))) ||
                                (classnum == CLASS_RTCW && (Weapon(CPlayer.mo.FindInventory("RTCW_K43")) || Weapon(CPlayer.mo.FindInventory("RTCW_M1Garand")))) ||
                                (classnum == CLASS_SOF && Weapon(CPlayer.mo.FindInventory("SoF_Flamegun")));

        bool hasslot6 = (classnum == CLASS_DOOM && altclassnum != 2 && CPlayer.mo.FindInventory("GotWeapon6")) ||
                        (classnum == CLASS_DOOM && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon6") || Weapon(CPlayer.mo.FindInventory("Stunner Rifle")))) ||
                        (classnum == CLASS_CATACOMB && Weapon(CPlayer.mo.FindInventory("Catacomb_BoltsQuickSpell"))) ||
                        (classnum != CLASS_DOOM && classnum != CLASS_CATACOMB && CPlayer.mo.FindInventory("GotWeapon6"));

        bool hasslot6skulltag = (classnum == CLASS_DOOM && Weapon(CPlayer.mo.FindInventory(" RailGun "))) ||
                                (classnum == CLASS_CHEX && Weapon(CPlayer.mo.FindInventory("Gigazorcher 2100"))) ||
                                (classnum == CLASS_HERETIC && Weapon(CPlayer.mo.FindInventory("CorvusTempestWand"))) ||
                                (classnum == CLASS_WOLFEN && altclassnum != 2 && Weapon(CPlayer.mo.FindInventory("Wolf3DLightningGun"))) ||
                                (classnum == CLASS_DUKE && altclassnum != 2 && (Weapon(CPlayer.mo.FindInventory("Expander")) || Weapon(CPlayer.mo.FindInventory("Shrinker")))) ||
                                (classnum == CLASS_MARATHON && Weapon(CPlayer.mo.FindInventory("SPNKR-25 Auto Cannon"))) ||
                                (classnum == CLASS_QUAKE && Weapon(CPlayer.mo.FindInventory("Rocket Powered Impaler"))) ||
                                (classnum == CLASS_ROTT && Weapon(CPlayer.mo.FindInventory("Split Missile"))) ||
                                (classnum == CLASS_CALEB && Weapon(CPlayer.mo.FindInventory("BloodFlamethrower"))) ||
                                (classnum == CLASS_RMR && Weapon(CPlayer.mo.FindInventory("Subestron Arm"))) ||
                                (classnum == CLASS_KATARN && Weapon(CPlayer.mo.FindInventory("Czerka Adventurer"))) ||
                                (classnum == CLASS_DISRUPTOR && Weapon(CPlayer.mo.FindInventory(" Disruptor Plasmalance "))) ||
                                (classnum == CLASS_BITTERMAN && Weapon(CPlayer.mo.FindInventory("Q2PlasmaBeam"))) ||
                                (classnum == CLASS_BOND && altclassnum == 0 && (Weapon(CPlayer.mo.FindInventory("Goldeneye_Cougar")) || Weapon(CPlayer.mo.FindInventory("Goldeneye_SilverPP7")) || Weapon(CPlayer.mo.FindInventory("Goldeneye_ArabahViper")))) ||
                                (classnum == CLASS_BOND && altclassnum == 1 && (Weapon(CPlayer.mo.FindInventory("Goldfinger_M1Garand")) || Weapon(CPlayer.mo.FindInventory("Goldfinger_Kar98k")))) ||
                                (classnum == CLASS_RTCW && (Weapon(CPlayer.mo.FindInventory("RTCW_MG42")) || Weapon(CPlayer.mo.FindInventory("RTCW_Browning")))) ||
                                (classnum == CLASS_OUTLAWS && Weapon(CPlayer.mo.FindInventory("Outlaws_OrganGun")));

        bool hasslot7 = (classnum == CLASS_DOOM && altclassnum == 0 && CPlayer.mo.FindInventory("GotWeapon7")) ||
                        (classnum == CLASS_DOOM && altclassnum == 1 && (CPlayer.mo.FindInventory("GotWeapon7") || Weapon(CPlayer.mo.FindInventory(" Unmaker ")))) ||
                        (classnum == CLASS_DOOM && altclassnum == 2 && (CPlayer.mo.FindInventory("GotWeapon7") || Weapon(CPlayer.mo.FindInventory("Pyro Cannon")))) ||
                        (classnum == CLASS_CALEB && Weapon(CPlayer.mo.FindInventory("LifeLeech"))) ||
                        (classnum == CLASS_DISRUPTOR && (CPlayer.mo.FindInventory("GotWeapon7") || CPlayer.mo.FindInventory("DisruptorTeraBall"))) ||
                        (classnum == CLASS_SW && (CPlayer.mo.FindInventory("GotWeapon7") || CPlayer.mo.FindInventory("GotNuke"))) ||
                        (classnum != CLASS_DOOM && classnum != CLASS_CALEB && classnum != CLASS_DISRUPTOR && classnum != CLASS_SW && classnum != CLASS_PAINKILLER && CPlayer.mo.FindInventory("GotWeapon7"));

        bool hasslot7skulltag = (classnum == CLASS_DOOM && Weapon(CPlayer.mo.FindInventory(" BFG10K "))) ||
                                (classnum == CLASS_CHEX && Weapon(CPlayer.mo.FindInventory("Liquid Zorcher"))) ||
                                (classnum == CLASS_HEXEN && altclassnum == 1 && Weapon(CPlayer.mo.FindInventory(" Bloodscourge "))) ||
                                (classnum == CLASS_DUKE && altclassnum != 2 && Weapon(CPlayer.mo.FindInventory("Duke3D_X3000"))) ||
                                (classnum == CLASS_MARATHON && Weapon(CPlayer.mo.FindInventory("Mercury Class Fusion Rifle"))) ||
                                (classnum == CLASS_CALEB && Weapon(CPlayer.mo.FindInventory("BloodNaturomDemonto"))) ||
                                (classnum == CLASS_KATARN && Weapon(CPlayer.mo.FindInventory("Wookie Bowcaster"))) ||
                                (classnum == CLASS_BITTERMAN && (Weapon(CPlayer.mo.FindInventory("Q2Trap")) || Weapon(CPlayer.mo.FindInventory("Q2Disruptor")))) ||
                                (classnum == CLASS_BOND && altclassnum == 0 && Weapon(CPlayer.mo.FindInventory("Goldeneye_GoldenGun"))) ||
                                (classnum == CLASS_BOND && altclassnum == 1 && Weapon(CPlayer.mo.FindInventory("Goldfinger_M14"))) ||
                                (classnum == CLASS_UNREAL && Weapon(CPlayer.mo.FindInventory("Unreal_QuadShot"))) ||
                                (classnum == CLASS_RTCW && Weapon(CPlayer.mo.FindInventory("RTCW_Flamethrower")));

        let descentprimary = CPlayer.mo.FindInventory("DescentPrimaryCounter");
        let descentsecondary = CPlayer.mo.FindInventory("DescentSecondaryCounter");

        bool usingslot1 = (classnum == CLASS_DOOM && weaponname == " Chainsaw ") ||
                          (classnum == CLASS_CHEX && weaponname == "Super Bootspork") ||
                          (classnum == CLASS_HERETIC && weaponname == "Gauntlets of the Necromancer") ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "Knife" && CPlayer.mo.FindInventory("BJSuperKnife")) ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && (weaponname == "Totenkopf_Mauser" || weaponname == "Totenkopf_MauserDual")) ||
                          (classnum == CLASS_HEXEN && altclassnum <= 1 && CPlayer.mo.FindInventory("FlechetteCooldown") && CPlayer.mo.FindInventory("FlechetteCooldown").Amount >= 9) ||
                          (classnum == CLASS_HEXEN && altclassnum == 2 && CPlayer.mo.FindInventory("Flechette2Cooldown") && CPlayer.mo.FindInventory("Flechette2Cooldown").Amount >= 12) ||
                          (classnum == CLASS_HEXEN && altclassnum == 3 && CPlayer.mo.FindInventory("Flechette3Cooldown") && CPlayer.mo.FindInventory("Flechette3Cooldown").Amount >= 5) ||
                          (classnum == CLASS_DUKE && weaponname == "Pipebombs") ||
                          (classnum == CLASS_MARATHON && (weaponname == "KKV-7 SMG Flechette" || (weaponname == ".44 Magnum Mega Class A1" && CPlayer.mo.FindInventory("UsingDualPistols")))) ||
                          (classnum == CLASS_QUAKE && (weaponname == "Mjolnir" || weaponname == "Q1Chainsaw")) ||
                          (classnum == CLASS_ROTT && weaponname == "Double Pistols") ||
                          (classnum == CLASS_BLAKE && weaponname == "Auto Charge Pistol" && CPlayer.mo.FindInventory("BlakeSuperAutoCharge")) ||
                          (classnum == CLASS_CALEB && weaponname == "Dynamite") ||
                          (classnum == CLASS_STRIFE && CPlayer.mo.FindInventory("StrifeBeaconCooldown") && CPlayer.mo.FindInventory("StrifeBeaconCooldown").Amount >= 101) ||
                          (classnum == CLASS_ERAD && (altclassnum == 0 || altclassnum == 3) && weaponname == " Arachnicator ") ||
                          (classnum == CLASS_ERAD && altclassnum == 1 && weaponname == "EradRovingMine") ||
                          (classnum == CLASS_ERAD && altclassnum == 2 && weaponname == "EradMiniTankDetonator") ||
                          (classnum == CLASS_C7 && weaponname == "M24CAW") ||
                          (classnum == CLASS_RMR && weaponname == "Dirtshark" && CPlayer.mo.FindInventory("SamsaraRMRDirtsharkUpgrade")) ||
                          (classnum == CLASS_KATARN && weaponname == "Thermal Detonator") ||
                          (classnum == CLASS_POGREED && CPlayer.mo.FindInventory("IPOGGrenadeCooldown") && CPlayer.mo.FindInventory("IPOGGrenadeCooldown").Amount >= 1) ||
                          (classnum == CLASS_DISRUPTOR && weaponname == " 18mm Semi " && CPlayer.mo.FindInventory("SamsaraDisruptorHas18mmAuto")) ||
                          (classnum == CLASS_WITCHAVEN && CPlayer.mo.FindInventory("WTShieldActive")) ||
                          (classnum == CLASS_HALFLIFE && (weaponname == "Hornetgun" || weaponname == "Shock Roach")) ||
                          (classnum == CLASS_SW && weaponname == "SWSticky") ||
                          (classnum == CLASS_CM && weaponname == "CMDarklightFoil") ||
                          (classnum == CLASS_JON && weaponname == " Anubis Mine ") ||
                          (classnum == CLASS_RR && weaponname == " RR Rip Saw ") ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2Machinegun") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2IceMace") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && (weaponname == "Goldeneye_ThrowingKnives" || weaponname == "Goldeneye_HuntingKnife")) ||
                          (classnum == CLASS_BOND && altclassnum == 1 && (weaponname == "Goldfinger_OddjobHat" || weaponname == "Goldfinger_GolfClub")) ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_WavesQuickSpell") ||
                          (classnum == CLASS_PAINKILLER && weaponname == "Painkiller_Stakegun") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_RazorJack") ||
                          (classnum == CLASS_RTCW && (weaponname == "RTCW_Grenade" || weaponname == "RTCW_Pineapple")) ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3GrenadeLauncher") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 1) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 1))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_MiniCrossbow") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_Crowbar") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_Pistol2") ||
                          (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_Knife");

        bool usingslot2 = (classnum == CLASS_DOOM && weaponname == " Shotgun ") ||
                          (classnum == CLASS_CHEX && weaponname == "Large Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == " Firemace ") ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "Machine Gun") ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && (weaponname == "Totenkopf_Kar98k" || weaponname == "Totenkopf_Sniper")) ||
                          (classnum == CLASS_HEXEN && altclassnum == 0 && weaponname == "Crusader's Longbow") ||
                          (classnum == CLASS_HEXEN && (altclassnum == 1 || altclassnum == 2) && weaponname == "Frost Shards") ||
                          (classnum == CLASS_HEXEN && altclassnum == 3 && weaponname == "Javelin of Zeal") ||
                          (classnum == CLASS_DUKE && weaponname == "  Shotgun  ") ||
                          (classnum == CLASS_MARATHON && weaponname == "WSTE-M5 Combat Shotgun") ||
                          (classnum == CLASS_QUAKE && weaponname == "Double Shotgun") ||
                          (classnum == CLASS_ROTT && weaponname == "MP40") ||
                          (classnum == CLASS_BLAKE && weaponname == "Slow Fire Protector") ||
                          (classnum == CLASS_CALEB && weaponname == "Flaregun") ||
                          (classnum == CLASS_STRIFE && (weaponname == "  Crossbow  " || weaponname == "  Crossbow Poison  ")) ||
                          (classnum == CLASS_ERAD && weaponname == "  Sonic Shock  ") ||
                          (classnum == CLASS_C7 && weaponname == "M343Vulcan") ||
                          (classnum == CLASS_RMR && weaponname == "ACR Laser Rifle") ||
                          (classnum == CLASS_KATARN && weaponname == "Stormtrooper Rifle") ||
                          (classnum == CLASS_POGREED && weaponname == " Aldus Flamethrower ") ||
                          (classnum == CLASS_DISRUPTOR && weaponname == " Phase Rifle ") ||
                          (classnum == CLASS_WITCHAVEN && weaponname == "Shortsword") ||
                          (classnum == CLASS_HALFLIFE && weaponname == "Assault Shotgun") ||
                          (classnum == CLASS_SW && weaponname == "SWRiotGun") ||
                          (classnum == CLASS_CM && weaponname == "CMFusionGun") ||
                          (classnum == CLASS_JON && weaponname == "ExShotgun") ||
                          (classnum == CLASS_RR && (weaponname == " RR Hunting Crossbow " || weaponname == " RR Dynomite Crossbow " || weaponname == " Chicken Crossbow ")) ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2Shotgun") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2AcidRune") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_KF7Soviet") ||
                          (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_MP40") ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_XTerminatorsQuickSpell") ||
                          (classnum == CLASS_PAINKILLER && weaponname == "Painkiller_Shotgun") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_ASMDShockRifle") ||
                          (classnum == CLASS_RTCW && (weaponname == "RTCW_MP40" || weaponname == "RTCW_Thompson")) ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3Shotgun") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 2) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 2))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_Shotgun") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_Shotgun") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_AssaultRifle") ||
                          (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_Shotgun");

        bool usingslot3 = (classnum == CLASS_DOOM && weaponname == "Super Shotgun") ||
                          (classnum == CLASS_DOOM && altclassnum == 2 && weaponname == "Automatic Shotgun") ||
                          (classnum == CLASS_CHEX && weaponname == "Super Large Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == "Ethereal Crossbow") ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "Mauser Rifle") ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && weaponname == "Totenkopf_STG44") ||
                          (classnum == CLASS_HEXEN && altclassnum == 0 && (weaponname == "Bishop's Shortsword" || weaponname == "Wand of Embers")) ||
                          (classnum == CLASS_HEXEN && (altclassnum == 1 || altclassnum == 3) && weaponname == "Timon's Axe") ||
                          (classnum == CLASS_HEXEN && altclassnum == 2 && weaponname == "Fire Blast") ||
                          (classnum == CLASS_DUKE && weaponname == "Explosive Shotgun") ||
                          (classnum == CLASS_MARATHON && weaponname == "Fusion Pistol") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Grenade Launcher" || weaponname == "Grenade Launcher DOE")) ||
                          (classnum == CLASS_ROTT && weaponname == "HeatSeeker") ||
                          (classnum == CLASS_BLAKE && weaponname == "Heavy Assault Weapon") ||
                          (classnum == CLASS_CALEB && weaponname == "Sawedoff") ||
                          (classnum == CLASS_STRIFE && weaponname == "Mini Missile Launcher") ||
                          (classnum == CLASS_ERAD && altclassnum == 0 && weaponname == "Death Bomb") ||
                          (classnum == CLASS_ERAD && altclassnum == 1 && weaponname == "Cluster Bomb") ||
                          (classnum == CLASS_ERAD && altclassnum >= 2 && weaponname == "Pellet Bomb") ||
                          (classnum == CLASS_C7 && weaponname == "AssaultShotgun") ||
                          (classnum == CLASS_RMR && weaponname == "ACR ADD-ON") ||
                          (classnum == CLASS_KATARN && weaponname == "Fusion Cutter") ||
                          (classnum == CLASS_POGREED && weaponname == " Plasma Shotgun ") ||
                          (classnum == CLASS_DISRUPTOR && weaponname == " AM Blaster ") ||
                          (classnum == CLASS_WITCHAVEN && weaponname == "Battle Axe") ||
                          (classnum == CLASS_HALFLIFE && (weaponname == ".357 Python" || weaponname == "Desert Eagle")) ||
                          (classnum == CLASS_SW && weaponname == "SWGrenade") ||
                          (classnum == CLASS_CM && weaponname == "CMBlastRifle") ||
                          (classnum == CLASS_JON && weaponname == "PSFlamethrower") ||
                          (classnum == CLASS_RR && weaponname == " Scattered Gun ") ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2SuperShotgun") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2SpellBookMagicMissile") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && (weaponname == "Goldeneye_AutoShotgun" || weaponname == "Goldeneye_Shotgun")) ||
                          (classnum == CLASS_BOND && altclassnum == 1 && (weaponname == "Goldfinger_Shotgun" || weaponname == "Goldfinger_OverUnder")) ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_BurstsQuickSpell") ||
                          (classnum == CLASS_PAINKILLER && weaponname == "Painkiller_Boltgun") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_FlakCannon") ||
                          (classnum == CLASS_RTCW && (weaponname == "RTCW_Mauser" || weaponname == "RTCW_Snooper")) ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3Nailgun") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 3) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 3))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_AssaultShotgun") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_GrenadeLauncher") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_Shotgun") ||
                          (classnum == CLASS_OUTLAWS && (weaponname == "Outlaws_SawedOffShotgun" || weaponname == "Outlaws_DoubleBarrelShotgun"));

        bool usingslot4 = (classnum == CLASS_DOOM && weaponname == " Chaingun ") ||
                          (classnum == CLASS_DOOM && altclassnum == 0 && weaponname == " Machine Gun ") ||
                          (classnum == CLASS_DOOM && altclassnum == 2 && weaponname == " Flamer ") ||
                          (classnum == CLASS_CHEX && weaponname == "Rapid Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == "Dragon Claw") ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "  Chaingun  ") ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && (weaponname == "Totenkopf_MP40" || weaponname == "Totenkopf_MP40Dual")) ||
                          (classnum == CLASS_HEXEN && altclassnum <= 1 && weaponname == "Serpent Staff") ||
                          (classnum == CLASS_HEXEN && altclassnum == 2 && weaponname == "Blight Shock") ||
                          (classnum == CLASS_HEXEN && altclassnum == 3 && weaponname == "Jotunn's Flail") ||
                          (classnum == CLASS_DUKE && weaponname == "Chaingun Cannon") ||
                          (classnum == CLASS_DUKE && altclassnum != 2 && weaponname == "Duke3D_M16") ||
                          (classnum == CLASS_MARATHON && weaponname == "MA-75B Assault Rifle") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Nailgun" || weaponname == "Nailgun DOE")) ||
                          (classnum == CLASS_ROTT && weaponname == "Bazooka") ||
                          (classnum == CLASS_BLAKE && weaponname == "Rapid Assault Weapon") ||
                          (classnum == CLASS_CALEB && weaponname == "Tommygun") ||
                          (classnum == CLASS_STRIFE && weaponname == "Assault Gun") ||
                          (classnum == CLASS_ERAD && weaponname == "  Dart Cannon  ") ||
                          (classnum == CLASS_C7 && weaponname == "AlienDualBlaster") ||
                          (classnum == CLASS_RMR && weaponname == "Cyclops Particle Accelerator") ||
                          (classnum == CLASS_KATARN && weaponname == "Imperial Repeater") ||
                          (classnum == CLASS_POGREED && weaponname == " Fast Chaingun ") ||
                          (classnum == CLASS_DISRUPTOR && weaponname == "Phase Repeater") ||
                          (classnum == CLASS_WITCHAVEN && weaponname == "Ice Halberd") ||
                          (classnum == CLASS_HALFLIFE && weaponname == "MP5") ||
                          (classnum == CLASS_SW && weaponname == "SWUzi") ||
                          (classnum == CLASS_CM && weaponname == "CMSMG") ||
                          (classnum == CLASS_JON && weaponname == "PSM60") ||
                          (classnum == CLASS_RR && weaponname == " Ranch Rifle ") ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2Chaingun") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2SpellBookBoneShard") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_AR33") ||
                          (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_AK47") ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_ZappersQuickSpell") ||
                          (classnum == CLASS_PAINKILLER && weaponname == "Painkiller_Rifle") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_Stinger") ||
                          (classnum == CLASS_RTCW && weaponname == "RTCW_FG42") ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3LightningGun") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 4) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 4))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_AssaultRifle") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_TommyGun") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_Machinegun") ||
                          (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_Rifle");

        bool usingslot4skulltag = (classnum == CLASS_DOOM && weaponname == " Minigun ") ||
                                  (classnum == CLASS_CHEX && weaponname == "Ultra Rapid Zorcher") ||
                                  (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "  Dual Chainguns  ") ||
                                  (classnum == CLASS_DUKE && altclassnum != 2 && weaponname == "Golden Desert Eagle") ||
                                  (classnum == CLASS_QUAKE && weaponname == "Q1AssaultCannon") ||
                                  (classnum == CLASS_ROTT && weaponname == "RoTTM60") ||
                                  (classnum == CLASS_BLAKE && weaponname == "Gatling Fusion Devastator") ||
                                  (classnum == CLASS_CALEB && weaponname == "BloodGreaseGun") ||
                                  (classnum == CLASS_ERAD && altclassnum == 0 && weaponname == "EradEnergywhip") ||
                                  (classnum == CLASS_ERAD && altclassnum == 1 && weaponname == "EradNitrofogger") ||
                                  (classnum == CLASS_ERAD && altclassnum >= 2 && weaponname == "EradFlamethrower") ||
                                  (classnum == CLASS_KATARN && weaponname == "DLT-19 Heavy Blaster Rifle") ||
                                  (classnum == CLASS_POGREED && weaponname == " Gatling Gun ") ||
                                  (classnum == CLASS_HALFLIFE && weaponname == "HLUzi") ||
                                  (classnum == CLASS_BITTERMAN && weaponname == "Q2ETFRifle") ||
                                  (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_Phantom") ||
                                  (classnum == CLASS_BOND && altclassnum == 1 && (weaponname == "Goldfinger_ThompsonDrum" || weaponname == "Goldfinger_Thompson")) ||
                                  (classnum == CLASS_RTCW && (weaponname == "RTCW_StG44" || weaponname == "RTCW_BAR")) ||
                                  (classnum == CLASS_QUAKE3 && weaponname == "Q3HeavyMachineGun");

        bool usingslot5 = (classnum == CLASS_DOOM && weaponname == "Rocket Launcher") ||
                          (classnum == CLASS_DOOM && altclassnum == 2 && weaponname == "Land Mine Layer") ||
                          (classnum == CLASS_CHEX && weaponname == "Zorch Propulsor") ||
                          (classnum == CLASS_HERETIC && weaponname == "Phoenix Rod") ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == " Rocket Launcher ") ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && weaponname == "Totenkopf_Panzerschreck") ||
                          (classnum == CLASS_HEXEN && altclassnum == 0 && weaponname == "Ice Fang") ||
                          (classnum == CLASS_HEXEN && (altclassnum == 1 || altclassnum == 3) && weaponname == "Hammer of Retribution") ||
                          (classnum == CLASS_HEXEN && altclassnum == 2 && weaponname == "Viscerelagh") ||
                          (classnum == CLASS_DUKE && weaponname == "RPG") ||
                          (classnum == CLASS_MARATHON && weaponname == "SPNKR-XP SSM Launcher") ||
                          (classnum == CLASS_QUAKE && (weaponname == "  Rocket Launcher  " || weaponname == "  Rocket Launcher DOE  ")) ||
                          (classnum == CLASS_ROTT && weaponname == " Firebomb ") ||
                          (classnum == CLASS_BLAKE && weaponname == "Plasma Discharge Unit") ||
                          (classnum == CLASS_CALEB && weaponname == "NapalmLauncher") ||
                          (classnum == CLASS_STRIFE && (weaponname == " Grenade Launcher " || weaponname == " Grenade Launcher WP " || weaponname == " Grenade Launcher Gas ")) ||
                          (classnum == CLASS_ERAD && weaponname == "    Missile Launcher    ") ||
                          (classnum == CLASS_C7 && weaponname == "AlienPlasmaRifle") ||
                          (classnum == CLASS_RMR && weaponname == "RMR Grenade Launcher") ||
                          (classnum == CLASS_KATARN && weaponname == "Mortar Gun") ||
                          (classnum == CLASS_POGREED && weaponname == " Fast Rocket Launcher ") ||
                          (classnum == CLASS_DISRUPTOR && weaponname == " Lock-on Cannon ") ||
                          (classnum == CLASS_WITCHAVEN && weaponname == "Fire Mace") ||
                          (classnum == CLASS_HALFLIFE && (weaponname == " RPG " || weaponname == "Spore Launcher")) ||
                          (classnum == CLASS_SW && weaponname == "SWMissileLauncher") ||
                          (classnum == CLASS_CM && weaponname == "CMRocketGun") ||
                          (classnum == CLASS_JON && weaponname == "PSCobraStaff") ||
                          (classnum == CLASS_RR && weaponname == " Dyn 'O' Mites ") ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2RocketLauncher") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2FireRune") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_RocketLauncher") ||
                          (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_SuperBazooka") ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_NukesQuickSpell") ||
                          (classnum == CLASS_PAINKILLER && weaponname == "Painkiller_RocketLauncher") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_EightBall") ||
                          (classnum == CLASS_RTCW && weaponname == "RTCW_Panzerfaust") ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3RocketLauncher") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 5) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 5))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_GEPGun") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_Bazooka") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_Rocket") ||
                          (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_Cannon");

        bool usingslot5skulltag = (classnum == CLASS_DOOM && weaponname == " GrenadeLauncher ") ||
                                  (classnum == CLASS_CHEX && weaponname == "Zorch Launcher") ||
                                  (classnum == CLASS_DUKE && altclassnum != 2 && weaponname == "Duke3D_Incinerator") ||
                                  (classnum == CLASS_ROTT && weaponname == "Doomstick") ||
                                  (classnum == CLASS_CALEB && (weaponname == "BloodProximityTNT" || weaponname == "BloodRemoteTNT")) ||
                                  (classnum == CLASS_KATARN && weaponname == "I.M. Mines") ||
                                  (classnum == CLASS_WITCHAVEN && weaponname == "Broad Sword") ||
                                  (classnum == CLASS_BITTERMAN && weaponname == "Q2Phalanx") ||
                                  (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_GrenadeLauncher") ||
                                  (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_M79") ||
                                  (classnum == CLASS_RTCW && (weaponname == "RTCW_K43" || weaponname == "RTCW_M1Garand")) ||
                                  (classnum == CLASS_SOF && weaponname == "SoF_Flamegun");

        bool usingslot6 = (classnum == CLASS_DOOM && weaponname == "Plasma Rifle") ||
                          (classnum == CLASS_DOOM && altclassnum == 0 && weaponname == " Incinerator ") ||
                          (classnum == CLASS_DOOM && altclassnum == 2 && weaponname == "Stunner Rifle") ||
                          (classnum == CLASS_CHEX && weaponname == "Phasing Zorcher") ||
                          (classnum == CLASS_HERETIC && weaponname == "Hellstaff") ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == " Flamethrower ") ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && weaponname == "Totenkopf_Chaingun") ||
                          (classnum == CLASS_HEXEN && altclassnum <= 1 && weaponname == "Firestorm") ||
                          (classnum == CLASS_HEXEN && altclassnum == 2 && weaponname == "Arc of Death") ||
                          (classnum == CLASS_HEXEN && altclassnum == 3 && weaponname == "Quickspell Gauntlets") ||
                          (classnum == CLASS_DUKE && weaponname == "Freezethrower") ||
                          (classnum == CLASS_MARATHON && weaponname == "TOZT-7 Napalm Unit") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Super Nailgun" || weaponname == "Super Nailgun DOE")) ||
                          (classnum == CLASS_ROTT && weaponname == "DrunkMissiles") ||
                          (classnum == CLASS_BLAKE && weaponname == "Dual Neutron Disruptor") ||
                          (classnum == CLASS_CALEB && weaponname == "TeslaCannon") ||
                          (classnum == CLASS_STRIFE && weaponname == "Flame Thrower") ||
                          (classnum == CLASS_ERAD && altclassnum == 0 && weaponname == "Eleena Smoke Bomb") ||
                          (classnum == CLASS_ERAD && (altclassnum == 1 || altclassnum == 3) && weaponname == "Napalm Charge") ||
                          (classnum == CLASS_ERAD && altclassnum == 2 && weaponname == "Ion Sphere") ||
                          (classnum == CLASS_C7 && weaponname == "AlienAssaultCannon") ||
                          (classnum == CLASS_RMR && weaponname == "RMR Railgun") ||
                          (classnum == CLASS_KATARN && weaponname == "Concussion Rifle") ||
                          (classnum == CLASS_POGREED && weaponname == " Laser Cannon ") ||
                          (classnum == CLASS_DISRUPTOR && weaponname == " AM Cyclone ") ||
                          (classnum == CLASS_WITCHAVEN && weaponname == "Frozen Two-Hand Sword") ||
                          (classnum == CLASS_HALFLIFE && (weaponname == "Gauss Cannon" || weaponname == "M249 Squad Automatic Weapon")) ||
                          (classnum == CLASS_SW && weaponname == " SWRailgun ") ||
                          (classnum == CLASS_CM && weaponname == "CMHVBMG") ||
                          (classnum == CLASS_JON && weaponname == "Sacred Manacle") ||
                          (classnum == CLASS_RR && weaponname == " Alien Bra Gun ") ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2HyperBlaster") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2RavenStaff") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_RCP90") ||
                          (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_M1Carbine") ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_BoltsQuickSpell") ||
                          (classnum == CLASS_PAINKILLER && weaponname == "Painkiller_Electrodriver") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_Minigun") ||
                          (classnum == CLASS_RTCW && weaponname == "RTCW_Venom") ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3PlasmaGun") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 6) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 6))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_FlameThrower") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_Flamethrower") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_Slugger") ||
                          (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_MachineGun");

        bool usingslot6skulltag = (classnum == CLASS_DOOM && weaponname == " RailGun ") ||
                                  (classnum == CLASS_CHEX && weaponname == "Gigazorcher 2100") ||
                                  (classnum == CLASS_HERETIC && weaponname == "CorvusTempestWand") ||
                                  (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "Wolf3DLightningGun") ||
                                  (classnum == CLASS_DUKE && altclassnum != 2 && (weaponname == "Expander" || weaponname == "Shrinker")) ||
                                  (classnum == CLASS_MARATHON && weaponname == "SPNKR-25 Auto Cannon") ||
                                  (classnum == CLASS_QUAKE && weaponname == "Rocket Powered Impaler") ||
                                  (classnum == CLASS_ROTT && weaponname == "Split Missile") ||
                                  (classnum == CLASS_CALEB && weaponname == "BloodFlamethrower") ||
                                  (classnum == CLASS_RMR && weaponname == "Subestron Arm") ||
                                  (classnum == CLASS_KATARN && weaponname == "Czerka Adventurer") ||
                                  (classnum == CLASS_DISRUPTOR && weaponname == " Disruptor Plasmalance ") ||
                                  (classnum == CLASS_BITTERMAN && weaponname == "Q2PlasmaBeam") ||
                                  (classnum == CLASS_BOND && altclassnum == 0 && (weaponname == "Goldeneye_Cougar" || weaponname == "Goldeneye_SilverPP7" || weaponname == "Goldeneye_ArabahViper")) ||
                                  (classnum == CLASS_BOND && altclassnum == 1 && (weaponname == "Goldfinger_M1Garand" || weaponname == "Goldfinger_Kar98k")) ||
                                  (classnum == CLASS_RTCW && (weaponname == "RTCW_MG42" || weaponname == "RTCW_Browning")) ||
                                  (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_OrganGun");

        bool usingslot7 = (classnum == CLASS_DOOM && weaponname == "B.F.G. 9000") ||
                          (classnum == CLASS_DOOM && altclassnum == 0 && (weaponname == "B.F.G. 2704" || weaponname == "Calamity Blade")) ||
                          (classnum == CLASS_DOOM && altclassnum == 1 && weaponname == " Unmaker ") ||
                          (classnum == CLASS_DOOM && altclassnum == 2 && weaponname == "Pyro Cannon") ||
                          (classnum == CLASS_CHEX && weaponname == "LAZ Device") ||
                          (classnum == CLASS_HERETIC && (weaponname == "DSparilStaff" || weaponname == "DSparilStaffMinion")) ||
                          (classnum == CLASS_WOLFEN && altclassnum != 2 && weaponname == "Spear of Destiny") ||
                          (classnum == CLASS_WOLFEN && altclassnum == 2 && weaponname == "Totenkopf_Flakgun") ||
                          (classnum == CLASS_HEXEN && altclassnum <= 1 && weaponname == "Wraithverge") ||
                          (classnum == CLASS_HEXEN && altclassnum == 2 && weaponname == "Bloodscourge") ||
                          (classnum == CLASS_HEXEN && altclassnum == 3 && weaponname == "Quietus") ||
                          (classnum == CLASS_DUKE && weaponname == "Devastator Weapon") ||
                          (classnum == CLASS_MARATHON && weaponname == "ONI-71 Wave Motion Cannon") ||
                          (classnum == CLASS_QUAKE && (weaponname == "Thunderbolt" || weaponname == "Thunderbolt DOE")) ||
                          (classnum == CLASS_ROTT && weaponname == "FlameWall") ||
                          (classnum == CLASS_BLAKE && weaponname == "Anti-Plasma Cannon") ||
                          (classnum == CLASS_CALEB && weaponname == "LifeLeech") ||
                          (classnum == CLASS_STRIFE && (weaponname == " Mauler " || weaponname == " Mauler Torpedo ")) ||
                          (classnum == CLASS_ERAD && weaponname == " Plasma Ball ") ||
                          (classnum == CLASS_C7 && weaponname == "AlienDisintegrator") ||
                          (classnum == CLASS_RMR && weaponname == " RMR Plasma Cannon ") ||
                          (classnum == CLASS_KATARN && weaponname == "Assault Cannon") ||
                          (classnum == CLASS_POGREED && weaponname == " Super Plasma Annihilator ") ||
                          (classnum == CLASS_DISRUPTOR && (weaponname == " Disruptor Zodiac " || (CPlayer.mo.FindInventory("DisruptorTeraBall") && CPlayer.mo.FindInventory("DisruptorBlastExists")))) ||
                          (classnum == CLASS_WITCHAVEN && weaponname == "Pike Axe") ||
                          (classnum == CLASS_HALFLIFE && (weaponname == "E.G.O.N." || weaponname == "Displacer Cannon")) ||
                          (classnum == CLASS_SW && (weaponname == "SWGuardianHead" || (weaponname == "SWMissileLauncher" && CPlayer.mo.FindInventory("MissileMode") && CPlayer.mo.FindInventory("MissileMode").Amount >= 2))) ||
                          (classnum == CLASS_CM && weaponname == "CMPlasmaGun") ||
                          (classnum == CLASS_JON && weaponname == " Mummy Staff ") ||
                          (classnum == CLASS_RR && weaponname == " Alien Arm Cannon ") ||
                          (classnum == CLASS_BITTERMAN && weaponname == "Q2BFG10K") ||
                          (classnum == CLASS_DEMONESS && weaponname == "Hexen2TempestStaff") ||
                          (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_Moonraker") ||
                          (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_Laser") ||
                          (classnum == CLASS_CATACOMB && weaponname == "Catacomb_AtomicQuickSpell") ||
                          (classnum == CLASS_UNREAL && weaponname == "Unreal_Redeemer") ||
                          (classnum == CLASS_RTCW && weaponname == "RTCW_TeslaGun") ||
                          (classnum == CLASS_QUAKE3 && weaponname == "Q3BFG10K") ||
                          (classnum == CLASS_DESCENT && ((!descentsecondaryactive && descentprimary && descentprimary.Amount == 7) || (descentsecondaryactive && descentsecondary && descentsecondary.Amount == 7))) ||
                          (classnum == CLASS_DEUSEX && weaponname == "DeusEx_MJ12PlasmaRifle") ||
                          (classnum == CLASS_KINGPIN && weaponname == "Kingpin_HMG") ||
                          (classnum == CLASS_SOF && weaponname == "SoF_MPG") ||
                          (classnum == CLASS_OUTLAWS && weaponname == "Outlaws_GatlingGun");

        bool usingslot7skulltag = (classnum == CLASS_DOOM && weaponname == " BFG10K ") ||
                                  (classnum == CLASS_CHEX && weaponname == "Liquid Zorcher") ||
                                  (classnum == CLASS_HEXEN && altclassnum == 1 && weaponname == " Bloodscourge ") ||
                                  (classnum == CLASS_DUKE && altclassnum != 2 && weaponname == "Duke3D_X3000") ||
                                  (classnum == CLASS_MARATHON && weaponname == "Mercury Class Fusion Rifle") ||
                                  (classnum == CLASS_CALEB && weaponname == "BloodNaturomDemonto") ||
                                  (classnum == CLASS_KATARN && weaponname == "Wookie Bowcaster") ||
                                  (classnum == CLASS_BITTERMAN && (weaponname == "Q2Trap" || weaponname == "Q2Disruptor")) ||
                                  (classnum == CLASS_BOND && altclassnum == 0 && weaponname == "Goldeneye_GoldenGun") ||
                                  (classnum == CLASS_BOND && altclassnum == 1 && weaponname == "Goldfinger_M14") ||
                                  (classnum == CLASS_UNREAL && weaponname == "Unreal_QuadShot") ||
                                  (classnum == CLASS_RTCW && weaponname == "RTCW_Flamethrower");

        let weaponbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_TEXT_ALIGN_LEFT;

        for (int slotnum = 1; slotnum <= 7; slotnum++)
        {
            bool hasslot = false, usingslot = false;
            bool hasslotskulltag = false, usingslotskulltag = false;

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
                  hasslotskulltag = hasslot4skulltag;
                  usingslotskulltag = usingslot4skulltag;
                  break;

                case 5:
                  hasslot = hasslot5;
                  usingslot = usingslot5;
                  hasslotskulltag = hasslot5skulltag;
                  usingslotskulltag = usingslot5skulltag;
                  break;

                case 6:
                  hasslot = hasslot6;
                  usingslot = usingslot6;
                  hasslotskulltag = hasslot6skulltag;
                  usingslotskulltag = usingslot6skulltag;
                  break;

                case 7:
                  hasslot = hasslot7;
                  usingslot = usingslot7;
                  hasslotskulltag = hasslot7skulltag;
                  usingslotskulltag = usingslot7skulltag;
                  break;
            }

            DrawString(GOHmHUDFont, hasslot || usingslot || hasslotskulltag || usingslotskulltag ? "\c" .. (usingslotskulltag ? colorschemeskulltagactivetext : (usingslot ? colorschemeactivetext : colorschemetext)) .. FormatNumber(slotnum, 1, 1) : "", (coordbasex + (10 * ((slotnum == 0 ? 10 : slotnum) - 1)), coordbasey), weaponbarflags);
        }
    }

    protected virtual void GOHDrawCooldownTimers(int invcoordbasex, int invcoordbasey, int wepcoordbasex, int wepcoordbasey)
    {
        int maxcooldowns = 17 * 2;

        static const Name CooldownDefinitions[] =
        {
            "TomeOfPowerCooldown",                    "[Black]",
            "FlechetteCooldown",                      "[DarkGreen]",
            "Flechette2Cooldown",                     "[DarkGreen]",
            "Flechette3Cooldown",                     "[DarkGreen]",
            "SamsaraHexenTomeOfPowerCooldown",        "[Black]",
            "SamsaraDiscOfRepulsionCooldown",         "[Yellow]",
            "SamsaraDarkServantCooldown",             "[DarkBrown]",
            "HolodukeCooldown",                       "[Gray]",
            "SamsaraQuadDamageCooldownDisplay",       "[Ice]",
            "SamsaraBloodGunsAkimboCooldown",         "[DarkGray]",
            "StrifeBeaconCooldown",                   "[LightBlue]",
            "IPOGGrenadeCooldown",                    "[White]",
            "DisruptorPSICooldown",                   "[Brick]",
            "SamsaraQuake2QuadDamageCooldownDisplay", "[Olive]",
            "Hexen2TomeOfPowerCooldown",              "[Black]",
            "Catacomb_HourglassCooldown",             "[Gray]",
            "SamsaraQuake3QuadDamageCooldownDisplay", "[LightBlue]"
        };

        Vector2 coordbase = (0, 0);

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

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
                  case 'TomeOfPowerCooldown':
                    if (Powerup(CPlayer.mo.FindInventory("PowerHereticTome"))) { continue; }
                    break;

                  case 'FlechetteCooldown':
                  case 'Flechette2Cooldown':
                  case 'Flechette3Cooldown':
                    if (cooldownname == "FlechetteCooldown" && altclassnum >= 2) { continue; }
                    if (cooldownname == "Flechette2Cooldown" && altclassnum != 2) { continue; }
                    if (cooldownname == "Flechette3Cooldown" && altclassnum <= 2) { continue; }
                    cooldownslot = 1;
                    break;

                  case 'SamsaraDarkServantCooldown':
                    if (CPlayer.mo.FindInventory("SamsaraHexen1LoadoutUnique3") && !CPlayer.mo.FindInventory("SamsaraHasAllLoadoutEquipment")) { continue; }
                    break;

                  case 'StrifeBeaconCooldown':
                  case 'IPOGGrenadeCooldown':
                    cooldownslot = 1;
                    break;

                  case 'SamsaraBloodGunsAkimboCooldown':
                    let bloodakimbomode = CPlayer.mo.FindInventory("SamsaraBloodGunsAkimboHUDDisplay");

                    if (!bloodakimbomode || bloodakimbomode.Amount != 2) { continue; }
                    break;

                  case 'DisruptorPSICooldown':
                    let currentpsi = CPlayer.mo.FindInventory("DisruptorPsionicSelected");

                    if (!currentpsi || currentpsi.Amount <= 2 || !canshowweaponbar) { continue; }

                    cooldownslot = 7;
                    break;

                  case 'SamsaraQuake2QuadDamageCooldownDisplay':
                    if (Powerup(CPlayer.mo.FindInventory("PowerQ2QuadDamage"))) { continue; }
                    break;

                  case 'SamsaraQuake3QuadDamageCooldownDisplay':
                    if (Powerup(CPlayer.mo.FindInventory("PowerQ3QuadDamageFactor"))) { continue; }
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
        int maxmiscitems = 28 * 4;

        static const Name MiscItemDefinitions[] =
        {
            "StrifeSigilPiece",                    "SIGP",           "",                     "",
            "SVETalismanRed",                      "FLGRA0",         "",                     "",
            "SamsaraTalismanRed",                  "FLGRA0",         "",                     "",
            "SVETalismanGreen",                    "FLGGA0",         "",                     "",
            "SamsaraTalismanGreen",                "FLGGA0",         "",                     "",
            "SVETalismanBlue",                     "FLGBA0",         "",                     "",
            "SamsaraTalismanBlue",                 "FLGBA0",         "",                     "",
            "SamsaraDoom64UnmakerArtifact1",       "DM64UAR1_HUDT",  "",                     "",
            "SamsaraDoom64UnmakerArtifact2",       "DM64UAR2_HUDT",  "",                     "",
            "SamsaraDoom64UnmakerArtifact3",       "DM64UAR3_HUDT",  "",                     "",
            "TotenkopfHasPowerArmor",              "TK55A0",         "",                     "",
            "TotenkopfHasHealingOrb",              "TK55B0",         "",                     "",
            "DukeBootserk",                        "DMBP",           "",                     "",
            "NuclearKicks",                        "UNIQN0",         "",                     "",
            "SamsaraHalfLifeCanLongJump",          "HW00A0",         "",                     "",
            "DescentQuadLaser",                    "DS57_HUDT",      "",                     "",
            "KillCountBar",                        "ADILB0",         "",                     "[Gray]",
            "WolfExtraLife",                       "WFLF",           "",                     "[Sapphire]",
            "DukeJetpackFuel",                     "DKJTA",          "",                     "[Gray]",
            "DukeVisionFuel",                      "ARTINIV",        "",                     "[DarkGray]",
            "DukeSteroidsFuel",                    "ARTISTE",        "",                     "[DarkBrown]",
            "CalebVisionFuel",                     "INBEAST",        "",                     "[Cream]",
            "KatarnBlazeItTimer",                  "PDFUB0",         "",                     "[DarkGray]",
            "DisruptorPsionicSelected",            "SQ7",            "DisruptorPSICooldown", "[Ice]",
            "FlashLightAmmo",                      "ARTINIVIP_HUDT", "",                     "[DarkGray]", // ARTINIVIP_HUDT is placeholder
            "Painkiller_SoulCount",                "PKSOULS_HUDT",   "",                     "[Brown]", // PKSOULS_HUDT is placeholder
            "DeusEx_AugmentationUpgradeCannister", "DXAUGCAN_HUDT",  "",                     "[Cyan]",
            "DeusEx_AugmentationBioEnergyCell",    "DXAUGECL_HUDT",  "",                     "[LightBlue]"
        };

        Vector2 coordnudge;

        int classnum = CPlayer.CurrentPlayerClass, altclassnum = 0;

        Inventory classmode;

        if (classnum >= 0 && classnum < CLASSCOUNT && AltClassTokenDefinitions[classnum] != "") { classmode = CPlayer.mo.FindInventory(AltClassTokenDefinitions[classnum]); }

        if (classmode) { altclassnum = clamp(classmode.Amount, 0, clamp(classmode.MaxAmount, 0, ALTCLASSCOUNT - 1)); }

        let canshowmaxamounts = CVar.FindCVar("goh_showmaxamounts").GetBool();

        int checkedmiscitems = 0, activemiscitems = 0;

        for (checkedmiscitems = 0; checkedmiscitems < maxmiscitems; checkedmiscitems += 4)
        {
            let currentmiscitem = CPlayer.mo.FindInventory(MiscItemDefinitions[checkedmiscitems]);

            switch (MiscItemDefinitions[checkedmiscitems])
            {
              default:
                if (!currentmiscitem) { continue; }
                break;

              case 'SamsaraDoom64UnmakerArtifact1':
              case 'SamsaraDoom64UnmakerArtifact2':
              case 'SamsaraDoom64UnmakerArtifact3':
                currentmiscitem = CPlayer.mo.FindInventory("SamsaraDoom64UnmakerArtifact");

                if (!currentmiscitem || altclassnum != 1) { continue; }
                break;

              case 'TotenkopfHasPowerArmor':
              case 'TotenkopfHasHealingOrb':
                if (!currentmiscitem || altclassnum != 2) { continue; }
                break;

              case 'KillCountBar':
                switch (classnum)
                {
                  default: continue;

                  case CLASS_HEXEN:
                  case CLASS_ROTT:
                  case CLASS_ERAD:
                  case CLASS_POGREED:
                  case CLASS_RR:
                  case CLASS_BOND:
                    if (CPlayer.mo.FindInventory("SamsaraAlliesAreBanned")) { continue; }
                    break;
                }
                break;

              case 'WolfExtraLife':
                if (!currentmiscitem || altclassnum == 2) { continue; }
                break;

              case 'KatarnBlazeItTimer':
                if (!currentmiscitem && !CPlayer.mo.FindInventory("KatarnFireRateUp")) { continue; }
                break;

              case 'DisruptorPsionicSelected':
                if (classnum != CLASS_DISRUPTOR) { continue; }
                break;

              case 'FlashLightAmmo':
                if (classnum != CLASS_HALFLIFE) { continue; }
                break;

              case 'Painkiller_SoulCount':
                if (classnum != CLASS_PAINKILLER) { continue; }
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
                bool usingpsienergy = false;
                bool ispowerup = false;
                bool showcooldowntimer = true;

                switch (MiscItemDefinitions[checkedmiscitems])
                {
                  default:
                    if (!currentmiscitem) { continue; }
                    break;

                  case 'Sigil':
                  case 'StrifeSigilPiece':
                    if (!currentmiscitem) { continue; }

                    switch (MiscItemDefinitions[checkedmiscitems] == "StrifeSigilPiece" ? currentmiscitem.Amount : currentmiscitem.Health)
                    {
                      case 1: currentmiscitemicon = currentmiscitemicon .. "A"; break;
                      case 2: currentmiscitemicon = currentmiscitemicon .. "B"; break;
                      case 3: currentmiscitemicon = currentmiscitemicon .. "C"; break;
                      case 4: currentmiscitemicon = currentmiscitemicon .. "D"; break;
                      default: currentmiscitemicon = currentmiscitemicon .. "E"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";
                    break;

                  case 'SamsaraDoom64UnmakerArtifact1':
                  case 'SamsaraDoom64UnmakerArtifact2':
                  case 'SamsaraDoom64UnmakerArtifact3':
                    currentmiscitem = CPlayer.mo.FindInventory("SamsaraDoom64UnmakerArtifact");

                    if (!currentmiscitem || altclassnum != 1) { continue; }

                    if (MiscItemDefinitions[checkedmiscitems] == "SamsaraDoom64UnmakerArtifact1" && currentmiscitem.Amount < 1) { continue; }
                    if (MiscItemDefinitions[checkedmiscitems] == "SamsaraDoom64UnmakerArtifact2" && currentmiscitem.Amount < 2) { continue; }
                    if (MiscItemDefinitions[checkedmiscitems] == "SamsaraDoom64UnmakerArtifact3" && currentmiscitem.Amount < 3) { continue; }
                    break;

                  case 'TotenkopfHasPowerArmor':
                  case 'TotenkopfHasHealingOrb':
                    if (!currentmiscitem || altclassnum != 2) { continue; }
                    break;

                  case 'DukeBootserk':
                    if (!currentmiscitem) { continue; }

                    switch (altclassnum)
                    {
                      case 0: currentmiscitemicon = currentmiscitemicon .. "A"; break;
                      case 1: currentmiscitemicon = currentmiscitemicon .. "B"; break;
                      case 2: currentmiscitemicon = currentmiscitemicon .. "C"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";
                    break;

                  case 'KillCountBar':
                    switch (classnum)
                    {
                      default: continue;

                      case CLASS_HEXEN:
                      case CLASS_ROTT:
                      case CLASS_ERAD:
                      case CLASS_POGREED:
                      case CLASS_RR:
                      case CLASS_BOND:
                        if (CPlayer.mo.FindInventory("SamsaraAlliesAreBanned")) { continue; }
                        break;
                    }

                    hascounter = true;
                    break;

                  case 'WolfExtraLife':
                    if (!currentmiscitem || altclassnum == 2) { continue; }

                    switch (altclassnum)
                    {
                      default: currentmiscitemicon = currentmiscitemicon .. "A"; break;

                      case 1:
                        currentmiscitemicon = currentmiscitemicon .. "B";
                        currentmiscitemcolor = "[Green]";
                        break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";

                    hascounter = true;
                    break;

                  case 'DukeJetpackFuel':
                    if (!currentmiscitem) { continue; }

                    switch (altclassnum)
                    {
                      default: break;
                      case 2: currentmiscitemicon = "PDWPI"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";

                    hascounter = true;
                    counterpercentage = true;
                    break;

                  case 'DukeVisionFuel':
                    if (!currentmiscitem) { continue; }

                    switch (altclassnum)
                    {
                      case 0: currentmiscitemicon = currentmiscitemicon .. "I"; break;

                      case 1:
                        currentmiscitemicon = currentmiscitemicon .. "2";
                        currentmiscitemcolor = "[Black]";
                        break;

                      case 2:
                        currentmiscitemicon = currentmiscitemicon .. "3";
                        currentmiscitemcolor = "[Gray]";
                        break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "P_HUDT";

                    hascounter = true;
                    counterpercentage = true;
                    break;

                  case 'DukeSteroidsFuel':
                    if (!currentmiscitem) { continue; }

                    switch (altclassnum)
                    {
                      case 0: currentmiscitemicon = currentmiscitemicon .. "R"; break;
                      case 1: currentmiscitemicon = currentmiscitemicon .. "2"; break;
                      case 2: currentmiscitemicon = currentmiscitemicon .. "3"; break;
                    }

                    currentmiscitemicon = currentmiscitemicon .. "P_HUDT";

                    hascounter = true;
                    counterpercentage = true;
                    break;

                  case 'CalebVisionFuel':
                    if (!currentmiscitem) { continue; }

                    hascounter = true;
                    counterpercentage = true;
                    break;

                  case 'KatarnBlazeItTimer':
                    if (!currentmiscitem && !CPlayer.mo.FindInventory("KatarnFireRateUp")) { continue; }

                    hascounter = true;
                    break;

                  case 'DisruptorPsionicSelected':
                    if (classnum != CLASS_DISRUPTOR) { continue; }

                    if (!currentmiscitem) { currentmiscitemicon = currentmiscitemicon .. "5I"; }
                    else
                    {
                        switch (currentmiscitem.Amount)
                        {
                          case 1:
                            currentmiscitemicon = currentmiscitemicon .. "5F";
                            currentmiscitemcolor = "[Red]";
                            showcooldowntimer = false; // heal doesn't run off a cooldown
                            break;

                          case 2:
                            currentmiscitemicon = currentmiscitemicon .. "6H";
                            currentmiscitemcolor = "[LightBlue]";
                            break;

                          default:
                            currentmiscitemicon = currentmiscitemicon .. "6G";
                            currentmiscitemcolor = "[Brick]";
                            if (CVar.FindCVar("goh_showweaponbar").GetBool()) { showcooldowntimer = false; } // slot cooldown display is used instead
                            break;
                        }
                    }

                    currentmiscitemicon = currentmiscitemicon .. "0";

                    usingpsienergy = true;
                    break;

                  case 'FlashLightAmmo':
                    if (classnum != CLASS_HALFLIFE) { continue; }

                    hascounter = true;
                    counterpercentage = true;
                    break;

                  case 'Painkiller_SoulCount':
                    if (classnum != CLASS_PAINKILLER) { continue; }

                    hascounter = true;
                    break;

                  case 'DeusEx_AugmentationUpgradeCannister':
                  case 'DeusEx_AugmentationBioEnergyCell':
                    if (!currentmiscitem) { continue; }

                    hascounter = true;
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

                    if (usingpsienergy)
                    {
                        int psienergyamt, psienergymaxamt;

                        [psienergyamt, psienergymaxamt] = GetAmount("DisruptorPSIEnergy");

                        DrawString(GOHmHUDFont, "\c" .. currentmiscitemcolor .. FormatNumber(psienergyamt, 1, 4) .. (canshowmaxamounts ? StringTable.Localize("$GOODOLHUD_SEPARATOR") .. FormatNumber(psienergymaxamt, 1, 4) : ""), (coordbasex, (coordbasey + coordnudge.Y) + 24), DI_SCREEN_RIGHT_TOP|DI_TEXT_ALIGN_CENTER);
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

                    coordnudge.Y += 44 + (hascounter || usingpsienergy ? 24 : 0);
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
            bool showpercentage = false;

            switch (item.GetClassName())
            {
              case 'CalebDoctorsBag':
              case 'RRCheapasswhiskey':
                showpercentage = true;
                break;
            }

            for (int j = 0; j < 2; j++)
            {
                if (j ^ !!(flags & DI_DRAWCURSORFIRST))
                {
                    if (item == CPlayer.mo.InvSel)
                    {
                        double flashAlpha = bgalpha;

                        if (flags & DI_ARTIFLASH) { flashAlpha *= itemflashFade; }

                        if (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS) || showpercentage) { parms.selectofs.Y -= 15; }

                        DrawTexture(parms.selector, position + parms.selectofs + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_OFFSETS, flashAlpha);
                    }
                }
                else { DrawInventoryIcon(item, itempos + ((boxsize.X + boxseparator) * i, 0), flags|DI_DIMDEPLETED|DI_ITEM_CENTER, 1, (36, 30)); }
            }

            if (parms.amountfont && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS) || showpercentage)) { DrawString(parms.amountfont, "\c" .. colorschemetext .. (showpercentage ? (FormatNumber(item.Amount * 100.0 / item.MaxAmount, 1, 3) .. StringTable.Localize("$GOODOLHUD_PERCENTAGE")) : FormatNumber(item.Amount, 1, 5)), textpos + ((boxsize.X + boxseparator) * i, 0), flags|DI_TEXT_ALIGN_CENTER, parms.cr, parms.itemalpha); }

            i++;
        }

        // Is there something to the left?
        if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst) { DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags|DI_ITEM_OFFSETS); }

        // Is there something to the right?
        if (item) { DrawTexture(parms.right, position + (parms.arrowoffset.X + 7, parms.arrowoffset.Y) + (width, 0), flags|DI_ITEM_OFFSETS); }
    }
}
