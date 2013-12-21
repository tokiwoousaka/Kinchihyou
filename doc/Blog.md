法事なので忌日表作ります
=================================================

つい先日、身内に不幸がありまして、海外のコメディドラマ顔負けのドタバタを繰り広げたりしていたわけですけども
・・・あ、ドラマとかはあんま見ないんですが。
そんなドタバタも一段落ついて、n年ぶりくらいに母ゆっくりとした時間を過ごしたりとか過ごしてなかったりとかする今日このごろです。

ども、凝り固まった背中にフェルビナクがよく効きます。おっさん化の著しいちゅーんさんです。  

つい最近ちょいとしたブログネタを仕入れたのもあり、さっきまでゴニョゴニョと関連資料を読み漁ったりしていたのですが、
ふとツイッターを見ると、我らがさっちゃん(@ne_sachirou)からリプライを貰っていた事に気がついたのです。

[ツイッターの内容]

ええ、すっかり忘れてました、アドベントカレンダーです。  
今書こうと思ってるネタはどう考えても今日中に記事にできそうな感じでは無いですし、さてどうしましょう。

ネタ決め
-------------------------------------------------

* 俺「ｗｓでｒｆｔｇｙふじこｌｐ；＠
* 母「どうした息子よ
* 俺「ネタが無い
* 母「何の
* 俺「アドベントカレンダーの
* 母「アドベントカレンダー？それは何だ、食えるのか
* 俺「食えないよ。かくかくしかじか。
* 母「そうか、じゃぁネタをやろう
* 俺「うおお、かあちゃんの背後に後光が見える
* 母「かあちゃんはまだ健在だ。ホレ
* 俺「これは何だ
* 母「忌日表
* 俺「はぁ
* 母「これを作ってブログに書けば良いじゃない、直ぐできそうだしタイムリーだし面白い記事が書けそうだろ？
* 俺「なるほど、そうする。

全然関係ない話ですが、「忌日表」の読みが安定しません。母は「きじつひょう」と呼んでいたけど、ググってみたら「きにちひょう」とか「きんちひょう」
の方が正しそうです。まぁ、僕は男の子なので細かいことは気にしないでおきましょう。

Haskellでは日付を扱うのに`time`パッケージの`Data.Time`とかいうモジュールをがあるのですが、
そういえば、使ったことが無かったので、練習がてら、命日を入力すると忌日表を作成するようなツールを作ってみます。

どうしてこうなった。

Data.Timeモジュールの使い方
-------------------------------------------------

`Data.Time`モジュールは`Data.Time.Calender`というモジュールをエクスポートしており、その中に`Day`という型が定義されています。  
`Day`の定義は以下のようになっており、データコンストラクタ`ModifiedJulianDay`に修正ユリウス通日を指定すれば得ることができます。

```
*Main> :i Day
newtype Day = ModifiedJulianDay {toModifiedJulianDay :: Integer}
  	-- Defined in `time-1.4.0.1:Data.Time.Calendar.Days'
instance Enum Day
  -- Defined in `time-1.4.0.1:Data.Time.Calendar.Days'
instance Eq Day
  -- Defined in `time-1.4.0.1:Data.Time.Calendar.Days'
instance Ord Day
  -- Defined in `time-1.4.0.1:Data.Time.Calendar.Days'
instance Read Day
  -- Defined in `time-1.4.0.1:Data.Time.Format.Parse'
instance Show Day
  -- Defined in `time-1.4.0.1:Data.Time.Calendar.Gregorian'
instance ParseTime Day
  -- Defined in `time-1.4.0.1:Data.Time.Format.Parse'
instance FormatTime Day -- Defined in `Data.Time.Format'
```

修正ユリウス通日とか良くわからないですが、適当な数値を入れまくって探してみた所、今日は1858年11月17日から56647日目なんだそうです。へーすごい。  
ちなみに計算の仕方とかはWikipediaに色々書いてあるっぽいです。面倒くさいのでちゃんと見てないですが。

```
*Main> ModifiedJulianDay 56647
2013-12-21
```

単純にshowすればグレゴリオ暦で表示してくれるのですが、データとしてグレゴリオ暦に変換したり、グレゴリオ暦から`Day`型の値を取得したい場合、
`toGregorian`関数、`fromGregorian`関数を使えば良いっぽいです。

```
*Main> toGregorian $ ModifiedJulianDay 56647
(2013,12,21)
*Main> toModifiedJulianDay $ fromGregorian 2013 12 21
56647
```

日数を加算するには`addDays`関数、二つの`Day`型の値から経過日数を計算するには`diffDays`関数を使います。

```
*Main> addDays 11 $ fromGregorian 2013 12 21
2014-01-01
*Main> diffDays (fromGregorian 2014 1 1) (fromGregorian 2013 12 21)
11
```

年/年単位で加減算するには`addGregolianMonths*`関数および`addGregolianYears*`関数を使います。
日が溢れた場合の処理によって使い分けが必要みたい。

```
*Main> addGregorianYearsClip 1 $ fromGregorian 2016 2 29
2017-02-28
*Main> addGregorianYearsRollOver 1 $ fromGregorian 2016 2 29
2017-03-01
*Main> addGregorianMonthsClip 1 $ fromGregorian 2016 3 31
2016-04-30
*Main> addGregorianMonthsRollOver 1 $ fromGregorian 2016 3 31
2016-05-01
```

この辺の作りの自明さはとてもHaskellっぽくて好きです。ではさっそく、忌日表を計算するプログラムを書いていきましょう。

作る
-------------------------------------------------

とりあえず何も考えずに手元にある生忌日表を元に忌日のデータを作ってきます。

```haskell
type Kinchi = (String, (Integer, Integer, Integer))
kinchis :: [Kinchi]
kinchis =
  [ ("七七忌" , (0 ,0 ,48))
  , ("1周忌"  , (1 ,0 ,0 ))
  , ("3回忌"  , (2 ,0 ,0 ))
  , ("7回忌"  , (6 ,0 ,0 ))
  , ("13回忌" , (12,0 ,0 ))
  , ("17回忌" , (16,0 ,0 ))
  , ("23回忌" , (22,0 ,0 ))
  , ("27回忌" , (26,0 ,0 ))
  , ("33回忌" , (32,0 ,0 ))
  , ("37回忌" , (36,0 ,0 ))
  , ("50回忌" , (49,0 ,0 ))
  ]
```

なんか、ちゃんと作ろうとすると法要の日数の数え方って命日の前日から数える場合と当日から数える場合とあるっぽいです。  
今日は面倒なので手元にある忌日表そのまんま出せるように作ってきます。Haskellなので改修には強いですし、うるう年の扱いとかもとりあえずいいや。

で、計算処理をぽちぽち・・・

```haskell
calcKinchi :: Kinchi -> Day -> (String, Day)
calcKinchi (n, (y, m, d)) = (,) n . addDays d . addGregorianMonthsClip m . addGregorianYearsClip y

calcKinchis :: [Kinchi] -> Day -> [(String, Day)]
calcKinchis ks d = map (flip calcKinchi d) ks
```

main関数実装。
例外処理？なにそれ美味しいの？

```haskell
printKinchis :: [(String, Day)] -> IO ()
printKinchis = mapM_ putStrLn . map (\(n, d) -> n ++ " - " ++ show d)
  
main :: IO ()
main = do
  putStrLn "命日を入力してちょ(\"yyyy-mm-dd\")"
  meinichi <- return . read =<< getLine
  printKinchis $ calcKinchis kinchis meinichi
```

出来た！ 

```
命日を入力してちょ("yyyy-mm-dd")
2013-12-21
七七忌 - 2014-02-07
1周忌 - 2014-12-21
3回忌 - 2015-12-21
7回忌 - 2019-12-21
13回忌 - 2025-12-21
17回忌 - 2029-12-21
23回忌 - 2035-12-21
27回忌 - 2039-12-21
33回忌 - 2045-12-21
37回忌 - 2049-12-21
50回忌 - 2062-12-21
```

え、戒名？知るかっ！

まとめ
-------------------------------------------------

あー、なんと言いますか。  
びっくりするほど技術的に面白いこと無いです。  
多分実装するのにかかった時間より、この記事をおもしろおかしくするのにかかった労力のほうが大きいんじゃないかとか、そんな気もします。

まぁ、人生いつ何があるかわかりませんし、こういったものを用意しておくと役に立つ事も・・・

無いかな(´・ω・｀)

蛇足
-------------------------------------------------

英語できない
