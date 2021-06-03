report 70200 "Red Statement Email Body"
{
    WordLayout = './Layouts/RedStatementEmailBody.docx';
    Caption = 'Statement Email Body';
    DefaultLayout = Word;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Search Name", "Print Statements", "Currency Filter";
            column(No_Cust; "No.")
            {
            }
            column(CompanyPicture; CompanyInfo.Picture)
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(PhoneNo_CompanyInfo; CompanyInfo."Phone No.")
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(CompanyInfoEmail; CompanyInfo."E-Mail")
            {
            }
            column(CompanyInfoHomePage; CompanyInfo."Home Page")
            {
            }
            column(VATRegNo_CompanyInfo; CompanyInfo."VAT Registration No.")
            {
            }
            column(GiroNo_CompanyInfo; CompanyInfo."Giro No.")
            {
            }
            column(BankName_CompanyInfo; CompanyInfo."Bank Name")
            {
            }
            column(BankAccNo_CompanyInfo; CompanyInfo."Bank Account No.")
            {
            }
            column(No1_Cust; Customer."No.")
            {
            }
            column(TodayFormatted; Format(Today))
            {
            }
            column(LastStatmntNo_Cust; Format(Customer."Last Statement No."))
            {
            }
            column(CustAddr7; CustAddr[7])
            {
            }
            column(CustAddr8; CustAddr[8])
            {
            }
            column(CompanyAddr7; CompanyAddr[7])
            {
            }
            column(CompanyAddr8; CompanyAddr[8])
            {
            }
            column(StatementCaption; StatementCaptionLbl)
            {
            }
            column(PhoneNo_CompanyInfoCaption; CompanyInfo.FieldCaption("Phone No."))
            {
            }
            column(VATRegNo_CompanyInfoCaption; CompanyInfo.FieldCaption("VAT Registration No."))
            {
            }
            column(GiroNo_CompanyInfoCaption; CompanyInfo.FieldCaption("Giro No."))
            {
            }
            column(BankName_CompanyInfoCaption; CompanyInfo.FieldCaption("Bank Name"))
            {
            }
            column(BankAccNo_CompanyInfoCaption; CompanyInfo.FieldCaption("Bank Account No."))
            {
            }
            column(No1_CustCaption; Customer.FieldCaption("No."))
            {
            }
            column(CompanyInfoHomepageCaption; CompanyInfo.FieldCaption("Home Page"))
            {
            }
            column(CompanyInfoEmailCaption; CompanyInfo.FieldCaption("E-Mail"))
            {
            }
            column(CompanyLegalOffice; CompanyInfo.GetLegalOffice)
            {
            }
            column(CompanyLegalOffice_Lbl; CompanyInfo.GetLegalOfficeLbl)
            {
            }

            dataitem(LetterText; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(GreetingText; GreetingLbl)
                {
                }
                column(BodyText; BodyLbl)
                {
                }
                column(ClosingText; ClosingLbl)
                {
                }
            }

            trigger OnAfterGetRecord()
            var
                FormatAddr: Codeunit "Format Address";
                Language: Codeunit Language;
            begin
                FormatAddr.Customer(CustAddr, Customer);
                CurrReport.Language(language.GetLanguageIdOrDefault(Customer."Language Code"));
            end;

            trigger OnPreDataItem()
            begin
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
    end;

    trigger OnPostReport()
    begin
    end;

    trigger OnPreReport()
    var
        FormatAddr: Codeunit "Format Address";
    begin
        CompanyInfo.Get();
        FormatAddr.Company(CompanyAddr, CompanyInfo);
    end;

    var
        CompanyInfo: Record "Company Information";
        CustAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        StatementCaptionLbl: Label 'Statement';
        GreetingLbl: Label 'Hello';
        ClosingLbl: Label 'Sincerely';
        BodyLbl: Label 'Thank you for your business. Your statement is attached to this message.';

}

