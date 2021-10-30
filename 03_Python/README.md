Auto-File Pusher
================
- Watch a web (http) file for existance
- When it is a NOT-404 error, pull it down
- Create directory, and push the file there...

Test Setup
----------
0. start tmux
1. In tmux `python3 -m http.server` (then Ctrl+b, d)
2. Start script `python3 AFP.py`
3. In another window/terminal ... DROP the picture (`file.png`) into the SAME folder tmux/http server is running
4. watch
