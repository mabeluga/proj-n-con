$pdfPath = "c:\Users\buins\OneDrive\Documents\try\PrincessIvyFetizanan_Mockup_ACtivity3.figma.pdf"
if (-not (Test-Path $pdfPath)) { Write-Output "PDF not found: $pdfPath"; exit 1 }
$bytes = [System.IO.File]::ReadAllBytes($pdfPath)

function Find-Seq([byte[]]$arr, [byte[]]$seq, $start=0) {
    for ($i = $start; $i -le $arr.Length - $seq.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $seq.Length; $j++) {
            if ($arr[$i + $j] -ne $seq[$j]) { $match = $false; break }
        }
        if ($match) { return $i }
    }
    return -1
}

$outDir = Split-Path $pdfPath
$counter = 0

# Extract JPEGs
$pos = 0
$jpegStart = [byte[]](0xFF,0xD8)
$jpegEnd = [byte[]](0xFF,0xD9)
while ($true) {
    $s = Find-Seq $bytes $jpegStart $pos
    if ($s -lt 0) { break }
    $e = Find-Seq $bytes $jpegEnd ($s + 2)
    if ($e -lt 0) { break }
    $len = $e - $s + 2
    $out = $bytes[$s..($s + $len - 1)]
    $counter++
    $fname = Join-Path $outDir ("extracted_{0:000}.jpg" -f $counter)
    [System.IO.File]::WriteAllBytes($fname, $out)
    Write-Output "Wrote $fname"
    $pos = $e + 2
}

# Extract PNGs
$pos = 0
$pngSig = [byte[]](0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A)
while ($true) {
    $s = Find-Seq $bytes $pngSig $pos
    if ($s -lt 0) { break }
    $iend = Find-Seq $bytes ([byte[]](0x49,0x45,0x4E,0x44)) ($s + 8)
    if ($iend -lt 0) { break }
    $endIndex = $iend + 8 # include IEND and CRC
    $out = $bytes[$s..($endIndex - 1)]
    $counter++
    $fname = Join-Path $outDir ("extracted_{0:000}.png" -f $counter)
    [System.IO.File]::WriteAllBytes($fname, $out)
    Write-Output "Wrote $fname"
    $pos = $endIndex
}

if ($counter -eq 0) { Write-Output "No JPEG/PNG image streams found." } else { Write-Output "Total images written: $counter" }
