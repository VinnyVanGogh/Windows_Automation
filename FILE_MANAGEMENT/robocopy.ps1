$SOURCE_PATH = Read-Host -Prompt "Enter the source path"
$DESTINATION_PATH = Read-Host -Prompt "Enter the destination path"

function Format-Path {
    param (
        [string]$path
    )
    return ('"' + $path + '"')
}

function Test-AndCreatePath {
    param (
        [string]$path_to_validate,
        [string]$path_type
    )
    $formatted_path = Format-Path -path $path_to_validate
    if (-not (Test-Path -Path $formatted_path -PathType $path_type)) {
        if ($path_type -eq "Container") {
            Write-Host "Path $formatted_path does not exist. Creating the directory..."
            $null = New-Item -ItemType Directory -Force -Path $path_to_validate
        } else {
            Write-Host "Path '$formatted_path' does not exist or is not a $path_type."
            exit
        }
    }
}

function Initialize-Robocopy {
    param (
        [string]$source,
        [string]$destination
    )
    robocopy $source $destination /E /COPYALL
}

function Complete-Robocopy {
    Test-AndCreatePath -path_to_validate $SOURCE_PATH -path_type "Container"
    Test-AndCreatePath -path_to_validate $DESTINATION_PATH -path_type "Container"

    $final_source_path = Format-Path -path $SOURCE_PATH
    $final_destination_path = Format-Path -path $DESTINATION_PATH

    Initialize-Robocopy -source $final_source_path -destination $final_destination_path
}

Complete-Robocopy