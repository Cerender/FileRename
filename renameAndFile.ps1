<#------------------------------------------------------------------------------
    Jason McClary
    mcclarj@mail.amc.edu
    06 Jul 2016 - Original Fax Script
    22 Nov 2016 - Modified for server report Folder
    06 Dec 2016 - Modified to use parameters



    Description:
    Append date to file name and move files from main folder to a monthly folder

    Arguments:
    loc     - File Location (to rename and/or sort)
    file    - File name with extension that you want to append date to
            - Default is NA to not rename a file
    log     - Error log file name - defaults to Errors.log
    days    - Number of days to keep before filing to a monthly folder
            - Default is NA to not organize a folder
    year    - True or False - adds year to appended date (YYYY-MM-DD vs MM-DD)
            - Default is True (YYYY-MM-DD)
    keep    - During the raname keep a copy of original file or not


    Tasks:
    - Append date to document
    - Create monthly folder if not there yet
    - Name folder as Year-Month (1993-08 for August 1993)
    - Move files from that month in to that folder
    - Only file documents older then specified days
------------------------------------------------------------------------------#>

<#
.SYNOPSIS
Append date to a file name and move files from main folder to a monthly folder.

.DESCRIPTION
Append current date to a file name and move files from main folder to a monthly folder.
Files are filed based off of file modified date and not appended date.

Parameters:
  -loc  - Path to the file
        - Default is current path

  -file - Full file name with extension. If no extension is provided no file will be renamed.
        - Default is to not append to any file

  -log  - Error log name
        - Default is Errors.log

  -days - Number of days to keep files outside of monthly folders.
        - Files older then the number of days specified are filed into monthly folders.
        - Default is to not file files into monthly folders

  -year - True to use year in file name or False to only use month and day.
        - Possible responses = Yes, no, true, false, 1, 0, y, n, t, or f.
        - Default is to use year (YYYY-MM-DD)

  -keep - During the raname keep a copy of original file or not
        - Possible responses = Yes, no, true, false, 1, 0, y, n, t, or f.
        - Default is to keep the original file

.PARAMETER loc
Path to the file. 
- Default is current path.

.PARAMETER file
Full file name with extension.  If no extension is provided no file will be renamed.
- Default is to not append to any file.

.PARAMETER log
Error log name.
- Default is Errors.log.

.PARAMETER days
Number of days to keep files outside of monthly folders.  Files older then the number of days specified are filed into monthly folders.
- Default is to not file files into monthly folders

.PARAMETER year
Determine if year is to beincuded in the file name. 
Possible responses = Yes, no, true, false, 1, 0, y, n, t, or f.
- Default is to use year (YYYY-MM-DD)

.PARAMETER keep
During the raname keep a copy of original file or not
Possible responses = Yes, no, true, false, 1, 0, y, n, t, or f.
- Default is to keep the original file

.EXAMPLE
Rename the Document Reconciliation.csv to Document Reconciliation-YYYY-MM-DD.csv and file files older then 5 days
renameAndFile.ps1 -loc 'D:\File_Shares\Recon\Varian' -file 'Document Reconciliation.csv' -days 5

.EXAMPLE
Rename the EDIS_MRECD_Daily.txt to EDIS_MRECD_Daily-MM-DD.txt and file files older then 5 days
renameAndFile.ps1 -loc 'D:\ReconWork\Parsed-MRKey' -file 'EDIS_MRECD_Daily.txt' -days 5 -year FALSE
#>

<#------------------------------------------------------------------------------
                                PARAMETERS
------------------------------------------------------------------------------#>
Param (
    [string]$loc=$(split-path -parent $MyInvocation.MyCommand.Definition),
    [string]$file='NA',
    [string]$log='Errors.log',
    [string]$days='NA',
    [string]$year='TRUE',
    [string]$keep='TRUE'
)


<#------------------------------------------------------------------------------
                                Script Variables
------------------------------------------------------------------------------#>
$ErrorActionPreference = "Stop"
#Date/ Time Stamp YYYY-MM-DD or MM-DD
SWITCH ($year){
    no {[bool]$year=$FALSE; break}
    n {[bool]$year=$FALSE; break}
    false {[bool]$year=$FALSE; break}
    f {[bool]$year=$FALSE; break}
    0 {[bool]$year=$FALSE; break}
    default {[bool]$year=$TRUE; break}
}

IF ($year){
    $dtStamp = $(Get-Date -UFormat "%Y") + "-" + $(Get-Date -UFormat "%m") + "-" +$(Get-Date -UFormat "%d")
}ELSE {
    $dtStamp = $(Get-Date -UFormat "%m") + "-" +$(Get-Date -UFormat "%d")
}

$DestinationDir = "1993-08"

$logDate = Get-Date -Format d
$logTime = Get-Date -Format t

SWITCH ($keep){
    no {[bool]$keep=$FALSE; break}
    n {[bool]$keep=$FALSE; break}
    false {[bool]$keep=$FALSE; break}
    f {[bool]$keep=$FALSE; break}
    0 {[bool]$keep=$FALSE; break}
    default {[bool]$keep=$TRUE; break}
}


<#------------------------------------------------------------------------------
                                FUNCTIONS
------------------------------------------------------------------------------#>



<#------------------------------------------------------------------------------
                                    MAIN
------------------------------------------------------------------------------#>
IF ($file -ne "NA"){
    $ext = [IO.Path]::GetExtension($file)
    $file = [System.IO.Path]::GetFileNameWithoutExtension($file)
    TRY {
        IF ($keep){
            Copy-Item -Path "$loc\$file$ext" -Destination "$loc\$($file)-$($dtStamp)$($ext)"
        }ELSE {
            Rename-Item -Path "$loc\$file$ext" -NewName "$($file)-$($dtStamp)$($ext)"
        }
        
        #"$($logDate) $($logTime): Success - File renamed" >> "$loc$log" #Log successes also comment out to turn this off
    }
    CATCH {
        $ErrorMessage = $_.Exception.Message
        IF (!(Test-Path "$loc\Logs")) {
                    New-Item "$loc\Logs" -type directory
                }
        "$($logDate) $($logTime): $ErrorMessage" >> "$loc\Logs\$log"
    }
}



IF ($days -ne "NA"){
    # Get all the files in the folder
    $files = get-childitem -File $loc

    IF ($files.count -gt 0) {
        FOREACH ($i in $files) {
            # For each file older then X days...
            IF ($i.LastWriteTime -lt (Get-Date).adddays(-$days).date) {

                # Use that files date to make a matching folder name (ex. 1993-08)
                $DestinationDir = $loc + "\$($i.LastWriteTime.year)" + "-"
                $month = "$($i.LastWriteTime.month)"
                # Add a leading zero to the month if needed
                IF ($month.length -lt 2) {
                    $month = "0" + $month
                }
                $DestinationDir = $DestinationDir + $month

                # Now see if there is a folder for that Year/Month if not make it
                IF (!(Test-Path $DestinationDir)) {
                    New-Item $DestinationDir -type directory
                }

                $DestinationFile = $DestinationDir + "\" + $i.Name

                # Move the file to that folder
                Move-Item $i.fullname $DestinationDir
            }
        }
    }
}