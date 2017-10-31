<#
.Synopsis
   Gets a Secret(s) from an ID or multiple IDs
.DESCRIPTION
   This will get a Secret from Secret Server by supplying a Secret ID(s). Set-SSCredentials must be run prior to this
.PARAMETER ID
    The ID(s) of the Secret
.EXAMPLE
   Get-Secret -ID 3041
.EXAMPLE
   Get-Secret -ID 3041, 3065
.INPUTS
   Secret ID(s) [int[]]
.OUTPUTS
   Outputs a custom Secret object with items and status
.COMPONENT
   The component this cmdlet SecretServer Module
#>
Function Get-Secret
{
[CmdletBinding()]
Param
    (
        [Parameter(Mandatory=$true)]
        [int[]]
        $Id
    )
begin
    {
        #Initialize the Secret Array
        $Secrets=@()
    }
process
    {
        foreach($i in $id)
            {
                try
                    {
                        $secret=Invoke-RestMethod -Uri ($Script:url+"Secrets/"+$i) -Method Get @Script:params
                        $Folder=Invoke-RestMethod -Uri ($Script:url+"folders/"+$secret.folderId) -Method Get @Script:params
                    }
                Catch
                    {
                        $result = $_.Exception.Response.GetResponseStream();
                        $reader = New-Object System.IO.StreamReader($result);
                        $reader.BaseStream.Position = 0;
                        $reader.DiscardBufferedData();
                        $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
                        Write-Host "Get Secret Error: $($responseBody.errorCode) - $($responseBody.message)"
                        return;
                    }
                $SecretObject= New-Object psobject
                $SecretObject | Add-Member -MemberType NoteProperty -Name Id -Value $secret.id
                $SecretObject | Add-Member -MemberType NoteProperty -Name Name -Value $secret.Name
                $SecretObject | Add-Member -MemberType NoteProperty -Name Template -Value $secret.secretTemplateName
                Foreach($item in $secret.items)
                    {
                        if([string]::IsNullOrEmpty($item.itemvalue))
                            {
                                continue
                            }
                        $SecretObject | Add-Member -MemberType NoteProperty -Name $item.fieldname -Value $item.itemvalue
                    }
                $SecretObject | Add-Member -MemberType NoteProperty -Name FolderPath -Value $Folder.folderPath
                $SecretObject | Add-Member -MemberType NoteProperty -Name Heartbeat -Value $secret.LastHeartbeatStatus
                $Secrets +=$SecretObject
            }
        return $Secrets
    }#end process
}#End function