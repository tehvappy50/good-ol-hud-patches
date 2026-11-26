class GoodOlHUDStrongholdStatusBar : DoomStatusBar
{
    override void Init()
    {
        Super.Init();

        Font fnt;

        // Create the fonts used for the HUDs
        fnt = "HUDFONT_DOOM";

        mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellCenter, 2, 2);

        fnt = "INDEXFONT";

        mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);

        diparms = InventoryBarState.Create(mIndexFont, Font.CR_GOLD, 1, "ARTIBOX", "SELECTBO", (0, 0), "INVGEML1", "INVGEMR1", (4, -9));
    }

    override void Draw (int state, double TicFrac)
    {
        BaseStatusBar.Draw (state, TicFrac);

        if (state == HUD_StatusBar)
        {
            BeginStatusBar();
            DrawMainBar (TicFrac);
        } else {
            if (state == HUD_Fullscreen)
            {
                BeginHUD();
                DrawFullScreenStuff ();
            }
        }
    }

    protected void DrawMainBar (double TicFrac)
    {
        Name weaponname;

        if (CPlayer.ReadyWeapon) { weaponname = CPlayer.ReadyWeapon.GetClassName(); }

        DrawImage("STBAR", (0, 168), DI_ITEM_OFFSETS);
        DrawImage("WIPCNTSM", (87, 177), DI_ITEM_OFFSETS);
        DrawImage("WIPCNTSM", (217, 177), DI_ITEM_OFFSETS);

        Inventory a1, a2;

        [a1, a2] = GetCurrentAmmo();

        // Special case for the Auto Shotgun - if AS is selected then display clip
        // Don't worry, the shells remaining are still shown to the right.
        if (weaponname == "AutoShotgun")
        {
            if (a2) { DrawString(mHUDFont, FormatNumber(a2.Amount, 3, 3), (40, 172), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW, Font.CR_GOLD); }
        } else {
            if (a1) { DrawString(mHUDFont, FormatNumber(a1.Amount, 3, 3), (40, 172), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW); }
        }

        DrawString(mHUDFont, FormatNumber(GetAmount("LifeItem"), 3, 3), (248, 172), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 3, 3), (85, 172), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3, 3), (216, 172), DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);

        //DrawBarKeys();
        DrawBarAmmo();
        DrawBarWeapons();

        if (CPlayer.mo.InvSel && !Level.NoInventoryBar)
        {
            DrawInventoryIcon(CPlayer.mo.InvSel, (140, 169), DI_ITEM_OFFSETS);

            if (CPlayer.mo.InvSel.Amount != 1) { DrawString(mAmountFont, FormatNumber(CPlayer.mo.InvSel.Amount), (169, 199 - mIndexFont.mFont.GetHeight()), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD); }
        }
        else { DrawTexture(GetMugShot(5), (140, 169), DI_ITEM_OFFSETS); }

        if (isInventoryBarVisible()) { DrawInventoryBar(diparms, (155, 200), 7); }
    }

    override void DrawBarAmmo()
    {
        DrawString(mIndexFont, FormatNumber(GetAmount("Clip"), 3, 3), (284, 173), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(GetAmount("Shell"), 3, 3), (284, 182), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(GetAmount("RocketAmmo"), 3, 3), (284, 191), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(GetAmount("Gas"), 3, 3), (315, 173), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(GetAmount("Mines"), 3, 3), (315, 182), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        DrawString(mIndexFont, FormatNumber(GetAmount("Cell"), 3, 3), (315, 191), DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
    }

    override void DrawBarWeapons()
    {
        DrawImage(CPlayer.HasWeaponsInSlot(2) ? "STYSNUM2" : "STGNUM2", (106, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(3) ? "STYSNUM3" : "STGNUM3", (114, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(4) ? "STYSNUM4" : "STGNUM4", (122, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(5) ? "STYSNUM5" : "STGNUM5", (130, 172), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(6) ? "STYSNUM6" : "STGNUM6", (106, 182), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(7) ? "STYSNUM7" : "STGNUM7", (114, 182), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(8) ? "STYSNUM8" : "STGNUM8", (122, 182), DI_ITEM_OFFSETS);
        DrawImage(CPlayer.HasWeaponsInSlot(9) ? "STYSNUM9" : "STGNUM9", (130, 182), DI_ITEM_OFFSETS);
    }

    protected void DrawFullScreenStuff ()
    {
        Name weaponname;

        if (CPlayer.ReadyWeapon) { weaponname = CPlayer.ReadyWeapon.GetClassName(); }

        // base
        DrawImage("STBARFS", (0, -32), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER);

        // health
        DrawImage("MEDIA0", (-98, -28), DI_SCREEN_CENTER_BOTTOM);
        DrawString(mHUDFont, FormatNumber(CPlayer.Health, 3), (-41, -42), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        DrawImage("WIPCNTSM", (-38, -37), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);

        // armor
        let armor = CPlayer.mo.FindInventory("BasicArmor", true);

        if (armor != null && armor.Amount > 0) { DrawInventoryIcon(armor, (-98, -6), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS); }

        DrawString(mHUDFont, FormatNumber(GetArmorAmount(), 3), (-41, -21), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
        DrawImage("WIPCNTSM", (-38, -16), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);

        // ammo
        Inventory ammotype1, ammotype2;
        [ammotype1, ammotype2] = GetCurrentAmmo();

        if (weaponname == "AutoShotgun")
        {
            // magazine
            if (ammotype2 != null && ammotype2 != ammotype1)
            {
                DrawInventoryIcon(ammotype2, (-6, -29), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
                DrawString(mHUDFont, FormatNumber(ammotype2.Amount, 3), (49, -42), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
            }

            // reserve
            if (ammotype1 != null)
            {
                DrawInventoryIcon(ammotype1, (-6, -7), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
                DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3), (49, -21), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
            }
        } else {
            // primary
            if (ammotype1 != null)
            {
                DrawInventoryIcon(ammotype1, (-6, -7), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
                DrawString(mHUDFont, FormatNumber(ammotype1.Amount, 3), (49, -21), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);
            }
        }

        // lives
        DrawString(mHUDFont, FormatNumber(GetAmount("LifeItem"), 3, 3), (85, -21), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT|DI_NOSHADOW);

        // frags
        if (deathmatch || teamplay) { DrawString(mHUDFont, FormatNumber(CPlayer.FragCount, 3, 2 + (CPlayer.FragCount < 0)), (-8, 1), DI_TEXT_ALIGN_RIGHT); }

        // selected inventory
        if (!Level.NoInventoryBar && CPlayer.mo.InvSel)
        {
            DrawInventoryIcon(CPlayer.mo.InvSel, (116, -35), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_CENTER);
            DrawString(mIndexFont, FormatNumber(CPlayer.mo.InvSel.Amount, 3), (142, -38), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);
        }

        // money
        DrawImage("SACKA0", (100, -25), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_OFFSETS);
        DrawString(mIndexFont, FormatNumber(GetAmount("CoinItem"), 3, 5), (142, -16), DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_RIGHT, Font.CR_GOLD);

        // inventory bar
        if (isInventoryBarVisible())
        {
            let fullscreenOffsetsMemory = fullscreenOffsets;

            fullscreenOffsets = false;

            DrawInventoryBar(diparms, (155, 200), 7, 0, HX_SHADOW);

            fullscreenOffsets = fullscreenOffsetsMemory;
        }
    }

    override void DrawFullscreenKeys()
    {
        Vector2 keypos = (-10, 2);
        int rowc = 0;
        double roww = 0;
        int curkeys = 0;

        for (let i = CPlayer.mo.Inv; i != null; i = i.Inv)
        {
            if (i is "Key" && i.Icon.IsValid())
            {
                if (++curkeys > 100) { break; }

                DrawTexture(i.Icon, keypos, DI_SCREEN_RIGHT_TOP|DI_ITEM_OFFSETS);

                Vector2 size = TexMan.GetScaledSize(i.Icon);

                keypos.Y += size.Y + 2;
                roww = max(roww, size.X);

                if (++rowc == 3)
                {
                    keypos.Y = 2;
                    keypos.X -= roww + 2;
                    roww = 0;
                    rowc = 0;
                }
            }
        }
    }

    void DrawInventoryBar(InventoryBarState parms, Vector2 position, int numfields, int flags = 0, double bgalpha = 1.)
    {
        double width = parms.boxsize.X * numfields;
        [position, flags] = AdjustPosition(position, flags, width, parms.boxsize.Y);

        CPlayer.mo.InvFirst = ValidateInvFirst(numfields);

        if (!CPlayer.mo.InvFirst) { return; } // Player has no listed inventory items.

        Vector2 boxsize = parms.boxsize;
        int boxseparator = 1;

        // First draw all the boxes
        for (int i = 0; i < numfields; i++) { DrawTexture(parms.box, position + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_LEFT_TOP, bgalpha); }

        // now the items and the rest
        Vector2 itempos = position + boxsize / 2;
        itempos += (-15, -15);

        Vector2 textpos = position + boxsize - (1, 1 + parms.amountfont.mFont.GetHeight());
        textpos += (-3, -1);

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
                        double flashAlpha = 1.; //bgalpha;

                        if (flags & DI_ARTIFLASH) { flashAlpha *= itemflashFade; }

                        DrawTexture(parms.selector, position + parms.selectofs + ((boxsize.X + boxseparator) * i, 0), flags|DI_ITEM_LEFT_TOP, flashAlpha);
                    }
                }
                else { DrawInventoryIcon(item, itempos + ((boxsize.X + boxseparator) * i, 0), flags|DI_DIMDEPLETED|DI_ITEM_OFFSETS); }
            }

            if (parms.amountfont && (item.Amount > 1 || (flags & DI_ALWAYSSHOWCOUNTERS))) { DrawString(parms.amountfont, FormatNumber(item.Amount), textpos + ((boxsize.X + boxseparator) * i, 0), flags|DI_TEXT_ALIGN_RIGHT, parms.cr, parms.itemalpha); }

            i++;
        }

        // Is there something to the left?
        if (CPlayer.mo.FirstInv() != CPlayer.mo.InvFirst) { DrawTexture(parms.left, position + (-parms.arrowoffset.X, parms.arrowoffset.Y), flags|DI_ITEM_RIGHT|DI_ITEM_VCENTER); }

        // Is there something to the right?
        if (item) { DrawTexture(parms.right, position + (parms.arrowoffset.X + 5, parms.arrowoffset.Y) + (width, 0), flags|DI_ITEM_LEFT|DI_ITEM_VCENTER); }
    }
}
