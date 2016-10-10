<#------------------------------------------------------------------------------
    Jason McClary
    mcclarj@mail.amc.edu
    07 Oct 2016
    10 Oct 2016 - added error checking and logging

    
    Description:
    Rename OR_EDM_Recon.xlsx to OR_EDM_Recon_YYYY-MM-DD.xlsx
    
    Arguments:
    None
        
    Tasks:
    - Rename the file


--------------------------------------------------------------------------------
                                CONSTANTS
------------------------------------------------------------------------------#>
#set-variable pathToFile -option Constant -value "NewTest\"
set-variable pathToFile -option Constant -value "D:\File_Shares\Recon\PICIS\"
set-variable fileToRename -option Constant -value "OR_EDM_Recon"
set-variable extensionOfFile -option Constant -value "xlsx"
set-variable errorLogName -option Constant -value "ReconRename.log"

<#------------------------------------------------------------------------------
                                Script Variables
------------------------------------------------------------------------------#>
$ErrorActionPreference = "Stop"
#Date/ Time Stamp
$dtStamp = $(Get-Date -UFormat "%Y") + "-" + $(Get-Date -UFormat "%m") + "-" +$(Get-Date -UFormat "%d")

<#------------------------------------------------------------------------------
                                FUNCTIONS
------------------------------------------------------------------------------#>
    
<#------------------------------------------------------------------------------
                                    MAIN
------------------------------------------------------------------------------#>
$logDate = Get-Date -Format d
$logTime = Get-Date -Format t

TRY {
    Rename-Item -Path "$pathToFile$fileToRename.$extensionOfFile" -NewName "$($fileToRename)_$($dtStamp).$($extensionOfFile)"
    "$($logDate) $($logTime): Success - File renamed" >> "$pathToFile$errorLogName" #Log successes also comment out to turn this off
}
CATCH {
    $ErrorMessage = $_.Exception.Message
    "$($logDate) $($logTime): $ErrorMessage" >> "$pathToFile$errorLogName"
}