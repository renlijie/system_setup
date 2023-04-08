# Setup procedure based on (WSL2) Ubuntu 22.04.1 LTS 

# vim
```bash
cp ~/system_setup/WSL/_vimrc ~/.vimrc
```

# zsh
```bash
sudo apt install zsh
```
## on-my-zsh https://ohmyz.sh/#install
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
## pure prompt https://github.com/sindresorhus/pure
```bash
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
mkdir ~/.zsh/zfunctions
cd ~/.zsh/pure
ln -s "$PWD/pure.zsh" "$HOME/.zsh/zfunctions/prompt_pure_setup"
ln -s "$PWD/async.zsh" "$HOME/.zsh/zfunctions/async"
```
## fzf https://github.com/junegunn/fzf
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```
## zshrc
```bash
cp ~/system_setup/WSL/_zshrc ~/.zshrc
```

# JAX with CUDA and CUDNN https://github.com/google/jax#installation (May not need to install CUDA separately as below)
```bash
sudo apt update && upgrade
sudo apt install python3 python3-pip ipython3
pip install --upgrade pip
pip install --upgrade "jax[cuda12_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
nvcc --version
sudo ln -s /path/to/cuda /usr/local/cuda-12.1
```

# (May not need) CUDA https://docs.nvidia.com/cuda/wsl-user-guide/index.html#cuda-support-for-wsl-2 or https://learn.microsoft.com/en-us/windows/wsl/tutorials/gpu-compute#setting-up-nvidia-cuda-with-docker (newer)
```bash
sudo apt-key del 7fa2af80
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-12-1-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda
rm cuda-repo-wsl-ubuntu-12-1-local_12.1.0-1_amd64.deb
```

# github https://github.com/settings/keys
git config --global user.email "...@gmail.com"
git config --global user.name "..."
ssh-keygen -t ed25519 -C "...@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub | clip.exe
