codeunit 50000 AzureBlobHandler
{
    procedure CreateGLLines()
    var

        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSContainerContent: Record "ABS Container Content" temporary;
        ABSOperationResponss: Codeunit "ABS Operation Response";
        CSVBuffer: Record "CSV Buffer" temporary;
        JournalLine: Record "Gen. Journal Line";
        InS: InStream;
        OutS: OutStream;
        LineNo: Integer;
        CsvLineNo: Integer;
        tempBlob: Codeunit "Temp Blob";
        Filename: Text;
        CSVAmount: Decimal;
        CSVDate: date;
    begin

        LineNo += 10000;

        Authorization := StorageServiceAuthorization.CreateSharedKey('BlQEU3nTt0z5N4KKTntuX+aaqLf4TUpH9SSuj51W9uU6ox4Y5te9O9qLp/x/OwmnXwqSPu8fHmxs+AStrsOScA==');
        ABSBlobClient.Initialize('bc365co', 'bc365', Authorization);
        ABSBlobClient.ListBlobs(ABSContainerContent);

        if ABSContainerContent.FindFirst() then
            repeat
                ABSOperationResponss := ABSBlobClient.GetBlobAsStream(ABSContainerContent.Name, InS);
                CSVBuffer.LoadDataFromStream(InS, ';');

                if CSVBuffer.FindFirst() then
                    repeat

                        if CsvLineNo <> CSVBuffer."Line No." then begin
                            CsvLineNo := CSVBuffer."Line No.";
                            JournalLine.Init();
                            JournalLine."Line No." := LineNo;
                            journalLine.Validate("Journal Template Name", 'STANDARD');
                            JournalLine.Validate("Journal Batch Name", 'STANDARD');

                            LineNo += 10000;
                        end;
                        case
                            CSVBuffer."Field No." of
                            1:
                                begin
                                    JournalLine.Validate("Account Type", JournalLine."Account Type"::"G/L Account");
                                    JournalLine.Validate("Account No.", CSVBuffer.Value);

                                end;

                            2:
                                begin
                                    Evaluate(CSVAmount, CSVBuffer.value);
                                    JournalLine.Validate(Amount, CSVAmount);

                                end;

                            3:
                                begin

                                    Evaluate(CSVDate, CSVBuffer.Value);
                                    JournalLine.Validate("Posting Date", CSVdate);
                                    JournalLine.Insert(true);

                                end;

                        end;
                    until CSVBuffer.Next() = 0;


            until ABSContainerContent.Next() = 0;


    end;


}
