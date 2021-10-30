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

def show_time():
  # Show the current time in HH:MM:SS format
	time = datetime.datetime.now()
	return time.strftime("%H:%M:%S")

#2 - connect to http://localhost:8000/ and check for a file every 500ms
def check_server(debug):
	HostIP = "localhost"
	HostPort = 8000
	file2downloadWithPath = "test.txt"
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	s.connect((HostIP, HostPort))

	#send http get request for text.txt
	s.send(b"GET /" + file2downloadWithPath.encode() + b" HTTP/1.1\r\n\r\n")
	response = s.recv(1024)
	s.close()

	# Print the response
	if debug:
		print(response)

	# evaluate the response for a 404 error
	if response.find(b"404") != -1:
		return True
	else:
		return False

	# if b"200 OK" in response:
	# 	print("File found")
	# 	return True
	# else:
	# 	print("File not found")
	# 	return False

# main program
# =============================================================================

toggleToShow = True
timeout= 0.5

hasFileBeenFound = False
hasFileBeenDownloaded = False
hasDirectoryBeenCreated = False
hasFileBeenDownloadedAndPlacedInDirectory = False

# loop: clear screen, show time, check server, pull file
while True:
	if toggleToShow:
		os.system("clear")
		print("Auto File Puller   <Ctrl+C to quit>")
		print("================")
		print("Current time: " + str(show_time()))
		print("")
		print("Statuses")
		print("--------")
		print("File found: "+str(hasFileBeenFound))
		print("File downloaded: "+str(hasFileBeenFound))
		print("File Placement Directory Created: "+str(hasDirectoryBeenCreated))
		print("File placed in directory: "+str(hasFileBeenDownloadedAndPlacedInDirectory))


	#Check server for file
	if not hasFileBeenFound:
		hasFileBeenFound = check_server(False)
	
	else: #File exists...
		print("File found...downloading...")

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



