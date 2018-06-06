# IronNet Powershell Beaconing Tool

param (
    [float]  $interval = 1,   # Average time between beacons in seconds
    [float]  $jitter   = .25, # Jitter to add to $interval
    [float]  $count    = 10,  # Number of beacons
    [string] $domain          # Domain to which to beacon
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
    $sleep = (Get-Random -Minimum $minSleep -Maximum $maxSleep);
    echo ("Sleep:  " + $sleep + "ms");
    Start-Sleep -Milliseconds $sleep;
}
