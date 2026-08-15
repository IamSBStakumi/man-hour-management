# Jujutsuコマンドチートシート

対象バージョン: `jj 0.44.0`

## 基本概念

- `@`: 現在の作業コピーコミット
- `@-`: `@`の親コミット
- `@--`: `@`の祖父母コミット
- bookmark: Gitのbranchに相当する名前付き参照
- change ID: コミットを書き換えても基本的に変わらないjj固有のID
- commit ID: Git commitと互換性のある、内容に応じて変わるID

jjでは、ファイルの変更が自動的に`@`へ記録される。そのため、通常は`git add`に相当する操作を必要としない。

## よく使うGitコマンドとの対応

| 目的 | Git | Jujutsu |
| --- | --- | --- |
| 状態を確認 | `git status` | `jj status` |
| 差分を確認 | `git diff` | `jj diff` |
| 履歴を確認 | `git log --oneline --graph` | `jj log` |
| ファイルをステージ | `git add <file>` | 不要。変更は自動記録される |
| 全変更をコミット | `git commit -am "message"` | `jj commit -m "message"` |
| 一部ファイルをコミット | `git add <file> && git commit` | `jj commit <file> -m "message"` |
| コミットメッセージを変更 | `git commit --amend -m "message"` | `jj describe -m "message"` |
| 新しい作業を開始 | `git switch -c feature main` | `jj new main`後に`jj bookmark create feature -r @` |
| mainへ戻る | `git switch main` | `jj new main` |
| branch一覧 | `git branch -a` | `jj bookmark list --all` |
| branchを作成 | `git branch feature` | `jj bookmark create feature -r <revision>` |
| branchを移動 | `git branch -f feature <revision>` | `jj bookmark set feature -r <revision>` |
| branchを削除 | `git branch -d feature` | `jj bookmark delete feature` |
| リモートを確認 | `git remote -v` | `jj git remote list` |
| リモートを追加 | `git remote add origin <url>` | `jj git remote add origin <url>` |
| fetch | `git fetch origin` | `jj git fetch --remote origin` |
| branchをpush | `git push -u origin feature` | `jj git push --bookmark feature` |
| main上へrebase | `git rebase main` | `jj rebase -d main` |
| merge commitを作成 | `git merge feature` | `jj new main feature` |
| ファイルの変更を破棄 | `git restore <file>` | `jj restore <file>` |
| コミットを取り消す | `git revert <commit>` | `jj restore --changes-in <revision>` |
| 直前の操作を取り消す | 状況により`git reset`など | `jj undo` |
| 操作履歴を確認 | `git reflog` | `jj op log` |
| 過去の操作状態へ戻す | `git reset`やreflogを利用 | `jj op restore <operation-id>` |

Gitとjjではデータモデルが異なるため、上記は完全に同一の動作ではなく、目的が近いコマンドの対応である。

## リポジトリの作成と取得

### 初期化

```bash
jj git init
```

既存のGitリポジトリをjjでも扱う場合:

```bash
jj git init --git-repo=.
```

### clone

```bash
jj git clone <repository-url>
```

### remote

```bash
jj git remote list
jj git remote add origin <repository-url>
jj git remote set-url origin <repository-url>
jj git remote remove origin
```

## 状態・差分・履歴

```bash
# 作業状態
jj status

# 現在の変更
jj diff

# 特定コミットの変更
jj diff -r <revision>

# 2地点間の差分
jj diff --from <base> --to <head>

# 変更ファイルの概要
jj diff --from main --to <bookmark> --stat

# 履歴
jj log

# main以降の履歴
jj log -r 'main..@'

# 特定bookmarkのPR対象履歴
jj log -r 'main..<bookmark>'
```

## コミット

### 現在の変更に説明を付ける

`@`をそのまま編集し続ける場合:

```bash
jj describe -m "commit message"
```

### 変更を確定して次の作業コピーを作る

```bash
jj commit -m "commit message"
```

実行後、コミット済みの変更は`@-`、新しい空の作業コピーは`@`になる。

### 一部のファイルだけをコミット

```bash
jj commit path/to/file path/to/directory -m "commit message"
```

指定しなかった変更は新しい`@`に残る。

### 新しい変更を作る

```bash
# 現在のコミットの子
jj new

# mainの子
jj new main

# 指定したコミットの子
jj new <revision>
```

### 既存の変更を再編集

```bash
jj edit <revision>
```

通常は既存コミットの直接編集より、`jj new`と`jj squash`の利用が推奨される。

## bookmark

### 一覧

```bash
jj bookmark list
jj bookmark list --all
```

### 作成

```bash
# 現在の作業コピーを指す
jj bookmark create feature/example -r @

# jj commit直後のコミットを指す
jj bookmark create feature/example -r @-
```

### 移動

```bash
jj bookmark set feature/example -r @-
```

bookmarkを後方または別系統へ移動する場合:

```bash
jj bookmark set feature/example -r <revision> --allow-backwards
```

### 削除

```bash
jj bookmark delete feature/example
```

## fetch・rebase・push

### リモートの更新を取得

```bash
jj git fetch --remote origin
```

### 作業コミットを最新mainへ載せ替える

```bash
jj git fetch --remote origin
jj rebase -s @ -d main
```

複数コミットを含むbranch全体を載せ替える場合は、対象範囲を確認してから`-b`を使う。

```bash
jj rebase -b <bookmark> -d main
```

### bookmarkをpush

```bash
jj git push --bookmark feature/example
```

`--bookmark`で未追跡bookmarkをpushすると、そのリモートbookmarkが作成され、自動的に追跡される。

## PRベースの作業例

```bash
# 1. mainから作業開始
jj new main

# 2. ファイルを編集してコミット
jj commit -m "feat: add example"

# 3. PR用bookmarkを作成
jj bookmark create feature/example -r @-

# 4. push
jj git push --bookmark feature/example

# 5. PRを作成
gh pr create --base main --head feature/example
```

同じPRへ追加コミットをpushする場合:

```bash
jj commit -m "fix: address review comments"
jj bookmark set feature/example -r @-
jj git push --bookmark feature/example
```

PR用の変更と別の作業を分離する場合:

```bash
# PR用bookmarkを作成済みのコミットへ付ける
jj bookmark create feature/example -r @-

# 現在の残りの変更をmain上へ移動
jj rebase -s @ -d main
```

## 履歴の編集

### 現在の変更を親へまとめる

```bash
jj squash
```

一部ファイルだけを親へまとめる場合:

```bash
jj squash path/to/file
```

### コミットを分割

```bash
jj split
```

### コミットを削除

```bash
jj abandon <revision>
```

子コミットは削除したコミットの親へ自動的にrebaseされる。

### ファイルの変更を破棄

```bash
# 指定ファイルを親の状態へ戻す
jj restore path/to/file

# 現在の変更をすべて親の状態へ戻す
jj restore
```

## 操作の取り消しと復旧

### 直前の操作を取り消す

```bash
jj undo
```

### operation履歴を確認

```bash
jj op log
```

### 特定のoperationへ戻す

```bash
jj op restore <operation-id>
```

`jj op restore`はリポジトリ全体を指定時点へ戻すため、その後に行ったbookmark操作なども戻る。

## よく使うrevset

| revset | 意味 |
| --- | --- |
| `@` | 現在の作業コピーコミット |
| `@-` | 現在の作業コピーの親 |
| `@--` | 現在の作業コピーの祖父母 |
| `main` | ローカルのmain bookmark |
| `main@origin` | originのmain bookmark |
| `root()` | ルートコミット |
| `main..@` | mainの子孫かつ`@`の祖先にあるコミット |
| `heads(all())` | すべてのheadコミット |
| `bookmarks()` | ローカルbookmarkが指すコミット |
| `conflicts()` | conflictを含むコミット |

## 困ったとき

```bash
# コマンド一覧
jj help

# 個別コマンドのヘルプ
jj help <command>

# 状態確認
jj status
jj log
jj bookmark list --all

# conflict一覧
jj resolve --list

# 操作履歴
jj op log
```

push前には、対象bookmarkと差分を必ず確認する。

```bash
jj log -r 'main..<bookmark>'
jj diff --from main --to <bookmark> --stat
```
