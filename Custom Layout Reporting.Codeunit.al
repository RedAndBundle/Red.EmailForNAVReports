codeunit 70201 "Red Custom Layout Reporting"
{
    procedure RunReportWithCustomReportSelection(
        var DataRecRef: RecordRef;
        var ReportID: Integer;
        var CustomReportSelection: Record "Custom Report Selection";
        var EmailPrintIfEmailIsMissing: Boolean;
        var TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary;
        var TempBlobList: Codeunit "Temp Blob List";
        var OutputType: Option Print,Preview,PDF,Email,Excel,Word,XML;
        var AnyOutputExists: Boolean
    ): Boolean
    begin
        case false of
            OutputType = OutputType::Email,
            CustomReportSelection."Red Alt Email Layout Code" = '',
            CustomReportSelection.GetSendToEmail(true) = '':
                exit(false);
        end;

        EmailReport(DataRecRef, ReportID, CustomReportSelection, TempBlobIndicesNameValueBuffer, TempBlobList);
        AnyOutputExists := true;
        exit(true);
    end;

    local procedure EmailReport(var DataRecRef: RecordRef; ReportID: Integer; CustomReportSelection: Record "Custom Report Selection"; var TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary; var TempBlobList: Codeunit "Temp Blob List")
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        TempPDF: Record "ForNAV Core Setup";
        TempHTML: Record "ForNAV Core Setup";
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

        CreateReportWithExtension(DataRecRef, ReportID, ReportID, REPORTFORMAT::Pdf, TempPDF, TempBlobIndicesNameValueBuffer, TempBlobList);
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
            CreateReportWithExtension(ReportRecordVariant, CustomReportSelection."Red Alt Email Report ID", ReportID, REPORTFORMAT::Html, TempHTML, TempBlobIndicesNameValueBuffer, TempBlobList);
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

    local procedure CreateReportWithExtension(var DataRecRef: RecordRef; ReportID: Integer; MasterReportId: Integer; ReportFormatType: ReportFormat; var tempBlob: Record "ForNAV Core Setup"; var TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary; var TempBlobList: Codeunit "Temp Blob List"): Text[250]
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
                    CustomLayoutReporting.CallReportSaveAs(ReportID, GetRequestParametersText(TempBlobIndicesNameValueBuffer, TempBlobList, MasterReportId), REPORTFORMAT::Pdf, os, DataRecRef);
                end;
            REPORTFORMAT::Html:
                begin

                    tempBlob.Blob.CreateOutStream(os);
                    CustomLayoutReporting.CallReportSaveAs(ReportID, GetRequestParametersText(TempBlobIndicesNameValueBuffer, TempBlobList, MasterReportId), REPORTFORMAT::Html, os, DataRecRef);
                end;
        end;

    end;

    [TryFunction]
    local procedure TryEmailReport(var TempPDF: Record "ForNAV Core Setup"; var TempHTML: Record "ForNAV Core Setup"; var CustomReportSelection: Record "Custom Report Selection"; var FieldRef2: FieldRef; AttachmentName: Text)
    var
        DocumentMailing: Codeunit "Document-Mailing";
        MailSent: Boolean;
        AttIs: InStream;
        BodyIs: InStream;
        Body: Text;
    begin
        TempHTML.Blob.CreateInStream(BodyIs);

        TempPDF.Blob.CreateInStream(AttIs);

        MailSent := DocumentMailing.EmailFileAndHtmlFromStream(AttIs, AttachmentName, BodyIs, CustomReportSelection.GetSendToEmail(true), DocumentMailing.GetEmailSubject('', AttachmentName, CustomReportSelection.Usage.AsInteger()), true, CustomReportSelection.Usage.AsInteger());

        if not MailSent then
            ClearLastError();
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

    local procedure GetRequestParametersText(var TempBlobIndicesNameValueBuffer: Record "Name/Value Buffer" temporary; var TempBlobList: Codeunit "Temp Blob List"; ReportID: Integer): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        ReqPageXML: Text;
        Index: Integer;
    begin
        TempBlobIndicesNameValueBuffer.Get(ReportID);
        Evaluate(Index, TempBlobIndicesNameValueBuffer.Value);
        TempBlobList.Get(Index, TempBlob);
        TempBlob.CreateInStream(InStr);
        InStr.ReadText(ReqPageXML);
        exit(ReqPageXML);
    end;
}