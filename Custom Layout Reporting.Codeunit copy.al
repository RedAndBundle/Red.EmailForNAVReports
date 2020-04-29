codeunit 70201 "Red Custom Layout Reporting"
{
    procedure RunReportWithCustomReportSelection(
        var DataRecRef: RecordRef;
        var ReportID: Integer;
        var CustomReportSelection: Record "Custom Report Selection";
        var EmailPrintIfEmailIsMissing: Boolean;
        var TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary;
        var TempBlobList: Codeunit "Temp Blob List";
        var OutputType: Option;
        var AnyOutputExists: Boolean
    ): Boolean
    begin
        exit(true);
    end;
}