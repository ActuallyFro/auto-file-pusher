############################################
# =============== I. Program Description & Settings =================================================================
# Create the Auto-File-Puller

# Settings
# --------
$checkEveryXMilliseconds= 5000
$outputFile="file.png"
$destination_folder = "New_Work_Folder"

# Loop Conditions:
$stillGettingFile = $true
$alwaysRun = $false

# It does the following:
# ----------------------
# 0. Get the current time
# 1. Clear screen/ print GUI
# 2. Check every checkEveryXMilliseconds for a file (but update the GUI every timeToUpdateFrameMS) 
# 3. Pull the file from the server IF IT EXISTS
# 4. Creates a directory for the file
# 5. Moves the downloaded file to the directory

# =============== II. Functions =================================================================
# -------------------------------------------------------------------
function Get-Time {
    return Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
}
# # -------------------------------------------------------------------

# # -------------------------------------------------------------------
# #2 - connect to http://localhost:8000/ and check for a file every 500ms
function Get-ServerFileExistsPS5 {
  #HAX -- UNCONFIRMED!
  #https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error/15841856#15841856 && https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.2

$Source = @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

  Add-Type -TypeDefinition $Source  
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy #Wont work if [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} has been run... 

    $url = "https://github.com/favicon.ico"
    $response = (Invoke-WebRequest $url -UseBasicParsing -OutFile $null)
    $response.StatusCode

    if ($response.StatusCode -eq 200) {
        return $true
    }
    else {
        return $false
    }
}

function Get-ServerFileExists {
  $fileExists = $false
  #Source: https://stackoverflow.com/questions/20259251/powershell-script-to-check-the-status-of-a-url
  $url = "https://github.com/favicon.ico"

  # $HTTP_Request = [System.Net.WebRequest]::Create($url)

  # PROBLEM:
  # |Exception calling "GetResponse" with "0" argument(s): "The remote server returned an error: (404) Not Found."
  # |At AFP.ps1:## char:3
  # |+   $HTTP_Response = $HTTP_Request.GetResponse()
  # |+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # |    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
  # |    + FullyQualifiedErrorId : WebException
  #Solution: Try/Catch -- https://stackoverflow.com/questions/25057721/how-do-you-get-the-response-from-a-404-page-requested-from-powershell

  try {
    # #HAX!!! -- https://stackoverflow.com/questions/9917875/power-shell-web-scraping-ssl-tsl-issue
    # [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

  #HAX -- UNCONFIRMED!
  #https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error/15841856#15841856 && https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.2

$Source = @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

  Add-Type -TypeDefinition $Source  
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy #Wont work if [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} has been run... 

    $HTTP_Request = [System.Net.WebRequest]::Create($url)
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode

    if ($HTTP_Status -eq 200) {
      # Write-Host "Site is OK!"
      $fileExists = $true
    
    }
    #  else {
    #   # Write-Host "The Site may be down, please check! (Error Code: HTTP_Status)"
    #   # return $false
    # }

  } catch [System.Net.WebException] {
      $statusCode = [int]$_.Exception.Response.StatusCode
      # echo "[DEBUG] $statusCode"
      $html = $_.Exception.Response.StatusDescription
      # echo "[DEBUG] $html"

      # Connection ERRORED! -- Get Response operates on a null object...
      # return $false
  }

  # Finally, we clean up the http request by closing it.
  if ($HTTP_Response -eq $null) { } 
  else { $HTTP_Response.Close() }

  return $fileExists
}


# 

# def check_server_for_exists(HostIP, HostPort, file2downloadWithPath, debug=False):
# 	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 	s.connect((HostIP, HostPort

# 	# USE HEAD and NOT GET ... b/c it will NOT start downloading...
# 	s.send(b"HEAD /" + file2downloadWithPath.encode() + b" HTTP/1.1\r\n\r\n")
# 	response = s.recv(1024)
# 	s.close()

# 	if debug:
# 		print(response)

# 	# https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404
# 	# if response.find(b"404") != -1 and response.find(b"not"):
# 	if response.find(b"404") != -1:
# 		return False
# 	else:
# 		return True

# 	# Alternative: Check code 200 -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200

# # -------------------------------------------------------------------

# def GetResponseBytesFromHTTPStreamFile(fileName):
# 	ResponseBytes=-1
# 	ContentStr =""
# 	StartString=b"Content-Length:"
# 	# Open temp_response.txt in , read subbytes starting at StartString until end of line
# 	with open(fileName, "rb") as f:
# 		for line in f:
# 			if line.startswith(StartString):
# 				ContentStr = line.decode()
# 				break

# 	match = re.match(r'Content-Length: ([\d]+)', ContentStr)
# 	if match:
# 		ResponseBytes = int(match.group(1

# 	return ResponseBytes


# # -------------------------------------------------------------------
# # 3. Pull the file from the server IF IT EXISTS
# def download_from_server(HostIP, HostPort, file2downloadWithPath, outputFile="superd00per.bin", debug=False):
# 	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# 	s.connect((HostIP, HostPort

# 	s.send(b"GET /" + file2downloadWithPath.encode() + b" HTTP/1.1\r\n\r\n")

# 	#A source: https://www.tomordonez.com/python-socket-save-data-to-file/
# 	# with open('data_stream.txt', 'r') as fhandle:
# 	# 		for line in fhandle:
# 	# 				match = re.match(r'Last-Modified: ([\w,: ]+)', line)
# 	# 				if match:
# 	# 						last_modified = match.group()
# 	# 						print(last_modified)
# 	# 				match2 = re.match(r'ETag: (["\w-]+)', line)
# 	# 						etag = match.group()
# 	# 						print(etag)
# 	#
# 	# SO something like Content-type: (e.g., image/png) && Content-Length: (e.g., 52638) could be parsed

# 	#save all only GET CONTENT to local file
# 	with open("temp_response.txt", "wb") as f: #wb IF NOT decoding, else w!
# 		while True:
# 			data = s.recv(1024)
# 			if not data:
# 				break
# 			f.write(data) #"utf-8" is default encoding
# 			# f.write(data.decode(


# 	s.close()

# 	ResponseBytes=GetResponseBytesFromHTTPStreamFile("temp_response.txt")
# 	if debug:
# 		print("Total Bytes from Content-Length: <"+ ResponseBytes)+">")

# 	#Get total binary bytes from file, save in FileSize
# 	FileSize = os.path.getsize("temp_response.txt")
# 	SkipToBytes = FileSize-ResponseBytes

# 	print("Skipping to Byte Position: "+ SkipToBytes	

# 	# mmmm... large files?
# 	ReadByteArray = open("temp_response.txt", "rb").read() #Read in all bytes
# 	last_ResponseBytes_bytes = ReadByteArray[-ResponseBytes:] #Slice the LAST ResponseBytes
# 	with open(outputFile, "wb") as f2:
# 		f2.write(last_ResponseBytes_bytes)

# 	#Delete temp_response.txt
# 	os.remove("temp_response.txt")

# 	return ResponseBytes


# # -------------------------------------------------------------------

# # -------------------------------------------------------------------
# # 4. Creates a directory for the file
# def create_destination_directory(strForNewDir):
# 	if not os.path.exists(strForNewDir):
# 		os.makedirs(strForNewDir)

# # -------------------------------------------------------------------

# # -------------------------------------------------------------------
# # 5. Moves the downloaded file to the directory
# # -------------------------------------------------------------------

# # main program
# # =============================================================================
$timeToUpdateFrameMS = 500 #update screen every 500 milliseconds || 0.5 sec -- DON'T server check! -- MID POINT ROUNDING... -_-
$updateFrame = $true
$runFileChecks = $true

$totalUpdateFramesPerSec = [float]1.0/[float]$timeToUpdateFrameMS
$totalUpdatesBeforeRunningServerCheck = [float]$totalUpdateFramesPerSec*$checkEveryXMilliseconds
$currentUpdateCount = 0

$strLastCheckPreDownloadTime = ""
$hasFileBeenFound = $false
$strFileFoundAtTime =""
$hasFileBeenDownloaded = $false
$strFileDownloadedAtTime = ""
$hasDirectoryBeenCreated = $false
$hasFileBeenDownloadedAndPlacedInDirectory = $false

# Logs
$hasFileDownloadedLogged = $false
$hasFileDownloadedSizeConfirmedLogged = $false
$strFileDownloadConfirmed=""
$hasNewDirectoryCreatedLogged = $false
$hasFileBeenDownloadedAndPlacedInDirectoryLogged = $false

# # =============== III. CHECK LOOP =================================================================

#create variable logfile for file output name
$logfile = "logfile.txt";

# # loop: clear screen, show time, check server, pull file
# while stillGettingFile or alwaysRun:
while($true){

#0. Get the current time
  $curTimeStr = Get-Time

	# 1. Clear screen/GUI
  if($updateFrame){
    $updateFrame = $false

    
    cls

		echo "Auto File Puller   <Ctrl+C to quit>"
		echo "================"
		echo "Config: Out file < $outputFile >"
		echo "Config: Saving to dir < $destination_folder >"
    $convertedSec = $checkEveryXMilliseconds/1000
		echo "Config: Check every < $convertedSec > secs"
		echo "Current time:  $curTimeStr"
		echo ""
		echo "Statuses"
		echo "--------"
		echo "File found: < $hasFileBeenFound $strFileFoundAtTime>"
		echo "File downloaded: <$hasFileBeenDownloaded>"
		echo "File Placement Directory Created: <$hasDirectoryBeenCreated>"
		echo "File placed in directory: <$hasFileBeenDownloadedAndPlacedInDirectory>"
		echo ""

		echo "Logs"
		echo "--------"
		echo "Waiting for file ... last check @<$strFileDownloadedAtTime>"  
    if($hasFileDownloadedLogged){
      echo "File found...downloading...@<$strFileDownloadedAtTime>"
    }

    if($hasFileBeenDownloaded){
      echo "File found...downloading...$strFileDownloadedAtTime"
    }

    if($hasFileDownloadedSizeConfirmedLogged){
      echo "File downloaded size confirmed: $strFileDownloadConfirmed"
    }

    if($hasNewDirectoryCreatedLogged){
      echo "New Directory ($destination_folder) made!"
    }

    if($hasFileBeenDownloadedAndPlacedInDirectoryLogged){
      echo "File placed in directory! [@$curTimeStr]"
    }
  }

# 	# 2. check every 500ms for a file
# 	#Check server for file; when found log time
  if (!$hasFileBeenFound){
    if($runFileChecks){
      $runFileChecks = $false
      $strFileDownloadedAtTime=$curTimeStr
      
      #TODO: 
      $hasFileBeenFound = Get-ServerFileExists #check_server_for_exists("localhost", 8000, "file.png")

      if ($hasFileBeenFound){
        $strFileFoundAtTime = " [@$curTimeStr]"
      }
    }

  } else { #File exists...
    if (!$hasFileDownloadedLogged){
      $hasFileDownloadedLogged = $true
    }
  }
	

    # echo "[DEBUG] Comparing $currentUpdateCount+1 vs. $totalUpdatesBeforeRunningServerCheck-1"

# 	# 3. Pull the file from the server IF IT EXISTS
# 	if $hasFileDownloadedLogged and not $hasFileBeenDownloaded:
# 		ResponseBytes = download_from_server("localhost", 8000, "file.png", outputFile)
# 		curTimeStr =  show_time( #update time due to serial processing
# 		$strFileDownloadedAtTime = " [@"+curTimeStr+"]"
# 		$hasFileBeenDownloaded = $true

# 		#check if file downloaded
# 		if os.path.isfile(outputFile):
# 			fileSize = os.path.getsize(outputFile)
# 			if fileSize == ResponseBytes:
# 				strFileDownloadConfirmed="<Size: "+ ResponseBytes)+">"
# 				$hasFileDownloadedSizeConfirmedLogged= $true

# 	# 4. Creates a directory for the file
# 	if $hasFileDownloadedSizeConfirmedLogged:
# 		if os.path.isdir($destination_folder):
# 			$hasDirectoryBeenCreated = $true
# 			hasNewDirectoryCreatedLogged = $true
# 		else:
# 			create_destination_directory($destination_folder)

# 	# 5. Moves the downloaded file to the directory
# 	if hasNewDirectoryCreatedLogged:
# 		if os.path.isfile(outputFile): #NOT needed, but best to check
# 			if os.path.isfile($destination_folder+"/"+outputFile):
# 				os.remove($destination_folder+"/"+outputFile)

# 			#move new file to directory
# 			shutil.move(outputFile, $destination_folder) #https://docs.python.org/3/library/shutil.html
# 			$hasFileBeenDownloadedAndPlacedInDirectory = $true

# 	#log the fact the file has been downloaded and placed in directory
# 	if $hasFileBeenDownloadedAndPlacedInDirectory:
# 		#Check for file in a directory
# 		if os.path.isfile($destination_folder+"/"+outputFile):
# 			$hasFileBeenDownloadedAndPlacedInDirectoryLogged = $true

  # wait 500ms
  Start-Sleep -Milliseconds $timeToUpdateFrameMS
  # Start-Sleep -Seconds $timeToUpdateFrame
  $updateFrame = $true

if (!$hasFileDownloadedLogged){
  $currentUpdateCount += 1



  if($currentUpdateCount -ge ($totalUpdatesBeforeRunningServerCheck-1)){ #HAX: EXCEPTION HANDLING/CHECKING NEEDED!
    $currentUpdateCount = 0
    $runFileChecks = $true
  }
}

# 	if not $:

}

#####################
#References
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comparison_operators?view=powershell-7.2
#https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.2