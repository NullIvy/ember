$d=[Console]::In.ReadToEnd()|ConvertFrom-Json
$e=[char]27;$R="$e[0m";$Bd="$e[1m"
$A="$e[38;2;217;119;87m";$W1="$e[38;2;240;238;230m";$G1="$e[38;2;140;138;132m";$G2="$e[38;2;85;85;82m"
function fmt($ms){$s=[int]([double]$ms/1000);if($s -lt 60){"${s}s"}else{"{0}m {1:D2}s" -f [math]::Floor($s/60),($s%60)}}
$cd="$env:USERPROFILE\.claude"
$t=if(Test-Path "$cd\rifi-timer.json"){Get-Content "$cd\rifi-timer.json" -Raw|ConvertFrom-Json}
$lc=if(Test-Path "$cd\rifi-last.json"){Get-Content "$cd\rifi-last.json" -Raw|ConvertFrom-Json}
$model=$d.model.display_name; if(-not $model){$model=$lc.model}
$dir=$d.workspace.current_dir; if(-not $dir){$dir=$d.cwd}; if(-not $dir){$dir=(Get-Location).Path}
$folder=Split-Path $dir -Leaf
$br=git -C $dir branch --show-current 2>$null
$last=if($t -and $t.last){fmt $t.last}else{'—'}

$l1="$A✻$R $Bd${W1}rifi$R ${G1}天尊$R    $W1$("$model".ToLower())$R $G2·$R $A$($lc.effort)$R    $G1~/$folder$R"
if($br){$l1+="  $G2·$R  $G1$br$R"}
$l2="$A◷$R $W1$last$R    ${G2}session$R $G1$(fmt $d.cost.total_duration_ms)$R    $G1+$([int]$d.cost.total_lines_added) −$([int]$d.cost.total_lines_removed)$R"
$p=$d.context_window.used_percentage
if($p){$n=[int][math]::Round([double]$p/10); $l2+="    ${G2}ctx$R $A$('●'*$n)$G2$('·'*(10-$n))$R $G1$([int]$p)%$R"}

$b=[Text.Encoding]::UTF8.GetBytes("$l1`n$l2");$o=[Console]::OpenStandardOutput();$o.Write($b,0,$b.Length)
