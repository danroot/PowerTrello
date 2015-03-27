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
   Login-Trello -Token xyz -Key -abc
   Get-TrelloCardsInBoard -BoardId fDsPBXFt
#>
function Get-TrelloCardsInBoard
{
	param($BoardId)
	return (Invoke-RestMethod ("https://api.trello.com/1/boards/" + $BoardId + "?lists=open&cards=open")).cards
}