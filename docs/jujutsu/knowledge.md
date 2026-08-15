# jujutsuに関して

jujutsu(以下、jj)はRust製のバージョン管理システム。
最新バージョンは0.44.0(2026/08/15時点)で正式リリースはまだの状態。

## How to Install

Rustのビルドシステム兼パッケージマネージャである
`cargo`を用いてインストールする。(公式推奨)

```bash
cargo install --locked --bin jj jj-cli
```

brew installもOK

## Init

以下コマンドで、リポジトリの初期化を行う

```bash
jj git init
```

その後、以下の操作が必要

```bash
// 1.リモートリポジトリとの関連付け
jj git remote add origin https://github.com/IamSBStakumi/man-hour-management.git

// 2.bookmarkの作成
jj bookmark create -r "@-" main

// 3.リモートリポジトリのブランチとの対応付け
jj bookmark track main@origin

// 4.push
jj git push
```

あるいはリモートのGitHubリポジトリをjjリポジトリとしてクローンすることも可能

```bash
jj git clone https://github.com/IamSBStakumi/xxxxx.git
```
