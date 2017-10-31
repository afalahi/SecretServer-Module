<#
.Synopsis
   Sets the Secret Server credentials and URL
.DESCRIPTION
   This Cmdlet will Authenticate the user and set a global token and url for the entire module. This Cmdlet supports WinAuth and Token Auth
.PARAMETER BaseUrl
    The base url for your Secret Server instance. This Parameter will validate a url to ensure it's valid
.PARAMETER UseDefaultCredentials
    Switch parameter for using Integrated windows Authentication. Windows Authentication must be enabled on the WinAuthWebServices directory
.PARAMETER UseTokenAuth
    Switch parameter for using token based authentication. You will need to supply a use name and password
.PARAMETER UserName
    A Secret Server username with the right permissions. This is typically a local account
.PARAMETER Password
    The password for the username
.EXAMPLE
   Set-SSCredentials -BaseUrl https://myssinstance.domain -UseTokenAuth -UserName someuser -Password pass123
.EXAMPLE
   Set-SSCredentials -BaseUrl https://myssinstance.domain -UseDefaultCredentials
.OUTPUTS
   None
.COMPONENT
   The component this cmdlet SecretServer Module
#>
Function Set-SSCredentials
{
[CmdletBinding()]
Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript(
        {
            If($_ -match "^((http|https)://)?([\w+?\.\w+])+([a-zA-Z0-9\~\!\@\#\$\%\^\&\*\(\)_\-\=\+\\\/\?\.\:\;\'\,]*)?$") {
                $true
            }
            else{
                Throw "$_ is not a valid URL format. Please enter url format as https://hostname, https://hostname/application"
            }
        })
        ]
        [String]
        $Url,
        [Parameter(ParameterSetName="DefaultCredentials")]
        [Switch]
        $UseDefaultCredentials,
        [Parameter(ParameterSetName="TokenAuth")]
        [Switch]
        $UseTokenAuth,
        [parameter(ParameterSetName="TokenAuth",Mandatory=$true)]
        [String]
        $UserName,
        [Parameter(
            ParameterSetName="TokenAuth",
            Mandatory=$true
        )]
        [Security.SecureString]$Password
            
    )
begin
    {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }
Process
    {        
    try
        {
            if($UseTokenAuth)
                {
                    $creds = 
                        @{
                            username = $UserName
                            password = $Password
                            grant_type = "password"
                        };
                    $response = Invoke-RestMethod "$Url/oauth2/token" -Method Post -Body $creds;
                    $token = $response.access_token;
                    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
                    $headers.Add("Authorization", "Bearer $token")
                    $Script:params=@{
                    Headers=$headers
                    ContentType='application/json'}
                    $Script:url=$Url+"/api/v1/"
                }
            else
                {
                    $Script:params=@{
                    UseDefaultCredentials=$true
                    ContentType='application/json'}
                    $Script:url=$Url+"/winauthwebservices/api/v1/"
                }
        }
    catch
        {
            $result = $_.Exception.Response.GetResponseStream();
            $reader = New-Object System.IO.StreamReader($result);
            $reader.BaseStream.Position = 0;
            $reader.DiscardBufferedData();
            $responseBody = $reader.ReadToEnd() | ConvertFrom-Json
            Write-Host "Post token error: $($responseBody.errorCode) - $($responseBody.message)"
            return;
        }
    }
end
{
    $creds.Clear()
}
}