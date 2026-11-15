# macOS 配置

本文面向 macOS。在终端运行：

```bash
git clone https://github.com/renlijie/system_setup.git "$HOME/system_setup"
cd "$HOME/system_setup"
./macOS/setup.sh
```

如果仓库已经存在：

```bash
cd "$HOME/system_setup"
git pull --ff-only
./macOS/setup.sh
```

如果 Homebrew 尚未安装，脚本会询问是否运行 [Homebrew 官方安装器](https://brew.sh)。安装过程可能要求输入管理员密码并安装 Xcode Command Line Tools。脚本支持 Apple Silicon，并优先使用其原生 Homebrew 路径 `/opt/homebrew`。安装成功后，脚本会设置当前运行环境，并在 `~/.zprofile` 追加 Homebrew shell 初始化命令（不会覆盖原有内容）。

脚本通过 Homebrew 安装 Git、Vim 和 fzf，安装 Oh My Zsh，并应用 `common/` 中与 WSL 共用的 Vim/Zsh 配置。现有的 `~/.vimrc` 和 `~/.zshrc` 若与仓库配置不同，会先在原文件旁备份。脚本不会设置 Git 提交身份、创建 SSH 密钥，也不会安装 JAX 或 CUDA。

只更新 Oh My Zsh：

```bash
./macOS/setup.sh --update
```

更新只允许快进；如果 Oh My Zsh 仓库副本有本地改动，脚本会停止而不会覆盖。运行 `./macOS/setup.sh --help` 查看选项。

macOS 自带 Zsh。重新打开终端即可加载新配置。Agnoster 主题的图标需要 Nerd Font；安装后在 Terminal 的字体设置中选择对应字体。
