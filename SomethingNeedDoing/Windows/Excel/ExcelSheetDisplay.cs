using Dalamud.Interface.Utility;
using Dalamud.Interface.Utility.Raii;
using ImGuiNET;
using Lumina.Excel;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace SomethingNeedDoing.Interface.Excel;
public sealed class ExcelSheetDisplay
{
    public ExcelSheetDisplay() { }

    private IExcelSheet? _sheet;
    private ISheetWrapper? _wrapper;
    private SortedSet<int>? _curFilteredRows;
    private string _curSearchFilter = "";
    private CancellationTokenSource? _filterCts;
    private float? itemHeight;

    private readonly Dictionary<int, float> _columnWidths = [];
    private const float MIN_COLUMN_WIDTH = 40f;
    private const float PADDING = 20f;

    public void Draw(IExcelSheet sheet)
    {
        if (sheet == null) return;

        if (_sheet != sheet)
        {
            _sheet = sheet;
            _wrapper = sheet switch
            {
                ExcelSheet<RawRow> rawRows => new RawRowWrapper(rawRows),
                SubrowExcelSheet<RawSubrow> subRows => new SubrowWrapper(subRows),
                _ => throw new ArgumentException("Unsupported sheet type")
            };
            _columnWidths.Clear();
        }

        ImGui.SetNextItemWidth(ImGui.GetContentRegionAvail().X * ImGuiHelpers.GlobalScale - ImGui.GetStyle().ItemSpacing.X);
        var filterDirty = ImGui.InputTextWithHint($"###{nameof(ExcelSheetDisplay)}filter", "Search...", ref _curSearchFilter, 256);

        if (filterDirty)
        {
            _filterCts?.Cancel();
            _filterCts = new();
            Task.Run(() => ApplyFilterAsync(sheet, _filterCts));
        }

        var height = ImGui.GetContentRegionAvail().Y;
        if (_sheet.Columns.Count < 100) // what is the max count? I thought it was 64 but it's more than that
        {
            using var table = ImRaii.Table($"{nameof(ExcelSheetDisplay)}", _sheet.Columns.Count + 1,
                ImGuiTableFlags.Borders | ImGuiTableFlags.ScrollX | ImGuiTableFlags.ScrollY | ImGuiTableFlags.NoSavedSettings, new(0, height));
            if (!table) return;

            ImGui.TableSetupScrollFreeze(1, 1);
            ImGui.TableHeadersRow();
            ImGui.TableSetColumnIndex(0);
            ImGui.TableHeader("RowId");

            for (var i = 0; i < _sheet.Columns.Count; i++)
            {
                using var id = ImRaii.PushId(i);
                ImGui.TableSetColumnIndex(i + 1);
                ImGui.TableHeader($"{i}: {_sheet.Columns[i].Type}");
            }

            ImGui.TableSetColumnIndex(0);
            itemHeight = ImGui.GetTextLineHeightWithSpacing();
            if (_wrapper != null)
                ImGuiClip.ClippedDraw(_curFilteredRows?.ToList() ?? Enumerable.Range(0, _wrapper.Count).ToList(), DrawRow, itemHeight ?? 0);
        }
        else
        {
            // this is a very poor horizontal clipping implementation
            const int maxVisibleColumns = 64;
            using var table = ImRaii.Table($"{nameof(ExcelSheetDisplay)}", maxVisibleColumns,
                ImGuiTableFlags.Borders | ImGuiTableFlags.ScrollX | ImGuiTableFlags.ScrollY | ImGuiTableFlags.NoSavedSettings,
                new(0, height));
            if (!table) return;

            // Calculate visible range based on scroll position and current widths
            var scrollX = ImGui.GetScrollX();
            var currentX = 0f;
            var startColumn = 0;

            // Find starting column based on scroll position
            while (startColumn < _sheet.Columns.Count && currentX < scrollX)
            {
                if (_columnWidths.TryGetValue(startColumn, out var width))
                    currentX += width;
                else
                    currentX += MIN_COLUMN_WIDTH;
                startColumn++;
            }

            var endColumn = Math.Min(startColumn + maxVisibleColumns - 1, _sheet.Columns.Count);

            CalculateColumnWidths(startColumn, endColumn);

            ImGui.TableSetupColumn("RowId", ImGuiTableColumnFlags.NoResize, MIN_COLUMN_WIDTH);
            for (var i = 1; i < maxVisibleColumns; i++)
            {
                var colIndex = startColumn + i - 1;
                var flags = ImGuiTableColumnFlags.None;
                if (colIndex >= _sheet.Columns.Count)
                    flags |= ImGuiTableColumnFlags.Disabled;

                var width = colIndex < _sheet.Columns.Count
                    ? _columnWidths.GetValueOrDefault(colIndex, MIN_COLUMN_WIDTH)
                    : MIN_COLUMN_WIDTH;

                ImGui.TableSetupColumn($"Col{i}", flags, width);
            }

            ImGui.TableSetupScrollFreeze(1, 1);

            ImGui.TableNextRow(ImGuiTableRowFlags.Headers);

            ImGui.TableSetColumnIndex(0);
            ImGui.TextUnformatted("RowId");

            for (var i = 0; i < maxVisibleColumns - 1 && (startColumn + i) < _sheet.Columns.Count; i++)
            {
                if (!ImGui.TableSetColumnIndex(i + 1)) continue;
                var columnIndex = startColumn + i;
                ImGui.TextUnformatted($"{columnIndex}: {_sheet.Columns[columnIndex].Type}");
            }

            // Calculate total width for scroll area
            var totalWidth = _columnWidths.Sum(kv => kv.Value);
            if (ImGui.GetScrollMaxX() < totalWidth)
                ImGui.SetScrollX(Math.Min(scrollX, totalWidth - ImGui.GetWindowWidth()));

            ImGui.TableSetColumnIndex(0);
            itemHeight = ImGui.GetTextLineHeightWithSpacing();
            if (_wrapper != null)
                ImGuiClip.ClippedDraw(_curFilteredRows?.ToList() ?? Enumerable.Range(0, _wrapper.Count).ToList(),
                    row => DrawRow(row, startColumn, endColumn), itemHeight ?? 0);
        }
    }

    private void CalculateColumnWidths(int startColumn, int endColumn)
    {
        // Reset widths for visible range
        for (var i = startColumn; i < endColumn; i++)
        {
            if (!_columnWidths.ContainsKey(i))
            {
                // Start with header width
                var headerText = $"{i}: {_sheet!.Columns[i].Type}";
                _columnWidths[i] = Math.Max(MIN_COLUMN_WIDTH, ImGui.CalcTextSize(headerText).X + PADDING);
            }
        }

        var rowsToSample = _curFilteredRows?.ToList() ?? Enumerable.Range(0, _wrapper!.Count).ToList();
        var sampleSize = Math.Min(100, rowsToSample.Count); // Limit sample size for performance
        var sampleStep = Math.Max(1, rowsToSample.Count / sampleSize);

        for (var i = 0; i < rowsToSample.Count; i += sampleStep)
        {
            var rowId = rowsToSample[i];
            for (var col = startColumn; col < endColumn; col++)
            {
                foreach (var (_, _, cellValue) in _wrapper!.ReadCellRows(rowId, col))
                {
                    var width = ImGui.CalcTextSize(cellValue).X + PADDING;
                    _columnWidths[col] = Math.Max(_columnWidths[col], width);
                }
            }
        }
    }

    /// <summary>
    /// Draw a horizontally clipped row
    /// </summary>
    /// <param name="rowId"></param>
    /// <param name="startColumn"></param>
    /// <param name="endColumn"></param>
    private void DrawRow(int rowId, int startColumn, int endColumn)
    {
        var rows = _wrapper!.ReadCellRows(rowId, 0).ToList();
        var hasMultipleRows = rows.Count > 1;

        foreach (var (_, subRowId, _) in rows)
        {
            ImGui.TableNextRow();
            ImGui.TableNextColumn();
            ImGui.TextUnformatted(hasMultipleRows ? $"{rowId}.{subRowId}" : rowId.ToString());

            // Draw visible columns
            for (var i = 0; i < 63 && (startColumn + i) < endColumn; i++)
            {
                ImGui.TableNextColumn();
                ImGui.AlignTextToFramePadding();
                var columnIndex = startColumn + i;
                var (_, _, cellValue) = _wrapper.ReadCellRows(rowId, columnIndex).ElementAt(subRowId);
                ImGui.TextUnformatted(cellValue);
            }
        }
    }

    /// <summary>
    /// Draw an entire row
    /// </summary>
    /// <param name="rowId"></param>
    private void DrawRow(int rowId)
    {
        var rows = _wrapper!.ReadCellRows(rowId, 0).ToList();
        var hasMultipleRows = rows.Count > 1;

        foreach (var (_, subRowId, _) in rows)
        {
            ImGui.TableNextRow();
            ImGui.TableNextColumn();
            ImGui.TextUnformatted(hasMultipleRows ? $"{rowId}.{subRowId}" : rowId.ToString());

            for (var c = 0; c < _sheet!.Columns.Count; c++)
            {
                ImGui.TableNextColumn();
                ImGui.AlignTextToFramePadding();
                var (_, _, cellValue) = _wrapper.ReadCellRows(rowId, c).ElementAt(subRowId);
                ImGui.TextUnformatted(cellValue);
            }
        }
    }

    private async Task ApplyFilterAsync(IExcelSheet sheet, CancellationTokenSource filterCts)
    {
        if (string.IsNullOrWhiteSpace(_curSearchFilter) || filterCts.IsCancellationRequested)
        {
            _curFilteredRows = null;
            return;
        }

        _curFilteredRows = new(Comparer<int>.Default);
        if (_wrapper != null)
        {
            for (var i = 0; i < sheet.Columns.Count; i++)
            {
                foreach (var (rowId, _) in _wrapper.SearchColumn(i, _curSearchFilter))
                {
                    if (!filterCts.IsCancellationRequested)
                        _curFilteredRows.Add(rowId);
                }
            }
        }
    }

    private interface ISheetWrapper
    {
        int Count { get; }
        IEnumerable<(int RowId, int SubRowId, string Value)> ReadCellRows(int rowId, int column);
        IEnumerable<(int RowId, string Value)> SearchColumn(int column, string searchText);
    }

    private class RawRowWrapper(ExcelSheet<RawRow> sheet) : ISheetWrapper
    {
        private readonly ExcelSheet<RawRow> _sheet = sheet;

        public int Count => _sheet.Count;

        public IEnumerable<(int RowId, int SubRowId, string Value)> ReadCellRows(int rowId, int column)
        {
            yield return (rowId, 0, _sheet.GetRowAt(rowId).ReadColumn(column).ToString() ?? string.Empty);
        }

        public IEnumerable<(int RowId, string Value)> SearchColumn(int column, string searchText)
        {
            for (var r = 0; r < Count; r++)
            {
                var value = ReadCellRows(r, column).First().Value;
                if (value.Contains(searchText, StringComparison.OrdinalIgnoreCase))
                    yield return (r, value);
            }
        }
    }

    private class SubrowWrapper(SubrowExcelSheet<RawSubrow> sheet) : ISheetWrapper
    {
        private readonly SubrowExcelSheet<RawSubrow> _sheet = sheet;

        public int Count => _sheet.Count;

        public IEnumerable<(int RowId, int SubRowId, string Value)> ReadCellRows(int rowId, int column)
        {
            var subrows = _sheet.GetRowAt(rowId);
            for (var i = 0; i < subrows.Count; i++)
                yield return (rowId, i, subrows[i].ReadColumn(column).ToString() ?? string.Empty);
        }

        public IEnumerable<(int RowId, string Value)> SearchColumn(int column, string searchText)
        {
            for (var r = 0; r < Count; r++)
            {
                var subrows = _sheet.GetRowAt(r);
                foreach (var subrow in subrows)
                {
                    var value = subrow.ReadColumn(column).ToString() ?? string.Empty;
                    if (value.Contains(searchText, StringComparison.OrdinalIgnoreCase))
                    {
                        yield return (r, value);
                        break;
                    }
                }
            }
        }
    }
}
