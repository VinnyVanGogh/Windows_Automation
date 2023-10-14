# Disable sleep settings
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Power {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@

$null = [Power]::SetThreadExecutionState([UInt32] "0x80000003")

# Re enable sleep settings 
$null = [Power]::SetThreadExecutionState([UInt32] "0x80000000")

