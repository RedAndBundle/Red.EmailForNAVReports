pageextension 70201 "Red Report Selections" extends "Report Selection - Sales"
{
    layout
    {
        addlast(Control1)
        {
            field("Email Body Layout Type"; "Email Body Layout Type")
            {
                ApplicationArea = Basic, Suite;
            }
            field("Red Alt Email Report ID"; "Red Alt Email Report ID")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ID of the report used for the email body.';
            }
            field("Red Alt Email Report Caption"; "Red Alt Email Report Caption")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the name of the report used for the email body.';
            }
            field("Red Alt Email Layout Code"; "Red Alt Email Layout Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the ID of the email body layout that is used for the email body.';
                Visible = false;
            }
            field("Red Alt Email Layout Desc"; "Red Alt Email Layout Desc")
            {
                ApplicationArea = Basic, Suite;
                DrillDown = true;
                Lookup = true;
                ToolTip = 'Specifies a description of the email body layout that is used for the email body.';

                trigger OnDrillDown()
                begin
                    LookupRedEmailBodyDescription;
                    CurrPage.Update(true);
                end;

                trigger OnLookup(var Text: Text): Boolean
                begin
                    LookupRedEmailBodyDescription;
                    CurrPage.Update(true);
                end;
            }
        }
    }

    procedure LookupRedEmailBodyDescription()
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        if CustomReportLayout.LookupLayoutOK("Red Alt Email Report ID") then
            Validate("Red Alt Email Layout Code", CustomReportLayout.Code)
        else
            Validate("Red Alt Email Layout Code", '');
    end;
}