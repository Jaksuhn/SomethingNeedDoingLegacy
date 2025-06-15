using Dalamud.Game.Text;
using ECommons.Configuration;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using SomethingNeedDoing.Macros;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace SomethingNeedDoing;

public class Config : IEzConfig
{
    public int Version { get; set; } = 1;
    public bool LockWindow { get; set; } = false;
    public string DefaultFileName { get; set; } = "UntitledMacro";
    public string DefaultFileExtension { get; set; } = ".txt";
    public FolderNode RootFolder { get; set; } = new FolderNode { Name = "/" };
    public bool CraftSkip { get; set; } = true;
    public bool SmartWait { get; set; } = false;
    public bool QualitySkip { get; set; } = true;
    public bool LoopTotal { get; set; } = false;
    public bool LoopEcho { get; set; } = false;
    public bool DisableMonospaced { get; set; } = false;
    public bool UseCraftLoopTemplate { get; set; } = false;
    public string CraftLoopTemplate { get; set; } =
        "/craft {{count}}\n" +
        "/waitaddon \"RecipeNote\" <maxwait.5>" +
        "/click \"RecipeNote Synthesize\"" +
        "/waitaddon \"Synthesis\" <maxwait.5>" +
        "{{macro}}" +
        "/loop";

    public bool CraftLoopFromRecipeNote { get; set; } = true;
    public int CraftLoopMaxWait { get; set; } = 5;
    public bool CraftLoopEcho { get; set; } = false;
    public int MaxTimeoutRetries { get; set; } = 0;
    public bool NoisyErrors { get; set; } = false;
    public int BeepFrequency { get; set; } = 900;
    public int BeepDuration { get; set; } = 250;
    public int BeepCount { get; set; } = 3;
    public bool UseSNDTargeting { get; set; } = true;

    public MacroNode? ARCharacterPostProcessMacro
    {
        get;
        set
        {
            if (value != null)
                value.IsPostProcess = true;
            field = value;
        }
    }
    public List<ulong> ARCharacterPostProcessExcludedCharacters { get; set; } = [];

    public bool StopMacroIfActionTimeout { get; set; } = true;
    public bool StopMacroIfItemNotFound { get; set; } = true;
    public bool StopMacroIfCantUseItem { get; set; } = true;
    public bool StopMacroIfTargetNotFound { get; set; } = true;
    public bool StopMacroIfAddonNotFound { get; set; } = true;
    public bool StopMacroIfAddonNotVisible { get; set; } = true;

    /// <summary>
    /// Gets or sets the chat channel to use.
    /// </summary>
    public XivChatType ChatType { get; set; } = XivChatType.Debug;

    /// <summary>
    /// Gets or sets the error chat channel to use.
    /// </summary>
    public XivChatType ErrorChatType { get; set; } = XivChatType.Urgent;

    /// <summary>
    /// Gets or sets the paths that lua macros will use when requiring files
    /// </summary>
    public List<string> LuaRequirePaths { get; set; } = [];

    /// <summary>
    /// Gets or sets the paths that lua macros will use when requiring files, set via IPC
    /// </summary>
    public List<string> ExternalLuaRequirePaths { get; set; } = [];

    public bool UseMacroFileSystem { get; set; } = false;

    internal void Save() => EzConfig.Save();

    internal IEnumerable<INode> GetAllNodes() => new INode[] { RootFolder }.Concat(GetAllNodes(RootFolder.Children));

    internal IEnumerable<INode> GetAllNodes(IEnumerable<INode> nodes)
    {
        foreach (var node in nodes)
        {
            yield return node;
            if (node is FolderNode folder)
            {
                var childNodes = GetAllNodes(folder.Children);
                foreach (var childNode in childNodes)
                {
                    yield return childNode;
                }
            }
        }
    }

    internal bool TryFindParent(INode node, out FolderNode? parent)
    {
        foreach (var candidate in GetAllNodes())
        {
            if (candidate is FolderNode folder && folder.Children.Contains(node))
            {
                parent = folder;
                return true;
            }
        }

        parent = null;
        return false;
    }

    internal void SetProperty(string key, string value)
    {
        var property = typeof(Config).GetProperty(key);
        if (property != null && property.Name != "Version" && property.CanWrite && (property.PropertyType == typeof(int) || property.PropertyType == typeof(bool)))
        {
            if (property.PropertyType == typeof(int) && int.TryParse(value, out var intValue))
                property.SetValue(this, intValue);
            else if (property.PropertyType == typeof(bool) && bool.TryParse(value, out var boolValue))
                property.SetValue(this, boolValue);
            else
                Svc.Log.Error($"Value type does not match property type for {key}: {value.GetType()} != {property.PropertyType}");
        }
        else
            Svc.Log.Error($"Invalid configuration key or type");
    }

    internal object? GetProperty(string key)
    {
        var property = typeof(Config).GetProperty(key);
        return property != null && property.Name != "Version" && property.CanWrite ? property.GetValue(this) : null;
    }

    [JsonIgnore]
    internal string RootFolderPath
        => Directory.GetDirectories(Svc.PluginInterface.GetPluginConfigDirectory()).Select(x => new DirectoryInfo(x)).FirstOrDefault(x => x.Name == RootFolder.Name)?.FullName
        ?? Directory.CreateDirectory(Path.Combine(Svc.PluginInterface.GetPluginConfigDirectory(), RootFolder.Name)).FullName;
}

public class ConfigFactory : ISerializationFactory
{
    public string DefaultConfigFileName => "SomethingNeedDoing.json";

    public bool IsBinary => false;

    public T? Deserialize<T>(string inputData)
    {
        try
        {
            return JsonConvert.DeserializeObject<T>(inputData, JsonSerializerSettings);
        }
        catch
        {
            return JsonConvert.DeserializeObject<T>(inputData);
        }
    }

    public string? Serialize(object data, bool pretty = false)
        => JsonConvert.SerializeObject(data, JsonSerializerSettings);
    public string? Serialize(object config) => Serialize(config, false);
    public T? Deserialize<T>(byte[] inputData) => Deserialize<T>(Encoding.UTF8.GetString(inputData));
    public byte[]? SerializeAsBin(object config) => Encoding.UTF8.GetBytes(Serialize(config));

    public static readonly JsonSerializerSettings JsonSerializerSettings = new()
    {
        TypeNameHandling = TypeNameHandling.Auto,
        TypeNameAssemblyFormatHandling = TypeNameAssemblyFormatHandling.Simple,
        SerializationBinder = new CustomSerializationBinder(),
        Formatting = Formatting.Indented,
    };

    public class CustomSerializationBinder : DefaultSerializationBinder
    {
        public override Type BindToType(string? assemblyName, string typeName)
        {
            try
            {
                return base.BindToType(assemblyName, typeName);
            }
            catch (Exception)
            {
                if (assemblyName == null || assemblyName == typeof(Plugin).Assembly.GetName().Name)
                    return typeof(Plugin).Assembly.GetTypes().First(x => x.FullName == typeName);
                throw;
            }
        }
    }
}
