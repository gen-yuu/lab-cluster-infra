#!/bin/bash
# Ubuntu環境のセットアップスクリプト
# エラーが発生したら処理を中断する設定
set -euo pipefail

# --- APTパッケージリストの更新と基本ツールのインストール ---
echo "---- Updating APT and installing base packages ----"
sudo apt-get update -y
# curl, gpg, gitなどをインストール
sudo apt-get install -y curl gpg git apt-transport-https ca-certificates

# --- Kubernetesツールのインストール ---
echo "---- Installing Kubernetes tools ----"

# 1. kubectlのインストール
echo "Installing kubectl..."
KUBE_VERSION="v1.33"
# GPGキーをダウンロードして保存
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# APTリポジトリの情報を追加
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# 2. helmのインストール
echo "Installing helm..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# 3. argocd CLIのインストール
echo "Installing argocd cli..."
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# --- Ansible Lintのインストール ---
echo "---- Installing Ansible Lint ----"
sudo apt-get install -y ansible-lint

# --- Python仮想環境のセットアップ ---
echo "---- Setting up Python virtual environment (.venv) ----"
# python3-venvとpipをインストール
sudo apt-get install -y python3-venv python3-pip

# .venvディレクトリがなければ作成
if [ ! -d ".venv" ]; then
  echo "Creating .venv..."
  python3 -m venv .venv
fi

# 仮想環境をアクティベートして、Pythonパッケージをインストール
# requirements.txtが存在する場合のみ実行
if [ -f "requirements.txt" ]; then
  echo "Installing Python packages from requirements.txt..."
source .venv/bin/activate
  pip install -r requirements.txt
  ansible-galaxy collection install community.kubernetes
  deactivate # パッケージインストール後に一旦非アクティブ化
else
  echo "requirements.txt not found. Skipping pip install."
fi


echo "---- Setup complete! ----"
echo "To activate the virtual environment, run: source .venv/bin/activate"