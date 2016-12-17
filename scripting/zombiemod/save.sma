new g_vault;

new Array:g_dataName;
new Trie:g_dataTrie;
new g_dataSize;

public Save::Init()
{
	g_vault = nvault_open("zombiemod");
	
	g_dataName = ArrayCreate(32);
	g_dataTrie = TrieCreate();
}

public Save::PluginEnd()
{
	nvault_close(g_vault);
}

public Save::Disconnect(id)
{
	if (is_user_connected(id))
		saveData(id);
}

public Save::PutInServer_P(id)
{
	loadData(id);
}

saveData(id)
{
	new name[32];
	get_user_name(id, name, charsmax(name));
	
	new data[128];
	formatex(data, charsmax(data), "%d", getMoney(id));
    
	nvault_set(g_vault, name, data);
	
	if (TrieKeyExists(g_dataTrie, name))
	{
		new index;
		TrieGetCell(g_dataTrie, name, index);
		OnSave(id, index);	
	}
	else
	{
		ArrayPushString(g_dataName, name);
		TrieSetCell(g_dataTrie, name, g_dataSize);
		OnSave(id, g_dataSize);
		g_dataSize++;
	}
}

loadData(id)
{
	new name[32];
	get_user_name(id, name, charsmax(name));
	
	new data[128];
	if (nvault_get(g_vault, name, data, charsmax(data)))
	{
		new money[16];
		parse(data, money, charsmax(money));
		
		setMoney(id, str_to_num(money));
	}
	else
	{
		setMoney(id, 1000);
	}

	if (TrieKeyExists(g_dataTrie, name))
	{
		new index;
		TrieGetCell(g_dataTrie, name, index);
		
		OnLoad(id, index);
	}
}

stock getDataSize()
{
	return g_dataSize;
}