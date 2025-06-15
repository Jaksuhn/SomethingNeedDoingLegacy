using ECommons.EzIpcManager;

namespace SomethingNeedDoing.IPC;
public class SNDProvider
{
    public SNDProvider() => EzIPC.Init(this);

    [EzIPC] public bool IsRunning => Service.MacroManager.State == Misc.LoopState.Running;
    [EzIPC] public void Pause() => Service.MacroManager.Pause();
    [EzIPC] public void Resume() => Service.MacroManager.Resume();
    [EzIPC] public void Stop() => Service.MacroManager.Stop();
    [EzIPC] public void RunByName(string macroName) => C.GetAllNodes().OfType<MacroNode>().FirstOrDefault(macro => macro?.Name == macroName, null)?.Run();

    [EzIPC]
    public void AddRequiredLuaPath(string path)
    {
        Svc.Log.Info($"Adding path: {path}");
        if (string.IsNullOrWhiteSpace(path))
            return;

        if (!C.ExternalLuaRequirePaths.Contains(path))
        {
            C.ExternalLuaRequirePaths.Add(path);
        }
    }
}
