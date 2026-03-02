# Flutter Web を GitHub Pages で公開する手順

## ブランチ構成

- **main**: ソースコード（HTML アプリ + Flutter アプリ）
- **gh-pages**: Flutter Web のビルド成果物のみ（GitHub Pages で公開）

## 初回：GitHub にリポジトリを作成してプッシュ

1. GitHub で新しいリポジトリを作成（例: `1st-pj`）
2. リモートを追加して両ブランチをプッシュ:

```bash
cd d:\src\1st-pj
git remote add origin https://github.com/<ユーザー名>/<リポジトリ名>.git
git push -u origin main
git push -u origin gh-pages
```

3. GitHub のリポジトリ → **Settings** → **Pages** で、**Source** に **Deploy from a branch** を選び、**Branch** で `gh-pages` / `/ (root)` を選択して Save

4. 数分後、`https://<ユーザー名>.github.io/<リポジトリ名>/` で Flutter Web アプリが表示されます。

## 更新時：Flutter Web を再ビルドして gh-pages を更新

```bash
cd d:\src\1st-pj\quit_smoking_app
flutter build web
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
