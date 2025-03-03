using System;
using System.Collections.Generic;
using System.Numerics;
using Dalamud.Interface;
using Dalamud.Interface.Colors;
using ImGuiNET;

namespace SomethingNeedDoing.Windows
{
    /// <summary>
    /// Enhanced tutorial highlighting system that uses color flagging instead of overlay drawing.
    /// </summary>
    public static class TutorialHighlighter
    {
        // Dictionary to track elements that should be highlighted
        private static Dictionary<string, string> elementsToHighlight = new Dictionary<string, string>();

        // The currently active highlight key
        private static string activeHighlightKey = string.Empty;

        // Set this to true to enable highlighting system
        public static bool IsHighlightingActive { get; set; } = false;

        // Predefined colors for highlighted elements
        public static Vector4 HighlightBackgroundColor = new Vector4(0.9f, 0.7f, 0.0f, 0.5f); // Golden yellow
        public static Vector4 HighlightBorderColor = new Vector4(1.0f, 0.84f, 0.0f, 1.0f);    // Bright gold
        public static Vector4 HighlightTextColor = ImGuiColors.DalamudWhite;                   // White text

        /// <summary>
        /// Set the active element to highlight
        /// </summary>
        public static void SetActiveHighlight(string key, string tooltip = "")
        {
            activeHighlightKey = key;

            if (!string.IsNullOrEmpty(key) && !string.IsNullOrEmpty(tooltip))
            {
                elementsToHighlight[key] = tooltip;
            }
        }

        /// <summary>
        /// Clear all highlights
        /// </summary>
        public static void ClearHighlights()
        {
            activeHighlightKey = string.Empty;
            elementsToHighlight.Clear();
            IsHighlightingActive = false;
        }

        /// <summary>
        /// Check if a specific element should be highlighted
        /// </summary>
        public static bool ShouldHighlight(string key)
        {
            return IsHighlightingActive && activeHighlightKey == key;
        }

        /// <summary>
        /// Get the tooltip for a highlighted element
        /// </summary>
        public static string GetTooltip(string key)
        {
            if (elementsToHighlight.TryGetValue(key, out string tooltip))
                return tooltip;

            return string.Empty;
        }

        /// <summary>
        /// Begin highlighting a button or other UI element
        /// Returns true if the element should be highlighted
        /// </summary>
        public static bool BeginHighlight(string key)
        {
            if (!ShouldHighlight(key))
                return false;

            // Push highlight colors for the UI element
            ImGui.PushStyleColor(ImGuiCol.Button, HighlightBackgroundColor);
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, HighlightBackgroundColor * 1.1f);
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, HighlightBackgroundColor * 0.9f);
            ImGui.PushStyleColor(ImGuiCol.Border, HighlightBorderColor);
            ImGui.PushStyleColor(ImGuiCol.Text, HighlightTextColor);

            // Add border to element
            ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 2.0f);

            // Make element slightly larger
            ImGui.PushStyleVar(ImGuiStyleVar.FramePadding, ImGui.GetStyle().FramePadding * 1.2f);

            return true;
        }

        /// <summary>
        /// End highlighting of a UI element
        /// </summary>
        public static void EndHighlight(string key)
        {
            if (!ShouldHighlight(key))
                return;

            // Pop all the style changes
            ImGui.PopStyleVar(2);
            ImGui.PopStyleColor(5);

            // Show tooltip when hovered
            if (ImGui.IsItemHovered() && elementsToHighlight.TryGetValue(key, out string tooltip))
            {
                ImGui.BeginTooltip();
                ImGui.TextUnformatted(tooltip);
                ImGui.EndTooltip();
            }

            // Auto-pulse effect (optional)
            if (ImGui.IsItemVisible())
            {
                // Draw a pulsing border around the item
                Vector2 min = ImGui.GetItemRectMin();
                Vector2 max = ImGui.GetItemRectMax();
                float pulseFactor = (float)Math.Sin(ImGui.GetTime() * 3) * 0.5f + 0.5f;
                float thickness = 3.0f * pulseFactor + 1.0f;

                ImGui.GetWindowDrawList().AddRect(
                    min,
                    max,
                    ImGui.ColorConvertFloat4ToU32(HighlightBorderColor with { W = 0.7f + 0.3f * pulseFactor }),
                    4.0f,
                    ImDrawFlags.None,
                    thickness
                );
            }
        }

        /// <summary>
        /// Add a helper arrow pointing to a highlighted element
        /// </summary>
        public static void DrawHelperArrow(string key)
        {
            if (!ShouldHighlight(key) || !ImGui.IsItemVisible())
                return;

            // Get the element position
            Vector2 center = ImGui.GetItemRectMin() + (ImGui.GetItemRectMax() - ImGui.GetItemRectMin()) / 2;

            // Calculate arrow position (to the left of the element)
            float offset = 30.0f + (float)Math.Sin(ImGui.GetTime() * 2) * 5.0f;
            Vector2 arrowTip = center - new Vector2(offset, 0);

            // Draw arrow
            float arrowSize = 15.0f;
            ImGui.GetWindowDrawList().AddTriangleFilled(
                arrowTip,
                arrowTip + new Vector2(-arrowSize, -arrowSize),
                arrowTip + new Vector2(-arrowSize, arrowSize),
                ImGui.ColorConvertFloat4ToU32(HighlightBorderColor)
            );
        }
    }
}
