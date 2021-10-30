import os #to allow for clearing the screen
import socket #for downloading the file
import datetime #to get clock time
import time #To sleep

# Program Description:
# Create the Auto-File-Puller
# It does the following:
# 1. Show the current time
# 2. check every 500ms for a file
# 3. Pull the file from the server IF IT EXISTS
# 4. Creates a directory for the file
# 5. Moves the downloaded file to the directory

# -------------------------------------------------------------------
#1 - Show the current time in HH:MM:SS format
def show_time():
	time = datetime.datetime.now()
	return time.strftime("%H:%M:%S")
# -------------------------------------------------------------------

# -------------------------------------------------------------------
#2 - connect to http://localhost:8000/ and check for a file every 500ms
def check_server(debug):
	HostIP = "localhost"
	HostPort = 8000
	file2downloadWithPath = "test.txt"
	
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((HostIP, HostPort))

	s.send(b"GET /" + file2downloadWithPath.encode() + b" HTTP/1.1\r\n\r\n")
	response = s.recv(1024)
	s.close()

	if debug:
		print(response)

	if response.find(b"404") != -1:
		return True
	else:
		return False
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# 3. Pull the file from the server IF IT EXISTS
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# 4. Creates a directory for the file
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# 5. Moves the downloaded file to the directory
# -------------------------------------------------------------------

# main program
# =============================================================================

toggleToShow = True
timeout= 0.5

hasFileBeenFound = False
strFileFoundAtTime =""
hasFileBeenDownloaded = False
hasDirectoryBeenCreated = False
hasFileBeenDownloadedAndPlacedInDirectory = False

# Logs
hasFileDownloadedLogged = False

# loop: clear screen, show time, check server, pull file
while True:
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
			print("File found...downloading...")
			# print("File downloaded: "+str(hasFileDownloadedLogged))


	#Check server for file; when found log time
	if not hasFileBeenFound:
		hasFileBeenFound = check_server(False)
		if hasFileBeenFound:
			strFileFoundAtTime = " [@"+curTimeStr+"]"
	
	else: #File exists...
		if not hasFileDownloadedLogged:
			hasFileDownloadedLogged = True

	# 	# # create directory
	# 	# os.system("mkdir -p ./AFP_downloads/")
	# 	# # move file
	# 	# os.system("mv file.png ./AFP_downloads/file.png")
	# 	# # exit loop
	# 	break
	# else:

	# wait 500ms
	time.sleep(timeout)
	toggleToShow = not toggleToShow



