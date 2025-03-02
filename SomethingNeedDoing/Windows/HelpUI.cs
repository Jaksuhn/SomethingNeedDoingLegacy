using Dalamud.Game.ClientState.Conditions;
using Dalamud.Game.ClientState.Keys;
using Dalamud.Game.ClientState.Objects.Enums;
using Dalamud.Game.Text;
using Dalamud.Interface;
using Dalamud.Interface.Colors;
using Dalamud.Interface.Utility.Raii;
using Dalamud.Interface.Windowing;
using ECommons.Automation.UIInput;
using ECommons.UIHelpers.AddonMasterImplementations;
using FFXIVClientStructs.FFXIV.Client.Game;
using ImGuiNET;
using SomethingNeedDoing.Grammar.Commands;
using SomethingNeedDoing.Macros.Commands.Modifiers;
using SomethingNeedDoing.Macros.Lua;
using SomethingNeedDoing.Misc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Reflection;
using System.Text;

namespace SomethingNeedDoing.Interface
{
    internal class HelpUI : Window
    {
        //----------------------------------------------------------------------------------------
        // Window Config and Fields
        //----------------------------------------------------------------------------------------

        public static new readonly string WindowName = "Something Need Doing - Help & Settings";

        private const ImGuiWindowFlags MAIN_WINDOW_FLAGS = ImGuiWindowFlags.NoScrollbar;
        private static readonly Vector2 DEFAULT_WINDOW_SIZE = new(550, 650);

        private static readonly Vector4 SECTION_HEADER_COLOR = new(0.65f, 0.7f, 0.9f, 1.0f);
        private static readonly Vector4 SUBSECTION_COLOR = new(0.6f, 0.65f, 0.85f, 1.0f);
        private static readonly Vector4 HIGHLIGHT_COLOR = new(0.7f, 0.9f, 1.0f, 1.0f);
        private static readonly Vector4 HELP_TEXT_COLOR = ImGuiUtils.ShadedColor;
        private const float INDENT_SIZE = 20.0f;
        private const ImGuiTreeNodeFlags HEADER_FLAGS = ImGuiTreeNodeFlags.DefaultOpen;

        //----------------------------------------------------------------------------------------
        // Search and Tab Tracking
        //----------------------------------------------------------------------------------------

        private string searchText = string.Empty;
        private bool isSearching = false;
        private int currentTab = 0;
        // This variable is used only to force-select a tab for one frame when a "Go to..." button is clicked.
        private int forcedTab = -1;

        // The tab order is as follows:
        // 0: Options, 1: Commands, 2: Modifiers, 3: Lua,
        // 4: CLI, 5: Clicks, 6: Sends, 7: Conditions,
        // 8: Game Data, 9: Changelog, 10: Debug
        private readonly string[] tabNames =
        {
            "Options", "Commands", "Modifiers", "Lua",
            "CLI", "Clicks", "Sends", "Conditions",
            "Game Data", "Changelog", "Debug"
        };

        private bool showOnlyActiveConditions = false;

        private readonly (string Name, string Description, string? Example)[] cliData =
        {
            ("help", "Show this window.", null),
            ("run", "Run a macro, the name must be unique.", $"{P.Aliases[0]} run MyMacro"),
            ("run loop #", "Run a macro and then loop N times, the name must be unique. Only the last /loop in the macro is replaced", $"{P.Aliases[0]} run loop 5 MyMacro"),
            ("pause", "Pause the currently executing macro.", null),
            ("pause loop", "Pause the currently executing macro at the next /loop.", null),
            ("resume", "Resume the currently paused macro.", null),
            ("stop", "Clear the currently executing macro list.", null),
            ("stop loop", "Clear the currently executing macro list at the next /loop.", null),
        };

        private readonly List<string> clickNames;
        private List<string> luaRequirePathsBuffer = new();

        public HelpUI() : base(WindowName)
        {
            Flags |= MAIN_WINDOW_FLAGS;
            Size = DEFAULT_WINDOW_SIZE;
            SizeCondition = ImGuiCond.FirstUseEver;
            RespectCloseHotkey = false;

            clickNames = new List<string>(ClickHelper.GetAvailableClicks());
            luaRequirePathsBuffer = new List<string>(C.LuaRequirePaths);
        }

        //----------------------------------------------------------------------------------------
        // ImGui Window Draw
        //----------------------------------------------------------------------------------------

        public override void Draw()
        {
            // 1) Always show search bar
            DrawSearchBar();

            // 2) If searching, show those results right away 
            if (isSearching && !string.IsNullOrWhiteSpace(searchText))
            {
                DrawSearchResults();
                ImGui.Spacing();
                ImGui.Separator();
                ImGui.Spacing();
            }

            // 3) Main tab bar always visible
            using var tabs = ImRaii.TabBar("SNDHelpMainTabBar");
            if (!tabs)
                return;

            // For each tab, if forcedTab equals its index, we add the SetSelected flag.
            // Otherwise we use no extra flag. This lets the user click tabs normally.
            // If the tab is active (i.e. the ImGui TabItem call returns true) we update currentTab.
            // After drawing, clear forcedTab so it only applies for one frame.
            // Tab #0: Options
            using (var tab = ImRaii.TabItem("Options", forcedTab == 0 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 0;
                    DrawOptions();
                }
            }

            // Tab #1: Commands
            using (var tab = ImRaii.TabItem("Commands", forcedTab == 1 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 1;
                    DrawCommands();
                }
            }

            // Tab #2: Modifiers
            using (var tab = ImRaii.TabItem("Modifiers", forcedTab == 2 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 2;
                    DrawModifiers();
                }
            }

            // Tab #3: Lua
            using (var tab = ImRaii.TabItem("Lua", forcedTab == 3 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 3;
                    DrawLua();
                }
            }

            // Tab #4: CLI
            using (var tab = ImRaii.TabItem("CLI", forcedTab == 4 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 4;
                    DrawCli();
                }
            }

            // Tab #5: Clicks
            using (var tab = ImRaii.TabItem("Clicks", forcedTab == 5 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 5;
                    DrawClicks();
                }
            }

            // Tab #6: Sends
            using (var tab = ImRaii.TabItem("Sends", forcedTab == 6 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 6;
                    DrawVirtualKeys();
                }
            }

            // Tab #7: Conditions
            using (var tab = ImRaii.TabItem("Conditions", forcedTab == 7 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 7;
                    DrawAllConditions();
                }
            }

            // Tab #8: Game Data
            using (var tab = ImRaii.TabItem("Game Data", forcedTab == 8 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 8;
                    DrawGameData();
                }
            }

            // Tab #9: Changelog (directly in tab)
            using (var tab = ImRaii.TabItem("Changelog", forcedTab == 9 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 9;
                    Changelog.Draw();
                }
            }

            // Tab #10: Debug
            using (var tab = ImRaii.TabItem("Debug", forcedTab == 10 ? ImGuiTabItemFlags.SetSelected : ImGuiTabItemFlags.None))
            {
                if (tab)
                {
                    currentTab = 10;
                    DrawDebug();
                }
            }

            // Clear forcedTab after one frame so tabs are not permanently forced.
            forcedTab = -1;
        }

        //----------------------------------------------------------------------------------------
        // Search Bar and Results
        //----------------------------------------------------------------------------------------

        private void DrawSearchBar()
        {
            ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.1f, 0.1f, 0.12f, 0.2f));
            ImGui.BeginChild("SNDHelpSearchBarRegion", new Vector2(-1, 45), true);

            ImGui.TextColored(SECTION_HEADER_COLOR, "Search:");
            ImGui.SameLine();

            ImGui.SetNextItemWidth(ImGui.GetContentRegionAvail().X - 160);
            bool enterPressed = ImGui.InputText("##SearchInput", ref searchText, 200, ImGuiInputTextFlags.EnterReturnsTrue);

            ImGui.SameLine();
            if (ImGui.Button("Search", new Vector2(70, 0)) || enterPressed)
            {
                isSearching = !string.IsNullOrWhiteSpace(searchText);
            }

            ImGui.SameLine();
            if (ImGui.Button("Clear", new Vector2(70, 0)))
            {
                searchText = string.Empty;
                isSearching = false;
            }

            ImGui.EndChild();
            ImGui.PopStyleColor();
        }

        private void DrawSearchResults()
        {
            BeginScrollableContent();

            ImGui.TextColored(SECTION_HEADER_COLOR, $"Search Results for \"{searchText}\"");
            ImGui.Spacing();

            string normalized = searchText.ToLowerInvariant();
            bool foundAny = false;

            // Each method tries to find matches. If found, prints a header + result block.
            bool commandsFound = SearchCommands(normalized);
            bool modifiersFound = SearchModifiers(normalized);
            bool cliFound = SearchCliCommands(normalized);
            bool clickFound = SearchClicks(normalized);
            bool keyFound = SearchVirtualKeys(normalized);
            bool condFound = SearchConditions(normalized);

            foundAny = commandsFound || modifiersFound || cliFound || clickFound || keyFound || condFound;

            if (!foundAny)
            {
                ImGui.TextColored(ImGuiColors.DalamudYellow, "No results found.");
                ImGui.TextWrapped("Try using different keywords or check your spelling.");
            }

            EndScrollableContent();
        }

        //----------------------------------------------------------------------------------------
        // Tabs
        //----------------------------------------------------------------------------------------

        #region TAB: Options

        private void DrawOptions()
        {
            BeginScrollableContent();
            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            SectionTitle("Crafting Options");

            if (ImGui.CollapsingHeader("Crafting skips", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var craftSkip = C.CraftSkip;
                if (ImGui.Checkbox("Craft Skip", ref craftSkip))
                {
                    C.CraftSkip = craftSkip;
                    C.Save();
                }
                ImGui.TextWrapped("Skip craft actions when not actually crafting.");

                ImGui.Spacing();
                var smartWait = C.SmartWait;
                if (ImGui.Checkbox("Smart Wait", ref smartWait))
                {
                    C.SmartWait = smartWait;
                    C.Save();
                }
                ImGui.TextWrapped("Wait for crafting actions to complete dynamically instead of <wait> or <unsafe>.");

                ImGui.Spacing();
                var qualitySkip = C.QualitySkip;
                if (ImGui.Checkbox("Quality Skip", ref qualitySkip))
                {
                    C.QualitySkip = qualitySkip;
                    C.Save();
                }
                ImGui.TextWrapped("Skip quality-increasing actions once HQ chance is 100%. Disable if you rely on final durability from Manipulation, etc.");

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("Loop echo", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var loopEcho = C.LoopEcho;
                if (ImGui.Checkbox("Craft and Loop Echo", ref loopEcho))
                {
                    C.LoopEcho = loopEcho;
                    C.Save();
                }
                ImGui.TextWrapped("/loop and /craft commands will have <echo> added.");

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("Action retry", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                ImGui.SetNextItemWidth(100);
                var maxRetries = C.MaxTimeoutRetries;
                if (ImGui.InputInt("Action max timeout retries", ref maxRetries, 1))
                {
                    maxRetries = Math.Clamp(maxRetries, 0, 10);
                    C.MaxTimeoutRetries = maxRetries;
                    C.Save();
                }
                ImGui.TextWrapped("Number of times to re-attempt /action if no timely server response.");

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("Font", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var disableMono = C.DisableMonospaced;
                if (ImGui.Checkbox("Disable Monospaced fonts", ref disableMono))
                {
                    C.DisableMonospaced = disableMono;
                    C.Save();
                }
                ImGui.TextWrapped("Use normal fonts in the macro editor (helpful for non-Latin text).");

                ImGui.Unindent(INDENT_SIZE);
            }

            SectionTitle("Craft Loop Configuration");

            if (ImGui.CollapsingHeader("Craft loop", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var useTemplate = C.UseCraftLoopTemplate;
                if (ImGui.Checkbox("Enable CraftLoop templating", ref useTemplate))
                {
                    C.UseCraftLoopTemplate = useTemplate;
                    C.Save();
                }
                ImGui.TextWrapped("Replace placeholders in a template with real values.");

                ImGui.Spacing();
                if (useTemplate)
                {
                    var craftLoopTemplate = C.CraftLoopTemplate;
                    const string MACRO_KEY = "{{macro}}";
                    const string COUNT_KEY = "{{count}}";

                    if (!craftLoopTemplate.Contains(MACRO_KEY))
                    {
                        ImGui.TextColored(ImGuiColors.DPSRed, $"Template must contain '{MACRO_KEY}'");
                    }

                    ImGui.TextWrapped($"{MACRO_KEY} inserts the macro text; {COUNT_KEY} inserts loop counts.");

                    if (ImGui.InputTextMultiline("##CraftLoopTemplate", ref craftLoopTemplate, 100_000, new Vector2(-1, 200)))
                    {
                        C.CraftLoopTemplate = craftLoopTemplate;
                        C.Save();
                    }
                }
                else
                {
                    var fromRecipe = C.CraftLoopFromRecipeNote;
                    if (ImGui.Checkbox("CraftLoop starts in the Crafting Log", ref fromRecipe))
                    {
                        C.CraftLoopFromRecipeNote = fromRecipe;
                        C.Save();
                    }
                    ImGui.TextWrapped("If true, the Crafting Log must be open to use CraftLoop; otherwise, the Synthesis window must be open.");

                    ImGui.Spacing();
                    var loopEcho = C.CraftLoopEcho;
                    if (ImGui.Checkbox("CraftLoop Craft and Loop echo", ref loopEcho))
                    {
                        C.CraftLoopEcho = loopEcho;
                        C.Save();
                    }
                    ImGui.TextWrapped("/craft or /gate commands from CraftLoop will add <echo>.");

                    ImGui.Spacing();
                    ImGui.SetNextItemWidth(100);
                    var loopMaxWait = C.CraftLoopMaxWait;
                    if (ImGui.InputInt("CraftLoop maxwait", ref loopMaxWait, 1))
                    {
                        loopMaxWait = Math.Max(0, loopMaxWait);
                        C.CraftLoopMaxWait = loopMaxWait;
                        C.Save();
                    }
                    ImGui.TextWrapped("Sets the <maxwait> for /waitaddon in macros generated by CraftLoop.");
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            SectionTitle("Notifications & UI");

            if (ImGui.CollapsingHeader("Chat", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var names = Enum.GetNames<XivChatType>();
                var chatTypes = Enum.GetValues<XivChatType>();

                // Normal
                var currentIndex = Array.IndexOf(chatTypes, C.ChatType);
                if (currentIndex < 0)
                {
                    currentIndex = Array.IndexOf(chatTypes, XivChatType.Echo);
                    C.ChatType = XivChatType.Echo;
                    C.Save();
                }

                ImGui.TextUnformatted("Normal chat channel:");
                ImGui.SameLine();
                ImGui.SetNextItemWidth(200f);
                if (ImGui.Combo("##NormalChat", ref currentIndex, names, names.Length))
                {
                    C.ChatType = chatTypes[currentIndex];
                    C.Save();
                }

                // Error
                var currentErrIndex = Array.IndexOf(chatTypes, C.ErrorChatType);
                if (currentErrIndex < 0)
                {
                    currentErrIndex = Array.IndexOf(chatTypes, XivChatType.Urgent);
                    C.ErrorChatType = XivChatType.Urgent;
                    C.Save();
                }

                ImGui.TextUnformatted("Error chat channel:");
                ImGui.SameLine();
                ImGui.SetNextItemWidth(200f);
                if (ImGui.Combo("##ErrorChat", ref currentErrIndex, names, names.Length))
                {
                    C.ErrorChatType = chatTypes[currentErrIndex];
                    C.Save();
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("Error beeps", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var noisy = C.NoisyErrors;
                if (ImGui.Checkbox("Noisy errors", ref noisy))
                {
                    C.NoisyErrors = noisy;
                    C.Save();
                }
                ImGui.TextWrapped("Play a beep if a check fails or an error occurs.");

                if (noisy)
                {
                    // Frequency
                    ImGui.SetNextItemWidth(100);
                    var freq = C.BeepFrequency;
                    if (ImGui.InputInt("Frequency (Hz)", ref freq, 100))
                    {
                        freq = Math.Clamp(freq, 200, 2000);
                        C.BeepFrequency = freq;
                        C.Save();
                    }

                    // Duration
                    ImGui.SetNextItemWidth(100);
                    var dur = C.BeepDuration;
                    if (ImGui.InputInt("Duration (ms)", ref dur, 50))
                    {
                        dur = Math.Clamp(dur, 50, 2000);
                        C.BeepDuration = dur;
                        C.Save();
                    }

                    // Count
                    ImGui.SetNextItemWidth(100);
                    var cnt = C.BeepCount;
                    if (ImGui.InputInt("Count", ref cnt, 1))
                    {
                        cnt = Math.Clamp(cnt, 1, 5);
                        C.BeepCount = cnt;
                        C.Save();
                    }

                    if (ImGui.Button("Test Sound", new Vector2(120, 0)))
                    {
                        System.Threading.Tasks.Task.Run(() =>
                        {
                            for (var i = 0; i < cnt; i++)
                                Console.Beep(freq, dur);
                        });
                    }
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            SectionTitle("Command Behaviors");

            if (ImGui.CollapsingHeader("/action", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var stopActionTimeout = C.StopMacroIfActionTimeout;
                if (ImGui.Checkbox("Stop macro if /action times out", ref stopActionTimeout))
                {
                    C.StopMacroIfActionTimeout = stopActionTimeout;
                    C.Save();
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("/item", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var stopNoItem = C.StopMacroIfItemNotFound;
                if (ImGui.Checkbox("Stop macro if the item to use is not found", ref stopNoItem))
                {
                    C.StopMacroIfItemNotFound = stopNoItem;
                    C.Save();
                }

                var stopCantUse = C.StopMacroIfCantUseItem;
                if (ImGui.Checkbox("Stop macro if you cannot use an item", ref stopCantUse))
                {
                    C.StopMacroIfCantUseItem = stopCantUse;
                    C.Save();
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("/target", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var defaultTarget = C.UseSNDTargeting;
                if (ImGui.Checkbox("Use SND's targeting system", ref defaultTarget))
                {
                    C.UseSNDTargeting = defaultTarget;
                    C.Save();
                }
                ImGui.TextWrapped("Override normal /target with SND's system.");

                var stopMacroIfNotFound = C.StopMacroIfTargetNotFound;
                if (ImGui.Checkbox("Stop macro if target not found", ref stopMacroIfNotFound))
                {
                    C.StopMacroIfTargetNotFound = stopMacroIfNotFound;
                    C.Save();
                }
                ImGui.TextWrapped("(Applies only if SND's targeting is in use).");

                ImGui.Unindent(INDENT_SIZE);
            }

            if (ImGui.CollapsingHeader("/waitaddon", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                var stopAddonNotFound = C.StopMacroIfAddonNotFound;
                if (ImGui.Checkbox("Stop macro if the requested addon is not found", ref stopAddonNotFound))
                {
                    C.StopMacroIfAddonNotFound = stopAddonNotFound;
                    C.Save();
                }

                var stopAddonNotVisible = C.StopMacroIfAddonNotVisible;
                if (ImGui.Checkbox("Stop macro if the requested addon is not visible", ref stopAddonNotVisible))
                {
                    C.StopMacroIfAddonNotVisible = stopAddonNotVisible;
                    C.Save();
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            SectionTitle("Plugin Integrations");

            if (ImGui.CollapsingHeader("AutoRetainer", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                ImGui.TextColored(SUBSECTION_COLOR, "Script to run on AutoRetainer CharacterPostProcess");
                ImGui.SetNextItemWidth(300);
                using (var combo = ImRaii.Combo("##ARCharacterPostProcessMacro", C.ARCharacterPostProcessMacro?.Name ?? "None"))
                {
                    if (combo)
                    {
                        if (ImGui.Selectable("None##EmptySelection"))
                        {
                            C.ARCharacterPostProcessMacro = null;
                            C.Save();
                        }

                        ImGui.Separator();
                        foreach (var node in C.GetAllNodes().OfType<MacroNode>())
                        {
                            if (ImGui.Selectable(node.Name))
                            {
                                C.ARCharacterPostProcessMacro = node;
                                C.Save();
                            }
                        }
                    }
                }

                bool isExcluded = C.ARCharacterPostProcessExcludedCharacters.Any(x => x == Svc.ClientState.LocalContentId);
                if (isExcluded)
                {
                    if (ImGui.Button("Remove current character from exclusion list", new Vector2(300, 0)))
                    {
                        C.ARCharacterPostProcessExcludedCharacters.RemoveAll(x => x == Svc.ClientState.LocalContentId);
                        C.Save();
                    }
                }
                else
                {
                    if (ImGui.Button("Exclude current character", new Vector2(300, 0)))
                    {
                        C.ARCharacterPostProcessExcludedCharacters.Add(Svc.ClientState.LocalContentId);
                        C.Save();
                    }
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            SectionTitle("Scripting");

            if (ImGui.CollapsingHeader("Lua", HEADER_FLAGS))
            {
                ImGui.Indent(INDENT_SIZE);

                ImGui.TextColored(SUBSECTION_COLOR, "Lua Required Paths");
                ImGui.TextWrapped("Add or remove directories from which Lua scripts can be loaded (require).");

                string[] localPaths = luaRequirePathsBuffer.ToArray();
                for (int i = 0; i < localPaths.Length; i++)
                {
                    ImGui.PushID($"LuaPath{i}");

                    if (ImGuiX.IconButton(FontAwesomeIcon.Trash, "Delete Path " + i))
                    {
                        luaRequirePathsBuffer.RemoveAt(i);
                        luaRequirePathsBuffer = luaRequirePathsBuffer.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                        C.LuaRequirePaths = luaRequirePathsBuffer.ToArray();
                        C.Save();
                        ImGui.PopID();
                        break;
                    }

                    ImGui.SameLine();
                    ImGui.SetNextItemWidth(ImGui.GetContentRegionAvail().X - 50);
                    if (ImGui.InputText($"##LuaPathInput{i}", ref localPaths[i], 512))
                    {
                        luaRequirePathsBuffer[i] = localPaths[i];
                        luaRequirePathsBuffer = luaRequirePathsBuffer.Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
                        C.LuaRequirePaths = luaRequirePathsBuffer.ToArray();
                        C.Save();
                    }

                    ImGui.PopID();
                }

                if (ImGuiX.IconButton(FontAwesomeIcon.Plus, "Add Path"))
                {
                    luaRequirePathsBuffer.Add(string.Empty);
                }

                ImGui.Unindent(INDENT_SIZE);
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: Commands

        private void DrawCommands()
        {
            BeginScrollableContent();
            SectionTitle("Available Commands");
            ImGui.TextWrapped("A list of recognized /commands. Click an example to copy.");

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            var macroCommandTypes = typeof(MacroCommand).Assembly
                .GetTypes()
                .Where(t => t.IsSubclassOf(typeof(MacroCommand)) && t != typeof(NativeCommand))
                .OrderBy(t => t.Name);

            foreach (var type in macroCommandTypes)
            {
                var commandsProp = type.GetProperty("Commands", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var descProp = type.GetProperty("Description", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var exProp = type.GetProperty("Examples", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);

                string cmdName = type.Name.ToLower().Replace("command", "");
                string[] aliases = commandsProp != null ? (string[])commandsProp.GetValue(null)! : Array.Empty<string>();
                string desc = descProp != null ? (string)descProp.GetValue(null)! : string.Empty;
                string[] examples = exProp != null ? (string[])exProp.GetValue(null)! : Array.Empty<string>();

                ImGui.TextColored(HIGHLIGHT_COLOR, $"/{cmdName}");
                if (aliases.Length > 0)
                    ImGui.TextUnformatted("Aliases: " + string.Join(", ", aliases));

                if (!string.IsNullOrEmpty(desc))
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Description:");
                    ImGui.TextWrapped(desc);
                }

                if (examples.Length > 0)
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Examples:");
                    foreach (var ex in examples)
                    {
                        ImGui.TextUnformatted("   • ");
                        ImGui.SameLine();
                        ImGuiUtils.ClickToCopyText(ex);
                    }
                }

                ImGui.Spacing();
                ImGui.Separator();
                ImGui.Spacing();
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: Modifiers

        private void DrawModifiers()
        {
            BeginScrollableContent();
            SectionTitle("Command Modifiers");
            ImGui.TextWrapped("Modifiers adjust the behavior of a command. Click an example to copy.");

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            var modifierTypes = typeof(MacroModifier).Assembly
                .GetTypes()
                .Where(t => t.IsSubclassOf(typeof(MacroModifier)))
                .OrderBy(t => t.Name);

            foreach (var type in modifierTypes)
            {
                var modProp = type.GetProperty("Modifier", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var descProp = type.GetProperty("Description", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var exProp = type.GetProperty("Examples", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);

                string modName = modProp != null ? (string)modProp.GetValue(null)! : string.Empty;
                string desc = descProp != null ? (string)descProp.GetValue(null)! : string.Empty;
                string[] examples = exProp != null ? (string[])exProp.GetValue(null)! : Array.Empty<string>();

                ImGui.TextColored(HIGHLIGHT_COLOR, modName);

                if (!string.IsNullOrEmpty(desc))
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Description:");
                    ImGui.TextWrapped(desc);
                }

                if (examples.Length > 0)
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Examples:");
                    foreach (var example in examples)
                    {
                        ImGui.TextUnformatted("   • ");
                        ImGui.SameLine();
                        ImGuiUtils.ClickToCopyText(example);
                    }
                }

                ImGui.Spacing();
                ImGui.Separator();
                ImGui.Spacing();
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: Lua

        private void DrawLua()
        {
            BeginScrollableContent();
            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            SectionTitle("Lua Scripting");
            ImGui.TextWrapped(
                "Lua scripts can yield commands for advanced logic.\n\n" +
                @"Example:
yield(""/ac Muscle memory <wait.3>"")
yield(""/ac Precise touch <wait.2>"")
yield(""/echo done!"")" +
                "\n\nDalamud services are globally available as Svc.<Name>. " +
                "See: https://github.com/goatcorp/Dalamud/tree/master/Dalamud/Plugin/Services for more details."
            );

            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();

            SectionTitle("Available Lua Helper Libraries");

            var commands = new List<(string, dynamic)>
            {
                (nameof(Actions), Actions.Instance),
                (nameof(Addons), Addons.Instance),
                (nameof(CharacterState), CharacterState.Instance),
                (nameof(CraftingState), CraftingState.Instance),
                (nameof(EntityState), EntityState.Instance),
                (nameof(Internal), Internal.Instance),
                (nameof(Inventory), Inventory.Instance),
                (nameof(Ipc), Ipc.Instance),
                (nameof(Quests), Quests.Instance),
                (nameof(UserEnv), UserEnv.Instance),
                (nameof(WorldState), WorldState.Instance),
            };

            foreach (var (libName, libObj) in commands)
            {
                ImGui.TextColored(HIGHLIGHT_COLOR, libName);
                using var color = ImRaii.PushColor(ImGuiCol.Text, HELP_TEXT_COLOR);
                ECommons.ImGuiMethods.ImGuiEx.TextWrapped(string.Join("\n", libObj.ListAllFunctions()));
                ImGui.Spacing();
                ImGui.Separator();
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: CLI

        private void DrawCli()
        {
            BeginScrollableContent();
            SectionTitle("Command-Line Interface");
            ImGui.TextWrapped($"Use {P.Aliases[0]} <command> in chat to control the plugin externally.");

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            foreach (var (cmdName, desc, example) in cliData)
            {
                ImGui.TextColored(HIGHLIGHT_COLOR, $"{P.Aliases[0]} {cmdName}");
                ImGui.TextColored(SUBSECTION_COLOR, "Description:");
                ImGui.TextWrapped(desc);

                if (!string.IsNullOrEmpty(example))
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Example:");
                    ImGuiUtils.ClickToCopyText(example);
                }

                ImGui.Spacing();
                ImGui.Separator();
                ImGui.Spacing();
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: Clicks

        private unsafe void DrawClicks()
        {
            BeginScrollableContent();
            SectionTitle("UI Click Commands");
            ImGui.TextWrapped("Use /click <name> to interact with UI elements. Red names are property-based and not directly callable.");

            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            const int COLUMNS = 2;
            if (ImGui.BeginTable("ClicksTable", COLUMNS, ImGuiTableFlags.Borders | ImGuiTableFlags.RowBg))
            {
                for (int i = 0; i < COLUMNS; i++)
                {
                    ImGui.TableSetupColumn($"ClickCol{i}", ImGuiTableColumnFlags.WidthStretch);
                }

                int col = 0;
                ImGui.TableNextRow();

                foreach (var clickName in clickNames)
                {
                    if (col == 0)
                        ImGui.TableNextRow();

                    ImGui.TableSetColumnIndex(col);

                    bool isProperty = clickName.Contains('.');
                    var color = isProperty ? ImGuiColors.DalamudRed : *ImGui.GetStyleColorVec4(ImGuiCol.Text);

                    ImGuiUtils.ClickToCopyText($"/click {clickName}", color);

                    col = (col + 1) % COLUMNS;
                }

                ImGui.EndTable();
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: Sends

        private void DrawVirtualKeys()
        {
            BeginScrollableContent();
            SectionTitle("Virtual Key Commands");
            ImGui.TextWrapped("Use /send <KEY> to emulate keyboard input. Active keys show in green.");

            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            var validKeys = Svc.KeyState.GetValidVirtualKeys().ToHashSet();
            var names = Enum.GetNames<VirtualKey>();
            var values = Enum.GetValues<VirtualKey>();

            const int COLUMNS = 3;
            if (ImGui.BeginTable("KeysTable", COLUMNS, ImGuiTableFlags.Borders | ImGuiTableFlags.RowBg))
            {
                for (int i = 0; i < COLUMNS; i++)
                {
                    ImGui.TableSetupColumn($"SendCol{i}", ImGuiTableColumnFlags.WidthStretch);
                }

                int col = 0;
                ImGui.TableNextRow();

                for (int i = 0; i < names.Length; i++)
                {
                    var keyName = names[i];
                    var keyValue = values[i];
                    if (!validKeys.Contains(keyValue))
                        continue;

                    bool isActive = Svc.KeyState[keyValue];

                    if (col == 0)
                        ImGui.TableNextRow();

                    ImGui.TableSetColumnIndex(col);

                    using var color = ImRaii.PushColor(ImGuiCol.Text, ImGuiColors.HealerGreen, isActive);
                    if (ImGui.Selectable($"/send {keyName}", false))
                    {
                        ImGui.SetClipboardText($"/send {keyName}");
                    }

                    col = (col + 1) % COLUMNS;
                }

                ImGui.EndTable();
            }

            EndScrollableContent();
        }

        #endregion

        #region TAB: Conditions

        private void DrawAllConditions()
        {
            BeginScrollableContent();

            SectionTitle("Game Conditions");
            ImGui.TextWrapped("Use /if condition <flag> in macros to check these states.");

            // Show currently active conditions in a box (left to right)
            DrawActiveConditionsSummary();

            ImGui.Spacing();
            ImGui.Checkbox("Show only active conditions", ref showOnlyActiveConditions);
            ImGui.Spacing();

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);

            // Full condition list in a table from left to right
            const int COLUMNS = 3;
            if (ImGui.BeginTable("ConditionFlagsTable", COLUMNS, ImGuiTableFlags.Borders | ImGuiTableFlags.RowBg))
            {
                for (int i = 0; i < COLUMNS; i++)
                {
                    ImGui.TableSetupColumn($"CondCol{i}", ImGuiTableColumnFlags.WidthStretch);
                }

                int col = 0;
                ImGui.TableNextRow();

                foreach (ConditionFlag flag in Enum.GetValues(typeof(ConditionFlag)))
                {
                    bool isActive = Svc.Condition[flag];
                    if (showOnlyActiveConditions && !isActive)
                        continue;

                    if (col == 0)
                        ImGui.TableNextRow();

                    ImGui.TableSetColumnIndex(col);

                    using var color = ImRaii.PushColor(ImGuiCol.Text, ImGuiColors.HealerGreen, isActive);
                    ImGui.TextUnformatted($"ID: {(int)flag}, {flag}");

                    col = (col + 1) % COLUMNS;
                }

                ImGui.EndTable();
            }

            EndScrollableContent();
        }

        /// <summary>
        /// Shows a small child listing all currently active conditions
        /// </summary>
        private void DrawActiveConditionsSummary()
        {
            var activeFlags = Enum.GetValues(typeof(ConditionFlag))
                .Cast<ConditionFlag>()
                .Where(f => Svc.Condition[f])
                .ToList();

            // Child with a tinted background
            ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.1f, 0.2f, 0.1f, 0.3f));
            ImGui.BeginChild("ActiveConditionsBox", new Vector2(-1, activeFlags.Count > 0 ? 80 : 40), true);

            ImGui.TextColored(HIGHLIGHT_COLOR, "Currently Active Conditions:");
            if (activeFlags.Count == 0)
            {
                ImGui.TextWrapped("None");
            }
            else
            {
                StringBuilder sb = new StringBuilder();
                int itemsPerRow = 6;

                for (int i = 0; i < activeFlags.Count; i++)
                {
                    sb.Append(activeFlags[i].ToString());

                    // Add comma if not the last item
                    if (i < activeFlags.Count - 1)
                    {
                        sb.Append(", ");
                    }

                    // Start a new line after every 6 items
                    if ((i + 1) % itemsPerRow == 0 && i < activeFlags.Count - 1)
                    {
                        ImGui.TextColored(ImGuiColors.HealerGreen, sb.ToString());
                        sb.Clear();
                    }
                }

                // Output any remaining items in the last line
                if (sb.Length > 0)
                {
                    ImGui.TextColored(ImGuiColors.HealerGreen, sb.ToString());
                }
            }

            ImGui.EndChild();
            ImGui.PopStyleColor();

            ImGui.Spacing();
        }

        #endregion

        #region TAB: Game Data

        private void DrawGameData()
        {
            SectionTitle("Game Data Reference");
            ImGui.TextWrapped("Reference info for enumerations such as ObjectKind, InventoryType, etc.");

            using var subTabs = ImRaii.TabBar("GameDataInnerTabs");
            if (subTabs)
            {
                using (var tab = ImRaii.TabItem("Object Kinds"))
                {
                    if (tab)
                        DrawEnumTable<ObjectKind>("Possible entity object kinds (e.g. for /target).");
                }

                using (var tab = ImRaii.TabItem("Inventory Types"))
                {
                    if (tab)
                        DrawEnumTable<InventoryType>("Enumerations for different inventory containers.");
                }
            }
        }

        private void DrawEnumTable<T>(string? description) where T : Enum
        {
            if (!string.IsNullOrEmpty(description))
            {
                ImGui.TextColored(SUBSECTION_COLOR, description);
                ImGui.Spacing();
            }

            using var font = ImRaii.PushFont(UiBuilder.MonoFont);
            if (ImGui.BeginTable($"EnumTable_{typeof(T).Name}", 2, ImGuiTableFlags.Borders | ImGuiTableFlags.RowBg))
            {
                ImGui.TableSetupColumn("Name", ImGuiTableColumnFlags.WidthStretch);
                ImGui.TableSetupColumn("Value", ImGuiTableColumnFlags.WidthFixed, 70.0f);
                ImGui.TableHeadersRow();

                foreach (var val in Enum.GetValues(typeof(T)))
                {
                    ImGui.TableNextRow();
                    ImGui.TableSetColumnIndex(0);
                    ImGui.TextUnformatted(val?.ToString() ?? "Unknown");

                    ImGui.TableSetColumnIndex(1);
                    var intVal = Convert.ChangeType(val, Enum.GetUnderlyingType(typeof(T)));
                    ImGui.TextUnformatted(intVal?.ToString() ?? "?");
                }

                ImGui.EndTable();
            }
        }

        #endregion

        #region TAB: Debug

        private void DrawDebug()
        {
            BeginScrollableContent();
            SectionTitle("Debug Information");
            ImGui.TextWrapped("Technical debug output, e.g. chest spawn locations.");

            var bronze = WorldState.Instance.GetBronzeChestLocations();
            var silver = WorldState.Instance.GetSilverChestLocations();
            var gold = WorldState.Instance.GetGoldChestLocations();

            if (bronze.Count == 0 && silver.Count == 0 && gold.Count == 0)
            {
                ImGui.TextWrapped("No chest locations found.");
            }
            else
            {
                if (bronze.Count > 0)
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Bronze Chests:");
                    foreach (var (x, y, z) in bronze)
                    {
                        ImGui.TextUnformatted($"  (X={x}, Y={y}, Z={z})");
                    }
                    ImGui.Spacing();
                }

                if (silver.Count > 0)
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Silver Chests:");
                    foreach (var (x, y, z) in silver)
                    {
                        ImGui.TextUnformatted($"  (X={x}, Y={y}, Z={z})");
                    }
                    ImGui.Spacing();
                }

                if (gold.Count > 0)
                {
                    ImGui.TextColored(SUBSECTION_COLOR, "Gold Chests:");
                    foreach (var (x, y, z) in gold)
                    {
                        ImGui.TextUnformatted($"  (X={x}, Y={y}, Z={z})");
                    }
                    ImGui.Spacing();
                }
            }

            EndScrollableContent();
        }

        #endregion

        //----------------------------------------------------------------------------------------
        // Search Implementation
        //----------------------------------------------------------------------------------------

        /// <summary>
        /// Searches for macro commands that match the search text.
        /// Prints a category header only if at least one match is found.
        /// </summary>
        private bool SearchCommands(string searchText)
        {
            var matchingCommands = new List<(string Name, string[] Aliases, string Description, string[] Examples)>();

            var types = typeof(MacroCommand).Assembly
                .GetTypes()
                .Where(t => t.IsSubclassOf(typeof(MacroCommand)) && t != typeof(NativeCommand))
                .OrderBy(t => t.Name);

            foreach (var type in types)
            {
                var commandsProp = type.GetProperty("Commands", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var descProp = type.GetProperty("Description", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var examplesProp = type.GetProperty("Examples", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);

                string cmdName = type.Name.ToLower().Replace("command", "");
                string[] aliases = commandsProp != null ? (string[])commandsProp.GetValue(null)! : Array.Empty<string>();
                string desc = descProp != null ? (string)descProp.GetValue(null)! : string.Empty;
                string[] exs = examplesProp != null ? (string[])examplesProp.GetValue(null)! : Array.Empty<string>();

                bool nameMatch = cmdName.Contains(searchText);
                bool aliasMatch = aliases.Any(a => a.ToLower().Contains(searchText));
                bool descMatch = desc.ToLower().Contains(searchText);
                bool exMatch = exs.Any(e => e.ToLower().Contains(searchText));

                if (nameMatch || aliasMatch || descMatch || exMatch)
                {
                    matchingCommands.Add((cmdName, aliases, desc, exs));
                }
            }

            if (matchingCommands.Count > 0)
            {
                ImGui.TextColored(HIGHLIGHT_COLOR, "Commands:");
                ImGui.Separator();

                foreach (var (cmdName, aliases, desc, exs) in matchingCommands)
                {
                    ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.08f, 0.08f, 0.08f, 0.2f));
                    ImGui.BeginGroup();

                    ImGui.TextColored(SUBSECTION_COLOR, $"/{cmdName}");
                    if (aliases.Length > 0)
                    {
                        ImGui.SameLine();
                        ImGui.TextDisabled($"(aliases: {string.Join(", ", aliases)})");
                    }

                    if (!string.IsNullOrEmpty(desc))
                    {
                        ImGui.Spacing();
                        ImGui.TextWrapped(desc);
                    }

                    if (exs.Length > 0)
                    {
                        ImGui.Spacing();
                        ImGui.TextColored(SUBSECTION_COLOR, "Examples:");
                        foreach (var ex in exs)
                        {
                            ImGui.TextUnformatted("   • ");
                            ImGui.SameLine();
                            ImGuiUtils.ClickToCopyText(ex);
                        }
                    }

                    // Instead of directly setting currentTab, we set forcedTab.
                    if (ImGui.Button($"Go to Commands Tab##{cmdName}"))
                    {
                        isSearching = false;
                        forcedTab = 1;
                    }

                    ImGui.EndGroup();
                    ImGui.PopStyleColor();
                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();
                }
                return true;
            }

            return false;
        }

        private bool SearchModifiers(string searchText)
        {
            bool anyFound = false;
            var modTypes = typeof(MacroModifier).Assembly
                .GetTypes()
                .Where(t => t.IsSubclassOf(typeof(MacroModifier)))
                .OrderBy(t => t.Name);

            // First, check if we have ANY matches before showing the header
            bool hasAnyMatches = false;
            foreach (var type in modTypes)
            {
                var modProp = type.GetProperty("Modifier", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var descProp = type.GetProperty("Description", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var exProp = type.GetProperty("Examples", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);

                string modName = modProp != null ? (string)modProp.GetValue(null)! : string.Empty;
                string desc = descProp != null ? (string)descProp.GetValue(null)! : string.Empty;
                string[] exs = exProp != null ? (string[])exProp.GetValue(null)! : Array.Empty<string>();

                bool nameMatch = modName.ToLower().Contains(searchText);
                bool descMatch = desc.ToLower().Contains(searchText);
                bool exMatch = exs.Any(e => e.ToLower().Contains(searchText));

                if (nameMatch || descMatch || exMatch)
                {
                    hasAnyMatches = true;
                    break;
                }
            }

            // Only show header if we have matches
            if (hasAnyMatches)
            {
                ImGui.TextColored(HIGHLIGHT_COLOR, "Modifiers:");
                ImGui.Separator();
            }

            // Now display all matching results
            foreach (var type in modTypes)
            {
                var modProp = type.GetProperty("Modifier", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var descProp = type.GetProperty("Description", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);
                var exProp = type.GetProperty("Examples", BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy);

                string modName = modProp != null ? (string)modProp.GetValue(null)! : string.Empty;
                string desc = descProp != null ? (string)descProp.GetValue(null)! : string.Empty;
                string[] exs = exProp != null ? (string[])exProp.GetValue(null)! : Array.Empty<string>();

                bool nameMatch = modName.ToLower().Contains(searchText);
                bool descMatch = desc.ToLower().Contains(searchText);
                bool exMatch = exs.Any(e => e.ToLower().Contains(searchText));

                if (nameMatch || descMatch || exMatch)
                {
                    anyFound = true;

                    ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.08f, 0.08f, 0.08f, 0.2f));
                    ImGui.BeginGroup();

                    ImGui.TextColored(SUBSECTION_COLOR, modName);
                    if (!string.IsNullOrEmpty(desc))
                    {
                        ImGui.Spacing();
                        ImGui.TextWrapped(desc);
                    }

                    if (exs.Length > 0)
                    {
                        ImGui.Spacing();
                        ImGui.TextColored(SUBSECTION_COLOR, "Examples:");
                        foreach (var ex in exs)
                        {
                            ImGui.TextUnformatted("   • ");
                            ImGui.SameLine();
                            ImGuiUtils.ClickToCopyText(ex);
                        }
                    }

                    if (ImGui.Button($"Go to Modifiers Tab##{modName}"))
                    {
                        isSearching = false;
                        forcedTab = 2;
                    }

                    ImGui.EndGroup();
                    ImGui.PopStyleColor();
                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();
                }
            }

            return anyFound;
        }

        private bool SearchCliCommands(string searchText)
        {
            bool anyResultsFound = false;
            bool headerShown = false;

            // Check if we have any matches first
            bool hasAnyMatches = cliData.Any(item =>
                item.Name.ToLower().Contains(searchText) ||
                item.Description.ToLower().Contains(searchText) ||
                (item.Example != null && item.Example.ToLower().Contains(searchText))
            );

            if (!hasAnyMatches)
                return false;

            foreach (var (name, desc, example) in cliData)
            {
                bool nameMatch = name.ToLower().Contains(searchText);
                bool descMatch = desc.ToLower().Contains(searchText);
                bool exMatch = (example != null) && example.ToLower().Contains(searchText);

                if (nameMatch || descMatch || exMatch)
                {
                    if (!headerShown)
                    {
                        ImGui.TextColored(HIGHLIGHT_COLOR, "CLI Commands:");
                        ImGui.Separator();
                        headerShown = true;
                    }

                    anyResultsFound = true;

                    ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.08f, 0.08f, 0.08f, 0.2f));
                    ImGui.BeginGroup();

                    ImGui.TextColored(SUBSECTION_COLOR, $"{P.Aliases[0]} {name}");
                    ImGui.Spacing();
                    ImGui.TextWrapped(desc);

                    if (example != null)
                    {
                        ImGui.Spacing();
                        ImGui.TextColored(SUBSECTION_COLOR, "Example:");
                        ImGuiUtils.ClickToCopyText(example);
                    }

                    if (ImGui.Button($"Go to CLI Tab##{name}"))
                    {
                        isSearching = false;
                        forcedTab = 4; // CLI tab index
                    }

                    ImGui.EndGroup();
                    ImGui.PopStyleColor();
                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();
                }
            }

            return anyResultsFound;
        }

        private bool SearchClicks(string searchText)
        {
            // Only show the header if we actually find results
            bool headerShown = false;
            bool anyFound = false;

            var matchingClicks = clickNames
                .Where(clickName => clickName.ToLower().Contains(searchText))
                .ToList();

            if (matchingClicks.Count > 0)
            {
                ImGui.TextColored(HIGHLIGHT_COLOR, "UI Click Commands:");
                ImGui.Separator();
                headerShown = true;

                foreach (var clickName in matchingClicks)
                {
                    anyFound = true;

                    ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.08f, 0.08f, 0.08f, 0.2f));
                    ImGui.BeginGroup();

                    bool isProp = clickName.Contains('.');
                    ImGui.TextColored(SUBSECTION_COLOR, $"/click {clickName}");
                    if (isProp)
                    {
                        ImGui.TextColored(ImGuiColors.DPSRed, "Note: This is property-based, cannot be called directly.");
                    }

                    if (ImGui.Button($"Copy##{clickName}", new Vector2(60, 0)))
                    {
                        ImGui.SetClipboardText($"/click {clickName}");
                    }

                    ImGui.SameLine();
                    if (ImGui.Button("Go to Clicks Tab"))
                    {
                        isSearching = false;
                        forcedTab = 5;
                    }

                    ImGui.EndGroup();
                    ImGui.PopStyleColor();
                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();
                }
            }

            return anyFound;
        }

        private bool SearchVirtualKeys(string searchText)
        {
            bool anyResultsFound = false;
            bool headerShown = false;

            var validKeys = Svc.KeyState.GetValidVirtualKeys().ToHashSet();
            var names = Enum.GetNames<VirtualKey>();
            var values = Enum.GetValues<VirtualKey>();

            // Check if any keys match before showing header
            bool hasAnyMatches = false;
            for (int i = 0; i < names.Length; i++)
            {
                var name = names[i];
                var vk = values[i];
                if (!validKeys.Contains(vk))
                    continue;

                if (name.ToLower().Contains(searchText))
                {
                    hasAnyMatches = true;
                    break;
                }
            }

            if (!hasAnyMatches)
                return false;

            // Now display matched results
            for (int i = 0; i < names.Length; i++)
            {
                var name = names[i];
                var vk = values[i];
                if (!validKeys.Contains(vk))
                    continue;

                if (name.ToLower().Contains(searchText))
                {
                    if (!headerShown)
                    {
                        ImGui.TextColored(HIGHLIGHT_COLOR, "Virtual Keys:");
                        ImGui.Separator();
                        headerShown = true;
                    }

                    anyResultsFound = true;

                    bool isActive = Svc.KeyState[vk];
                    ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.08f, 0.08f, 0.08f, 0.2f));
                    ImGui.BeginGroup();

                    if (isActive)
                        ImGui.TextColored(ImGuiColors.HealerGreen, $"/send {name} (ACTIVE)");
                    else
                        ImGui.TextUnformatted($"/send {name}");

                    if (ImGui.Button($"Copy##VKey{name}", new Vector2(60, 0)))
                    {
                        ImGui.SetClipboardText($"/send {name}");
                    }

                    ImGui.SameLine();
                    if (ImGui.Button("Go to Sends Tab"))
                    {
                        isSearching = false;
                        forcedTab = 6;
                    }

                    ImGui.EndGroup();
                    ImGui.PopStyleColor();
                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();
                }
            }

            return anyResultsFound;
        }

        private bool SearchConditions(string searchText)
        {
            bool anyResultsFound = false;
            bool headerShown = false;

            // Check if any conditions match first
            bool hasAnyMatches = false;
            foreach (ConditionFlag flag in Enum.GetValues(typeof(ConditionFlag)))
            {
                string flagName = flag.ToString();
                bool nameMatch = flagName.ToLower().Contains(searchText);
                bool idMatch = ((int)flag).ToString().Contains(searchText);

                if (nameMatch || idMatch)
                {
                    hasAnyMatches = true;
                    break;
                }
            }

            if (!hasAnyMatches)
                return false;

            // Now display the matching conditions
            foreach (ConditionFlag flag in Enum.GetValues(typeof(ConditionFlag)))
            {
                string flagName = flag.ToString();
                bool isActive = Svc.Condition[flag];

                bool nameMatch = flagName.ToLower().Contains(searchText);
                bool idMatch = ((int)flag).ToString().Contains(searchText);

                if (nameMatch || idMatch)
                {
                    if (!headerShown)
                    {
                        ImGui.TextColored(HIGHLIGHT_COLOR, "Game Conditions:");
                        ImGui.Separator();
                        headerShown = true;
                    }

                    anyResultsFound = true;

                    ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.08f, 0.08f, 0.08f, 0.2f));
                    ImGui.BeginGroup();

                    if (isActive)
                        ImGui.TextColored(ImGuiColors.HealerGreen, $"ID: {(int)flag}, Enum: {flagName} (ACTIVE)");
                    else
                        ImGui.TextUnformatted($"ID: {(int)flag}, Enum: {flagName}");

                    ImGui.TextWrapped($"Use in macros with: /if condition {flagName}");

                    if (ImGui.Button($"Go to Conditions Tab##{flagName}"))
                    {
                        isSearching = false;
                        forcedTab = 7;
                    }

                    ImGui.EndGroup();
                    ImGui.PopStyleColor();
                    ImGui.Spacing();
                    ImGui.Separator();
                    ImGui.Spacing();
                }
            }

            return anyResultsFound;
        }

        //----------------------------------------------------------------------------------------
        // Utility: Begin/End scrollable child and section titles
        //----------------------------------------------------------------------------------------

        private void BeginScrollableContent()
        {
            ImGui.PushStyleColor(ImGuiCol.ChildBg, new Vector4(0.05f, 0.05f, 0.05f, 0.0f));
            // Force vertical scrollbar to always be on
            ImGui.BeginChild("ScrollableRegion", new Vector2(0, 0), false,
                ImGuiWindowFlags.AlwaysVerticalScrollbar);
        }

        private void EndScrollableContent()
        {
            ImGui.EndChild();
            ImGui.PopStyleColor();
        }

        private void SectionTitle(string title)
        {
            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();
            ImGui.TextColored(SECTION_HEADER_COLOR, title);
            ImGui.Spacing();
            ImGui.Separator();
            ImGui.Spacing();
        }
    }
}
