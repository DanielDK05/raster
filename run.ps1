try {
    jai build.jai - $args;
    
    if ($LastExitCode -gt 0) {
        echo "Jai build failed, exiting..."
        exit 1
    }
    
    $executablePath = "./out/raster.exe"
    if (-not (Test-Path $executablePath)) {
        throw "Executable not found at path: $executablePath"
    }
    
    & $executablePath
}
catch {
    echo "Error: $_"
    exit 1
}
