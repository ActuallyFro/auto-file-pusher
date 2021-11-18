$download_url = "https://github.com/favicon.ico"
$local_path = "./favicon.ico"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($download_url, $local_path)