codeunit 70200 "Red Custom Layout Report Evnt"
// Copyright (c) 2020 ForNAV ApS - All Rights Reserved
// The intellectual work and technical concepts contained in this file are proprietary to ForNAV.
// Unauthorized reverse engineering, distribution or copying of this file, parts hereof, or derived work, via any medium is strictly prohibited without written permission from ForNAV ApS.
// This source code is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Layout Reporting", 'OnBeforeRunReportWithCustomReportSelection', '', false, false)]
    local procedure OnBeforeRunReportWithCustomReportSelection(
        var DataRecRef: RecordRef;
        var ReportID: Integer;
        var CustomReportSelection: Record "Custom Report Selection";
        var EmailPrintIfEmailIsMissing: Boolean;
        var TempBlobReqParamStore: Record TempBlob;
        var OutputType: Option;
        var AnyOutputExists: Boolean;
        var InHandled: Boolean
    )
    var
        RedCustomLayoutReporting: Codeunit "Red Custom Layout Reporting";
    begin
        if InHandled then
            exit;

        InHandled := RedCustomLayoutReporting.RunReportWithCustomReportSelection(DataRecRef, ReportID, CustomReportSelection, EmailPrintIfEmailIsMissing, TempBlobReqParamStore, OutputType, AnyOutputExists);
    end;
}