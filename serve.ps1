$root = "G:\My Drive\_Projects\001_My_First_Claude_Something"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:5500/")
$listener.Start()
Write-Host "Listening on http://localhost:5500/"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $path = $request.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    $filePath = Join-Path $root $path.TrimStart("/")

    if (Test-Path $filePath -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        switch ([System.IO.Path]::GetExtension($filePath)) {
            ".html" { $response.ContentType = "text/html" }
            ".js"   { $response.ContentType = "application/javascript" }
            ".css"  { $response.ContentType = "text/css" }
            default { $response.ContentType = "application/octet-stream" }
        }
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
    }
    $response.OutputStream.Close()
}
