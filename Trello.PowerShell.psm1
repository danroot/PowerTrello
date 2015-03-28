<#
.Synopsis
Retrieves an oAuth 2.0 access token from the specified base authorization
URL, client application ID, and callback URL.

.Parameter AuthUrl
The base authorization URL defined by the service provider.

.Parameter ClientId
The client ID (aka. app ID, consumer ID, etc.).

.Parameter RedirectUri
The callback URL configured on your application's registration with the
service provider.

.Parameter SleepInterval
The number of seconds to sleep while waiting for the user to authorize the
application.

.Parameter Scope
A string array of "scopes" (permissions) that your application will be
requesting from the user's account.
#>
function Get-oAuth2AccessToken {
[CmdletBinding()]
param (
[Parameter(Mandatory = $true)] [string] $AuthUrl
, [int] $SleepInterval = 2
)



# Create the Internet Explorer object and navigate to the constructed authorization URL
$IE = New-Object -ComObject InternetExplorer.Application;
$IE.Navigate($AuthUrl);
$IE.Visible = $true;

# Sleep the script for $X seconds until callback URL has been reached
# NOTE: If user cancels authorization, this condition will not be satisifed
while ($IE.LocationUrl -notmatch ‘token=’) {
Write-Debug -Message (‘Sleeping {0} seconds for access URL’ -f $SleepInterval);
Start-Sleep -Seconds $SleepInterval;
}

# Parse the access token from the callback URL and exit Internet Explorer
Write-Debug -Message (‘Callback URL is: {0}’ -f $IE.LocationUrl);
[Void]($IE.LocationUrl -match ‘=([\w\.]+)’);
$AccessToken = $Matches[1];
$IE.Quit();

# Write the access token to the pipeline inside of a HashTable (in case we want to return other properties later)
Write-Debug -Message (‘Access token is: {0}’ -f $AccessToken);
return $AccessToken
}





<#
 .Synopsis
  Logs into Trello and returns a token that may be used to make calls.
 .Description
  Logs into Trello and returns a token that may be used to make calls. Use with other commands to work with private boards
 .Parameter BoardId
  The id of the board
 .Example
  # Get all cards on a private board
   $auth = Get-TrelloToken -Key abc -AppName "My App"
   Get-TrelloCardsInBoard -BoardId fDsPBXFt -Token $auth
#>
function Get-TrelloToken
{
	param($Key, $AppName, $Expiration="30days", $Scope="read")

	$token = Get-oAuth2AccessToken -AuthUrl "https://trello.com/1/authorize?key=$Key&name=$AppName&expiration=$Expiration&scope=$Scope&response_type=token&callback_method=fragment&return_url=https://trello.com?"
	return @{Token=$token;AccessKey=$Key}
}

<#
 .Synopsis
  Gets all cards on a Trello board
 .Description
  Gets all cards on a Trello board.  Use with Login-Trello for private boards
 .Parameter BoardId
  The id of the board
 .Example
   # Get all cards on a public board
   Get-TrelloCardsInBoard -BoardId fDsPBXFt
 .Example
   # Get all cards on a private board
   $auth = Login-Trello -Token xyz -Key -abc
   Get-TrelloCardsInBoard -BoardId fDsPBXFt -Auth $auth
#>
function Get-TrelloBoards
{
	param($Token)
	return (Invoke-RestMethod ("https://api.trello.com/1/members/my/boards/?token=$($Token.Token)&key=$($Token.AccessKey)"))
}


<#
 .Synopsis
  Gets all cards on a Trello board
 .Description
  Gets all cards on a Trello board.  Use with Login-Trello for private boards
 .Parameter BoardId
  The id of the board
 .Example
   # Get all cards on a public board
   Get-TrelloCardsInBoard -BoardId fDsPBXFt
 .Example
   # Get all cards on a private board
   $auth = Login-Trello -Token xyz -Key -abc
   Get-TrelloCardsInBoard -BoardId fDsPBXFt -Auth $auth
#>
function Get-TrelloCardsInBoard
{
	param($BoardId)
	return (Invoke-RestMethod ("https://api.trello.com/1/boards/" + $BoardId + "?lists=open&cards=open")).cards
}