Function Get-SecretStub{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript(
                                                {
            If($_ -match "^((http|https)://)?([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)?$")
            {
                $true
            }
            else
            {
                Throw "$_ is not a valid URL format. Please enter url format as https://hostname, https://hostname/application"
            }
        })
        ]
        [String]
        $Url,
        [Parameter(Mandatory=$true)]
        [String]
        $SearchText,
        [Parameter(Mandatory=$true)]
        [hashtable]
        $Headers,
        [Parameter(Mandatory=$false)]
        [String]
        $FolderId


    )
    try
    {
        $getTemplate=Invoke-RestMethod -Uri ($Url+"/api/v1/secret-templates?filter.SearchText=$SearchText") -Method Get -Headers $Headers
    }
    catch
    {
        $result = $_.Exception.Response.GetResponseStream();
        $reader = New-Object System.IO.StreamReader($result);
        $reader.BaseStream.Position = 0;
        $reader.DiscardBufferedData();
        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "Get Template Error: $($responseBody.errorCode) - $($responseBody.message)"
        return;
    }
    foreach($record in $getTemplate.records)
    {
        if($record.name -match $SearchText)
        {
            $templateId=$record.id
        }
        else
        {
            continue
        }
    }
    if($FolderId.Length -ne 0)
    {
        $filter="?filter.SecretTemplateId=$templateId&filter.FolderId=$FolderId"
    }
    else
    {
        $filter="?filter.SecretTemplateId=$templateId"
    
    }
    try
    {
        Invoke-RestMethod -Uri ($Url+"/api/v1/secrets/stub$filter") -Method Get -Headers $Headers
        return
    }
    catch
    {
        $result = $_.Exception.Response.GetResponseStream();
        $reader = New-Object System.IO.StreamReader($result);
        $reader.BaseStream.Position = 0;
        $reader.DiscardBufferedData();
        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "Get Stub Error: $($responseBody.errorCode) - $($responseBody.message)"
        return;
    }
}