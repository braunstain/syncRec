$pi1        = "mic1@192.168.0.100"
$pi2        = "mic1@192.168.0.101"
$numTests   = 10
$duration   = 10
$script     = "/home/mic1/record_precise.py"
$resultsDir = ".\test_results"

New-Item -ItemType Directory -Force $resultsDir | Out-Null

for ($i = 1; $i -le $numTests; $i++) {
    $name1 = "test${i}_pi100"
    $name2 = "test${i}_pi101"

    Write-Host ""
    Write-Host "=== Test $i / $numTests ==="

    $currentTime = [double](ssh $pi1 "python3 -c 'import time; print(time.time())'")
    $startTime   = $currentTime + 5

    Write-Host "Start time: $startTime Play sound in about 10 seconds"

    $cmd1 = "python $script --start-time $startTime --duration $duration --output /home/mic1/$name1.wav"
    $cmd2 = "python $script --start-time $startTime --duration $duration --output /home/mic1/$name2.wav"


    $p1 = Start-Process ssh -ArgumentList @($pi1, $cmd1) -NoNewWindow -PassThru
    $p2 = Start-Process ssh -ArgumentList @($pi2, $cmd2) -NoNewWindow -PassThru

    $p1.WaitForExit()
    $p2.WaitForExit()

    Write-Host "Copying WAVs..."
    scp "${pi1}:/home/mic1/${name1}.wav" "$resultsDir\"
    scp "${pi2}:/home/mic1/${name2}.wav" "$resultsDir\"
    Write-Host "Saved $name1.wav and $name2.wav"
}

Write-Host ""
Write-Host "All $numTests tests complete. Results in $resultsDir"
