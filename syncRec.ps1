$pi1 = "mic1@192.168.0.100"
$pi2 = "mic1@192.168.0.101"

$currentTime = [double](ssh mic1@192.168.0.100 "python3 -c 'import time; print(time.time())'")
$startTime = $currentTime + 5

$out_name = "test1_new"

if($args){
    $out_name = $args
}
 

Write-Host "Scheduled start time = $startTime"

$remoteCmd = @"
python /home/mic1/record.py --start-time $startTime --duration 10 --output /home/mic1/$out_name.wav
"@

$p1 = Start-Process ssh -ArgumentList @($pi1, $remoteCmd) -NoNewWindow -PassThru -RedirectStandardOutput "pi1.txt" -RedirectStandardError "pi1.err"
$p2 = Start-Process ssh -ArgumentList @($pi2, $remoteCmd) -NoNewWindow -PassThru -RedirectStandardOutput "pi2.txt" -RedirectStandardError "pi2.err"
#$job1 = Start-Job {param($h,$c) ssh $h $c } -ArgumentList $pi1, $remoteCmd
#$job2 = Start-Job {param($h,$c) ssh $h $c } -ArgumentList $pi2, $remoteCmd

#$result1 = Receive-Job -Wait $job1
#$result2 = Receive-Job -Wait $job2

$p1.WaitForExit()
$p2.WaitForExit()

"Pi1:"
Get-Content .\pi1.txt
Get-Content .\pi1.err
"Pi2:"
Get-Content .\pi1.txt
Get-Content .\pi1.err


#Write-Host "Pi1 Time : $result1"
#Write-Host "Pi2 Time : $result2"




