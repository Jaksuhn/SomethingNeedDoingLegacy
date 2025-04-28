using Dalamud.Plugin;
using ECommons;
using ECommons.Configuration;
using ECommons.Logging;
using ECommons.SimpleGui;
using ECommons.Singletons;
using ImGuiNET;
using SomethingNeedDoing.Interface;
using SomethingNeedDoing.IPC;
using SomethingNeedDoing.Macros.Lua;

namespace SomethingNeedDoing;

public sealed class Plugin : IDalamudPlugin
{
    internal string Name => "Something Need Doing (Expanded Edition)";
    internal string Prefix => "SND";
    private const string Command = "/somethingneeddoing";
    internal string[] Aliases => ["/snd", "/pcraft"];

    internal static Plugin P { get; private set; } = null!;
    internal static Config C => P.Config;

    private readonly Config Config = null!;

    private readonly SNDProvider _sndProvider;

    public Plugin(IDalamudPluginInterface pluginInterface)
    {
        P = this;
        pluginInterface.Create<Service>();
        ECommonsMain.Init(pluginInterface, this, Module.ObjectFunctions, Module.DalamudReflector);

        EzConfig.DefaultSerializationFactory = new ConfigFactory();
        EzConfig.Migrate<Config>();
        Config = EzConfig.Init<Config>();

        SingletonServiceManager.Initialize(typeof(Service));

        Svc.Framework.RunOnFrameworkThread(() =>
        {
            EzConfigGui.Init(new Windows.MacrosUI().Draw);
            EzConfigGui.WindowSystem.AddWindow(new HelpUI());
            EzConfigGui.WindowSystem.AddWindow(new ExcelWindow());
            Svc.PluginInterface.UiBuilder.OpenMainUi += EzConfigGui.Window.Toggle;
            Svc.PluginInterface.UiBuilder.Draw += DrawDevBarEntry;

            EzCmd.Add(Command, OnChatCommand, "Open a window to edit various settings.");
            Aliases.ToList().ForEach(a => EzCmd.Add(a, OnChatCommand, $"{Command} Alias"));

            Service.AutoRetainerApi.OnCharacterPostprocessStep += CheckCharacterPostProcess;
            Service.AutoRetainerApi.OnCharacterReadyToPostProcess += DoCharacterPostProcess;
        });

        _sndProvider = new();
    }

    private void DrawDevBarEntry()
    {
        if (Svc.PluginInterface.IsDevMenuOpen && ImGui.BeginMainMenuBar())
        {
            if (ImGui.MenuItem("SND Excel"))
            {
                if (ImGui.GetIO().KeyShift)
                    EzConfigGui.Toggle();
                else
                    EzConfigGui.GetWindow<ExcelWindow>()!.Toggle();
            }
            ImGui.EndMainMenuBar();
        }
    }

    private void CheckCharacterPostProcess()
    {
        if (C.ARCharacterPostProcessMacro is not { }) return;
        if (C.ARCharacterPostProcessExcludedCharacters.Any(x => x == Svc.ClientState.LocalContentId))
            Svc.Log.Info("Skipping post process macro for current character.");
        else
            Service.AutoRetainerApi.RequestCharacterPostprocess();
    }

    private void DoCharacterPostProcess()
    {
        Service.MacroManager.OnMacroCompleted += OnPostProcessMacroCompleted;
        Service.MacroManager.EnqueueMacro(C.ARCharacterPostProcessMacro!);
    }

    private void OnPostProcessMacroCompleted(MacroNode node)
    {
        if (node.IsPostProcess)
        {
            Svc.Framework.RunOnFrameworkThread(() =>
            {
                PluginLog.Debug("Finishing post process macro for current character.");
                Service.AutoRetainerApi.FinishCharacterPostProcess();
            });
            Service.MacroManager.OnMacroCompleted -= OnPostProcessMacroCompleted;
        }
    }

    public void Dispose()
    {
        Service.AutoRetainerApi.OnCharacterPostprocessStep -= CheckCharacterPostProcess;
        Service.AutoRetainerApi.OnCharacterReadyToPostProcess -= DoCharacterPostProcess;

        Svc.PluginInterface.UiBuilder.OpenMainUi -= EzConfigGui.Window.Toggle;
        Svc.PluginInterface.UiBuilder.Draw -= DrawDevBarEntry;
        Ipc.Instance?.Dispose();
        ECommonsMain.Dispose();
    }

    private void OnChatCommand(string command, string arguments)
    {
        arguments = arguments.Trim();

        if (arguments == string.Empty)
        {
            EzConfigGui.Window.IsOpen ^= true;
            return;
        }
        else if (arguments.StartsWith("run "))
        {
            arguments = arguments[4..].Trim();

            var loopCount = 0u;
            if (arguments.StartsWith("loop "))
            {
                arguments = arguments[5..].Trim();
                var nextSpace = arguments.IndexOf(' ');
                if (nextSpace == -1)
                {
                    Service.ChatManager.PrintError("Could not determine loop count");
                    return;
                }

                if (!uint.TryParse(arguments[..nextSpace], out loopCount))
                {
                    Service.ChatManager.PrintError("Could not parse loop count");
                    return;
                }

                arguments = arguments[(nextSpace + 1)..].Trim();
            }

            var macroName = arguments.Trim('"');
            var nodes = C.GetAllNodes()
                .OfType<MacroNode>()
                .Where(node => node.Name.Trim() == macroName)
                .ToArray();

            if (nodes.Length == 0)
            {
                Service.ChatManager.PrintError("No macros match that name");
                return;
            }

            if (nodes.Length > 1)
            {
                Service.ChatManager.PrintError("More than one macro matches that name");
                return;
            }

            var node = nodes[0];

            if (loopCount > 0)
            {
                // Clone a new node so the modification doesn't save.
                node = new MacroNode()
                {
                    Name = node.Name,
                    Contents = node.Contents,
                };

                var lines = node.Contents.Split('\r', '\n');
                for (var i = lines.Length - 1; i >= 0; i--)
                {
                    var line = lines[i].Trim();
                    if (line.StartsWith("/loop"))
                    {
                        var parts = line.Split()
                            .Where(s => !string.IsNullOrEmpty(s))
                            .ToArray();

                        var echo = line.Contains("<echo>") ? "<echo>" : string.Empty;
                        lines[i] = $"/loop {loopCount} {echo}";
                        node.Contents = string.Join('\n', lines);
                        Service.ChatManager.PrintMessage($"Running macro \"{macroName}\" {loopCount} times");
                        break;
                    }
                }
            }
            else
            {
                Service.ChatManager.PrintMessage($"Running macro \"{macroName}\"");
            }

            Service.MacroManager.EnqueueMacro(node);
            return;
        }
        else if (arguments == "pause")
        {
            Service.ChatManager.PrintMessage("Pausing");
            Service.MacroManager.Pause();
            return;
        }
        else if (arguments == "pause loop")
        {
            Service.ChatManager.PrintMessage("Pausing at next /loop");
            Service.MacroManager.Pause(true);
            return;
        }
        else if (arguments == "resume")
        {
            Service.ChatManager.PrintMessage("Resuming");
            Service.MacroManager.Resume();
            return;
        }
        else if (arguments == "stop")
        {
            Service.ChatManager.PrintMessage($"Stopping");
            Service.MacroManager.Stop();
            return;
        }
        else if (arguments == "stop loop")
        {
            Service.ChatManager.PrintMessage($"Stopping at next /loop");
            Service.MacroManager.Stop(true);
            return;
        }
        else if (arguments == "help")
        {
            EzConfigGui.GetWindow<HelpUI>()!.Toggle();
            return;
        }
        else if (arguments == "excel")
        {
            EzConfigGui.GetWindow<ExcelWindow>()!.Toggle();
            return;
        }
        else if (arguments.StartsWith("cfg"))
        {
            var args = arguments[4..].Trim().Split(" ");
            C.SetProperty(args[0], args[1]);
            return;
        }
    }
}
