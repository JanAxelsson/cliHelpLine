# VHS tape script for cliHelpLine Demo GIF
# -----------------------------------------------------------
# To generate the GIF:
#   vhs assets/demo.tape
#
# Output: assets/demo.gif
# -----------------------------------------------------------

Output assets/demo.gif

Set Shell "bash"
Set FontSize 16
Set Width 720
Set Height 350
Set Padding 20
Set WindowBar Colorful
Set WindowBarSize 40
Set Theme "Catppuccin Mocha"
Set LineHeight 1.3
Set TypingSpeed 50ms

# Configure Bold Green prompt ($) and Bold command input via helper script
Hide
Type "source assets/setup_prompt.sh"
Enter
Sleep 500ms
Show

# Step 1: Show purely the header comments of the file (head -n 3)
Sleep 400ms
Type "head -n 3 backup.sh"
Sleep 200ms
Enter

# Step 2: Pause so the viewer clearly reads the comments (~2.0s)
Sleep 2000ms

# Step 3: Run the script with --help
Type "./backup.sh --help"
Sleep 200ms
Enter

# Step 4: Pause to see the comments turned into clean help text (~3.0s)
Sleep 3000ms
