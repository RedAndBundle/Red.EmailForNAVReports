codeunit 70202 "Red Report Selection"
{
    procedure GetAlternativeEmailBodyLayout(ReportUsage: Integer; RecordVariant: Variant; var TempBodyReportSelections: Record "Report Selections" temporary; CustNo: Code[20]; var CustEmailAddress: Text[250]; var EmailBodyText: Text): Boolean
    begin
        if GetCustomReportSelection(TempBodyReportSelections, ReportUsage, CustNo, Database::Customer) then
            exit(true);

        if GetReportSelections(TempBodyReportSelections, ReportUsage) then
            exit(true);
    end;

    local procedure GetCustomReportSelection(var TempBodyReportSelections: Record "Report Selections"; ReportUsage: Integer; AccountNo: Code[20]; TableNo: Integer): Boolean
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        CustomReportSelection.SetRange(Usage, ReportUsage);
        CustomReportSelection.SetRange("Source Type", TableNo);
        CustomReportSelection.SetRange("Source No.", AccountNo);
        CustomReportSelection.SetFilter("Red Alt Email Layout Code", '<>%1', '');
        CustomReportSelection.SetFilter("Red Alt Email Report ID", '<>0');
        if CustomReportSelection.IsEmpty then
            exit(false);

        TempBodyReportSelections.Reset();
        TempBodyReportSelections.DeleteAll();
        if CustomReportSelection.FindSet then
            repeat
                TempBodyReportSelections.Usage := CustomReportSelection.Usage;
                TempBodyReportSelections.Sequence := Format(CustomReportSelection.Sequence);
                TempBodyReportSelections."Report ID" := CustomReportSelection."Red Alt Email Report ID";
                TempBodyReportSelections."Custom Report Layout Code" := CustomReportSelection."Red Alt Email Layout Code";
                TempBodyReportSelections."Email Body Layout Code" := CustomReportSelection."Red Alt Email Layout Code";
                TempBodyReportSelections."Use for Email Attachment" := false;
                TempBodyReportSelections."Use for Email Body" := true;
                TempBodyReportSelections."Red Alt Email Report ID" := CustomReportSelection."Red Alt Email Report ID";
                TempBodyReportSelections."Red Alt Email Layout Code" := CustomReportSelection."Red Alt Email Layout Code";
                TempBodyReportSelections.Insert();
            until CustomReportSelection.Next() = 0;

        exit(not TempBodyReportSelections.IsEmpty());
    end;

    local procedure GetReportSelections(var TempBodyReportSelections: Record "Report Selections"; ReportUsage: Integer): Boolean
    var
        ReportSelections: Record "Report Selections";
    begin
        TempBodyReportSelections.Reset();
        TempBodyReportSelections.DeleteAll();
        with ReportSelections do begin
            SetRange(Usage, ReportUsage);
            SetFilter("Red Alt Email Layout Code", '<>%1', '');
            SetFilter("Red Alt Email Report ID", '<>0');
            if FindSet then
                repeat
                    TempBodyReportSelections.Usage := ReportSelections.Usage;
                    TempBodyReportSelections.Sequence := Format(ReportSelections.Sequence);
                    TempBodyReportSelections."Report ID" := ReportSelections."Red Alt Email Report ID";
                    TempBodyReportSelections."Custom Report Layout Code" := ReportSelections."Red Alt Email Layout Code";
                    TempBodyReportSelections."Email Body Layout Code" := ReportSelections."Red Alt Email Layout Code";
                    TempBodyReportSelections."Use for Email Attachment" := false;
                    TempBodyReportSelections."Use for Email Body" := true;
                    TempBodyReportSelections."Red Alt Email Report ID" := ReportSelections."Red Alt Email Report ID";
                    TempBodyReportSelections."Red Alt Email Layout Code" := ReportSelections."Red Alt Email Layout Code";
                    TempBodyReportSelections.Insert();
                until Next() = 0;
        end;

        exit(not TempBodyReportSelections.IsEmpty());
    end;

    procedure HasAlternativeEmailLayout(var TempBodyReportSelections: Record "Report Selections"): Boolean
    begin
        with TempBodyReportSelections do begin
            SetFilter("Red Alt Email Layout Code", '<>%1', '');
            SetFilter("Red Alt Email Report ID", '<>0');
            exit(not IsEmpty());
        end;
    end;
}