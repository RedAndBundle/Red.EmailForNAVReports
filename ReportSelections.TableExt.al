tableextension 70200 RedCustomReportSelection extends "Custom Report Selection"
{
    fields
    {
        modify("Use for Email Body")
        {
            trigger OnBeforeValidate()
            begin
                RedCheckIfAlternateEmailBody();
            end;
        }
        field(70200; "Red Alt Email Report ID"; Integer)
        {
            Caption = 'Alternative Email Report ID';
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));

            trigger OnValidate()
            var
                ReportManagement: Codeunit "ForNAV Report Management";
            begin
                if ReportManagement.IsForNAVReport("Red Alt Email Report ID") then
                    Error(RedCannotBeForNAVReportErr, FieldCaption("Red Alt Email Report ID"));

                Validate("Use for Email Body", false);

                if ("Red Alt Email Report ID" = 0) or ("Red Alt Email Report ID" <> xRec."Red Alt Email Report ID") then begin
                    Validate("Red Alt Email Layout Code", '');
                end;

                CalcFields("Red Alt Email Report Caption");
            end;
        }
        field(70201; "Red Alt Email Report Caption"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" where("Object Type" = CONST(Report), "Object ID" = field("Red Alt Email Report ID")));
            Caption = 'Alternative Email Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70202; "Red Alt Email Layout Code"; Code[20])
        {
            Caption = 'Alternative Email Layout Code';
            TableRelation = "Custom Report Layout" where(Code = field("Red Alt Email Layout Code"), "Report ID" = field("Red Alt Email Report ID"));

            trigger OnValidate()
            begin
                Validate("Use for Email Body", false);
                CalcFields("Email Body Layout Description");
            end;
        }
        field(70203; "Red Alt Email Layout Desc"; Text[250])
        {
            CalcFormula = Lookup ("Custom Report Layout".Description where(Code = field("Red Alt Email Layout Code")));
            Caption = 'Alternative Email Body Layout Description';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    local procedure RedCheckIfAlternateEmailBody()
    begin
        if not "Use for Email Body" then
            exit;
        if "Red Alt Email Report ID" <> 0 then
            Error(RedCannotBeUsedErr, FieldCaption("Red Alt Email Report ID"), "Red Alt Email Report ID");
        if "Red Alt Email Layout Code" <> '' then
            Error(RedCannotBeUsedErr, FieldCaption("Red Alt Email Layout Desc"), "Red Alt Email Layout Desc");
    end;

    var
        RedCannotBeForNAVReportErr: Label 'The %1 cannot be a ForNAV report';
        RedCannotBeUsedErr: Label '%1 cannot be %2';
}