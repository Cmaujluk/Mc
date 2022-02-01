import win32gui
w=win32gui
print(w.GetWindowText (w.GetForegroundWindow()))