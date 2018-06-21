<#

.SYNOPSIS

Make jittery HTTP beacons.

.DESCRIPTION

This script makes repeated, possibly jittery HTTP requests to a domain.  Each request will be of the form
http://domain/COUNTER.txt, where COUNTER is an incrementing decimal number.

.EXAMPLE

.\psbeacon.ps1 -interval 10 -jitter .3 -count 20 -domain https://example.org

#>

param (
    # Average time between beacons in seconds
    [float]  $interval = 1,
    # Jitter to add to the beacon interval, as a value between 0 and 1
    [float]  $jitter   = .25,
    # Number of beacons
    [float]  $count    = 10,
    # Domain and protocol (e.g. http://example.com) to which to beacon
    [string] $domain
)

# Make sure we have a domain to which to beacon
if ("" -eq $domain) {
    write-error "Please specify a domain with -domain";
    exit 1;
}

# Calculate minimum and maximum sleep
$minSleep = ($interval - ($jitter * $interval)) * 1000;
$maxSleep = ($interval + ($jitter * $interval)) * 1000;

echo ("Will beacon between " + $minSleep + "ms and " + $maxSleep + "ms to " + $domain + ".");

for ($i = 0; $i -lt $count; $i++) {
    # Add a path to the URL
    $url = $domain+"/"+$i+".txt";
    echo ("Beacon: " + $url + ".");
    # Try to grab the URL
    try {
        (New-Object system.net.webclient).DownloadString($url) | Out-Null;
    } catch {
        echo ("Error:  " + $_);
    }
    # Sleep a bit before the next beacon
    $sleep = $minSleep;
    if ($minSleep -ne $maxSleep) {
        $sleep = (Get-Random -Minimum $minSleep -Maximum $maxSleep);
    }
    echo ("Sleep:  " + $sleep + "ms");
    Start-Sleep -Milliseconds $sleep;
}
