@echo off
setlocal
set PORT=5500
for /f "usebackq tokens=2 delims=:," %%P in (`findstr "port" "%~dp0server.config.json"`) do (
    set PORT=%%P
    set PORT=%PORT: =%
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$port=%PORT%; $listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add(\"http://localhost:$port/\"); $listener.Start(); Write-Output \"Listening on http://localhost:$port\"; while ($listener.IsListening) { $ctx = $listener.GetContext(); $req = $ctx.Request; $path = $req.Url.LocalPath.TrimStart('/'); if ([string]::IsNullOrEmpty($path)) { $path = 'index.html' }; $file = Join-Path '%~dp0' $path; $res = $ctx.Response; if (Test-Path $file -PathType Leaf) { $bytes = [System.IO.File]::ReadAllBytes($file); $ext = [System.IO.Path]::GetExtension($file); $ct = switch ($ext) { '.html' {'text/html'} '.css' {'text/css'} '.js' {'application/javascript'} '.json' {'application/json'} default {'application/octet-stream'} }; $res.ContentType = $ct; $res.ContentLength64 = $bytes.Length; $res.OutputStream.Write($bytes,0,$bytes.Length) } else { $res.StatusCode = 404 }; $res.Close() }"
