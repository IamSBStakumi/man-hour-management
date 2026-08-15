# jujutsuに関して

jujutsu(以下、jj)はRust製のバージョン管理システム。
最新バージョンは0.44.0(2026/08/15時点)

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
# 1.リモートリポジトリとの関連付け
jj git remote add origin (url)

# 2.bookmarkの作成
jj bookmark create main -r @

# 3.commit
jj describe -m "commit comment"

# 4.push
jj git push
```

あるいはリモートのGitHubリポジトリをjjリポジトリとしてクローンすることも可能

```bash
jj git clone https://github.com/IamSBStakumi/xxxxx.git
```

その後、以下の作業が必要

```bash
# 1.bookmarkの作成
jj bookmark set main -r @

# コミット以降は同様
```

### 新規bookmarkの初回push

新規作成したbookmarkは、通常の`jj git push`ではpush対象にならない。
初回pushでは、対象のbookmarkを明示する。

```bash
jj git push --bookmark main
```

`--bookmark`で指定したbookmarkが未追跡の場合、push後に自動的に追跡される。

## branch

jjでは`bookmark`がgitのブランチに相当するものである。

```bash
# 作業bookmarkを作成
jj bookmark create feature/xxxxx -r @-

# GitHubへpush
jj git push --bookmark feature/xxxxx
```

## commit

```bash
jj commit filename -m "commit message"
```
