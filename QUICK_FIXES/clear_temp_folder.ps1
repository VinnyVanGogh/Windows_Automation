$TEMP_FOLDER = $env:TEMP

function Remove-ItemsInFolder {
    param (
        [string]$target_folder
    )
    $items = Get-ChildItem -Path $target_folder -Force

    if ($items) {
        foreach ($item in $items) {
            Remove-Item -Path $item.FullName -Recurse -Force
            Write-Host "Deleted: $($item.FullName)"
        }
        Write-Host "All files and folders in $target_folder have been deleted."
    } else {
        Write-Host "No files or folders found in $target_folder."
    }
}

Remove-ItemsInFolder -target_folder $TEMP_FOLDER
