codeunit 70201 "Red Custom Layout Reporting"
// Copyright (c) 2020 ForNAV ApS - All Rights Reserved
// The intellectual work and technical concepts contained in this file are proprietary to ForNAV.
// Unauthorized reverse engineering, distribution or copying of this file, parts hereof, or derived work, via any medium is strictly prohibited without written permission from ForNAV ApS.
// This source code is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
{
    procedure RunReportWithCustomReportSelection(
        var DataRecRef: RecordRef;
        var ReportID: Integer;
        var CustomReportSelection: Record "Custom Report Selection";
        var EmailPrintIfEmailIsMissing: Boolean;
        var TempBlobReqParamStore: Record TempBlob;
        var OutputType: Option Print,Preview,PDF,Email,Excel,Word,XML;
        var AnyOutputExists: Boolean
    ): Boolean
    begin
        case true of
            OutputType <> OutputType::Email,
            CustomReportSelection."Red Alt Email Layout Code" = '',
            CustomReportSelection."Send To Email" = '':
                exit(false);
        end;

        EmailReport(DataRecRef, ReportID, CustomReportSelection, TempBlobReqParamStore);
        AnyOutputExists := true;
        exit(true);
    end;

    local procedure EmailReport(var DataRecRef: RecordRef; ReportID: Integer; CustomReportSelection: Record "Custom Report Selection"; var TempBlobReqParamStore: Record TempBlob)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        TempPDF: Record TempBlob;
        TempHTML: Record TempBlob;
        CustomReportLayout: Record "Custom Report Layout";
        MailManagement: Codeunit "Mail Management";
        FieldRef1: FieldRef;
        FieldRef2: FieldRef;
        ReportRecordVariant: Variant;
        EmailBodyLayoutCode: Code[20];
        CustomReportLayoutCode: Code[20];
        AttachmentName: Text;
    begin
        CustomReportLayoutCode := ResolveCustomReportLayoutCode(CustomReportSelection);
        ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutCode);

        CreateReportWithExtension(DataRecRef, ReportID, ReportID, REPORTFORMAT::Pdf, TempPDF, TempBlobReqParamStore);
        if not TempPDF.Blob.HasValue then
            exit;

        if CustomReportLayout.Get(CustomReportLayoutCode) then;
        AttachmentName := GenerateAttachmentNameForReport('pdf', CustomReportLayout.Description, DataRecRef);

        if CustomReportLayoutCode <> '' then
            ReportLayoutSelection.SetTempLayoutSelected('');

        GetKeyFieldRef(DataRecRef, FieldRef1);
        GetNameFieldRef(DataRecRef, FieldRef2);

        EmailBodyLayoutCode := ResolveEmailBodyLayoutCode(CustomReportSelection);

        if EmailBodyLayoutCode <> '' then begin
            ReportLayoutSelection.SetTempLayoutSelected(EmailBodyLayoutCode);
            ReportRecordVariant := DataRecRef;
            BindSubscription(MailManagement);
            CreateReportWithExtension(ReportRecordVariant, CustomReportSelection."Red Alt Email Report ID", ReportID, REPORTFORMAT::Html, TempHTML, TempBlobReqParamStore);
            if not TempHTML.Blob.HasValue then
                exit;
            UnbindSubscription(MailManagement);
        end;

        ReportLayoutSelection.SetTempLayoutSelected('');

        TryEmailReport(TempPDF, TempHTML, CustomReportSelection, FieldRef2, AttachmentName);
    end;

    local procedure GetKeyFieldRef(var TableRecordRef: RecordRef; var KeyFieldRef: FieldRef): Boolean
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        case TableRecordRef.Number of
            DATABASE::Customer,
            DATABASE::Vendor:
                begin
                    DataTypeManagement.FindFieldByName(TableRecordRef, KeyFieldRef, 'No.');
                    exit(true);
                end;
            else
                exit(false);
        end;
    end;

    local procedure GetNameFieldRef(var TableRecordRef: RecordRef; var NameFieldRef: FieldRef): Boolean
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        case TableRecordRef.Number of
            DATABASE::Customer,
            DATABASE::Vendor:
                begin
                    DataTypeManagement.FindFieldByName(TableRecordRef, NameFieldRef, 'Name');
                    exit(true);
                end;
            else
                exit(false);
        end;
    end;

    local procedure CreateReportWithExtension(var DataRecRef: RecordRef; ReportID: Integer; MasterReportId: Integer; ReportFormatType: ReportFormat; var tempBlob: Record TempBlob; var TempBlobReqParamStore: Record TempBlob): Text[250]
    var
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
        ReportManagement: Codeunit "ForNAV Report Management";
        os: OutStream;
    begin
        BindSubscription(CustomLayoutReporting);
        case ReportFormatType of
            REPORTFORMAT::Pdf:
                begin
                    tempBlob.Blob.CreateOutStream(os);
                    CustomLayoutReporting.CallReportSaveAs(ReportID, GetRequestParametersText(TempBlobReqParamStore, MasterReportId), REPORTFORMAT::Pdf, os, DataRecRef);
                end;
            REPORTFORMAT::Html:
                begin

                    tempBlob.Blob.CreateOutStream(os);
                    CustomLayoutReporting.CallReportSaveAs(ReportID, GetRequestParametersText(TempBlobReqParamStore, MasterReportId), REPORTFORMAT::Html, os, DataRecRef);
                end;
        end;

    end;

    [TryFunction]
    local procedure TryEmailReport(var TempPDF: Record TempBlob; var TempHTML: Record TempBlob; var CustomReportSelection: Record "Custom Report Selection"; var FieldRef2: FieldRef; AttachmentName: Text)
    var
        DocumentMailing: Codeunit "Document-Mailing";
        MailSent: Boolean;
        AttIs: InStream;
        BodyIs: InStream;
        AttFilename: Text;
        BodyFilename: Text;
    begin
        TempHTML.Blob.CreateInStream(BodyIs);
        BodyFilename := CreateFileFromInStream(BodyIs);

        TempPDF.Blob.CreateInStream(AttIs);
        AttFilename := CreateFileFromInStream(AttIs);

        MailSent := DocumentMailing.EmailFile(
            CopyStr(AttFilename, 1, 250),
            AttachmentName,
            BodyFilename,
            '',
            CustomReportSelection."Send To Email",
            StrSubstNo('%1', FieldRef2.Value),
            TRUE,
            CustomReportSelection.Usage);

        if not MailSent then
            ClearLastError();
    end;

    local procedure CreateFileFromInStream(is: InStream) TempFileName: Text
    var
        FileManagement: Codeunit "File Management";
        TempFile: File;
        os: OutStream;
    begin
        TempFileName := FileManagement.ServerTempFileName('');
        TempFile.CREATE(TempFileName);

        TempFile.CreateOutStream(os);
        CopyStream(os, is);
        TempFile.CLOSE;
    end;

    local procedure GenerateAttachmentNameForReport(Extension: Text; LayoutName: Text; DataRecordRef: RecordRef): Text[250]
    var
        NameFieldRef: FieldRef;
        ObjectName: Text;
    begin
        if GetNameFieldRef(DataRecordRef, NameFieldRef) then
            ObjectName := StrSubstNo('%1', NameFieldRef.Value);

        if LayoutName <> '' then
            ObjectName := StrSubstNo('%1_%2', CopyStr(ObjectName, 1, 50), LayoutName);

        exit(StrSubstNo('%1.%2', ObjectName, Extension));
    end;

    local procedure ResolveCustomReportLayoutCode(var CustomReportSelection: Record "Custom Report Selection"): Code[20]
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if CustomReportSelection."Custom Report Layout Code" <> '' then
            exit(CustomReportSelection."Custom Report Layout Code");

        if ReportLayoutSelection.Get(CustomReportSelection."Report ID", CompanyName) then
            exit(ReportLayoutSelection."Custom Report Layout Code");

        exit('');
    end;

    local procedure ResolveEmailBodyLayoutCode(var CustomReportSelection: Record "Custom Report Selection"): Code[20]
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        exit(CustomReportSelection."Red Alt Email Layout Code");
    end;

    local procedure GetRequestParametersText(var TempBlobReqParamStore: Record TempBlob; ReportID: Integer): Text
    var
        InStr: InStream;
        ReqPageXML: Text;
    begin
        TempBlobReqParamStore.Get(ReportID);
        TempBlobReqParamStore.CalcFields(Blob);
        TempBlobReqParamStore.Blob.CreateInStream(InStr);
        InStr.ReadText(ReqPageXML);
        exit(ReqPageXML);
    end;
}