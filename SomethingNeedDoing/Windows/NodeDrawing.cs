using Dalamud.Interface;
using Dalamud.Interface.Colors;
using Dalamud.Interface.Utility;
using Dalamud.Interface.Utility.Raii;
using ECommons.ImGuiMethods;
using ImGuiNET;
using SomethingNeedDoing.Interface;
using SomethingNeedDoing.Misc;
using System;
using System.Numerics;
using System.Text;
using System.Text.RegularExpressions;
using System.Linq;

namespace SomethingNeedDoing.Windows
{
    internal class NodeDrawing
    {
        // Regex for generating unique names.
        private readonly Regex incrementalName = new(@"(?<all> \((?<index>\d+)\))$", RegexOptions.Compiled);
        private INode? draggedNode = null;

        /// <summary>
        /// The currently selected node in the UI.
        /// This is a public static property so other parts of the plugin can set or read it.
        /// </summary>
        public static INode? SelectedNode { get; set; }

        /// <summary>
        /// If set, the folder with this name will be auto-opened/expanded.
        /// </summary>
        public static string FolderToAutoOpen = string.Empty;

        /// <summary>
        /// A flag to force open a specific context menu
        /// </summary>
        public static string ForceOpenContextMenu { get; set; } = string.Empty;

        /// <summary>
        /// A flag to force input field to have specific value
        /// </summary>
        public static string ForceRenameValue { get; set; } = string.Empty;

        /// <summary>
        /// Draws the entire node tree starting from the root folder.
        /// </summary>
        public void DisplayNodeTree()
        {
            DrawHeader();
            DisplayNode(C.RootFolder);
        }

        /// <summary>
        /// Draws the selected node details (macro editor).
        /// </summary>
        public void DrawSelected()
        {
            using var child = ImRaii.Child("##Panel", -Vector2.One, true);
            if (!child || SelectedNode is not MacroNode selectedMacro) return;

            ImGui.TextUnformatted("Macro Editor");

            using (var disabled = ImRaii.Disabled(Service.MacroManager.State == LoopState.Running))
            {
                // Apply highlight to Run button if it's active
                bool isPlayButtonHighlighted = TutorialHighlighter.BeginHighlight("PlayButton");

                if (ImGuiEx.IconButton(FontAwesomeIcon.Play, "Run"))
                    selectedMacro.Run();

                if (isPlayButtonHighlighted)
                {
                    TutorialHighlighter.EndHighlight("PlayButton");
                    TutorialHighlighter.DrawHelperArrow("PlayButton");
                }
            }

            ImGui.SameLine();
            ImGui.SetNextItemWidth(150);

            // Apply highlight to Language dropdown if it's active
            bool isLanguageDropdownHighlighted = TutorialHighlighter.BeginHighlight("LanguageDropdown");

            var lang = selectedMacro.Language;
            if (ImGuiEx.EnumCombo("Language", ref lang, l => l != Language.CSharp))
            {
                selectedMacro.Language = lang;
                C.Save();
            }

            if (isLanguageDropdownHighlighted)
            {
                TutorialHighlighter.EndHighlight("LanguageDropdown");
                TutorialHighlighter.DrawHelperArrow("LanguageDropdown");
            }

            ImGui.SameLine();

            // Apply highlight to Import button if needed
            bool isImportContentsHighlighted = TutorialHighlighter.BeginHighlight("ImportMacroContents");

            if (ImGuiX.IconButton(FontAwesomeIcon.FileImport, "Import from clipboard"))
            {
                var text = Utils.ConvertClipboardToSafeString();
                if (Utils.IsLuaCode(text))
                    selectedMacro.Language = Language.Lua;

                selectedMacro.Contents = text;
                C.Save();
            }

            if (isImportContentsHighlighted)
            {
                TutorialHighlighter.EndHighlight("ImportMacroContents");
            }

            ImGui.SetNextItemWidth(-1);

            // Apply highlight to macro editor if needed
            bool isMacroEditorHighlighted = TutorialHighlighter.BeginHighlight("MacroEditor");

            // If editor is highlighted, add a colored border
            if (isMacroEditorHighlighted)
            {
                ImGui.PushStyleColor(ImGuiCol.FrameBg, new Vector4(0.15f, 0.15f, 0.2f, 1.0f));
                ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 2.0f);
                ImGui.PushStyleColor(ImGuiCol.Border, TutorialHighlighter.HighlightBorderColor);
            }

            using var font = ImRaii.PushFont(UiBuilder.MonoFont, !C.DisableMonospaced);
            var contents = selectedMacro.Contents;
            if (ImGui.InputTextMultiline($"##{selectedMacro.Name}-editor", ref contents, 1_000_000, new Vector2(-1, -1)))
            {
                selectedMacro.Contents = contents;
                C.Save();
            }

            if (isMacroEditorHighlighted)
            {
                ImGui.PopStyleColor(2);
                ImGui.PopStyleVar();
                TutorialHighlighter.EndHighlight("MacroEditor");

                // For the editor, place the arrow in a different position
                Vector2 editorMin = ImGui.GetItemRectMin();
                Vector2 editorMax = ImGui.GetItemRectMax();
                Vector2 editorCenter = new Vector2(editorMin.X + (editorMax.X - editorMin.X) * 0.5f, editorMin.Y + 30);

                // Draw an arrow pointing to the top of the editor
                float pulseFactor = (float)Math.Sin(ImGui.GetTime() * 3) * 0.5f + 0.5f;
                ImGui.GetWindowDrawList().AddTriangleFilled(
                    editorCenter + new Vector2(0, -20),
                    editorCenter + new Vector2(-15, -40),
                    editorCenter + new Vector2(15, -40),
                    ImGui.ColorConvertFloat4ToU32(TutorialHighlighter.HighlightBorderColor with { W = 0.7f + 0.3f * pulseFactor })
                );
            }
        }

        /// <summary>
        /// Draws the header with buttons to add macro, add folder, and import macro.
        /// </summary>
        private void DrawHeader()
        {
            // Apply highlight to Add Macro button if it's the active highlight
            bool isAddMacroHighlighted = TutorialHighlighter.BeginHighlight("AddMacro");

            if (ImGuiX.IconButton(FontAwesomeIcon.Plus, "Add macro"))
            {
                var newNode = new MacroNode { Name = GetUniqueNodeName("Untitled macro") };
                C.RootFolder.Children.Add(newNode);
                C.Save();
            }

            if (isAddMacroHighlighted)
            {
                TutorialHighlighter.EndHighlight("AddMacro");
                TutorialHighlighter.DrawHelperArrow("AddMacro");
            }

            ImGui.SameLine();

            // Apply highlight to Add Folder button if it's the active highlight
            bool isAddFolderHighlighted = TutorialHighlighter.BeginHighlight("AddFolder");

            if (ImGuiX.IconButton(FontAwesomeIcon.FolderPlus, "Add folder"))
            {
                var newNode = new FolderNode { Name = GetUniqueNodeName("Untitled folder") };
                C.RootFolder.Children.Add(newNode);
                C.Save();
            }

            if (isAddFolderHighlighted)
            {
                TutorialHighlighter.EndHighlight("AddFolder");
                TutorialHighlighter.DrawHelperArrow("AddFolder");
            }

            ImGui.SameLine();

            // Apply highlight to Import Macro button if needed
            bool isImportMacroHighlighted = TutorialHighlighter.BeginHighlight("ImportMacro");

            if (ImGuiX.IconButton(FontAwesomeIcon.FileImport, "Import macro from clipboard"))
            {
                var text = Utils.ConvertClipboardToSafeString();
                var node = new MacroNode { Name = GetUniqueNodeName("Untitled macro") };
                C.RootFolder.Children.Add(node);
                node.Contents = text;
                C.Save();
            }

            if (isImportMacroHighlighted)
            {
                TutorialHighlighter.EndHighlight("ImportMacro");
            }
        }

        /// <summary>
        /// Recursively displays nodes.
        /// </summary>
        private void DisplayNode(INode node)
        {
            using var _ = ImRaii.PushId(node.Name);
            if (node is FolderNode folderNode)
                DisplayFolderNode(folderNode);
            else if (node is MacroNode macroNode)
                DisplayMacroNode(macroNode);
        }

        /// <summary>
        /// Displays a macro node.
        /// </summary>
        private void DisplayMacroNode(MacroNode node)
        {
            var flags = ImGuiTreeNodeFlags.Leaf;
            if (node == SelectedNode)
                flags |= ImGuiTreeNodeFlags.Selected;

            // Apply highlight to Macro node if it's the active one
            bool isMacroHighlighted = TutorialHighlighter.BeginHighlight("Macro_" + node.Name);

            // Add color styling to treenode if highlighted
            if (isMacroHighlighted)
            {
                ImGui.PushStyleColor(ImGuiCol.Text, TutorialHighlighter.HighlightTextColor);
                ImGui.PushStyleColor(ImGuiCol.Header, TutorialHighlighter.HighlightBackgroundColor);
                ImGui.PushStyleColor(ImGuiCol.HeaderHovered, TutorialHighlighter.HighlightBackgroundColor * 1.1f);
            }

            ImGui.TreeNodeEx($"{node.Name}##tree", flags);

            if (isMacroHighlighted)
            {
                ImGui.PopStyleColor(3);
                TutorialHighlighter.EndHighlight("Macro_" + node.Name);
                TutorialHighlighter.DrawHelperArrow("Macro_" + node.Name);
            }

            NodeContextMenu(node);
            NodeDragDrop(node);

            if (ImGui.IsItemClicked())
                SelectedNode = node;

            ImGui.TreePop();
        }

        /// <summary>
        /// Displays a folder node.
        /// </summary>
        private void DisplayFolderNode(FolderNode node)
        {
            if (node == C.RootFolder)
                ImGui.SetNextItemOpen(true, ImGuiCond.FirstUseEver);

            // Check if this folder should be auto-opened by the tutorial
            if (!string.IsNullOrEmpty(FolderToAutoOpen) && FolderToAutoOpen == node.Name)
            {
                ImGui.SetNextItemOpen(true, ImGuiCond.Always);
                FolderToAutoOpen = string.Empty;
            }

            // Apply highlight to Folder node if it's the active one
            bool isFolderHighlighted = TutorialHighlighter.BeginHighlight("Folder_" + node.Name);

            // Add color styling to treenode if highlighted
            if (isFolderHighlighted)
            {
                ImGui.PushStyleColor(ImGuiCol.Text, TutorialHighlighter.HighlightTextColor);
                ImGui.PushStyleColor(ImGuiCol.Header, TutorialHighlighter.HighlightBackgroundColor);
                ImGui.PushStyleColor(ImGuiCol.HeaderHovered, TutorialHighlighter.HighlightBackgroundColor * 1.1f);
            }

            var expanded = ImGui.TreeNodeEx($"{node.Name}##tree", ImGuiTreeNodeFlags.None);

            if (isFolderHighlighted)
            {
                ImGui.PopStyleColor(3);
                TutorialHighlighter.EndHighlight("Folder_" + node.Name);
                TutorialHighlighter.DrawHelperArrow("Folder_" + node.Name);
            }

            NodeContextMenu(node);
            NodeDragDrop(node);

            if (expanded)
            {
                foreach (var childNode in node.Children.ToArray())
                    DisplayNode(childNode);
                ImGui.TreePop();
            }
        }

        /// <summary>
        /// Shows a context menu for a node (folder or macro) on right-click.
        /// </summary>
        // Update the NodeContextMenu method in NodeDrawing.cs to position the popup over the item

        private void NodeContextMenu(INode node)
        {
            if (node == null) return;

            // Force open the context menu if requested
            bool shouldForceOpen = !string.IsNullOrEmpty(ForceOpenContextMenu) &&
                                  ForceOpenContextMenu == node.Name;

            if (shouldForceOpen)
            {
                // Get the position of the current item 
                Vector2 itemMin = ImGui.GetItemRectMin();
                Vector2 itemMax = ImGui.GetItemRectMax();
                Vector2 itemCenter = (itemMin + itemMax) * 0.5f;

                // Position the context menu at the center of the item
                // This makes it look like it was right-clicked
                ImGui.SetNextWindowPos(itemCenter);

                ImGui.OpenPopup($"{node.Name}ContextMenu");
                ForceOpenContextMenu = string.Empty; // Reset after opening
            }
            else
            {
                // Normal right-click behavior
                ImGui.OpenPopupOnItemClick($"{node.Name}ContextMenu", ImGuiPopupFlags.MouseButtonRight);
            }

            using var ctx = ImRaii.ContextPopupItem($"{node.Name}ContextMenu");
            if (ctx)
            {
                var name = node.Name;

                // If we have a forced rename value, use it
                if (!string.IsNullOrEmpty(ForceRenameValue))
                {
                    name = ForceRenameValue;
                    ImGui.SetKeyboardFocusHere(); // Focus the input field

                    // Simply set up the rename field and clear the value 
                    // The actual renaming will be done in the tutorial class
                    ForceRenameValue = string.Empty; // Clear after use
                }

                // Apply highlight to rename field if needed
                bool isRenameHighlighted = TutorialHighlighter.BeginHighlight("RenameInput");
                if (isRenameHighlighted)
                {
                    ImGui.PushStyleColor(ImGuiCol.FrameBg, new Vector4(0.15f, 0.15f, 0.2f, 1.0f));
                    ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 2.0f);
                    ImGui.PushStyleColor(ImGuiCol.Border, TutorialHighlighter.HighlightBorderColor);
                }

                bool enterPressed = ImGui.InputText("##rename", ref name, 100,
                    ImGuiInputTextFlags.AutoSelectAll | ImGuiInputTextFlags.EnterReturnsTrue);

                if (isRenameHighlighted)
                {
                    ImGui.PopStyleColor(2);
                    ImGui.PopStyleVar();
                    TutorialHighlighter.EndHighlight("RenameInput");
                }

                if (enterPressed)
                {
                    node.Name = GetUniqueNodeName(name);
                    C.Save();
                }

                // Rest of your context menu code (unchanged)...
                if (node is MacroNode macroNode)
                {
                    bool isPlayContextHighlighted = TutorialHighlighter.BeginHighlight("ContextPlay");

                    if (ImGuiX.IconButton(FontAwesomeIcon.Play, "Run"))
                        macroNode.Run();

                    if (isPlayContextHighlighted)
                    {
                        TutorialHighlighter.EndHighlight("ContextPlay");
                    }

                    ImGui.SameLine();
                }

                if (node is FolderNode folderNode)
                {
                    bool isContextAddMacroHighlighted = TutorialHighlighter.BeginHighlight("ContextAddMacro");

                    if (ImGuiX.IconButton(FontAwesomeIcon.Plus, "Add macro"))
                    {
                        var newNode = new MacroNode { Name = GetUniqueNodeName("Untitled macro") };
                        folderNode.Children.Add(newNode);
                        C.Save();
                    }

                    if (isContextAddMacroHighlighted)
                    {
                        TutorialHighlighter.EndHighlight("ContextAddMacro");
                    }

                    ImGui.SameLine();

                    bool isContextAddFolderHighlighted = TutorialHighlighter.BeginHighlight("ContextAddFolder");

                    if (ImGuiX.IconButton(FontAwesomeIcon.FolderPlus, "Add folder"))
                    {
                        var newNode = new FolderNode { Name = GetUniqueNodeName("Untitled folder") };
                        folderNode.Children.Add(newNode);
                        C.Save();
                    }

                    if (isContextAddFolderHighlighted)
                    {
                        TutorialHighlighter.EndHighlight("ContextAddFolder");
                    }

                    ImGui.SameLine();
                }

                if (node != C.RootFolder)
                {
                    ImGui.SameLine();

                    bool isContextCopyHighlighted = TutorialHighlighter.BeginHighlight("ContextCopy");

                    if (ImGuiX.IconButton(FontAwesomeIcon.Copy, "Copy Name"))
                        ImGui.SetClipboardText(node.Name);

                    if (isContextCopyHighlighted)
                    {
                        TutorialHighlighter.EndHighlight("ContextCopy");
                    }

                    ImGui.SameLine();

                    bool isContextDeleteHighlighted = TutorialHighlighter.BeginHighlight("ContextDelete");

                    if (ImGuiX.IconButton(FontAwesomeIcon.TrashAlt, "Delete"))
                    {
                        if (C.TryFindParent(node, out var parentNode))
                        {
                            parentNode!.Children.Remove(node);
                            C.Save();
                        }
                    }

                    if (isContextDeleteHighlighted)
                    {
                        TutorialHighlighter.EndHighlight("ContextDelete");
                    }

                    ImGui.SameLine();
                }
            }
        }

        /// <summary>
        /// Generates a unique node name.
        /// </summary>
        private string GetUniqueNodeName(string name)
        {
            var nodeNames = C.GetAllNodes().Select(node => node.Name).ToList();

            while (nodeNames.Contains(name))
            {
                var match = incrementalName.Match(name);
                if (match.Success)
                {
                    var all = match.Groups["all"].Value;
                    var index = int.Parse(match.Groups["index"].Value) + 1;
                    name = name[..^all.Length];
                    name = $"{name} ({index})";
                }
                else
                    name = $"{name} (1)";
            }

            return name.Trim();
        }

        /// <summary>
        /// Handles drag-and-drop of nodes.
        /// </summary>
        private void NodeDragDrop(INode node)
        {
            if (node != C.RootFolder)
            {
                if (ImGui.BeginDragDropSource())
                {
                    draggedNode = node;
                    ImGui.TextUnformatted(node.Name);
                    ImGui.SetDragDropPayload("NodePayload", IntPtr.Zero, 0);
                    ImGui.EndDragDropSource();
                }
            }

            if (ImGui.BeginDragDropTarget())
            {
                var payload = ImGui.AcceptDragDropPayload("NodePayload");

                bool nullPtr;
                unsafe { nullPtr = payload.NativePtr == null; }

                if (!nullPtr && payload.IsDelivery() && draggedNode != null)
                {
                    if (!C.TryFindParent(draggedNode, out var draggedNodeParent))
                        throw new Exception($"Could not find parent of node \"{draggedNode.Name}\"");

                    if (node is FolderNode targetFolderNode)
                    {
                        draggedNodeParent!.Children.Remove(draggedNode);
                        targetFolderNode.Children.Add(draggedNode);
                        C.Save();
                    }
                    else
                    {
                        if (!C.TryFindParent(node, out var targetNodeParent))
                            throw new Exception($"Could not find parent of node \"{node.Name}\"");

                        var targetNodeIndex = targetNodeParent!.Children.IndexOf(node);
                        var draggedNodeIndex = draggedNodeParent.Children.IndexOf(draggedNode);

                        if (draggedNodeParent == targetNodeParent && draggedNodeIndex < targetNodeIndex)
                            targetNodeIndex--;

                        draggedNodeParent.Children.Remove(draggedNode);
                        targetNodeParent.Children.Insert(targetNodeIndex, draggedNode);
                        C.Save();
                    }
                    draggedNode = null;
                }

                ImGui.EndDragDropTarget();
            }
        }
    }
}
