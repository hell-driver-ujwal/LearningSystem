param([string]$Server='(LocalDB)\MSSQLLocalDB')
$ErrorActionPreference='Stop'
# Build the current schema/seed unchanged, but never execute its destructive old-database lifecycle.
$finalRoot=Split-Path $PSScriptRoot -Parent
$finalSource=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'CreateDatabase.sql') -Raw
$finalStart="USE [LearningSystem];`r`nGO`r`n"
if(!$finalSource.Contains($finalStart)){$finalStart="USE [LearningSystem];`nGO`n"}
$finalFrom=$finalSource.IndexOf($finalStart,[StringComparison]::Ordinal)
$finalTo=$finalSource.LastIndexOf('USE [master];',[StringComparison]::Ordinal)
if($finalFrom -lt 0 -or $finalTo -le $finalFrom){throw 'Unexpected script layout. Review before executing.'}
$finalBody=$finalSource.Substring($finalFrom+$finalStart.Length,$finalTo-$finalFrom-$finalStart.Length)
if($finalBody -match '(?i)DROP\s+DATABASE|sp_detach_db|ALTER\s+DATABASE'){throw 'Unexpected database lifecycle in schema/seed section.'}
$finalMdf=Join-Path $finalRoot 'App_Data\LearningSystemFinal.mdf'
$finalLdf=Join-Path $finalRoot 'App_Data\LearningSystemFinal_log.ldf'
if((Test-Path -LiteralPath $finalMdf) -or (Test-Path -LiteralPath $finalLdf)){throw 'Final database files already exist. Nothing will be overwritten.'}
$finalMdfLiteral=$finalMdf.Replace("'","''")
$finalLdfLiteral=$finalLdf.Replace("'","''")
$finalHeader=@"
:on error exit
USE [master];
GO
IF DB_ID(N'LearningSystemFinal') IS NOT NULL THROW 51000, 'LearningSystemFinal already exists. Nothing was overwritten.', 1;
CREATE DATABASE [LearningSystemFinal] ON PRIMARY
(NAME=N'LearningSystemFinal',FILENAME=N'$finalMdfLiteral')
LOG ON (NAME=N'LearningSystemFinal_log',FILENAME=N'$finalLdfLiteral');
GO
USE [LearningSystemFinal];
GO
"@
$finalSql=Join-Path $env:TEMP ('LearningSystemFinal-'+[guid]::NewGuid().ToString('N')+'.sql')
Set-Content -LiteralPath $finalSql -Value ($finalHeader+"`r`n"+$finalBody) -Encoding utf8
Write-Output ('Source SHA256: '+(Get-FileHash -LiteralPath (Join-Path $PSScriptRoot 'CreateDatabase.sql') -Algorithm SHA256).Hash)
Write-Output 'Creating only LearningSystemFinal; existing LearningSystem files/catalog are not changed.'
& sqlcmd -S $Server -E -b -l 15 -f 65001 -i $finalSql
if($LASTEXITCODE -ne 0){throw 'Final creation failed. Connection has not been switched. Inspect the new database; old database remains untouched.'}
Write-Output 'LearningSystemFinal created and kept attached. Review schema/seed checks before switching Web.config.'
