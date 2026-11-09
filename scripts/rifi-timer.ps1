param($mode)
$f="$env:USERPROFILE\.claude\rifi-timer.json"
$t=if(Test-Path $f){Get-Content $f -Raw|ConvertFrom-Json}else{[pscustomobject]@{start=0;last=0}}
$now=[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
if($mode -eq 'start'){$t.start=$now}elseif($t.start -gt 0){$t.last=$now-$t.start;$t.start=0}
$t|ConvertTo-Json|Set-Content $f
