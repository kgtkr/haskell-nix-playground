# haskell-nix-playground

## HLSが環境にある状態でVSCode起動
```sh
$ direnv allow
$ nix develop -c code .
```

## ビルド
```sh
$ nix build
# ./result/bin/haskell-nix-playground
```

### ghcjs
```sh
$ nix build .#js-unknown-ghcjs:haskell-nix-playground:exe:haskell-nix-playground-app
# node result/bin/haskell-nix-playground.jsexe/all.js
```

## テスト
```sh
$ cabal test
```

## repl
```sh
$ cabal repl haskell-nix-playground-app
:main
```

## materialization更新
```sh
$ nix run .#materialize
# shaに変更がある場合はflake.nixを書き換える
```

## checkMaterialization
```sh
$ nix build .#checkMaterialization
```

## nixファイルフォーマット
```sh
$ nixpkgs-fmt $$(git ls-files ":(attr:!linguist-generated)*.nix")
```

