# Flutter Web を GitHub Pages で公開する手順

## ブランチ構成

- **main**: ソースコード（HTML アプリ + Flutter アプリ）
- **gh-pages**: Flutter Web のビルド成果物のみ（GitHub Pages で公開）

## 初回：GitHub にリポジトリを作成してプッシュ

1. GitHub で新しいリポジトリを作成（例: `1st-pj`）
2. リモートを追加して**両方のブランチ**をプッシュ（main だけだと Pages に何も出ません）:

```bash
cd d:\src\1st-pj
git remote add origin https://github.com/<ユーザー名>/<リポジトリ名>.git
git push -u origin main
git push -u origin gh-pages
```

**注意**: `git push -u origin gh-pages` を実行しないと、GitHub の gh-pages ブランチは空のままです。必ず両方プッシュしてください。

3. GitHub のリポジトリ → **Settings** → **Pages** で、**Source** に **Deploy from a branch** を選び、**Branch** で `gh-pages` / `/ (root)` を選択して Save

4. 数分後、`https://<ユーザー名>.github.io/<リポジトリ名>/` で Flutter Web アプリが表示されます。

## 更新時：Flutter Web を再ビルドして gh-pages を更新

**重要**: GitHub Pages は `https://<user>.github.io/quit_smoking_app/` のようにサブパスで配信するため、必ず `--base-href "/quit_smoking_app/"` を付けてビルドしてください。付けないとアセットが読み込めず白画面になります。

```bash
cd d:\src\1st-pj\quit_smoking_app
flutter build web --base-href "/quit_smoking_app/"
cd ..
git checkout gh-pages
git rm -rf .
Copy-Item -Path "quit_smoking_app\build\web\*" -Destination "." -Recurse -Force
# .gitignore に quit_smoking_app のみ書かれていることを確認
git add .
git commit -m "Update Flutter Web build"
git push origin gh-pages
git checkout main
```

（PowerShell の場合。Bash の場合は `cp -r quit_smoking_app/build/web/* .` などに読み替えてください。）

## gh-pages に何も表示されない場合

- リモートに gh-pages をまだプッシュしていない場合、以下でプッシュできます（リモート `origin` を追加済みなら）:

```bash
cd d:\src\1st-pj
git push -u origin gh-pages
```

- GitHub のリポジトリページで **Branch** 一覧に `gh-pages` が出ているか確認してください。出ていれば、Settings → Pages で Branch に `gh-pages` を選んで保存すると公開されます。
