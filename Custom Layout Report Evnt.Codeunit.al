codeunit 70200 "Red Custom Layout Report Evnt"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Layout Reporting", 'OnBeforeRunReportWithCustomReportSelection', '', false, false)]
    local procedure OnBeforeRunReportWithCustomReportSelection(
        var DataRecRef: RecordRef;
        var ReportID: Integer;
        var CustomReportSelection: Record "Custom Report Selection";
        var EmailPrintIfEmailIsMissing: Boolean;
        var TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary;
        var TempBlobList: Codeunit "Temp Blob List";
        var OutputType: Option;
        var AnyOutputExists: Boolean;
        var InHandled: Boolean
    )
    var
        RedCustomLayoutReporting: Codeunit "Red Custom Layout Reporting";
    begin
        if InHandled then
            exit;

        InHandled := RedCustomLayoutReporting.RunReportWithCustomReportSelection(DataRecRef, ReportID, CustomReportSelection, EmailPrintIfEmailIsMissing, TempBlobIndicesNameValueBuffer, TempBlobList, OutputType, AnyOutputExists);
    end;
}