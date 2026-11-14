# WSL setup

These instructions target Ubuntu on WSL 2. Run commands inside the Ubuntu
terminal, as your normal Linux user.

## First-time install from WSL

Open the Ubuntu terminal and run:

```bash
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/renlijie/system_setup.git "$HOME/system_setup"
cd "$HOME/system_setup"
./WSL/setup.sh
```

Git is installed first because it is needed to download the repository. The
setup script then installs the base packages (Vim, Zsh, Python virtual-
environment support, fzf and supporting tools), Oh My Zsh, the Pure prompt,
and this repository's Vim/Zsh configuration. fzf and its Zsh key
bindings/completion are installed on every run. **This setup does not install
JAX or CUDA.** Run it as your normal user, not as root.

If `~/system_setup` already exists, skip the `git clone` command and use:

```bash
cd "$HOME/system_setup"
git pull --ff-only
./WSL/setup.sh
```

The script is safe to rerun. If a configuration file differs from the
repository version, the existing file is backed up alongside it with a
`.bak.<timestamp>` suffix before replacement.

## Rerunning setup or updating components

Run the setup script again from the repository directory:

```bash
cd "$HOME/system_setup"
./WSL/setup.sh --update
```

Updates use fast-forward-only Git pulls and stop if a checkout has local
changes. The script does not upgrade Ubuntu packages or change your login shell.

To start using Zsh in the current terminal:

```bash
exec zsh
```

To make Zsh your login shell, run this separately:

```bash
chsh -s "$(command -v zsh)"
```

Open a new WSL terminal afterward. Use `./WSL/setup.sh --help` to see all
options.

## Python and optional JAX

Use a virtual environment for Python packages rather than installing them into
Ubuntu's system Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

For CPU-only JAX, install it in the active environment with:

```bash
python -m pip install --upgrade jax
```

For the RTX 5080 under WSL 2, JAX's NVIDIA GPU support is currently
experimental. The current JAX instructions use CUDA 13 and require an NVIDIA
driver version 580 or newer. Install the latest NVIDIA production driver on
Windows, verify GPU passthrough from Ubuntu with `nvidia-smi`, then install
JAX's CUDA 13 wheels in the active virtual environment:

```bash
python -m pip install --upgrade "jax[cuda13]"
python -c "import jax; print(jax.devices())"
```

The JAX CUDA wheels include the CUDA runtime libraries, so a separate CUDA
Toolkit installation is not needed just to run JAX. Do not set
`LD_LIBRARY_PATH` globally when using these wheels; it can override the
libraries JAX expects.

## Optional CUDA Toolkit

Install the CUDA Toolkit only if you need development tools such as `nvcc` or
build software against a locally installed toolkit. Follow NVIDIA's
[CUDA on WSL guide](https://docs.nvidia.com/cuda/wsl-user-guide/) and install
the version required by your workload. Do **not** install a Linux NVIDIA
display driver inside WSL. If the Toolkit uses `/usr/local/cuda/bin`, the Zsh
configuration adds it to `PATH`; configure library paths only for tools that
need them, rather than globally.

## Git and SSH (optional)

Set your own Git identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Create a key only if you do not already have one, then add its public key to
[GitHub SSH keys](https://github.com/settings/keys):

```bash
test -f ~/.ssh/id_ed25519 || ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub | clip.exe
```
