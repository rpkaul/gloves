/*  CS:GO Gloves SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

public void ReadConfig()
{
	if(g_smGlovesGroupIndex != null) delete g_smGlovesGroupIndex;
	g_smGlovesGroupIndex = new StringMap();
	
	char code[4];
	char language[32];
	GetLanguageInfo(GetServerLanguage(), code, sizeof(code), language, sizeof(language));
	
	BuildPath(Path_SM, configPath, sizeof(configPath), "configs/gloves/gloves_%s.cfg", language);
	
	if(!FileExists(configPath))
	{
		BuildPath(Path_SM, configPath, sizeof(configPath), "configs/gloves/gloves_english.cfg");
	}
	if(!FileExists(configPath))
	{
		SetFailState("Could not find a config file for any languages.");
	}
	
	KeyValues kv = CreateKeyValues("Gloves");
	FileToKeyValues(kv, configPath);
	
	if (!KvGotoFirstSubKey(kv))
	{
		SetFailState("CFG File not found: %s", configPath);
		CloseHandle(kv);
	}
	
	if(menuGlovesGroup != null)
	{
		delete menuGlovesGroup;
	}
	menuGlovesGroup = new Menu(GloveMainMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_DisplayItem);
	menuGlovesGroup.SetTitle("%T", "GloveMenuTitle", LANG_SERVER);
	menuGlovesGroup.AddItem("0;0", "Default");
	menuGlovesGroup.AddItem("-1;-1", "Random");
	menuGlovesGroup.ExitBackButton = true;
	
	int counter = 1;
	do {
		char name[64];
		char groupName[64];
		char index[10];
		char group[10];
		char buffer[20];
		bool isFirstFlag = true;
		
		KvGetSectionName(kv, groupName, sizeof(groupName));
		KvGetString(kv, "index", group, sizeof(group));
		g_smGlovesGroupIndex.SetValue(group, counter);
		KvGotoFirstSubKey(kv);
		
		if(menuGloves[counter] != null)
		{
			delete menuGloves[counter];
		}
		menuGloves[counter] = new Menu(GloveMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_DisplayItem);
		menuGloves[counter].SetTitle(name);
		Format(buffer, sizeof(buffer), "%s;-1", group);
		menuGloves[counter].AddItem(buffer, "Random");

		menuGloves[counter].ExitBackButton = true;

		do {
			KvGetSectionName(kv, name, sizeof(name));
			KvGetString(kv, "index", index, sizeof(index));
			
			Format(buffer, sizeof(buffer), "%s;%s", group, index);
			menuGloves[counter].AddItem(buffer, name);
			
			if (isFirstFlag)
			{
				Format(buffer, sizeof(buffer), "%s;%s", group, index);
				menuGlovesGroup.AddItem(buffer, groupName);
				isFirstFlag = false;
			}
		} while (KvGotoNextKey(kv));

		KvGoBack(kv);
		counter++;
	} while (KvGotoNextKey(kv));
	
	CloseHandle(kv);
}
