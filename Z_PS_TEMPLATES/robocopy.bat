@echo off
SET domainUsername=domainUsername 
REM ex. jdoe
SET localUsername=localUsername 
REM ex. jdoe
SET folderToCopy=folderToCopy 
REM ex. Desktop, Documents, Downloads, etc.
SET folderToCopyTo=folderToCopyTo
REM ex. Desktop, Documents, Downloads, etc.

REM an example of how to copy a folder from one user to another
robocopy C:\Users\%localUsername%\%folderToCopy% C:\Users\%domainUsername%\%folderToCopyTo% /E /XO /R:1 /W:1

REM an example of how to copy a folder from a network share to a local user
robocopy \\server\share\%folderToCopy% C:\Users\%domainUsername%\%folderToCopyTo% /E /XO /R:1 /W:1

REM an example of how to copy all folders from one user to another
robocopy C:\Users\mwdocusr\Documents C:\Users\leah\Documents /E /XO /R:1 /W:1
robocopy C:\Users\mwdocusr\Downloads C:\Users\leah\Downloads /E /XO /R:1 /W:1
robocopy C:\Users\mwdocusr\Desktop C:\Users\leah\Desktop /E /XO /R:1 /W:1
robocopy C:\Users\mwdocusr\Favorites C:\Users\leah\Favorites /E /XO /R:1 /W:1

REM an example of how to use variables
SET Temp=C:\Users\vincevasile\Temp
SET Temp2=C:\Users\vincevasile\Temp2
robocopy %Temp% %Temp2% /E /XO /R:1 /W:1

REM for maribeth goldsby to transfer files from her old computer to her new one
robocopy \\mgoldsbypc\c$\Users\maribeth\Documents C:\Users\maribeth\Documents /E /XO /R:1 /W:1 /COPYALL; robocopy \\mgoldsbypc\c$\Users\maribeth\Downloads C:\Users\maribeth\Downloads /E /XO /R:1 /W:1 /COPYALL; robocopy \\mgoldsbypc\c$\Users\maribeth\Desktop C:\Users\maribeth\Desktop /E /XO /R:1 /W:1 /COPYALL; robocopy \\mgoldsbypc\c$\Users\maribeth\Favorites C:\Users\maribeth\Favorites /E /XO /R:1 /W:1 /COPYALL

robocopy c:\users\vincevasile\temp c:\users\vincevasile\temp2 /E /XO /R:1 /W:1 /COPYALL; robocopy c:\users\vincevasile\Documents c:\users\vincevasile\temp2 /E /XO /R:1 /W:1 /COPYALL; robocopy c:\users\vincevasile\Downloads c:\users\vincevasile\temp2 /E /XO /R:1 /W:1 /COPYALL
