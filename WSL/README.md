# WSL 配置

本文面向 WSL 2 中的 Ubuntu。请在 Ubuntu 终端中以普通 Linux 用户运行命令，不要以 `root` 运行 setup。

如果尚未安装 WSL 或 Ubuntu，请先参考 [Microsoft WSL 安装指南](https://learn.microsoft.com/windows/wsl/install)。

## 首次安装

先打开 Ubuntu 终端，再运行：

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/renlijie/system_setup.git "$HOME/system_setup"
cd "$HOME/system_setup"
./WSL/setup.sh
```

先安装 Git 才能克隆仓库。setup 会安装 Vim、Zsh、Python 虚拟环境支持等基础软件，以及 Oh My Zsh 和 fzf，并应用本仓库的 Vim/Zsh 配置。fzf 每次都会安装，Zsh 会自动设为登录 shell。**setup 不会安装 JAX 或 CUDA。**

配置使用 Oh My Zsh 内置的 Agnoster 主题，以及 `git` 和 `fzf` 插件。Agnoster 的图标需要 Powerline/Nerd Font；字体安装说明见下文。

如果 `~/system_setup` 已经存在，请跳过 `git clone`，运行：

```bash
cd "$HOME/system_setup"
git pull --ff-only
./WSL/setup.sh
```

如果配置文件与仓库版本不同，setup 会先在原文件旁创建带 `.bak.<timestamp>` 后缀的备份，再替换配置。登录 shell 的修改会在新开 WSL 终端后生效；当前终端不会自动切换。

## 更新和重跑

更新仓库配置并重新应用：

```bash
cd "$HOME/system_setup"
git pull --ff-only
./WSL/setup.sh
```

只更新 Oh My Zsh 和 fzf 的上游 checkout：

```bash
./WSL/setup.sh --update
```

上游更新只允许快进；如果上游仓库副本有本地改动，脚本会停止而不会覆盖。脚本不会升级 Ubuntu 系统软件包。运行 `./WSL/setup.sh --help` 查看选项。

## 常见问题

### 提示符仍然显示旧内容或 `user@host`

当前终端或 `~/.zshrc` 可能仍在使用旧配置。先拉取仓库并重新运行 setup：

```bash
cd "$HOME/system_setup"
git pull --ff-only
./WSL/setup.sh
exec zsh
```

setup 会备份并更新 `~/.zshrc`。本机 WSL 提示符使用 Agnoster，并隐藏 `user@host`。

### Agnoster 图标显示成方框或问号

Nerd Font 要安装在 **Windows** 上，而不是 WSL 里面。可以从 [Nerd Fonts 的 Meslo 字体目录](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo/S) 下载并安装 `MesloLGSNerdFontMono-Regular.ttf`。也可以安装同一字体家族的 `Bold`、`Italic` 和 `BoldItalic` 版本。

然后在 Windows Terminal 的 Ubuntu 配置文件中，将字体设为 **MesloLGS Nerd Font Mono**，并重启 Windows Terminal。

### 在 Zsh 中执行 `source ~/.vimrc` 后出现错误

不要在 Zsh 提示符中运行 `source ~/.vimrc`。`.vimrc` 是 Vim 配置，不是 shell 脚本。Vim 启动时会自动加载它；需要重新加载时，先打开 Vim，再执行：

```vim
:source ~/.vimrc
```

### Vim 报错 `E185: Cannot find color scheme 'seoul256'`

当前配置只会在 Seoul256 插件已安装时启用该配色。如果配色仍不可用，在 Vim 中运行 `:PlugInstall`，完成后重启 Vim。

## Python 和可选 JAX

建议在虚拟环境中安装 Python 包，不要直接安装到 Ubuntu 系统 Python：

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

仅安装 CPU 版 JAX：

```bash
python -m pip install --upgrade jax
```

RTX 5080 在 WSL 2 上使用 JAX GPU 时，目前仍属于实验性支持。JAX 的 CUDA 13 安装方式要求 NVIDIA 驱动版本至少为 580。先在 Windows 安装最新的 NVIDIA 正式版驱动，并在 Ubuntu 中用 `nvidia-smi` 确认 GPU 可用，再在已激活的虚拟环境中安装：

```bash
python -m pip install --upgrade "jax[cuda13]"
python -c "import jax; print(jax.devices())"
```

JAX 的 CUDA wheel 已包含运行时库；仅运行 JAX 不需要额外安装 CUDA Toolkit。使用这些 wheel 时，不要全局设置 `LD_LIBRARY_PATH`，以免覆盖 JAX 需要的库。更多信息见 [JAX 官方安装指南](https://docs.jax.dev/en/latest/installation.html)。

## 可选 CUDA Toolkit

只有需要 `nvcc` 等开发工具，或要针对本地 Toolkit 构建软件时，才需要单独安装 CUDA Toolkit。请按工作负载选择版本，并遵循 [NVIDIA CUDA on WSL 指南](https://docs.nvidia.com/cuda/wsl-user-guide/)。

**不要在 WSL 中安装 Linux NVIDIA 显示驱动。** 如果 Toolkit 安装在 `/usr/local/cuda/bin`，Zsh 配置会将其加入 `PATH`。仅在确有需要时为具体工具配置库路径，不要全局设置。

## Git 和 SSH（可选）

设置 Git 提交身份：

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

如果还没有 SSH key，可以创建一个，并将公钥添加到 [GitHub SSH keys](https://github.com/settings/keys)：

```bash
test -f ~/.ssh/id_ed25519 || ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub | clip.exe
```
