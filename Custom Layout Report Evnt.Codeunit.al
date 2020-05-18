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

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeGetEmailBodyCustomer', '', false, false)]
    local procedure OnBeforeGetEmailBodyCustomer(ReportUsage: Integer; RecordVariant: Variant; var TempBodyReportSelections: Record "Report Selections" temporary; CustNo: Code[20]; var CustEmailAddress: Text[250]; var EmailBodyText: Text; var IsHandled: Boolean)
    var
        RedReportSelection: Codeunit "Red Report Selection";
    begin
        if IsHandled then
            exit;

        RedReportSelection.GetAlternativeEmailBodyLayout(ReportUsage, RecordVariant, TempBodyReportSelections, CustNo, CustEmailAddress, EmailBodyText);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnFindReportSelections', '', false, false)]
    local procedure OnFindReportSelections(var FilterReportSelections: Record "Report Selections"; var IsHandled: Boolean; var ReturnReportSelections: Record "Report Selections"; AccountNo: Code[20]; TableNo: Integer)
    var
        RedReportSelection: Codeunit "Red Report Selection";
    begin
        if IsHandled then
            exit;

        IsHandled := RedReportSelection.HasAlternativeEmailLayout(FilterReportSelections);
    end;
}