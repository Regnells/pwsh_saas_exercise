<#
Creates a function that allows you to create X amounts of virtual machines
based on a .txt file with pre-specified names entered by the user (hopefully)
while also creating the VM(s) VHDX disk and allowing the user to set the 
proper RAM size for the machine.
#>
function Custom-VMMaker
{
    [Cmdletbinding()]
        param (
            #User must enter a valid path to a .txt file
            [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Enter where you want to import your names from. Has to be a .txt file with names only")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '^\D:\\.*\.txt$' ) {
                    $true
                }
                else {
                    Throw "$_ is not a valid path"
                }
            })]
            [string]$VMNamnLista,

            #Check if user entered a valid path and if not throw error message
            [Parameter(Mandatory = $true, Position = 2, HelpMessage = "Enter the path to where you want to store your new VM(s)")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '^\D:\\.*' ) {
                    $true
                }
                else {
                    Throw "$_ is not a valid path"
                }
            })]
            [string]$VMPath,
            
            #Check if user entered a valid path and if not throw error message
            [Parameter(Mandatory = $true, Position = 3, HelpMessage = "Enter the path to where you want to store your new VHDX files")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '^\D:\\.*' ) {
                    $true
                }
                else {
                    Throw "$_ is not a valid path"
                }
            })]
            [string]$VHDPath,

            #Makes sure that there are at least between 1 and 3 numbers followed by 2 letters 
            #(should probably check for length and specific letters (MB,GB etc.)as well but I can't be bothered)
            [Parameter(Mandatory = $true, Position = 6, HelpMessage = "Enter amount of RAM you want your new VM(s) to have")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '\d{1,3}\D\D' ){
                    $true
                }
                else {
                    Throw "Requires you specify the amount with either MB or GB" 
                }
            })]
            [string]$MemoryStartupBytes,

            #Checks if input is either 1 or 2, otherwise throw error message
            [Parameter(Mandatory = $true, Position = 5, HelpMessage = "Select what generation of VM you want, 1 or 2")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '^[1-2]$' ){
                    $true
                }
                else {
                    Throw "Generation can only be 1 or 2" 
                }
            })]
            [int]$Generation,

            #Makes sure that there are at least between 1 and 3 numbers followed by 2 letters 
            #(should probably check for length and specific letters (MB,GB etc.)as well but I can't be bothered)
            [Parameter(Mandatory = $true, Position = 5, HelpMessage = "Input what size you want your new VHDX to be")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '\d{1,3}\D\D' ){
                    $true
                }
                else {
                    Throw "You need to specify the amount with either GB or MB" 
                }
            })]
            [string]$VHDSize,


            #Makes sure that there are at least between 1 and 3 numbers followed by 2 letters 
            #(should probably check for length and specific letters (MB,GB etc.)as well but I can't be bothered)
            [Parameter(Mandatory = $true, HelpMessage = "Assign the minimum RAM size for your VM(s) Eg. 512MB")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({
                if ( $_ -match '\d{1,3}\D\D' ){
                    $true
                }
                else {
                    Throw "You need to specify the amount with either GB or MB" 
                }
            })]
            [string]$MinimumBytes,

            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [bool]$DynamicMemoryEnabled

        )

        #Start logging to file.
        Start-Transcript -Path "D:\Rasmus LABB\Loggning\VMMakerlog.txt" -Append

    #Starts a Foreach loop based on the content in the .txt file called upon
    foreach ( $VMNamn in Get-Content $VMNamnLista )
    {
        #These variables consolidate certain variables for easier use. These particular ones converts int32/string to Uint64 and defines the name for the newly created VHDX.
        $VHDPathComplete = "$($VHDPath)\$($VMNamn).vhdx"
        $VHDSize64 = ($VHDSize/[uint64] 1)
        $VMStartupBytes64 = ($($MemoryStartupBytes)/[uint64] 1)
        $VMMinBytes64 = ($($MinimumBytes)/[uint64] 1)

        Write-Progress -Activity "Creating Virtual Machines and accompanying VHDX files"
        #Creating the VHDX, VM and sets the RAM memory for the newly created VM.
        New-VHD -Path $VHDPathComplete -SizeBytes $VHDSize64
        New-VM -Name $VMNamn -Path $VMPath -VHDPath $VHDPathComplete -MemoryStartupBytes $VMStartupBytes64 -Generation $Generation
        Set-VMMemory $VMNamn -DynamicMemoryEnabled $DynamicMemoryEnabled -MinimumBytes $VMMinBytes64 -StartupBytes $VMStartupBytes64 -MaximumBytes $VMStartupBytes64 
    }
    Stop-Transcript
}