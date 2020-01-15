# Setup procedure based on Ubuntu 18.04.1 LTS (Bionic Beaver)
Assuming minimal install + updates + 3rd party software.

## terminal
### color scheme not needed anymore
```bash
sudo apt-get install dconf-cli
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized.git ~/.terminal-solarized
cd ~/.terminal-solarized
./install.sh
```

## vim
```bash
sudo apt install vim
```
### vimrc
```bash
echo "source ~/dotfiles/_vimrc" > ~/.vimrc
```
### plugins
```vim
:PlugInstall
```

## zsh
```bash
sudo apt install zsh
```
### on-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
### pure prompt
```bash
cd
git clone https://github.com/sindresorhus/pure.git ~/.pure
mkdir ~/.zfunctions
cd ~/.pure
ln -s "$PWD/pure.zsh" "$HOME/.zfunctions/prompt_pure_setup"
ln -s "$PWD/async.zsh" "$HOME/.zfunctions/async"
```
### zshrc
```bash
echo "source ~/dotfiles/_zshrc" > ~/.zshrc
```
### fzf
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## tensorflow
### ROCm
```bash
sudo apt install libnuma-dev
wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | sudo apt-key add -
echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update
sudo apt install rocm-dkms
groups
sudo usermod -a -G video $LOGNAME 
reboot
/opt/rocm/bin/rocminfo 
/opt/rocm/opencl/bin/x86_64/clinfo 
echo 'export PATH=$PATH:/opt/rocm/bin:/opt/rocm/profiler/bin:/opt/rocm/opencl/bin/x86_64' | sudo tee -a /etc/profile.d/rocm.sh
```
### tensorflow
```bash
sudo apt update
sudo apt install rocm-libs miopen-hip cxlactivitylogger
sudo apt install wget python3-pip
pip3 install --user tensorflow-rocm
```

## backup
```bash
sudo dd if=/dev/nvme0n1p3 bs=10MB status=progress > /media/lijie/100G/efi-backup.img
```

## misc
### boot
```bash
sudo efibootmgr
sudo vi /etc/default/grub
sudo update-grub
```
### chrome
Disable chrome background processes after shutdown
### delete files without going through Trash
```bash
gsettings set org.gnome.nautilus.preferences show-delete-permanently true
```
### fix timezone descrepency in win10 dual boot
Do in win10 cmd (admin)
```winbatch
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_QWORD /d 1
```
Disable win10 automatic time and reboot.
