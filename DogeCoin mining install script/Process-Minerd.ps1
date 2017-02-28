[CmdletBinding()]param(
    [switch]$start,
    [switch]$stop
)

# minerd --url=stratum+tcp://dogepool.pw:3334 --userpass=hakunamakuba.dogecoin1:kOY7xtpE6yB4g3bw-NC

if($start){
	minerd -t 1 --url=stratum+tcp://dogepool.pw:3334 --userpass=hakunamakuba.dogecoin1:kOY7xtpE6yB4g3bw-NC
}elseif($stop){
	Stop-Process -Name minerd
}