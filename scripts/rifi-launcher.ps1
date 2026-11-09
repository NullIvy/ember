param([switch]$Full)
[Console]::OutputEncoding=[Text.Encoding]::UTF8
$e=[char]27;$R="$e[0m";$Bd="$e[1m"
function fg($r,$g,$b){"$e[38;2;${r};${g};${b}m"}
$A=fg 217 119 87; $B=fg 120 78 62; $W1=fg 230 226 216; $G1=fg 150 140 128; $G2=fg 92 84 76
$W=72;$RC=$W+2
$exe="$env:USERPROFILE\.local\bin\claude.exe";$cfg="$env:USERPROFILE\.claude\rifi-last.json"
function row($s=""){Write-Host "$B│$R$s$e[${RC}G$B│$R$e[K"}
function edge($lt,$rt){Write-Host "$B$lt$('─'*$W)$e[${RC}G$rt$e[0m$e[K"}
function kv($k,$v,$x=0){$col=$RC-2-$v.Length-$x;row "  $G1$k$R$e[${col}G$W1$v$R"}
$last=if(Test-Path $cfg){Get-Content $cfg -Raw|ConvertFrom-Json}else{$null}
if(-not $last){$last=[pscustomobject]@{model='opus';effort='medium';hasEffort=$null}}
$models='opus','sonnet','haiku';$efforts='low','medium','high','xhigh','max'
$dir=(Get-Location).Path;$folder=Split-Path $dir -Leaf
$br=git branch --show-current 2>$null; $chg=@(git status --porcelain 2>$null).Count

Write-Host ""
Write-Host "$B┌─$R$W1 CLAUDE CODE $G2//$W1 OPERATOR FILE $R$B$('─'*$W)$e[$($RC-7)G$G1 ■ ■ $A■ $B┐$R$e[K"
row
row "   $A▐▛███▜▌$R      $Bd$W1█▀█ █ █▀▀ █$R   $A天尊$R"
row "  $A▝▜█████▛▘$R     $Bd$W1█▀▄ █ █▀  █$R   ${G1}operator file #01$R"
row "    $A▘▘ ▝▝$R       $Bd$W1▀ ▀ ▀ ▀   ▀$R   $A●$R ${W1}online$R"
row
edge "├" "┤"
kv "NAME" "RIFI 天尊" 2
kv "FUNCTION" "PRESALES / DEVELOPER / STUDENT"
kv "WORKSPACE" $folder
if($br){kv "BRANCH" "$br · $chg changed"}
kv "LAST SESSION" "$($last.model) / $($last.effort)"
edge "├" "┤"
row "  ${G1}CAPABILITIES$R"
$it="Jelasin kode bikin bengong","Benerin error, paste aja","Bikin fitur & script baru","Git: commit, diff, README","Tugas kuliah + presentasi","Debug deploy & database"
for($i=0;$i -lt 6;$i+=2){row ("  $A{0:D2}$R $W1{1}$R$e[39G$A{2:D2}$R $W1{3}$R" -f ($i+1),$it[$i],($i+2),$it[$i+1])}
edge "├" "┤"
function opts($list,$cur){($list|%{$n=[array]::IndexOf($list,$_)+1;if($_ -eq $cur){"$A$n$R $Bd$W1$_$R"}else{"$G2$n$R $G1$_$R"}}) -join "  "}
row "  ${G1}MODEL $R   $(opts $models $last.model)"
row "  ${G1}EFFORT$R   $(opts $efforts $last.effort)"
row "  ${G2}opus pinter · sonnet cepet · haiku kilat$R$e[$($RC-7)G$W1$(Get-Date -f HH:mm)$R"
edge "└" "┘"
Write-Host ""
Write-Host -NoNewline "  $A›$R ${G1}ketik 2 angka (mis. 31) · enter = lanjut · auto 3s$R   "

$buf='';$sw=[Diagnostics.Stopwatch]::StartNew()
while($true){
  if([Console]::KeyAvailable){
    $k=[Console]::ReadKey($true)
    if($k.Key -eq 'Enter'){break}
    if($k.Key -eq 'Backspace' -and $buf){$buf=$buf.Substring(0,$buf.Length-1);Write-Host -NoNewline "`b `b";continue}
    if($k.KeyChar -match '\d' -and $buf.Length -lt 2){$buf+=$k.KeyChar;Write-Host -NoNewline "$A$($k.KeyChar)$R";$sw=$null}
    if($buf.Length -eq 2){Start-Sleep -Milliseconds 150;break}
  } elseif($sw -and $sw.ElapsedMilliseconds -gt 3000){break}
  Start-Sleep -Milliseconds 30
}
$model=$last.model;$effort=$last.effort
if($buf.Length -ge 1){$n=[int]"$($buf[0])";if($n -ge 1 -and $n -le 3){$model=$models[$n-1]}}
if($buf.Length -ge 2){$n=[int]"$($buf[1])";if($n -ge 1 -and $n -le 5){$effort=$efforts[$n-1]}}
if($null -eq $last.hasEffort){$last.hasEffort=((& $exe --help 2>$null|Out-String) -match '--effort')}
[pscustomobject]@{model=$model;effort=$effort;hasEffort=$last.hasEffort}|ConvertTo-Json|Set-Content $cfg -Encoding UTF8

Write-Host ""; Write-Host ""
Write-Host -NoNewline "  $A▶$R ${W1}booting$R $A$model$R $G2/$R $A$effort$R  "
1..20|%{Write-Host -NoNewline "$B▮$R";Start-Sleep -Milliseconds 10}; Write-Host " $W1 ready$R"; Write-Host ""

Remove-Item "$env:USERPROFILE\.claude\rifi-timer.json" -ErrorAction SilentlyContinue
$ax=@('--model',$model); if($last.hasEffort){$ax+=@('--effort',$effort)}
$pal=[ordered]@{0='14/14/13';1='d9/64/5a';2='a3/b1/8a';3='e8/b0/6a';4='d9/77/57';5='c7/7d/5f';6='e0/c9/a6';7='e6/e2/d8';8='6b/5a/4e';9='e8/8f/6f';10='b8/c4/a0';11='f0/c4/8a';12='e8/8f/6f';13='d9/96/7c';14='ec/dc/c0';15='fa/f9/f5'}
$osc=($pal.GetEnumerator()|%{"$e]4;$($_.Key);rgb:$($_.Value)$e\"}) -join ''
[Console]::Write($osc + "$e]10;rgb:e6/e2/d8$e\$e]12;rgb:d9/77/57$e\")
try { & $exe @ax } finally { [Console]::Write("$e]104$e\$e]110$e\$e]112$e\") }


