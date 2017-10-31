Function New-SSUser{
Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [String]
        $FirstName,
        [Parameter(Mandatory=$true,Position=1)]
        [String]
        $LastName,
        [Parameter(Mandatory=$true,Position=2)]
        [String]
        $Password,
        [Parameter(Mandatory=$false)]
        [String]
        $Email,
        [Parameter()]
        [switch]
        $EnableTwoFactor,
        [Parameter()]
        [ValidateSet("Email","Duo","Radius","TOTP")]
        [String]
        $TwoFactorProvider
        
    )

$body = 
@{
    userName = $FirstName[0]+$LastName
    Password = $Password
    DisplayName = $FirstName+" "+$LastName
    enabled = $True
    domainId = -1
    isApplicationAccount = $false
}|
    <#twoFactor = $false
    radiusTwoFactor = $false
    oathTwoFactor = $false
    duoTwoFactor = $false#>

 ConvertTo-Json
switch ($TwoFactorProvider) {
    condition {  }
    Default {}
}
try
{
    $user=Invoke-RestMethod -Uri "$Url/api/v1/users" -Method Post -Body $body -Headers $headers -ContentType "application/json"
}
Catch
{
    $result = $_.Exception.Response.GetResponseStream();
    $reader = New-Object System.IO.StreamReader($result);
    $reader.BaseStream.Position = 0;
    $reader.DiscardBufferedData();
    $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
    Write-Host "Post error: $($responseBody.errorCode) - $($responseBody.message)"
    return;
}
}