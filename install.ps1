Set-StrictMode -Version Latest

function Write-Error {
    Write-Host -ForegroundColor Red $args[0]
}

function Write-Success {
    Write-Host -ForegroundColor Green $args[0]
}

$DEBUG_MODE = $false

if ($args[0] -eq "debug") {
    Write-Host "Debug mode: deploying codec with extra output port for debug messages"
    $DEBUG_MODE = $true
}

$UMPF_MODE = $false

if ($args[0] -eq "umpf") {
    Write-Host "Umpf mode: deploying codec with extra functionality for copying Umpf settings to Combinators (includes debugging)"
    $UMPF_MODE = $true
}

$REMOTE_DIR = "C:\ProgramData\Propellerhead Software\Remote"

$VENDOR = "Novation"

if (-not (Test-Path $REMOTE_DIR)) {
    Write-Error "Error – no Reason!"
    Write-Host "Reason does not seem to be installed on this system – directory not found:"
    Write-Host $REMOTE_DIR
    exit 1
} else {
    Write-Host "Reason is installed, using remote dir:"
    Write-Host $REMOTE_DIR
}

$CODECS_TARGET_DIR = "${REMOTE_DIR}\Codecs\Lua Codecs\${VENDOR}"

if (-not (Test-Path $CODECS_TARGET_DIR)) {
    Write-Host "Creating codecs dir:"
    Write-Host $CODECS_TARGET_DIR
    New-Item -Path $CODECS_TARGET_DIR -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Using existing codecs dir:"
    Write-Host $CODECS_TARGET_DIR
}

$MAPS_TARGET_DIR = "${REMOTE_DIR}\Maps\${VENDOR}"

if (-not (Test-Path $MAPS_TARGET_DIR)) {
    Write-Host "Creating maps dir:"
    Write-Host $MAPS_TARGET_DIR
    New-Item -Path $MAPS_TARGET_DIR -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Using existing maps dir:"
    Write-Host $MAPS_TARGET_DIR
}

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DIST_DIR = "${SCRIPT_DIR}\dist"
$SRC_DIR = "${SCRIPT_DIR}\src"
$CODECS_SOURCE_DIR = "${SRC_DIR}\codecs"
$MAPS_SOURCE_DIR = "${SRC_DIR}\maps"
$CODECS_DIST_DIR = "${DIST_DIR}\codecs"
$MAPS_DIST_DIR = "${DIST_DIR}\maps"

Write-Host "Setting up dist dir ${DIST_DIR}"
Remove-Item -Path $DIST_DIR -Recurse -ErrorAction SilentlyContinue
New-Item -Path $DIST_DIR -ItemType Directory | Out-Null

Write-Host "Copying files to dist dir"

Copy-Item -Path $CODECS_SOURCE_DIR -Destination "${DIST_DIR}\" -Recurse
Copy-Item -Path $MAPS_SOURCE_DIR -Destination "${DIST_DIR}\" -Recurse

Write-Host "Bundling Lua code"

$filePath = "${CODECS_DIST_DIR}\SL MkIII.lua"

luabundler bundle $filePath -p "?.lua" -o $filePath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error bundling the Lua script. Did you install luabundler? Please refer to the readme file for instructions."
    exit 1
}

("ENV_UMPF_TO_COMBI_MODE = $UMPF_MODE", (Get-Content -Path $filePath)) | Set-Content -Path $filePath

luabundler bundle "${CODECS_DIST_DIR}\SL MkIII Mixer.lua" -p "?.lua" -o "${CODECS_DIST_DIR}\SL MkIII Mixer.lua"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error bundling the Lua script. Did you install luabundler? Please refer to the readme file for instructions."
    exit 1
}

if ($DEBUG_MODE -or $UMPF_MODE) {
    Write-Host "Using debug versions of .luacodec files, replacing production versions"
    Move-Item -Path "${CODECS_DIST_DIR}\SL MkIII.debug.luacodec" -Destination "${CODECS_DIST_DIR}\SL MkIII.luacodec" -Force
    Move-Item -Path "${CODECS_DIST_DIR}\SL MkIII Mixer.debug.luacodec" -Destination "${CODECS_DIST_DIR}\SL MkIII Mixer.luacodec" -Force
} else {
    Write-Host "Using production versions of .luacodec files, removing debug versions"
    Remove-Item -Path "${CODECS_DIST_DIR}\SL MkIII.debug.luacodec"
    Remove-Item -Path "${CODECS_DIST_DIR}\SL MkIII Mixer.debug.luacodec"
}


Write-Host "Copying files to Reason remote dirs"

Copy-Item -Path "${CODECS_DIST_DIR}\*" -Destination "${CODECS_TARGET_DIR}\"
Copy-Item -Path "${MAPS_DIST_DIR}\*" -Destination "${MAPS_TARGET_DIR}\"

Write-Success "Installation successful!"
