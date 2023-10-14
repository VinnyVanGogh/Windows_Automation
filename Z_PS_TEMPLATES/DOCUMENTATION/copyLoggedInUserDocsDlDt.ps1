$loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
robocopy \\MGOLDSBYPC\Users\Maribeth\Desktop C:\Users\Maribeth\Desktop /E /XO /R:1 /W:1
robocopy \\MGOLDSBYPC\Users\Maribeth\Documents C:\Users\Maribeth\Documents /E /XO /R:1 /W:1
robocopy \\MGOLDSBYPC\Users\Maribeth\Downloads C:\Users\Maribeth\Downloads /E /XO /R:1 /W:1
robocopy \\MGOLDSBYPC\Users\Maribeth\Favorites C:\Users\Maribeth\Favorites /E /XO /R:1 /W:1
