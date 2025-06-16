#!/bin/bash
# macOS環境のセットアップスクリプト
# エラーが発生したら処理を中断する設定
set -euo pipefail

# --- Homebrewのチェックとツールのインストール ---
echo "---- Checking and installing tools with Homebrew ----"
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Brewfileを使って、必要なツールをまとめてインストール/アップデート
brew bundle --file=./Brewfile

# --- Python仮想環境のセットアップ ---
echo "---- Setting up Python virtual environment (.venv) ----"
# .venvディレクトリがなければ作成
if [ ! -d ".venv" ]; then
  echo "Creating .venv..."
  python3 -m venv .venv
fi

# 仮想環境をアクティベートして、Pythonパッケージをインストール
echo "Installing Python packages from requirements.txt..."
source .venv/bin/activate
pip install -r requirements.txt
ansible-galaxy collection install community.kubernetes
deactivate # パッケージインストール後に一旦非アクティブ化

mkdir -p ./.kube
ssh k8s-master "sudo cat /etc/kubernetes/admin.conf" > ./.kube/config

echo "---- Setup complete! ----"
echo "To activate the virtual environment, run: source .venv/bin/activate"