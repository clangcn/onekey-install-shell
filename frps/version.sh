#!/bin/bash
frpver=$(wget -qO- https://github.com/fatedier/frp/releases/latest | grep "<title>" |sed -r 's/.*Release (.+) · fatedier.*/\1/')
export FRPS_VER=${frpver:1}
export FRPS_INIT="https://raw.githubusercontent.com/clangcn/onekey-install-shell/master/frps/frps.init"
export aliyun_download_url="https://code.aliyun.com/clangcn/frp/raw/master"
export github_download_url="https://github.com/fatedier/frp/releases/download"
