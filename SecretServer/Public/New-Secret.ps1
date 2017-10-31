Function New-Secret
{
[CmdletBinding()]
Param
    (
        [String]
        $SecretName


    )
    DynamicParam 
    {

           $templates=Invoke-RestMethod -Uri ($Script:url+"/secret-templates") -Method Get @Script:params
                        if($templates.take -lt $templates.total)
                        {
                            $take=$templates.total
                            $templates=Invoke-RestMethod -Uri ($Script:url+"/secret-templates?take=$take") -Method Get @Script:params
                        }
           $DynamicParams = @(
                @{
                    Name = 'Template'
                    Type = [string]
                    Position = 0
                    Mandatory = $true
                    ValidateSet = $templates.records.name
                })

           <# $Secretitems=@{}
            $templates.records | Foreach { $Secretitems[$_.name] = $_.id }
            $templateId=$Secretitems[$DynamicParams[0].ValidateSet]
            $stub=Invoke-RestMethod -Uri ($Global:url+"/api/v1/secrets/stub")#>
            
            $DynamicParams += @{
                    Name = 'SecretField'
                    Type = [string]
                    Position = 2
                    Mandatory = $false
                    ParameterSetName = 'Secret'
                }
            $DynamicParams| ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
            

    }
Begin
    {
        $Template 
        New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

    }
Process
    {
        #$PSBoundParameters
        #New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters
        #if($template -eq "Active Directory Account"){ $domainname=Read-Host "Enter Domain name:" }
        try
        {
          
        }
        Catch
        {
            $result = $_.Exception.Response.GetResponseStream();
            $reader = New-Object System.IO.StreamReader($result);
            $reader.BaseStream.Position = 0;
            $reader.DiscardBufferedData();
            $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
            Write-Host "Get templates error: $($responseBody.errorCode) - $($responseBody.message)"
            return;
        }
    }
}