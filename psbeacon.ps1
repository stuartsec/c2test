<#

.SYNOPSIS

Make jittery HTTP beacons.

.DESCRIPTION

This script makes repeated, possibly jittery HTTP requests to a domain.  Each request will be of the form
http://domain/COUNTER.txt, where COUNTER is an incrementing decimal number.

User-Agent headers for various browsers:

Edge, Win 10:    Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 Edge/17.17074
IE, Win 10:      Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
Chrome 67, OS X: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36

.EXAMPLE

Make 20 beacons at an interval between 7ish and 13ish seconds to example.org

.\psbeacon.ps1 -interval 10 -jitter .3 -count 20 -domain https://example.org

.EXAMPLE

Spoof IE

.\psbeacon.ps1 -useragent "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko" -domain http://example.com

#>

param (
    # Average time between beacons in seconds
    [float]  $interval = 1,
    # Jitter to add to the beacon interval, as a value between 0 and 1
    [float]  $jitter   = .25,
    # Number of beacons
    [float]  $count    = 10,
    # Domain and protocol (e.g. http://example.com) to which to beacon
    [string] $domain,
    # User-agent to send to the server
    [string] $useragent
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

$i = 0;
for (;;) {
    # Add a path to the URL
    $url = $domain+"/"+$i+".txt";
    echo ("Beacon: " + $url + ".");
    # Try to grab the URL
    try {
        $wc = (New-Object system.net.webclient);
        if ("" -ne $useragent) {
            $wc.Headers['User-Agent'] = $useragent;
        }
        $wc.DownloadString($url) | Out-Null;
    } catch {
        echo ("Error:  " + $_);
    }

    # Give up if this is the last beacon
    $i++;
    if ($i -ge $count) {
        break;
    }

    # Sleep a bit before the next beacon
    $sleep = $minSleep;
    if ($minSleep -ne $maxSleep) {
        $sleep = (Get-Random -Minimum $minSleep -Maximum $maxSleep);
    }
    echo ("Sleep:  " + $sleep + "ms");
    Start-Sleep -Milliseconds $sleep;
}

# vim:ff=dos
