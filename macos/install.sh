echo "Val's macOS install script"
echo "Last updated : Oct 2021"

echo "Install homebrew"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Download config files from git"
cd $HOME

mkdir -p devel
cd devel
git clone https://github.com/louen/config-files.git

/bin/bash $HOME/devel/config-files/shells/zsh/install-home.sh
/bin/bash $HOME/devel/config-files/vim/install-home.sh

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew analytics -v off

cp $HOME/devel/config-files/linux/gitconfig $HOME/.gitconfig

echo "Installing basic software : iterm2 / firefox / vlc / htop / rectangle"

brew install --cask iterm2
brew install --cask firefox
brew install --cask vlc
brew install --cask htop
brew install --cask rectangle
brew install thefuck

echo "Installing text editors : vscode / macvim"
brew install --cask visual-studio-code
brew install --cask macvim

echo "Installing fonts : Fira code"
brew tap homebrew/cask-fonts
brew install --cask font-fira-code

echo "Installing useful apps : spotify / dropbox / keepass / blender "
brew install --cask spotify
brew install --cask dropbox
brew install --cask keepassxc
brew install --cask blender

# Defaults settings
# Shamelessely stolen from jtilander/dotfiles and esycat/devops/osx/
echo "Writing defaults"

## General OS Settings

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Save to disk rather than cloud by default
defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false

# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

## Finder 
# Always open everything in Finder's list view.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Open new finder windows on Home directory
defaults write com.apple.Finder NewWindowTarget -string "PfHm"

# Search in current directory by default
defaults write com.apple.Finder FXDefaultSearchScope -string "SCcf"

# Use AirDrop over every interface.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Have textedit default to plain text.
defaults write com.apple.TextEdit RichText -int 0

# Show the ~/Library folder.
chflags nohidden ~/Library

## Override US regional settings

# Set 24h clock in the menubar
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d HH:mm:ss"

# Use Metric everywhere
defaults write -g AppleTemperatureUnit -string "Celsius"
defaults write -g AppleMetricUnits -bool true
defaults write -g AppleMeasurementUnits -string "Centimeters"

# Set First day of week to Monday
defaults write -g AppleFirstWeekday -dict gregorian 2

# Set Time fromat to 24-Hour Time
defaults write -g AppleICUForce24HourTime -bool true

defaults write -g AppleICUTimeFormatStrings -dict-add "1" "HH:mm"
defaults write -g AppleICUTimeFormatStrings -dict-add "2" "HH:mm:ss"
defaults write -g AppleICUTimeFormatStrings -dict-add "3" "HH:mm:ss z"
defaults write -g AppleICUTimeFormatStrings -dict-add "4" "HH:mm:ss zzzz"

# Set day order to day, month, year
defaults write -g AppleICUDateFormatStrings -dict-add "1" "dd/MM/yy"
defaults write -g AppleICUDateFormatStrings -dict-add "2" "dd MMM y"
defaults write -g AppleICUDateFormatStrings -dict-add "3" "dd MMMM y"
defaults write -g AppleICUDateFormatStrings -dict-add "4" "EEEE, dd MMMM y"


## Setup proper keybindings for home / end
if [ ! -d ~/Library/KeyBindings ]; then
	mkdir -p ~/Library/KeyBindings
fi
cat > ~/Library/KeyBindings/DefaultKeyBinding.dict <<EOM
{
    "\UF729"  = "moveToBeginningOfLine:";
    "$\UF729" = "moveToBeginningOfLineAndModifySelection:";
    "\UF72B"  = "moveToEndOfLine:";
    "$\UF72B" = "moveToEndOfLineAndModifySelection:";
    "\UF72C"  = "pageUp:";
    "\UF72D"  = "pageDown:";
}
EOM

## Dock settings
# No bouncing 
defaults write com.apple.dock no-bouncing -bool TRUE
# No genie effect
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock tilesize -int 50

echo "Downloading Dracula config for iterm to $HOME/Documents"
# configuring iterm
curl -fsSL https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Dracula.itermcolors > $HOME/Documents/Dracula.itermcolors

echo "Set computer name (Preferences/Sharing)"
echo "Add e-mail to gitconfig"
echo "Open iTerm and make default term + set Dracula + set default font + set transparency 7 / blur 10"
echo "Open FFox and make default browser"

