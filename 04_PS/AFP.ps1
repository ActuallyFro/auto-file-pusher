#Going to try this one...

#create variable logfile for file output name
# $logfile = "logfile.txt";

# Get-Date -Format 'yyyy-MM-dd HH:mm:ss' | Out-File -Encoding ASCII -FilePath $logfile
$startTime=Get-Date -Format 'yyyy-MM-dd HH:mm:ss' 
echo "Starting time: " $startTime

