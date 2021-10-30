import os #to allow for clearing the screen
import socket #for downloading the file
import datetime #to get clock time
import time #To sleep
import re #regex to parse downloaded text stream

# Program Description:
# ====================
# Create the Auto-File-Puller

# Settings
# --------
toggleToShow = True
checkEveryXSec= 5.0
destination_folder = "New_Work_Folder"


# It does the following:
# ----------------------
# 0. Clear screen/GUI
# 1. Show the current time
# 2. check every 500ms for a file
# 3. Pull the file from the server IF IT EXISTS
# 4. Creates a directory for the file
# 5. Moves the downloaded file to the directory

# Note: Requests exists -- I HATE libs on libs ... that ARE NOT STDLibs; python pushes you too... https://docs.python.org/3/library/http.client.html

# -------------------------------------------------------------------
#1 - Show the current time in HH:MM:SS format
def show_time():
	time = datetime.datetime.now()
	return time.strftime("%H:%M:%S")
# -------------------------------------------------------------------

# -------------------------------------------------------------------
#2 - connect to http://localhost:8000/ and check for a file every 500ms
def check_server_for_exists(HostIP, HostPort, file2downloadWithPath, debug=False):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((HostIP, HostPort))

	# USE HEAD and NOT GET ... b/c it will NOT start downloading...
	s.send(b"HEAD /" + file2downloadWithPath.encode() + b" HTTP/1.1\r\n\r\n")
	response = s.recv(1024)
	s.close()

	if debug:
		print(response)

	# https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404
	if response.find(b"404") != -1 and response.find(b"not"):
		return False
	else:
		return True

	# Alternative: Check code 200 -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200

# -------------------------------------------------------------------

def GetResponseBytesFromHTTPStreamFile(fileName):
	ResponseBytes=-1
	ContentStr =""
	StartString=b"Content-Length:"
	# Open temp_response.txt in , read subbytes starting at StartString until end of line
	with open(fileName, "rb") as f:
		for line in f:
			if line.startswith(StartString):
				ContentStr = line.decode()
				break

	match = re.match(r'Content-Length: ([\d]+)', ContentStr)
	if match:
		ResponseBytes = int(match.group(1))

	return ResponseBytes


# -------------------------------------------------------------------
# 3. Pull the file from the server IF IT EXISTS
def download_from_server(HostIP, HostPort, file2downloadWithPath, outputFile="superd00per.bin", debug=False):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((HostIP, HostPort))

	s.send(b"GET /" + file2downloadWithPath.encode() + b" HTTP/1.1\r\n\r\n")

	#A source: https://www.tomordonez.com/python-socket-save-data-to-file/
	# with open('data_stream.txt', 'r') as fhandle:
	# 		for line in fhandle:
	# 				match = re.match(r'Last-Modified: ([\w,: ]+)', line)
	# 				if match:
	# 						last_modified = match.group()
	# 						print(last_modified)
	# 				match2 = re.match(r'ETag: (["\w-]+)', line)
	# 						etag = match.group()
	# 						print(etag)
	#
	# SO something like Content-type: (e.g., image/png) && Content-Length: (e.g., 52638) could be parsed

	#save all only GET CONTENT to local file
	with open("temp_response.txt", "wb") as f: #wb IF NOT decoding, else w!
		while True:
			data = s.recv(1024)
			if not data:
				break
			f.write(data) #"utf-8" is default encoding
			# f.write(data.decode())


	s.close()

	ResponseBytes=GetResponseBytesFromHTTPStreamFile("temp_response.txt")
	if debug:
		print("Total Bytes from Content-Length: <"+str(ResponseBytes)+">")

	#Get total binary bytes from file, save in FileSize
	FileSize = os.path.getsize("temp_response.txt")
	SkipToBytes = FileSize-ResponseBytes

	print("Skipping to Byte Position: "+str(SkipToBytes))	

	# mmmm... large files?
	ReadByteArray = open("temp_response.txt", "rb").read() #Read in all bytes
	last_ResponseBytes_bytes = ReadByteArray[-ResponseBytes:] #Slice the LAST ResponseBytes
	with open(outputFile, "wb") as f2:
		f2.write(last_ResponseBytes_bytes)

	#Delete temp_response.txt
	os.remove("temp_response.txt")

	return ResponseBytes


# -------------------------------------------------------------------

# -------------------------------------------------------------------
# 4. Creates a directory for the file
def create_destination_directory(strForNewDir):
	if not os.path.exists(strForNewDir):
		os.makedirs(strForNewDir)

# -------------------------------------------------------------------

# -------------------------------------------------------------------
# 5. Moves the downloaded file to the directory
# -------------------------------------------------------------------

# main program
# =============================================================================


hasFileBeenFound = False
strFileFoundAtTime =""
hasFileBeenDownloaded = False
strFileDownloadedAtTime = ""
hasDirectoryBeenCreated = False
hasFileBeenDownloadedAndPlacedInDirectory = False

# Logs
hasFileDownloadedLogged = False
hasFileDownloadedSizeConfirmedLogged = False
strFileDownloadConfirmed=""

# loop: clear screen, show time, check server, pull file
while True:
	# 0. Clear screen/GUI & 1. Show the current time
	if toggleToShow:
		curTimeStr = str(show_time())
		os.system("clear")
		print("Auto File Puller   <Ctrl+C to quit>")
		print("================")
		print("Current time: " + curTimeStr)
		print("")
		print("Statuses")
		print("--------")
		print("File found: "+str(hasFileBeenFound)+strFileFoundAtTime)
		print("File downloaded: "+str(hasFileBeenDownloaded))
		print("File Placement Directory Created: "+str(hasDirectoryBeenCreated))
		print("File placed in directory: "+str(hasFileBeenDownloadedAndPlacedInDirectory))
		print("")
		print("Logs")
		print("--------")
		if hasFileDownloadedLogged:
			print("File found...downloading..."+strFileDownloadedAtTime)
		if hasFileBeenDownloaded:
			print("File downloaded!")
		if hasFileDownloadedSizeConfirmedLogged:
			print("File downloaded size confirmed: "+strFileDownloadConfirmed)


	# 2. check every 500ms for a file
	#Check server for file; when found log time
	if not hasFileBeenFound:
		hasFileBeenFound = check_server_for_exists("localhost", 8000, "file.png")

		if hasFileBeenFound:
			strFileFoundAtTime = " [@"+curTimeStr+"]"
	
	else: #File exists...
		if not hasFileDownloadedLogged:
			hasFileDownloadedLogged = True

	# 3. Pull the file from the server IF IT EXISTS
	if hasFileDownloadedLogged and not hasFileBeenDownloaded:
		ResponseBytes = download_from_server("localhost", 8000, "file.png", "file.png")
		curTimeStr = str(show_time()) #update time due to serial processing
		strFileDownloadedAtTime = " [@"+curTimeStr+"]"
		hasFileBeenDownloaded = True

		#check if file downloaded
		if os.path.isfile("file.png"):
			fileSize = os.path.getsize("file.png")
			if fileSize == ResponseBytes:
				strFileDownloadConfirmed="<Size: "+str(ResponseBytes)+">"
				hasFileDownloadedSizeConfirmedLogged= True

	# 4. Creates a directory for the file
	if hasFileDownloadedSizeConfirmedLogged:
		create_destination_directory(destination_folder)



# 5. Moves the downloaded file to the directory

	# wait 500ms
	time.sleep(checkEveryXSec)
	toggleToShow = not toggleToShow



