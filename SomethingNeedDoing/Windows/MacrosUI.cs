using Dalamud.Interface;
using Dalamud.Interface.Utility;
using Dalamud.Interface.Utility.Raii;
using Dalamud.Interface.Windowing;
using ECommons.SimpleGui;
using ImGuiNET;
using SomethingNeedDoing.Interface;
using SomethingNeedDoing.Misc;
using System;
using System.Numerics;

namespace SomethingNeedDoing.Windows
{
    public class MacrosUI : Window
    {
        private static NodeDrawing NodesUI = null!;

        // Static field for AutomatedTutorial instance.
        private static AutomatedTutorial? _automatedTutorial = null;

        public MacrosUI() : base($"Something Need Doing {P.GetType().Assembly.GetName().Version}###SomethingNeedDoing")
        {
            Size = new Vector2(525, 600);
            SizeCondition = ImGuiCond.FirstUseEver;
            RespectCloseHotkey = false;
            NodesUI = new NodeDrawing();
        }

        public override void Draw()
        {
            using var table = ImRaii.Table("Native", 2, ImGuiTableFlags.SizingStretchProp);
            if (!table) return;
            ImGui.TableNextColumn();
            NodesUI.DisplayNodeTree();
            ImGui.TableNextColumn();
            DrawStateHeader();
            DrawRunningMacro();
            NodesUI.DrawSelected();
        }

        private static void DrawStateHeader()
        {
            ImGui.TextUnformatted("Macro Queue");
            var state = Service.MacroManager.State;
            var stateName = state switch
            {
                LoopState.NotLoggedIn => "Not Logged In",
                LoopState.Running when Service.MacroManager.PauseAtLoop => "Pausing Soon",
                LoopState.Running when Service.MacroManager.StopAtLoop => "Stopping Soon",
                _ => Enum.GetName(state),
            };
            var buttonCol = ImGuiX.GetStyleColorVec4(ImGuiCol.Button);
            using (var _ = ImRaii.PushColor(ImGuiCol.ButtonActive, buttonCol).Push(ImGuiCol.ButtonHovered, buttonCol))
                ImGui.Button($"{stateName}##LoopState", new Vector2(100, 0));

            ImGui.SameLine();
            if (ImGuiX.IconButton(FontAwesomeIcon.QuestionCircle, "Help"))
                EzConfigGui.GetWindow<HelpUI>()!.Toggle();

            ImGui.SameLine();
            if (ImGuiX.IconButton(FontAwesomeIcon.FileExcel, "Excel Browser"))
                EzConfigGui.GetWindow<ExcelWindow>()!.Toggle();

            ImGui.SameLine();
            if (ImGuiX.IconButton(FontAwesomeIcon.BookOpen, "Tutorial"))
                OpenTutorialWindow();

            if (Service.MacroManager.State == LoopState.Paused)
            {
                ImGui.SameLine();
                if (ImGuiX.IconButton(FontAwesomeIcon.Play, "Resume"))
                    Service.MacroManager.Resume();

                ImGui.SameLine();
                if (ImGuiX.IconButton(FontAwesomeIcon.StepForward, "Step"))
                    Service.MacroManager.NextStep();

                ImGui.SameLine();
                if (ImGuiX.IconButton(FontAwesomeIcon.TrashAlt, "Clear"))
                    Service.MacroManager.Stop();
            }
            else if (Service.MacroManager.State == LoopState.Running)
            {
                ImGui.SameLine();
                if (ImGuiX.IconButton(FontAwesomeIcon.Pause, "Pause (hold control to pause at next /loop)"))
                    Service.MacroManager.Pause(ImGui.GetIO().KeyCtrl);

                ImGui.SameLine();
                if (ImGuiX.IconButton(FontAwesomeIcon.Stop, "Stop (hold control to stop at next /loop)"))
                    Service.MacroManager.Stop(ImGui.GetIO().KeyCtrl);
            }
            // Instead of calling TutorialHighlightRenderer, we don't need to do anything
            // since highlighting is now applied directly to the UI elements
        }

        public static void DrawRunningMacro()
        {
            ImGui.PushItemWidth(-1);
            var style = ImGui.GetStyle();
            var runningHeight = ImGui.CalcTextSize("CalcTextSize").Y * ImGuiHelpers.GlobalScale * 3 + style.FramePadding.Y * 2 + style.ItemSpacing.Y * 2;
            using (var runningMacros = ImRaii.ListBox("##running-macros", new Vector2(-1, runningHeight)))
            {
                if (runningMacros)
                {
                    var macroStatus = Service.MacroManager.MacroStatus;
                    for (var i = 0; i < macroStatus.Length; i++)
                    {
                        var (name, stepIndex) = macroStatus[i];
                        var text = name;
                        if (i == 0 || stepIndex > 1)
                            text += $" (step {stepIndex})";
                        ImGui.Selectable($"{text}##{Guid.NewGuid()}", i == 0);
                    }
                }
            }
            var contentHeight = ImGui.CalcTextSize("CalcTextSize").Y * ImGuiHelpers.GlobalScale * 5 + style.FramePadding.Y * 2 + style.ItemSpacing.Y * 4;
            var macroContent = Service.MacroManager.CurrentMacroContent();
            using (var currentMacro = ImRaii.ListBox("##current-macro", new Vector2(-1, contentHeight)))
            {
                if (currentMacro)
                {
                    var stepIndex = Service.MacroManager.CurrentMacroStep();
                    if (stepIndex == -1)
                        ImGui.Selectable("Looping", true);
                    else
                    {
                        for (var i = stepIndex; i < macroContent.Length; i++)
                        {
                            var step = macroContent[i];
                            var isCurrentStep = i == stepIndex;
                            ImGui.Selectable(step, isCurrentStep);
                        }
                    }
                }
            }
            ImGui.PopItemWidth();
        }

        /// <summary>
        /// Opens the tutorial window.
        /// </summary>
        private static void OpenTutorialWindow()
        {
            if (_automatedTutorial == null || !_automatedTutorial.IsOpen)
            {
                _automatedTutorial = new AutomatedTutorial();
                Svc.PluginInterface.UiBuilder.Draw += DrawTutorialWindow;
            }
            _automatedTutorial.IsOpen = true;
        }

        /// <summary>
        /// Draws the tutorial window.
        /// </summary>
        private static void DrawTutorialWindow()
        {
            if (_automatedTutorial != null && _automatedTutorial.IsOpen)
            {
                _automatedTutorial.Draw();
                if (!_automatedTutorial.IsOpen)
                {
                    Svc.PluginInterface.UiBuilder.Draw -= DrawTutorialWindow;
                    _automatedTutorial = null;
                }
            }
        }
    }
}
