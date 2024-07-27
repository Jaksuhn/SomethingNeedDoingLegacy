using ECommons;
using ECommons.Automation;
using ECommons.Automation.UIInput;
using FFXIVClientStructs.FFXIV.Client.Game.UI;
using FFXIVClientStructs.FFXIV.Client.UI;
using FFXIVClientStructs.FFXIV.Client.UI.Agent;
using FFXIVClientStructs.FFXIV.Component.GUI;
using SomethingNeedDoing.Exceptions;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;

namespace SomethingNeedDoing.Misc.Commands;

public class AddonCommands
{
    internal static AddonCommands Instance { get; } = new();

    public List<string> ListAllFunctions()
    {
        var methods = GetType().GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.FlattenHierarchy);
        var list = new List<string>();
        foreach (var method in methods.Where(x => x.Name != nameof(ListAllFunctions) && x.DeclaringType != typeof(object)))
        {
            var parameterList = method.GetParameters().Select(p => $"{p.ParameterType.Name} {p.Name}{(p.IsOptional ? " = " + (p.DefaultValue ?? "null") : "")}");
            list.Add($"{method.ReturnType.Name} {method.Name}({string.Join(", ", parameterList)})");
        }
        return list;
    }

    public unsafe void OpenRouletteDuty(byte contentRouletteID) => AgentContentsFinder.Instance()->OpenRouletteDuty(contentRouletteID);
    public unsafe void OpenRegularDuty(uint cfcID) => AgentContentsFinder.Instance()->OpenRegularDuty(cfcID);
    public unsafe void SelectDuty(uint dutyCode)
    {
        if (!GenericHelpers.TryGetAddonByName<AtkUnitBase>("ContentsFinder", out var addon) || !GenericHelpers.IsAddonReady(addon))
            return;

        var componentList = addon->GetNodeById(52)->GetAsAtkComponentList();
        if (componentList == null) return;

        var numDutiesLoaded = *(uint*)((nint)componentList + 508 + 4);
        var agent = AgentContentsFinder.Instance();

        if (agent == null) return;

        var baseAddress = *(nint*)((nint)agent + 6960);
        if (baseAddress == 0) return;

        for (var i = 0; i < numDutiesLoaded; i++)
        {
            var dutyId = GetDutyId(baseAddress, i);
            if (dutyCode == dutyId)
            {
                Callback.Fire(addon, true, 3, i + 1);
                return;
            }
        }
        return;
    }

    private unsafe int GetDutyId(nint baseAddress, int index)
    {
        return *(int*)(baseAddress + 212 + index * 240);
    }

    public void SetDFLanguageJ(bool state) => Svc.GameConfig.UiConfig.Set("ContentsFinderUseLangTypeJA", state);
    public void SetDFLanguageE(bool state) => Svc.GameConfig.UiConfig.Set("ContentsFinderUseLangTypeEN", state);
    public void SetDFLanguageD(bool state) => Svc.GameConfig.UiConfig.Set("ContentsFinderUseLangTypeDE", state);
    public void SetDFLanguageF(bool state) => Svc.GameConfig.UiConfig.Set("ContentsFinderUseLangTypeFR", state);
    public void SetDFJoinInProgress(bool state) => Svc.GameConfig.UiConfig.Set("ContentsFinderSupplyEnable", state);
    public unsafe void SetDFUnrestricted(bool state) => ContentsFinder.Instance()->IsUnrestrictedParty = state;
    public unsafe void SetDFLevelSync(bool state) => ContentsFinder.Instance()->IsLevelSync = state;
    public unsafe void SetDFMinILvl(bool state) => ContentsFinder.Instance()->IsMinimalIL = state;
    public unsafe void SetDFSilenceEcho(bool state) => ContentsFinder.Instance()->IsSilenceEcho = state;
    public unsafe void SetDFExplorerMode(bool state) => ContentsFinder.Instance()->IsExplorerMode = state;
    public unsafe void SetDFLimitedLeveling(bool state) => ContentsFinder.Instance()->IsLimitedLevelingRoulette = state;

    public unsafe int GetDiademAetherGaugeBarCount() => GenericHelpers.TryGetAddonByName<AtkUnitBase>("HWDAetherGauge", out var addon) ? addon->AtkValues[1].Int / 200 : 0;

    public unsafe int GetDDPassageProgress()
    {
        if (GenericHelpers.TryGetAddonByName<AtkUnitBase>("DeepDungeonMap", out var addon))
        {
            var key = addon->GetNodeById(7)->ChildNode->PrevSiblingNode;
            var image = key->GetAsAtkComponentNode()->Component->UldManager.NodeList[1]->GetAsAtkImageNode();
            return image->PartId * 10;
        }

        return 0;
    }

    public unsafe bool IsAddonVisible(string addonName) => GenericHelpers.TryGetAddonByName<AtkUnitBase>(addonName, out var addon) && addon->IsVisible;
    public unsafe bool IsAddonReady(string addonName) => GenericHelpers.TryGetAddonByName<AtkUnitBase>(addonName, out var addon) && GenericHelpers.IsAddonReady(addon);

    public unsafe bool IsNodeVisible(string addonName, params int[] ids)
    {
        var ptr = Svc.GameGui.GetAddonByName(addonName, 1);
        if (ptr == nint.Zero)
            return false;

        var addon = (AtkUnitBase*)ptr;
        var node = GetNodeByIDChain(addon->GetRootNode(), ids);
        return node != null && node->IsVisible();
    }

    public void GetClicks()
    {
        foreach (var s in ClickHelper.GetAvailableClicks())
            Svc.Log.Info(s);
    }

    private unsafe AtkResNode* GetNodeByIDChain(AtkResNode* node, params int[] ids)
    {
        if (node == null || ids.Length <= 0)
            return null;

        if (node->NodeId == ids[0])
        {
            if (ids.Length == 1)
                return node;

            var newList = new List<int>(ids);
            newList.RemoveAt(0);

            var childNode = node->ChildNode;
            if (childNode != null)
                return GetNodeByIDChain(childNode, [.. newList]);

            if ((int)node->Type >= 1000)
            {
                var componentNode = node->GetAsAtkComponentNode();
                var component = componentNode->Component;
                var uldManager = component->UldManager;
                childNode = uldManager.NodeList[0];
                return childNode == null ? null : GetNodeByIDChain(childNode, [.. newList]);
            }

            return null;
        }

        //check siblings
        var sibNode = node->PrevSiblingNode;
        return sibNode != null ? GetNodeByIDChain(sibNode, ids) : null;
    }

    public unsafe string GetToastNodeText(int index, params int[] nodeNumbers)
    {
        var ptr = (AtkUnitBase*)Svc.GameGui.GetAddonByName("_WideText", index);
        if (ptr == null) return string.Empty;
        if (ptr->UldManager.NodeList == null || ptr->UldManager.NodeListCount < 4) return string.Empty;

        var uld = ptr->UldManager;
        AtkResNode* node = null;
        var debugString = string.Empty;

        for (var i = 0; i < nodeNumbers.Length; i++)
        {
            var nodeNumber = nodeNumbers[i];

            var count = uld.NodeListCount;
            if (nodeNumber < 0 || nodeNumber >= count)
                throw new MacroCommandError($"Addon node number must be between 0 and {count} for the _WideText addon");

            node = uld.NodeList[nodeNumber];
            debugString += $"[{nodeNumber}]";

            if (node == null)
                throw new MacroCommandError($"_WideText addon node{debugString} is null");

            // More nodes to traverse
            if (i < nodeNumbers.Length - 1)
            {
                if ((int)node->Type < 1000)
                    throw new MacroCommandError($"_WideText addon node{debugString} is not a component");

                uld = ((AtkComponentNode*)node)->Component->UldManager;
            }
        }

        var textNode = (AtkTextNode*)node;
        return textNode->NodeText.ToString();
    }

    public unsafe string GetNodeText(string addonName, params int[] nodeNumbers)
    {
        if (nodeNumbers.Length == 0)
            throw new MacroCommandError("At least one node number is required");

        var ptr = Svc.GameGui.GetAddonByName(addonName, 1);
        if (ptr == nint.Zero)
            throw new MacroCommandError($"Could not find {addonName} addon");

        var addon = (AtkUnitBase*)ptr;
        var uld = addon->UldManager;

        AtkResNode* node = null;
        var debugString = string.Empty;
        for (var i = 0; i < nodeNumbers.Length; i++)
        {
            var nodeNumber = nodeNumbers[i];

            var count = uld.NodeListCount;
            if (nodeNumber < 0 || nodeNumber >= count)
                throw new MacroCommandError($"Addon node number must be between 0 and {count} for the {addonName} addon");

            node = uld.NodeList[nodeNumber];
            debugString += $"[{nodeNumber}]";

            if (node == null)
                throw new MacroCommandError($"{addonName} addon node {debugString} is null");

            // More nodes to traverse
            if (i < nodeNumbers.Length - 1)
            {
                if ((int)node->Type < 1000)
                    throw new MacroCommandError($"{addonName} addon node {debugString} is not a component");

                uld = ((AtkComponentNode*)node)->Component->UldManager;
            }
        }

        if (node->Type is not NodeType.Text or NodeType.Counter)
            throw new MacroCommandError($"{addonName} addon node {debugString} is not a text node");

        if (node->Type == NodeType.Counter)
            return ((AtkCounterNode*)node)->NodeText.ToString();

        var textNode = (AtkTextNode*)node;
        return textNode->NodeText.ExtractText();
    }

    public unsafe void SetNodeText(string addonName, string text, params int[] ids)
    {
        var ptr = Svc.GameGui.GetAddonByName(addonName, 1);
        if (ptr == nint.Zero)
            return;

        var addon = (AtkUnitBase*)ptr;
        var node = GetNodeByIDChain(addon->GetRootNode(), ids);
        if (node != null && node->Type == NodeType.Text)
            node->GetAsAtkTextNode()->NodeText = new FFXIVClientStructs.FFXIV.Client.System.String.Utf8String(text);
    }

    public unsafe string GetSelectStringText(int index)
    {
        var ptr = Svc.GameGui.GetAddonByName("SelectString", 1);
        if (ptr == nint.Zero)
            throw new MacroCommandError("Could not find SelectString addon");

        var addon = (AddonSelectString*)ptr;
        var popup = &addon->PopupMenu.PopupMenu;

        var count = popup->EntryCount;
        Svc.Log.Debug($"index={index} // Count={count} // {index < 0 || index > count}");
        if (index < 0 || index > count)
            throw new MacroCommandError("Index out of range");

        var textPtr = popup->EntryNames[index];
        return textPtr == null
            ? throw new MacroCommandError("Text pointer was null")
            : Marshal.PtrToStringUTF8((nint)textPtr) ?? string.Empty;
    }

    public unsafe string GetSelectIconStringText(int index)
    {
        var ptr = Svc.GameGui.GetAddonByName("SelectIconString", 1);
        if (ptr == nint.Zero)
            throw new MacroCommandError("Could not find SelectIconString addon");

        var addon = (AddonSelectIconString*)ptr;
        var popup = &addon->PopupMenu.PopupMenu;

        var count = popup->EntryCount;
        if (index < 0 || index > count)
            throw new MacroCommandError("Index out of range");

        var textPtr = popup->EntryNames[index];
        return textPtr == null
            ? throw new MacroCommandError("Text pointer was null")
            : Marshal.PtrToStringUTF8((nint)textPtr) ?? string.Empty;
    }

    public unsafe int GetNodeListCount(string addonName) => GenericHelpers.TryGetAddonByName<AtkUnitBase>(addonName, out var addon) ? addon->UldManager.NodeListCount : 0;

    public unsafe ushort GetNodeWidth(string addonName, params int[] nodeNumbers)
    {
        if (nodeNumbers.Length == 0)
            throw new MacroCommandError("At least one node number is required");

        var ptr = Svc.GameGui.GetAddonByName(addonName, 1);
        if (ptr == nint.Zero)
            throw new MacroCommandError($"Could not find {addonName} addon");

        var addon = (AtkUnitBase*)ptr;
        var uld = addon->UldManager;

        AtkResNode* node = null;
        var debugString = string.Empty;
        for (var i = 0; i < nodeNumbers.Length; i++)
        {
            var nodeNumber = nodeNumbers[i];

            var count = uld.NodeListCount;
            if (nodeNumber < 0 || nodeNumber >= count)
                throw new MacroCommandError($"Addon node number must be between 0 and {count} for the {addonName} addon");

            node = uld.NodeList[nodeNumber];
            debugString += $"[{nodeNumber}]";

            if (node == null)
                throw new MacroCommandError($"{addonName} addon node {debugString} is null");

            // More nodes to traverse
            if (i < nodeNumbers.Length - 1)
            {
                if ((int)node->Type < 1000)
                    throw new MacroCommandError($"{addonName} addon node {debugString} is not a component");

                uld = ((AtkComponentNode*)node)->Component->UldManager;
            }
        }

        return node->Width;
    }

    public unsafe ushort GetNodeHeight(string addonName, params int[] nodeNumbers)
    {
        if (nodeNumbers.Length == 0)
            throw new MacroCommandError("At least one node number is required");

        var ptr = Svc.GameGui.GetAddonByName(addonName, 1);
        if (ptr == nint.Zero)
            throw new MacroCommandError($"Could not find {addonName} addon");

        var addon = (AtkUnitBase*)ptr;
        var uld = addon->UldManager;

        AtkResNode* node = null;
        var debugString = string.Empty;
        for (var i = 0; i < nodeNumbers.Length; i++)
        {
            var nodeNumber = nodeNumbers[i];

            var count = uld.NodeListCount;
            if (nodeNumber < 0 || nodeNumber >= count)
                throw new MacroCommandError($"Addon node number must be between 0 and {count} for the {addonName} addon");

            node = uld.NodeList[nodeNumber];
            debugString += $"[{nodeNumber}]";

            if (node == null)
                throw new MacroCommandError($"{addonName} addon node {debugString} is null");

            // More nodes to traverse
            if (i < nodeNumbers.Length - 1)
            {
                if ((int)node->Type < 1000)
                    throw new MacroCommandError($"{addonName} addon node {debugString} is not a component");

                uld = ((AtkComponentNode*)node)->Component->UldManager;
            }
        }

        return node->Height;
    }
}
