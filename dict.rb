# -*- coding: utf-8 -*-

require 'uri'
require 'open-uri'
require 'rexml/document'

# 入力引数の検証
# オプション、検索語がない場合
if ARGV.length < 2 then
    puts "please input OPTION and WORD that want to search meaning"
    exit
# オプションがない場合
elsif ARGV.length == 2 and not(ARGV[0].include?("-")) then
    puts "please input OPTION with '-'"
    exit
end

# 引数を変数に代入
# オプションを設定
option = ARGV[0].gsub("-", "")
# 日本語をURLエンコード
searchWord = URI.escape(ARGV[1])

# オプションの正当性を確認
# 英和辞典を選択
case option
when "ej", "testej"
    dic = "EJdict"
# 和英辞典を選択
when "je", "testje"
    dic = "EdictJE"
# 誤ったオプションの場合
else
    puts "wrong OPTION! (must be \"-ej\" or \"-je\")"
    exit
end

# 検索メソッドへのリクエストURLを指定
url = "http://public.dejizo.jp/NetDicV09.asmx/SearchDicItemLite?Dic=#{dic}&Word=#{searchWord}&Scope=HEADWORD&Match=STARTWITH&Merge=AND&Prof=XHTML&PageSize=20&PageIndex=0"

# 検索メソッドのレスポンスを取得
result = open(url)
# 検索対象を保管するHash
ids = {}

case option
# 英和辞典での処理
when "ej", "testej"
    # 検索メソッドのレスポンスをXML形式に変換
    doc = REXML::Document.new(result)
    # XMLの各要素について、ハッシュidsに"id=>word"の形式で格納
    doc.elements.each("/SearchDicItemResult/TitleList/DicItemTitle") do |ele|
        id = ele.elements["ItemID"].text
        word = ele.elements["Title/span"].text
        ids[id] = word
    end
    # 登録されたHashの要素それぞれに対して処理
    ids.each do |id, word|
        # 内容取得メソッドへのリクエストURL
        url = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?Dic=#{dic}&Item=#{id}&Loc=&Prof=XHTML"
        result = open(url)                      # レスポンス
        doc = REXML::Document.new(result)       # XMLに変換
        # XMLの各要素について、データを加工して標準出力
        doc.elements.each("/GetDicItemResult") do |ele|
            puts word
            means = ele.elements["Body/div/div"].text.split("\t")
            means.each do |mean|
                puts "\t" + mean
            end
        end
    end

# 和英辞典をでの処理
when "je", "testje"
    # 検索メソッドのレスポンスをXML形式に変換
    doc = REXML::Document.new(result)
    # XMLの各要素について、ハッシュidsに"id=>word"の形式で格納
    doc.elements.each("/SearchDicItemResult/TitleList/DicItemTitle") do |ele|
        id = ele.elements["ItemID"].text
        word = ele.elements["Title/span"].text
        ids[id] = word
    end
    # 登録されたHashの要素それぞれに対して処理
    ids.each do |id, word|
        # 内容取得メソッドへのリクエストURL
        url = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?Dic=#{dic}&Item=#{id}&Loc=&Prof=XHTML"
        result = open(url)                      # レスポンス
        doc = REXML::Document.new(result)       # XMLに変換
        # XMLの各要素について、データを加工して標準出力
        doc.elements.each("/GetDicItemResult") do |ele|
            puts word
            means = ele.elements["Body/div/div/div"].text.split("\t")
            means.each do |mean|
                puts "\t" + mean
            end
        end
    end
end

