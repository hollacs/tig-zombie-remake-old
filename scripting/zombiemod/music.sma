public PlayMusicTask()
{
	new Float:delay;
	OnPlayMusic(delay);
	
	set_task(delay, "PlayMusicTask", TASK_MUSIC);
}

stock playMusicTask(Float:delay)
{
	remove_task(TASK_MUSIC);
	set_task(delay, "PlayMusicTask", TASK_MUSIC);
}

stock playMusic(id, const music[])
{
	client_cmd(id, "mp3 play ^"%s^"", music);
}

stock stopMusic(id)
{	
	client_cmd(id, "mp3 stop");
	
	if (!id)
	{
		remove_task(TASK_MUSIC);
	}
}