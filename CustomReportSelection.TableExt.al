tableextension 70200 RedCustomReportSelection extends "Custom Report Selection"
// Copyright (c) 2020 ForNAV ApS - All Rights Reserved
// The intellectual work and technical concepts contained in this file are proprietary to ForNAV.
// Unauthorized reverse engineering, distribution or copying of this file, parts hereof, or derived work, via any medium is strictly prohibited without written permission from ForNAV ApS.
// This source code is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
{
    fields
    {
        field(70200; "Red Alt Email Report ID"; Integer)
        {
            Caption = 'Alternative Email Report ID';
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));

            trigger OnValidate()
            var
                ReportManagement: Codeunit "ForNAV Report Management";
            begin
                CalcFields("Red Alt Email Report Caption");
                if ("Red Alt Email Report ID" = 0) or ("Red Alt Email Report ID" <> xRec."Red Alt Email Report ID") then begin
                    Validate("Red Alt Email Layout Code", '');
                end;
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
                if "Red Alt Email Layout Code" <> '' then
                    TestField("Use for Email Body", false);
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

    var
        CannotBeForNAVReportErr: Label 'The %1 cannot be a ForNAV report';
}