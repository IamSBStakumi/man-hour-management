---
description: 現在のbookmarkの変更をPR作成前に検査し、差分からPR本文を組み立ててgh pr createする。pre-PRゲートを兼ねる。
---

# PR作成（pre-PRゲート付き /pr-create）

このコマンドはPRを出す前のゲートを兼ねる。検査に通らなければPRを作らない。検査を通過したら、Jujutsuの差分からタイトルと本文を組み立て、ユーザーの承認後にbookmarkのpushとPR作成を行う。

作業diffのレビューだけなら`/review`、既に開いているPRへレビューを投稿するなら`/pr-review`を使う。

## 使い方

```text
/pr-create
/pr-create --base develop   # baseを指定（既定はmain）
/pr-create --draft          # Draft PRとして作成
/pr-create --yes            # 内容確認を省いて作成
```

## 手順

### 1. 実行環境と変更範囲の確認

次を確認する。

```bash
jj root
gh --version
gh auth status
jj git remote list
jj status
jj bookmark list --all
```

- `origin`のURLが正しく、GitHub CLIが認証済みであること。
- PRのheadには`main`以外の作業bookmarkを使用すること。
- `@`または`@-`に対応する作業bookmarkを一意に特定できること。
- baseとheadの間にPR対象の差分があること。
- 未解決conflict、説明のないコミット、対象外の変更が混在していないこと。

作業bookmarkを一意に特定できない場合や変更範囲が不明確な場合は、pushせずユーザーへ確認する。認証情報やトークンは出力しない。

### 2. 検査とレビュー

Jujutsuを正として、コミットと差分を確認する。

```bash
jj log -r '<base>..<head>'
jj diff --from '<base>' --to '<head>'
```

colocated Gitリポジトリの`HEAD`はJujutsuの作業状態と一致しない場合があるため、`git log <base>..HEAD`だけで変更範囲を決定しない。

プロジェクトに定義されたformat、lint、testを調べ、変更範囲に関係する検査を実行する。検査に失敗した場合はPRを作成しない。該当する検査コマンドが存在しない場合は、その旨を確認画面とPR本文に記載する。

### 3. PRタイトルと本文の作成

タイトルは`<type>: <subject>`形式にする。typeにはgit-flowに従い、`feat`、`fix`、`refactor`、`docs`、`test`、`chore`のいずれかを使用する。

`.github/pull_request_template.md`が存在する場合は各節を埋める。存在しない場合は、次の見出しで本文を作成する。

- 概要: 何を、なぜ変更したか。
- 変更内容: 主な実装内容。
- 対象外: 今回対応していないこと。
- 確認方法: 実行した検査と結果。検査がない場合はその旨。
- レビュアーへの確認事項: 判断が分かれた点や要確認事項。

差分の逐語的なコピーを避け、判断と理由が分かる日本語で記述する。`.claude/rules/japanese-writing.md`が存在する場合はその規範にも従う。

### 4. 作成前の確認

pushとPR作成の前に、次をまとめて提示する。

- baseとhead
- push対象のbookmarkとコミット
- PRタイトルと本文
- 実行した検査と結果
- DraftかReady for reviewか

`--yes`が指定されていない場合は、ユーザーの承認を得るまで外向きの操作を行わない。`--yes`が指定されていても、conflict、検査失敗、対象bookmarkの曖昧さ、認証失敗は無視しない。

### 5. bookmarkのpush

作業bookmarkがPR対象の先端を指していない場合は、承認済みの移動先へ更新する。その後、対象bookmarkを明示してpushする。

```bash
jj bookmark set '<bookmark>' -r '<head>'
jj git push --bookmark '<bookmark>'
```

### 6. PRの作成

同じheadのPRが既に存在しないことを確認する。

```bash
gh pr list --head '<bookmark>'
```

既存PRがある場合は新規作成せず、そのURLを返す。存在しない場合はPR本文を標準入力で渡して作成する。

```bash
gh pr create --base '<base>' --head '<bookmark>' --title '<title>' --body-file -
```

`--draft`指定時のみ`--draft`を追加する。作成後、PRのURLと、base、head、検査結果を返す。Co-Authored-Byは付けない。
