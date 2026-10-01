param([string]$ConnectionString, [string]$CompilerPath)
$ErrorActionPreference='Stop'
$demoRoot=Split-Path $PSScriptRoot -Parent
if(!$ConnectionString){
    [xml]$demoWeb=Get-Content (Join-Path $demoRoot 'Web.config')
    $ConnectionString=$demoWeb.configuration.connectionStrings.add.connectionString.Replace('|DataDirectory|',(Join-Path $demoRoot 'App_Data'))
}
if(!$CompilerPath){
    $demoVs=Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
    $CompilerPath=& $demoVs -latest -products '*' -find 'MSBuild\**\Bin\Roslyn\csc.exe' | Select-Object -First 1
}
if(!(Test-Path -LiteralPath $CompilerPath)){throw 'Pass -CompilerPath with the installed Visual Studio Roslyn csc.exe path.'}
$demoManifest=Get-Content (Join-Path $demoRoot 'docs\presentation-manifest.json') -Raw | ConvertFrom-Json
foreach($demoCourse in $demoManifest){
    foreach($demoAsset in @("Uploads\Images\$($demoCourse.image)","Uploads\Documents\$($demoCourse.pdf)")){
        if(!(Test-Path -LiteralPath (Join-Path $demoRoot $demoAsset))){throw "Required local asset missing: $demoAsset"}
    }
}
$demoTool=Join-Path $env:TEMP ('LearningSystemPresentation-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $demoTool | Out-Null
$demoExe=Join-Path $demoTool 'PresentationSeed.exe'
$demoRefs=@('System','System.Core','System.Data','System.Web','System.Web.Extensions','System.Configuration','System.Xml','System.Drawing') | ForEach-Object { '/r:'+ (Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\$_.dll") }
$demoSources=@((Join-Path $PSScriptRoot 'SeedPresentationHistory.cs'))+@(Get-ChildItem (Join-Path $demoRoot 'Helpers') -Filter *.cs | ForEach-Object FullName)
& $CompilerPath /nologo /target:exe "/out:$demoExe" $demoRefs $demoSources
if($LASTEXITCODE -ne 0){throw 'Fixture tool compilation failed; no seed was executed.'}
$demoXml=New-Object System.Xml.XmlDocument
$demoXml.LoadXml('<configuration><connectionStrings><add name="LearningSystemDb" providerName="System.Data.SqlClient" /></connectionStrings></configuration>')
$demoXml.configuration.connectionStrings.add.SetAttribute('connectionString',$ConnectionString)
$demoXml.Save($demoExe+'.config')
try {
    & $demoExe (Join-Path $PSScriptRoot 'SeedPresentationDemo.sql')
    if($LASTEXITCODE -ne 0){throw 'Fixture seeding stopped. Review the error; existing data is not rebuilt.'}
} finally {
    # This directory contains only this run's console tool; never application uploads or databases.
    Remove-Item -LiteralPath ($demoExe+'.config') -Force -ErrorAction SilentlyContinue
}
