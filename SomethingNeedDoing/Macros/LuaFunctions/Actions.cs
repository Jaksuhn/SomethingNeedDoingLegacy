using FFXIVClientStructs.FFXIV.Client.Game;
using FFXIVClientStructs.FFXIV.Client.Game.UI;
using FFXIVClientStructs.FFXIV.Client.UI;
using FFXIVClientStructs.FFXIV.Client.UI.Agent;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.InteropServices;

namespace SomethingNeedDoing.Macros.Lua;

internal class Actions
{
    internal static Actions Instance { get; } = new();

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

    private readonly AbandonDuty abandonDuty = Marshal.GetDelegateForFunctionPointer<AbandonDuty>(Svc.SigScanner.ScanText("E8 ?? ?? ?? ?? 48 8B 43 28 41 B2 01"));

    private delegate void AbandonDuty(bool a1);

    public void LeaveDuty() => abandonDuty(false);

    public unsafe void TeleportToGCTown(bool useTickets = false)
    {
        var gc = UIState.Instance()->PlayerState.GrandCompany;
        var aetheryte = gc switch
        {
            0 => 0u,
            1 => 8u,
            2 => 2u,
            3 => 9u,
            _ => 0u
        };
        if (useTickets)
        {
            var ticket = gc switch
            {
                0 => 0u,
                1 => 21069u,
                2 => 21070u,
                3 => 21071u,
                _ => 0u
            };
            if (InventoryManager.Instance()->GetInventoryItemCount(ticket) > 0)
                AgentInventoryContext.Instance()->UseItem(ticket);
        }
        else
            Telepo.Instance()->Teleport(aetheryte, 0);
    }

    private unsafe uint GetSpellActionId(uint actionId) => ActionManager.Instance()->GetAdjustedActionId(actionId);

    public unsafe float GetRecastTimeElapsed(uint actionId) => ActionManager.Instance()->GetRecastTimeElapsed(ActionType.Action, GetSpellActionId(actionId));
    public unsafe float GetRealRecastTimeElapsed(uint actionId) => ActionManager.Instance()->GetRecastTimeElapsed(ActionType.Action, actionId);

    public unsafe float GetRecastTime(uint actionId) => ActionManager.Instance()->GetRecastTime(ActionType.Action, GetSpellActionId(actionId));
    public unsafe float GetRealRecastTime(uint actionId) => ActionManager.Instance()->GetRecastTime(ActionType.Action, actionId);

    public float GetSpellCooldown(uint actionId) => Math.Abs(GetRecastTime(GetSpellActionId(actionId)) - GetRecastTimeElapsed(GetSpellActionId(actionId)));
    public float GetRealSpellCooldown(uint actionId) => Math.Abs(GetRealRecastTime(actionId) - GetRealRecastTimeElapsed(actionId));

    public int GetSpellCooldownInt(uint actionId)
    {
        var cooldown = (int)Math.Ceiling(GetSpellCooldown(actionId) % GetRecastTime(actionId));
        return Math.Max(0, cooldown);
    }

    public int GetActionStackCount(int maxStacks, uint actionId)
    {
        var cooldown = GetSpellCooldownInt(actionId);
        var recastTime = GetRecastTime(actionId);

        return cooldown <= 0 || recastTime == 0 ? maxStacks : maxStacks - (int)Math.Ceiling(cooldown / (recastTime / maxStacks));
    }

    public unsafe bool IsMainCommandUnlocked(uint command) => UIModule.Instance()->IsMainCommandUnlocked(command);
    public unsafe void ExecuteMainCommand(uint RowId) => UIModule.Instance()->ExecuteMainCommand(RowId);

    public unsafe void ExecuteAction(uint actionID) => ActionManager.Instance()->UseAction(ActionType.Action, actionID);
    public unsafe void ExecuteGeneralAction(uint actionID) => ActionManager.Instance()->UseAction(ActionType.GeneralAction, actionID);
    public unsafe void ExecuteChocoboRaceAbility(uint actionID) => ActionManager.Instance()->UseAction(ActionType.ChocoboRaceAbility, actionID);
    public unsafe void ExecuteChocoboRaceItem(uint actionID) => ActionManager.Instance()->UseAction(ActionType.ChocoboRaceItem, actionID);
}
