using Dalamud.Interface;
using Dalamud.Interface.Colors;
using Dalamud.Interface.Components;
using Dalamud.Interface.Utility;
using Dalamud.Interface.Utility.Raii;
using Dalamud.Interface.Windowing;
using FFXIVClientStructs.FFXIV.Client.UI.Agent;
using ImGuiNET;
using SomethingNeedDoing.Interface;
using SomethingNeedDoing.Misc;
using System;
using System.Numerics;
using System.Threading.Tasks;

namespace SomethingNeedDoing.Windows
{
    /// <summary>
    /// Automated tutorial window that guides the user through creating, renaming,
    /// editing, and running a macro – including highlighting UI elements and simulating
    /// user actions (like right-clicking to rename and opening dropdowns).
    /// </summary>
    public class AutomatedTutorial : Window
    {
        // Extended tutorial steps to include a language change step.
        private enum TutorialStep
        {
            Introduction,
            CreateFolder,
            RenameFolder,
            CreateMacro,
            RenameMacro,
            EditMacro,
            ChangeLanguage, // step to change the language to Lua
            RunMacro,
            Complete
        }

        // Tutorial state variables.
        private TutorialStep currentStep = TutorialStep.Introduction;
        private float animationTimer = 0f;
        private bool actionInProgress = false;
        private float stepDelay = 1.0f; // Seconds to wait between steps
        private float delayTimer = 0f;
        private bool waitingForDelay = false;
        private string statusMessage = string.Empty;

        // Demo objects created during the tutorial.
        private FolderNode? demoFolder = null;
        private MacroNode? demoMacro = null;

        // Auto-advance settings for the tutorial.
        private bool autoAdvance = true;
        private float autoAdvanceTimer = 0f;
        private float autoAdvanceDelay = 3.0f;

        /// <summary>
        /// Constructor. Sets up the tutorial window with a larger size and no auto-resize flag.
        /// </summary>
        public AutomatedTutorial()
            : base("Tutorial###AutomatedTutorial")
        {
            // Provide a fixed initial size so the top area isn't cut off.
            Size = new Vector2(500, 250);
            SizeCondition = ImGuiCond.FirstUseEver;

            // Removed ImGuiWindowFlags.AlwaysAutoResize; only using NoCollapse here.
            Flags = ImGuiWindowFlags.NoCollapse;
        }

        public override void OnOpen()
        {
            base.OnOpen();
            ResetTutorial();
        }

        public override void OnClose()
        {
            base.OnClose();
            // Clear highlighting when tutorial closes
            TutorialHighlighter.ClearHighlights();
            TutorialHighlighter.IsHighlightingActive = false;
            currentStep = TutorialStep.Introduction;
        }

        /// <summary>
        /// Resets the tutorial state.
        /// </summary>
        private void ResetTutorial()
        {
            currentStep = TutorialStep.Introduction;
            animationTimer = 0f;
            actionInProgress = false;
            delayTimer = 0f;
            waitingForDelay = false;
            statusMessage = string.Empty;
            demoFolder = null;
            demoMacro = null;

            // Use new highlighting system
            TutorialHighlighter.ClearHighlights();
            TutorialHighlighter.IsHighlightingActive = false;
        }

        public override void Update()
        {
            base.Update();

            float deltaTime = ImGui.GetIO().DeltaTime;
            animationTimer += deltaTime;

            // Handle automatic delay between steps.
            if (waitingForDelay)
            {
                delayTimer += deltaTime;
                if (delayTimer >= stepDelay)
                {
                    waitingForDelay = false;
                    delayTimer = 0f;
                    PerformNextAction();
                }
            }

            // Handle auto-advance timer if enabled.
            if (autoAdvance && !actionInProgress && !waitingForDelay)
            {
                autoAdvanceTimer += deltaTime;
                if (autoAdvanceTimer >= autoAdvanceDelay)
                {
                    autoAdvanceTimer = 0f;
                    currentStep++;
                    ExecuteCurrentStep();
                }
            }
        }

        public override void Draw()
        {
            ImGui.TextColored(ImGuiColors.DalamudViolet, "Automated Macro Tutorial");
            ImGui.Separator();

            // Display current step information. (Total steps: 8, excluding introduction.)
            ImGui.TextColored(ImGuiColors.ParsedBlue, $"Step {(int)currentStep} / 8: {currentStep}");
            ImGui.ProgressBar((int)currentStep / 8.0f, new Vector2(-1, 20));

            // Display status message.
            if (!string.IsNullOrEmpty(statusMessage))
            {
                ImGui.TextWrapped(statusMessage);
            }

            ImGui.Spacing();

            // Display step-specific instructions.
            switch (currentStep)
            {
                case TutorialStep.Introduction:
                    DrawIntroductionStep();
                    break;
                case TutorialStep.CreateFolder:
                    DrawCreateFolderStep();
                    break;
                case TutorialStep.RenameFolder:
                    DrawRenameFolderStep();
                    break;
                case TutorialStep.CreateMacro:
                    DrawCreateMacroStep();
                    break;
                case TutorialStep.RenameMacro:
                    DrawRenameMacroStep();
                    break;
                case TutorialStep.EditMacro:
                    DrawEditMacroStep();
                    break;
                case TutorialStep.ChangeLanguage:
                    DrawChangeLanguageStep();
                    break;
                case TutorialStep.RunMacro:
                    DrawRunMacroStep();
                    break;
                case TutorialStep.Complete:
                    DrawCompleteStep();
                    break;
            }

            ImGui.Separator();

            // Draw control buttons.
            DrawControls();
        }

        /// <summary>
        /// Step 0: Introduction instructions.
        /// </summary>
        private void DrawIntroductionStep()
        {
            ImGui.TextWrapped("Welcome to the automated tutorial! This guide will walk you through creating and using macros by performing each action for you.");
            ImGui.Spacing();
            ImGui.TextWrapped("Each step will be highlighted in the main interface and automatically performed.");
            ImGui.Spacing();
            ImGui.TextWrapped("Click 'Start Tutorial' to begin!");
        }

        /// <summary>
        /// Step 1: Create a new folder.
        /// </summary>
        private void DrawCreateFolderStep()
        {
            ImGui.TextWrapped("Creating a new folder to organize your macros...");
            ImGui.Spacing();

            if (demoFolder != null)
            {
                ImGui.TextColored(ImGuiColors.HealerGreen, $"✓ Created folder: {demoFolder.Name}");
            }
        }

        /// <summary>
        /// Step 2: Rename the folder (simulate right-click rename).
        /// </summary>
        private void DrawRenameFolderStep()
        {
            ImGui.TextWrapped("Renaming the folder to give it a meaningful name. In normal use, you would right-click the folder, type in the desired name and press enter...");
            ImGui.Spacing();

            if (demoFolder != null)
            {
                ImGui.TextColored(ImGuiColors.HealerGreen, $"✓ Renamed folder to: {demoFolder.Name}");
            }
        }

        /// <summary>
        /// Step 3: Create a macro inside the folder.
        /// </summary>
        private void DrawCreateMacroStep()
        {
            ImGui.TextWrapped("Creating a new macro inside the folder...");
            ImGui.Spacing();

            if (demoMacro != null)
            {
                ImGui.TextColored(ImGuiColors.HealerGreen, $"✓ Created macro: {demoMacro.Name}");
            }
        }

        /// <summary>
        /// Step 4: Rename the macro (simulate right-click rename).
        /// </summary>
        private void DrawRenameMacroStep()
        {
            ImGui.TextWrapped("Renaming the macro to something descriptive. In normal use, you would right-click the macro, type in the desired name and press enter...");
            ImGui.Spacing();

            if (demoMacro != null)
            {
                ImGui.TextColored(ImGuiColors.HealerGreen, $"✓ Renamed macro to: {demoMacro.Name}");
            }
        }

        /// <summary>
        /// Step 5: Edit the macro contents.
        /// </summary>
        private void DrawEditMacroStep()
        {
            ImGui.TextWrapped("Adding content to the macro...");
            ImGui.Spacing();

            if (demoMacro != null && !string.IsNullOrEmpty(demoMacro.Contents))
            {
                ImGui.TextColored(ImGuiColors.HealerGreen, "✓ Added commands to the macro:");
                using (var child = ImRaii.Child("MacroContents", new Vector2(-1, 60), true))
                {
                    using var font = ImRaii.PushFont(UiBuilder.MonoFont);
                    ImGui.TextUnformatted(demoMacro.Contents);
                }
            }
        }

        /// <summary>
        /// Step 6: Change the macro language to Lua (simulate clicking on the dropdown).
        /// </summary>
        private void DrawChangeLanguageStep()
        {
            ImGui.TextWrapped("Changing the macro language to Lua. Click on the language dropdown to select Lua.");
            ImGui.Spacing();

            if (demoMacro != null)
            {
                ImGui.TextColored(ImGuiColors.HealerGreen, $"✓ Changed language to: {demoMacro.Language}");
            }
        }

        /// <summary>
        /// Step 7: Run the macro.
        /// </summary>
        private void DrawRunMacroStep()
        {
            ImGui.TextWrapped("Running the macro to see it in action...");
            ImGui.Spacing();

            ImGui.TextColored(ImGuiColors.HealerGreen, "✓ Macro is now running!");
            ImGui.TextWrapped("Watch the Macro Queue panel to see its progress.");
        }

        /// <summary>
        /// Step 8: Completion.
        /// </summary>
        private void DrawCompleteStep()
        {
            ImGui.TextColored(ImGuiColors.HealerGreen, "Tutorial Complete!");
            ImGui.Spacing();
            ImGui.TextWrapped("You've now seen how to:");
            ImGui.BulletText("Create and rename folders");
            ImGui.BulletText("Create and rename macros");
            ImGui.BulletText("Edit macro contents");
            ImGui.BulletText("Change macro language to Lua");
            ImGui.BulletText("Run macros");
            ImGui.Spacing();
            ImGui.TextWrapped("Feel free to explore and create your own macros!");
        }

        /// <summary>
        /// Draws control buttons for navigating the tutorial.
        /// </summary>
        private void DrawControls()
        {
            // Auto-advance toggle.
            bool autoAdvanceValue = autoAdvance;
            if (ImGui.Checkbox("Auto-advance steps", ref autoAdvanceValue))
            {
                autoAdvance = autoAdvanceValue;
                autoAdvanceTimer = 0f;
            }

            ImGui.SameLine();

            if (currentStep == TutorialStep.Introduction)
            {
                // Start button on the introduction step.
                if (ImGui.Button("Start Tutorial", new Vector2(120, 0)))
                {
                    currentStep = TutorialStep.CreateFolder;
                    ExecuteCurrentStep();
                }
            }
            else if (currentStep < TutorialStep.Complete)
            {
                // Manual navigation buttons.
                if (ImGui.Button("Previous", new Vector2(80, 0)) && currentStep > TutorialStep.Introduction)
                {
                    currentStep--;
                    ExecuteCurrentStep();
                }

                ImGui.SameLine();

                if (ImGui.Button("Next", new Vector2(80, 0)) && currentStep < TutorialStep.Complete)
                {
                    currentStep++;
                    ExecuteCurrentStep();
                }

                ImGui.SameLine();

                if (ImGui.Button("Skip to End", new Vector2(100, 0)))
                {
                    // Create all prerequisites at once if not already done.
                    if (demoFolder == null)
                    {
                        demoFolder = new FolderNode { Name = "Tutorial Folder" };
                        C.RootFolder.Children.Add(demoFolder);

                        demoMacro = new MacroNode
                        {
                            Name = "Tutorial Macro",
                            Contents = "yield(\"/echo This is a tutorial macro\")\n" +
           "yield(\"/wait 1\")\n" +
           "yield(\"/echo Created by the automated tutorial\")\n" +
           "yield(\"/wait 1\")\n" +
           "yield(\"/echo Tutorial complete!\")",

                            Language = Language.Lua  // Make sure it's set to Lua when skipping
                        };
                        demoFolder.Children.Add(demoMacro);

                        C.Save();

                        // Run the macro.
                        demoMacro.Run();
                    }

                    currentStep = TutorialStep.Complete;
                    ExecuteCurrentStep();
                }
            }
            else
            {
                // Close and restart options for the completed tutorial.
                if (ImGui.Button("Close Tutorial", new Vector2(120, 0)))
                {
                    IsOpen = false;
                }

                ImGui.SameLine();

                if (ImGui.Button("Start Over", new Vector2(100, 0)))
                {
                    ResetTutorial();
                }
            }
        }

        /// <summary>
        /// Method to highlight a UI element using the new TutorialHighlighter.
        /// </summary>
        private void HighlightElement(string elementKey, string tooltip)
        {
            // Use the new highlighting system instead of the old position-based one
            TutorialHighlighter.IsHighlightingActive = true;
            TutorialHighlighter.SetActiveHighlight(elementKey, tooltip);
        }

        /// <summary>
        /// Executes the action for the current tutorial step.
        /// </summary>
        private void ExecuteCurrentStep()
        {
            actionInProgress = true;
            autoAdvanceTimer = 0f;

            // Reset any active highlights.
            TutorialHighlighter.ClearHighlights();

            switch (currentStep)
            {
                case TutorialStep.Introduction:
                    statusMessage = "Welcome to the tutorial! Click 'Start Tutorial' to begin.";
                    actionInProgress = false;
                    break;

                case TutorialStep.CreateFolder:
                    statusMessage = "Creating a new folder...";
                    HighlightAddFolderButton();
                    ScheduleAction(() => CreateDemoFolder());
                    break;

                case TutorialStep.RenameFolder:
                    statusMessage = "Renaming the folder...";
                    if (demoFolder != null)
                    {
                        HighlightFolder(demoFolder);
                        // Make sure the folder is visible
                        NodeDrawing.FolderToAutoOpen = demoFolder.Name;
                        ScheduleAction(() => RenameFolder());
                    }
                    else
                    {
                        CreateDemoFolder();
                        ScheduleAction(() => {
                            currentStep = TutorialStep.RenameFolder;
                            ExecuteCurrentStep();
                        });
                    }
                    break;

                case TutorialStep.CreateMacro:
                    statusMessage = "Creating a new macro...";
                    if (demoFolder != null)
                    {
                        HighlightFolder(demoFolder);
                        // Make sure the folder is visible
                        NodeDrawing.FolderToAutoOpen = demoFolder.Name;
                        // Set the folder as selected
                        NodeDrawing.SelectedNode = demoFolder;

                        ScheduleAction(() => CreateDemoMacro());
                    }
                    else
                    {
                        CreateDemoFolder();
                        RenameFolder();
                        ScheduleAction(() => CreateDemoMacro());
                    }
                    break;

                case TutorialStep.RenameMacro:
                    statusMessage = "Renaming the macro...";
                    if (demoMacro != null)
                    {
                        HighlightMacro(demoMacro);
                        // Make sure the parent folder is visible
                        NodeDrawing.FolderToAutoOpen = demoFolder?.Name ?? "";

                        ScheduleAction(() => RenameMacro());
                    }
                    else
                    {
                        if (demoFolder == null)
                        {
                            CreateDemoFolder();
                            RenameFolder();
                        }
                        CreateDemoMacro();
                        ScheduleAction(() => {
                            currentStep = TutorialStep.RenameMacro;
                            ExecuteCurrentStep();
                        });
                    }
                    break;

                case TutorialStep.EditMacro:
                    statusMessage = "Adding content to the macro...";
                    if (demoMacro != null)
                    {
                        // Auto-select the macro in the tree view so it appears in the editor
                        NodeDrawing.SelectedNode = demoMacro;

                        // Highlight the macro editor
                        HighlightMacroEditor();

                        ScheduleAction(() => EditMacro());
                    }
                    else
                    {
                        if (demoFolder == null)
                        {
                            CreateDemoFolder();
                            RenameFolder();
                        }
                        CreateDemoMacro();
                        RenameMacro();
                        ScheduleAction(() => EditMacro());
                    }
                    break;

                case TutorialStep.ChangeLanguage:
                    statusMessage = "Changing macro language to Lua...";
                    if (demoMacro != null)
                    {
                        // Make sure the macro is selected and visible in the editor
                        NodeDrawing.SelectedNode = demoMacro;

                        HighlightLanguageDropdown();

                        ScheduleAction(() => ChangeLanguage());
                    }
                    else
                    {
                        if (demoFolder == null)
                        {
                            CreateDemoFolder();
                            RenameFolder();
                        }
                        CreateDemoMacro();
                        RenameMacro();
                        EditMacro();
                        ScheduleAction(() => ChangeLanguage());
                    }
                    break;

                case TutorialStep.RunMacro:
                    statusMessage = "Running the macro...";
                    if (demoMacro != null)
                    {
                        // Make sure the macro is selected
                        NodeDrawing.SelectedNode = demoMacro;

                        HighlightRunButton();

                        ScheduleAction(() => RunMacro());
                    }
                    else
                    {
                        if (demoFolder == null)
                        {
                            CreateDemoFolder();
                            RenameFolder();
                        }
                        CreateDemoMacro();
                        RenameMacro();
                        EditMacro();
                        ChangeLanguage();
                        ScheduleAction(() => RunMacro());
                    }
                    break;

                case TutorialStep.Complete:
                    TutorialHighlighter.ClearHighlights();
                    TutorialHighlighter.IsHighlightingActive = false;
                    actionInProgress = false;
                    break;
            }
        }

        /// <summary>
        /// Schedules an action to be executed after a specified delay.
        /// </summary>
        /// <param name="action">The action to perform.</param>
        /// <param name="delay">The delay in seconds.</param>
        private void ScheduleAction(Action action, float delay = 1.0f)
        {
            waitingForDelay = true;
            delayTimer = 0f;
            stepDelay = delay;

            // Run the action on the framework thread after the delay.
            Task.Run(async () =>
            {
                await Task.Delay((int)(delay * 1000));
                Svc.Framework.RunOnFrameworkThread(() => action());
            });
        }

        /// <summary>
        /// Performs the next action in the current step once the delay has elapsed.
        /// </summary>
        private void PerformNextAction()
        {
            switch (currentStep)
            {
                case TutorialStep.CreateFolder:
                    CreateDemoFolder();
                    break;
                case TutorialStep.RenameFolder:
                    RenameFolder();
                    break;
                case TutorialStep.CreateMacro:
                    CreateDemoMacro();
                    break;
                case TutorialStep.RenameMacro:
                    RenameMacro();
                    break;
                case TutorialStep.EditMacro:
                    EditMacro();
                    break;
                case TutorialStep.ChangeLanguage:
                    ChangeLanguage();
                    break;
                case TutorialStep.RunMacro:
                    RunMacro();
                    break;
            }

            actionInProgress = false;
        }

        #region Actions

        /// <summary>
        /// Creates a demo folder if one does not already exist.
        /// </summary>
        private void CreateDemoFolder()
        {
            if (demoFolder == null)
            {
                demoFolder = new FolderNode { Name = "New Folder" };
                C.RootFolder.Children.Add(demoFolder);
                C.Save();
                statusMessage = "✓ Created a new folder";

                // After creating, schedule renaming
                ScheduleAction(() => {
                    currentStep = TutorialStep.RenameFolder;
                    ExecuteCurrentStep();
                }, 1.0f);
            }
            else
            {
                actionInProgress = false;
            }
        }

        /// <summary>
        /// Simulates a right-click rename of the folder.
        /// </summary>
        private void RenameFolder()
        {
            if (demoFolder != null)
            {
                // Make sure the folder is visible and highlighted
                NodeDrawing.FolderToAutoOpen = demoFolder.Name;
                HighlightFolder(demoFolder);

                // Force open the context menu
                NodeDrawing.ForceOpenContextMenu = demoFolder.Name;

                // Set the rename value
                NodeDrawing.ForceRenameValue = "Tutorial Folder";

                // We need to explicitly rename since we can't simulate Enter key properly
                ScheduleAction(() => {
                    // Directly set the name after a delay to ensure the context menu had a chance to open
                    demoFolder.Name = "Tutorial Folder";
                    C.Save();

                    statusMessage = "✓ Renamed folder to 'Tutorial Folder'";
                    NodeDrawing.FolderToAutoOpen = "Tutorial Folder";
                    actionInProgress = false;
                }, 1.5f);
            }
            else
            {
                actionInProgress = false;
            }
        }

        /// <summary>
        /// Creates a demo macro within the folder.
        /// </summary>
        private void CreateDemoMacro()
        {
            if (demoFolder != null && demoMacro == null)
            {
                demoMacro = new MacroNode { Name = "New Macro" };
                demoFolder.Children.Add(demoMacro);
                C.Save();
                statusMessage = "✓ Created a new macro in the folder";

                // After creating, schedule renaming
                ScheduleAction(() => {
                    currentStep = TutorialStep.RenameMacro;
                    ExecuteCurrentStep();
                }, 1.0f);
            }
            else
            {
                actionInProgress = false;
            }
        }

        /// <summary>
        /// Simulates a right-click rename of the macro.
        /// </summary>
        private void RenameMacro()
        {
            if (demoMacro != null)
            {
                // Make sure the macro is visible and highlighted
                NodeDrawing.FolderToAutoOpen = demoFolder?.Name ?? "";
                HighlightMacro(demoMacro);

                // Force open the context menu
                NodeDrawing.ForceOpenContextMenu = demoMacro.Name;

                // Set the rename value
                NodeDrawing.ForceRenameValue = "Tutorial Macro";

                // We need to explicitly rename since we can't simulate Enter key properly
                ScheduleAction(() => {
                    // Directly set the name after a delay to ensure the context menu had a chance to open
                    demoMacro.Name = "Tutorial Macro";
                    C.Save();

                    statusMessage = "✓ Renamed macro to 'Tutorial Macro'";
                    NodeDrawing.SelectedNode = demoMacro;
                    actionInProgress = false;
                }, 1.5f);
            }
            else
            {
                actionInProgress = false;
            }
        }

        /// <summary>
        /// Edits the macro contents.
        /// </summary>
        private void EditMacro()
        {
            if (demoMacro != null)
            {
                // Ensure the macro is selected first
                NodeDrawing.SelectedNode = demoMacro;

                demoMacro.Contents = "yield(\"/echo This is a tutorial macro\")\n" +
                                     "yield(\"/wait 1\")\n" +
                                     "yield(\"/echo Created by the automated tutorial\")\n" +
                                     "yield(\"/wait 1\")\n" +
                                     "yield(\"/echo Tutorial complete!\")";
                // Initially set language to Native; will change in the ChangeLanguage step.
                demoMacro.Language = Language.Native;
                C.Save();
                statusMessage = "✓ Added commands to the macro";
            }
            actionInProgress = false;
        }

        /// <summary>
        /// Changes the macro language to Lua.
        /// </summary>
        private void ChangeLanguage()
        {
            if (demoMacro != null)
            {
                // Ensure the macro is selected
                NodeDrawing.SelectedNode = demoMacro;

                // This is critical - explicitly set the language to Lua
                demoMacro.Language = Language.Lua;
                C.Save();
                statusMessage = "✓ Changed macro language to Lua";
            }
            actionInProgress = false;
        }

        /// <summary>
        /// Runs the macro.
        /// </summary>
        private void RunMacro()
        {
            if (demoMacro != null)
            {
                demoMacro.Run();
                statusMessage = "✓ Macro is now running!";
            }
            actionInProgress = false;
        }

        #endregion

        #region Highlighting

        /// <summary>
        /// Highlights the Add Folder button.
        /// </summary>
        private void HighlightAddFolderButton()
        {
            // Use our new highlighting system instead
            HighlightElement("AddFolder", "Add Folder");
        }

        /// <summary>
        /// Highlights the folder in the UI.
        /// </summary>
        /// <param name="folder">The folder node to highlight.</param>
        private void HighlightFolder(FolderNode folder)
        {
            // Use new highlighting system based on element ID
            HighlightElement("Folder_" + folder.Name, "Right-click to rename");
        }

        /// <summary>
        /// Highlights the macro in the UI.
        /// </summary>
        /// <param name="macro">The macro node to highlight.</param>
        private void HighlightMacro(MacroNode macro)
        {
            // Use new highlighting system based on element ID
            HighlightElement("Macro_" + macro.Name, macro.Name);
        }

        /// <summary>
        /// Highlights the macro editor area.
        /// </summary>
        private void HighlightMacroEditor()
        {
            // Use new highlighting system based on element ID
            HighlightElement("MacroEditor", "Macro Editor");
        }

        /// <summary>
        /// Highlights the language dropdown in the macro editor UI.
        /// </summary>
        private void HighlightLanguageDropdown()
        {
            // Use new highlighting system based on element ID
            HighlightElement("LanguageDropdown", "Select Lua from dropdown");
        }

        /// <summary>
        /// Highlights the Run button.
        /// </summary>
        private void HighlightRunButton()
        {
            // Use new highlighting system based on element ID
            HighlightElement("PlayButton", "Run Macro");
        }

        #endregion
    }
}
