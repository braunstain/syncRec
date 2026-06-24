param(
    [Parameter(Mandatory=$true)]
    [string]$Prefix,

    [Parameter(Mandatory=$true)]
    [int]$Duration
)

$pi1        = "mic1@192.168.0.100"
$pi2        = "mic1@192.168.0.101"
$script     = "/home/mic1/record_precise.py"
$resultsDir = ".\test_results"
$leadTime   = 5   # seconds until recording starts

function Get-HostFromSshTarget($target) {
    return ($target -split "@")[-1]
}

function Fail($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

function Check-Pi($target) {
    $hostOnly = Get-HostFromSshTarget $target

    Write-Host "Checking $target..."

    if (-not (Test-Connection -ComputerName $hostOnly -Count 1 -Quiet)) {
        Fail "$target is not reachable by ping"
    }

    ssh $target "echo ok" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Fail "SSH failed for $target"
    }

    ssh $target "test -f $script"
    if ($LASTEXITCODE -ne 0) {
        Fail "Recording script not found on ${target}: $script"
    }
}

if ($Duration -le 0) {
    Fail "Duration must be positive"
}

if ([string]::IsNullOrWhiteSpace($Prefix)) {
    Fail "Prefix is required"
}

$Prefix = $Prefix -replace '[^\w\-]', '_'

New-Item -ItemType Directory -Force $resultsDir | Out-Null

Check-Pi $pi1
Check-Pi $pi2

$currentTime = [double](ssh $pi1 "python3 -c 'import time; print(time.time())'")
$startTime   = $currentTime + $leadTime


$timestamp = Get-Date -Format "ddMMyyyy_HHmmss"
$name1 = "${Prefix}_${timestamp}_pi100"
$name2 = "${Prefix}_${timestamp}_pi101"

Write-Host ""
Write-Host "Recording:"
Write-Host "  Prefix:   $Prefix"
Write-Host "  Duration: $Duration seconds"
Write-Host "  Start:    $startTime"
Write-Host "  Files:    $name1.wav, $name2.wav"
Write-Host "Play sound after recording starts."

$cmd1 = "python3 $script --start-time $startTime --duration $Duration --output /home/mic1/$name1.wav"
$cmd2 = "python3 $script --start-time $startTime --duration $Duration --output /home/mic1/$name2.wav"

$p1 = Start-Process ssh -ArgumentList @($pi1, $cmd1) -NoNewWindow -PassThru
$p2 = Start-Process ssh -ArgumentList @($pi2, $cmd2) -NoNewWindow -PassThru

$p1.WaitForExit()
$p2.WaitForExit()


Write-Host ""
Write-Host "Copying WAVs..."

scp "${pi1}:/home/mic1/${name1}.wav" "$resultsDir\"
if ($LASTEXITCODE -ne 0) { Fail "Failed copying from $pi1" }

scp "${pi2}:/home/mic1/${name2}.wav" "$resultsDir\"
if ($LASTEXITCODE -ne 0) { Fail "Failed copying from $pi2" }

Write-Host ""
Write-Host "Done. Results saved in $resultsDir"