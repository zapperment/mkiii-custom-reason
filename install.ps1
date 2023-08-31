Set-StrictMode -Version Latest

function Write-Error {
    Write-Host -ForegroundColor Red $args[0]
}

function Write-Success {
    Write-Host -ForegroundColor Green $args[0]
}

$REMOTE_DIR = "C:\ProgramData\Propellerhead Software\Remote"

# Set VENDOR variable
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

luabundler bundle "${CODECS_DIST_DIR}\SL MkIII.lua" -p "${SRC_DIR}\?.lua" -o "${CODECS_DIST_DIR}\SL MkIII.lua"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error bundling the Lua script. Did you install luabundler? Please refer to the readme file for instructions."
    exit 1
}

luabundler bundle "${CODECS_DIST_DIR}\SL MkIII Mixer.lua" -p "${SRC_DIR}\?.lua" -o "${CODECS_DIST_DIR}\SL MkIII Mixer.lua"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error bundling the Lua script. Did you install luabundler? Please refer to the readme file for instructions."
    exit 1
}

Write-Host "Copying files to Reason remote dirs"

Copy-Item -Path "${CODECS_DIST_DIR}\*" -Destination "${CODECS_TARGET_DIR}\"
Copy-Item -Path "${MAPS_DIST_DIR}\*" -Destination "${MAPS_TARGET_DIR}\"

Write-Success "Installation successful!"
