#!/bin/zsh
set -euxo pipefail

# ================= CONFIG =================
PYTHON_INSTALLED=true
SYSTEM_PYTHON=false
INSTALL_ANACONDA=false
ADD_TO_SYSTEM_PATH=true

# Force Zsh
USE_ZSH_SHELL=true

# Directories
PACKAGES_DIR="$HOME/packages"
TOOLS_DIR="$HOME/tools"
mkdir -p "$PACKAGES_DIR" "$TOOLS_DIR"

# ================= NODE INSTALL =================
NODE_DIR="$TOOLS_DIR/nodejs"
NODE_SRC="$PACKAGES_DIR/nodejs.tar.xz"
NODE_LINK="https://mirrors.ustc.edu.cn/node/v24.14.0/node-v24.14.0-linux-x64.tar.xz"

if [[ -z "$(command -v node)" ]]; then
    echo "Installing Node.js"

    if [[ ! -f "$NODE_SRC" ]]; then
        wget "$NODE_LINK" -O "$NODE_SRC"
    fi

    mkdir -p "$NODE_DIR"
    tar xf "$NODE_SRC" -C "$NODE_DIR" --strip-components=1

    # IMPORTANT: make node available immediately
    export PATH="$NODE_DIR/bin:$PATH"

    # Persist for Zsh
    if [[ "$ADD_TO_SYSTEM_PATH" == true ]]; then
        echo 'export PATH="$HOME/tools/nodejs/bin:$PATH"' >> "$HOME/.zshrc"
    fi
else
    echo "Node already installed"
    NODE_DIR="$(dirname $(dirname $(which node)))"
fi

# ================= NPM GLOBAL PACKAGES =================
"$NODE_DIR/bin/npm" install -g vim-language-server
"$NODE_DIR/bin/npm" install -g bash-language-server
"$NODE_DIR/bin/npm" install -g yaml-language-server

# ================= LUA LANGUAGE SERVER =================
LUA_DIR="$TOOLS_DIR/lua-language-server"
LUA_SRC="$PACKAGES_DIR/lua-ls.tar.gz"
LUA_LINK="https://github.com/LuaLS/lua-language-server/releases/download/3.6.11/lua-language-server-3.6.11-linux-x64.tar.gz"

if [[ ! -x "$LUA_DIR/bin/lua-language-server" ]]; then
    echo "Installing lua-language-server"

    if [[ ! -f "$LUA_SRC" ]]; then
        wget "$LUA_LINK" -O "$LUA_SRC"
    fi

    mkdir -p "$LUA_DIR"
    tar zxf "$LUA_SRC" -C "$LUA_DIR"

    if [[ "$ADD_TO_SYSTEM_PATH" == true ]]; then
        echo 'export PATH="$HOME/tools/lua-language-server/bin:$PATH"' >> "$HOME/.zshrc"
    fi
fi

# ================= RIPGREP =================
RG_DIR="$TOOLS_DIR/ripgrep"
RG_SRC="$PACKAGES_DIR/ripgrep.tar.gz"
RG_LINK="https://github.com/BurntSushi/ripgrep/releases/download/12.0.0/ripgrep-12.0.0-x86_64-unknown-linux-musl.tar.gz"

if [[ -z "$(command -v rg)" ]]; then
    echo "Installing ripgrep"

    if [[ ! -f "$RG_SRC" ]]; then
        wget "$RG_LINK" -O "$RG_SRC"
    fi

    mkdir -p "$RG_DIR"
    tar zxf "$RG_SRC" -C "$RG_DIR" --strip-components=1

    export PATH="$RG_DIR:$PATH"

    echo 'export PATH="$HOME/tools/ripgrep:$PATH"' >> "$HOME/.zshrc"
    echo 'export MANPATH="$HOME/tools/ripgrep/doc/man:$MANPATH"' >> "$HOME/.zshrc"
    echo 'export FPATH="$HOME/tools/ripgrep/complete:$FPATH"' >> "$HOME/.zshrc"
fi

# ================= NEOVIM =================
NVIM_DIR="$TOOLS_DIR/nvim"
NVIM_SRC="$PACKAGES_DIR/nvim.tar.gz"
NVIM_LINK="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"

if [[ ! -x "$NVIM_DIR/bin/nvim" ]]; then
    echo "Installing Neovim"

    mkdir -p "$NVIM_DIR"

    if [[ ! -f "$NVIM_SRC" ]]; then
        wget "$NVIM_LINK" -O "$NVIM_SRC"
    fi

    tar zxf "$NVIM_SRC" -C "$NVIM_DIR" --strip-components=1

    export PATH="$NVIM_DIR/bin:$PATH"
    echo 'export PATH="$HOME/tools/nvim/bin:$PATH"' >> "$HOME/.zshrc"
fi

# ================= NVIM CONFIG =================
NVIM_CONFIG="$HOME/.config/nvim"

rm -rf "$NVIM_CONFIG.backup" || true
[[ -d "$NVIM_CONFIG" ]] && mv "$NVIM_CONFIG" "$NVIM_CONFIG.backup"

git clone --depth=1 https://github.com/jdhao/nvim-config.git "$NVIM_CONFIG"

# Install plugins
"$NVIM_DIR/bin/nvim" -c "autocmd User LazyInstall quitall" -c "lua require('lazy').install()"

source $HOME/.zshrc
echo "DONE ✔"
