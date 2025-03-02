using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Dalamud.Interface.Utility;
using Dalamud.Interface.Utility.Raii;
using ImGuiNET;
using Lumina.Excel;

namespace SomethingNeedDoing.Interface.Excel
{
    /// <summary>
    /// Displays an Excel sheet using ImGui tables with pagination and a leading "RowId" column.
    /// </summary>
    public sealed class ExcelSheetDisplay
    {
        private IExcelSheet? _sheet;
        private ISheetWrapper? _wrapper;
        private SortedSet<int>? _curFilteredRows;
        private string _curSearchFilter = "";
        private CancellationTokenSource? _filterCts;
        private float? itemHeight;
        private readonly Dictionary<int, float> _columnWidths = new Dictionary<int, float>();

        private const float MIN_COLUMN_WIDTH = 40f;
        private const float PADDING = 20f;
        private const int PAGE_SIZE = 60;
        private int _currentPage = 0;

        public ExcelSheetDisplay() { }

        /// <summary>
        /// Renders the Excel sheet.
        /// </summary>
        public void Draw(IExcelSheet sheet)
        {
            if (sheet == null)
                return;

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
            bool filterDirty = ImGui.InputTextWithHint($"###{nameof(ExcelSheetDisplay)}filter", "Search...", ref _curSearchFilter, 256);
            if (filterDirty)
            {
                _filterCts?.Cancel();
                _filterCts = new CancellationTokenSource();
                Task.Run(() => ApplyFilterAsync(sheet, _filterCts));
            }

            float height = ImGui.GetContentRegionAvail().Y;

            if (_sheet.Columns.Count <= PAGE_SIZE)
            {
                using var table = ImRaii.Table($"{nameof(ExcelSheetDisplay)}", _sheet.Columns.Count + 1,
                    ImGuiTableFlags.Borders | ImGuiTableFlags.ScrollX | ImGuiTableFlags.ScrollY | ImGuiTableFlags.NoSavedSettings,
                    new System.Numerics.Vector2(0, height));
                if (!table)
                    return;

                ImGui.TableSetupScrollFreeze(1, 1);
                ImGui.TableHeadersRow();

                // Row ID header
                ImGui.TableSetColumnIndex(0);
                ImGui.TableHeader("RowId");

                // Data column headers
                for (int i = 0; i < _sheet.Columns.Count; i++)
                {
                    ImGui.TableSetColumnIndex(i + 1);
                    string headerText = $"{i}: {_sheet.Columns[i].Type}";
                    ImGui.TableHeader(headerText);
                    if (ImGui.IsItemHovered())
                        ImGui.SetTooltip(string.Format("Column {0} of {1}", i, _sheet.Columns.Count));
                    if (!_columnWidths.ContainsKey(i))
                        _columnWidths[i] = Math.Max(MIN_COLUMN_WIDTH, ImGui.CalcTextSize(headerText).X + PADDING);
                }

                itemHeight = ImGui.GetTextLineHeightWithSpacing();
                if (_wrapper != null)
                {
                    ImGuiClip.ClippedDraw(
                        _curFilteredRows?.ToList() ?? Enumerable.Range(0, _wrapper.Count).ToList(),
                        row => DrawRow(row, 0, _sheet.Columns.Count),
                        itemHeight ?? 0);
                }
            }
            else
            {
                int totalPages = (_sheet.Columns.Count + PAGE_SIZE - 1) / PAGE_SIZE;
                _currentPage = Math.Clamp(_currentPage, 0, totalPages - 1);
                int startColumn = _currentPage * PAGE_SIZE;
                int endColumn = Math.Min(startColumn + PAGE_SIZE, _sheet.Columns.Count);

                // Pagination controls
                float paginationHeight = 40f;
                ImGui.BeginChild("PaginationControls", new System.Numerics.Vector2(0, paginationHeight), false);
                if (ImGui.Button("Previous") && _currentPage > 0)
                    _currentPage--;
                ImGui.SameLine();
                if (ImGui.Button("Next") && _currentPage < totalPages - 1)
                    _currentPage++;
                ImGui.SameLine();
                ImGui.SliderInt("Page", ref _currentPage, 0, totalPages - 1, $"{_currentPage + 1}/{totalPages}");
                ImGui.SameLine();
                ImGui.Text($"Total Columns: {_sheet.Columns.Count}");
                ImGui.EndChild();

                int columnsToRender = endColumn - startColumn;
                using var table = ImRaii.Table($"{nameof(ExcelSheetDisplay)}", columnsToRender + 1,
                    ImGuiTableFlags.Borders | ImGuiTableFlags.ScrollX | ImGuiTableFlags.ScrollY | ImGuiTableFlags.NoSavedSettings,
                    new System.Numerics.Vector2(0, height - paginationHeight));
                if (!table)
                    return;

                ImGui.TableSetupScrollFreeze(1, 1);
                ImGui.TableHeadersRow();

                // Row ID header
                ImGui.TableSetColumnIndex(0);
                ImGui.TableHeader("RowId");

                // Paginated data column headers
                for (int i = startColumn; i < endColumn; i++)
                {
                    ImGui.TableSetColumnIndex(i - startColumn + 1);
                    string headerText = $"{i}: {_sheet.Columns[i].Type}";
                    ImGui.TableHeader(headerText);
                    if (ImGui.IsItemHovered())
                        ImGui.SetTooltip(string.Format("Column {0} of {1}", i, _sheet.Columns.Count));
                    if (!_columnWidths.ContainsKey(i))
                        _columnWidths[i] = Math.Max(MIN_COLUMN_WIDTH, ImGui.CalcTextSize(headerText).X + PADDING);
                }

                itemHeight = ImGui.GetTextLineHeightWithSpacing();
                if (_wrapper != null)
                {
                    ImGuiClip.ClippedDraw(
                        _curFilteredRows?.ToList() ?? Enumerable.Range(0, _wrapper.Count).ToList(),
                        row => DrawRow(row, startColumn, endColumn),
                        itemHeight ?? 0);
                }
            }
        }

        private void DrawRow(int rowId, int startColumn, int endColumn)
        {
            List<(int RowId, int SubRowId, string Value)> rows = _wrapper!.ReadCellRows(rowId, 0).ToList();
            bool hasMultipleRows = rows.Count > 1;
            foreach (var (rId, subRowId, _) in rows)
            {
                ImGui.TableNextRow();
                // Row ID cell
                ImGui.TableNextColumn();
                ImGui.TextUnformatted(hasMultipleRows ? $"{rId}.{subRowId}" : rId.ToString());
                // Data cells
                for (int i = startColumn; i < endColumn; i++)
                {
                    ImGui.TableNextColumn();
                    ImGui.AlignTextToFramePadding();
                    var (_, _, cellValue) = _wrapper.ReadCellRows(rowId, i).ElementAt(subRowId);
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

            _curFilteredRows = new SortedSet<int>(Comparer<int>.Default);
            if (_wrapper != null)
            {
                for (int i = 0; i < sheet.Columns.Count; i++)
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

        private class RawRowWrapper : ISheetWrapper
        {
            private readonly ExcelSheet<RawRow> _sheet;
            public RawRowWrapper(ExcelSheet<RawRow> sheet) { _sheet = sheet; }
            public int Count => _sheet.Count;
            public IEnumerable<(int RowId, int SubRowId, string Value)> ReadCellRows(int rowId, int column)
            {
                yield return (rowId, 0, _sheet.GetRowAt(rowId).ReadColumn(column).ToString() ?? string.Empty);
            }
            public IEnumerable<(int RowId, string Value)> SearchColumn(int column, string searchText)
            {
                for (int r = 0; r < Count; r++)
                {
                    string value = ReadCellRows(r, column).First().Value;
                    if (value.Contains(searchText, StringComparison.OrdinalIgnoreCase))
                        yield return (r, value);
                }
            }
        }

        private class SubrowWrapper : ISheetWrapper
        {
            private readonly SubrowExcelSheet<RawSubrow> _sheet;
            public SubrowWrapper(SubrowExcelSheet<RawSubrow> sheet) { _sheet = sheet; }
            public int Count => _sheet.Count;
            public IEnumerable<(int RowId, int SubRowId, string Value)> ReadCellRows(int rowId, int column)
            {
                var subrows = _sheet.GetRowAt(rowId);
                for (int i = 0; i < subrows.Count; i++)
                    yield return (rowId, i, subrows[i].ReadColumn(column).ToString() ?? string.Empty);
            }
            public IEnumerable<(int RowId, string Value)> SearchColumn(int column, string searchText)
            {
                for (int r = 0; r < Count; r++)
                {
                    var subrows = _sheet.GetRowAt(r);
                    foreach (var subrow in subrows)
                    {
                        string value = subrow.ReadColumn(column).ToString() ?? string.Empty;
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
}
