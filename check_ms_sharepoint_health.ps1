# Script name:		check_ms_sharepoint_health.ps1
# Version:			v1.02.150906
# Created on:		01/02/2014
# Author:			D'Haese Willem, De Clerck John
# Purpose:			Checks MS SharePoint farm health
# Recent History:
#	17/03/14 => Creation date
#	18/03/14 => Changed output
#	06/09/15 => Cleanup for release
# Copyright:
#	This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#	by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#	in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#	PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#	License along with this program.  If not, see <http://www.gnu.org/licenses/>.

if ($PSVersionTable) {$Host.Runspace.ThreadOptions = 'ReuseThread'}

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$Status = 3
$ReportsList = [Microsoft.SharePoint.Administration.Health.SPHealthReportsList]::Local
$FormUrl = '{0}{1}?id=' -f $ReportList.ParentWeb.Url, $ReportsList.Forms.List.DefaultDisplayFormUrl

$ReportProblems = $ReportsList.Items | Where-Object {$_['Severity'] -ne '4 - Success'} | ForEach-Object {
    New-Object PSObject -Property @{
        Url = "<a href='$FormUrl$($_.ID)'>$($_['Title'])</a>"
        Severity = $_['Category']
        Explanation = $_['Explanation']
        Modified = $_['Modified']
        FailingServers = $_['Failing Servers']
        FailingServices = $_['Failing Services']
        Remedy = $_['Remedy']
    }
} 

if ($ReportProblems.count -gt '0') {
	Write-Host 'SharePoint Health Analyzer detected problems: '
	foreach($ReportProblem in $ReportProblems) {
		if ($ReportProblem.FailingServers) {
			$ServerString = ' on ' + $ReportProblem.FailingServers -replace "(?m)[`n`r]+",''
		}
		else {
			$ServerString = ''
		}
		Write-Host "Service $($ReportProblem.FailingServices)$ServerString, modified $($ReportProblem.Modified)"
	}
	$Status = 2
}
else {
	Write-Host 'No SharePoint health problems detected.'
	$Status = 0
}

exit $Status
