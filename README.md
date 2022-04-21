# コンピュータ論理設計 / Computer Logic Design

Tokyo Institute of Technology 2022-1Q

## ACRi 接続方法 & 環境構築

### 環境構築
1. `code ~/.ssh/config`でリモート接続時のコマンドを省略する
2. 
```
Host acri
  HostName gw.acri.c.titech.ac.jp
  User <user-name>
  PreferredAuthentications publickey
  UseKeychain yes
  AddKeysToAgent yes
```

のような内容を追加する。

3. vscodeで Remote - SSH という拡張機能をインストール
4. Connect to Host から acri へ接続する


### 接続方法

5. `4.` の方法でアクセスできた先では `iverilog <filename>.v`のような処理は行えないので、自分が予約したサーバへアクセスする。
  `ssh vs<server-number>` でアクセスする。

6. vscode側で、Open Folder から cld を選択し開く
7. GUIでファイルを見ることができる

8. ローカルからリモートへデータをアップロードする場合は、ドラック&ドロップで可能
9. リモートからローカルへデータをダウンロードする場合は、ファイルを選択して右クリックでダウンロードが可能(ファイル指定でするのは面倒なので、ダウンロードしたいファイルをまとめてフォルダにするのが良い )

### 参考資料

- [Qiita: SSH公開鍵認証で接続するまで](https://qiita.com/kazokmr/items/754169cfa996b24fcbf5)
- [Qitta:` ~/.ssh/config` ](https://qiita.com/passol78/items/2ad123e39efeb1a5286b)
- [Qiita: OpenSSHと踏み台運用](https://qiita.com/aucfan-yotsuya/items/5a5f017dbc6ae778096a)
- [ACRi](https://gw.acri.c.titech.ac.jp/wp/manual/how-to-reserve)
- [ACRi MacOS](https://www.acri.c.titech.ac.jp/wordpress/archives/1730)

## ローカル環境で iverilog を使えるようにする

1. `brew install icarus-verilog`   
[homebrew-icarus-verilog](https://formulae.brew.sh/formula/icarus-verilog)

2. `brew install --cask xquartz gtkwave`   
GTKWaveのインストール

### 参考資料

[Qiita: iverilog MacOS](https://qiita.com/y-vectorfield/items/51b778ded1b2cad92f63)
## Vivado, Vitis (SDK)　関連

### 参考資料

[ACRi: サーバで Vivado と Vitis (または SDK) を使用する](https://gw.acri.c.titech.ac.jp/wp/manual/vivado-vitis)

## Verilog-HDL の文法

[Verilog-HDL](./docs/verilog-hdl.md)