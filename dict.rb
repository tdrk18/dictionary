# -*- coding: utf-8 -*-

require 'net/http'
require 'uri'
require 'open-uri'
require 'rexml/document'
require 'nkf'

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
option = ARGV[0].gsub("-", "")
searchWord = ARGV[1]

# オプションの正当性を確認
# 英和辞典を選択
if option == "ej" then
    dic = "EJdict"
# 和英辞典を選択
elsif option == "je" then
    dic = "EdictJE"
    # 日本語をURLエンコード
    searchWord = URI.escape(searchWord)
# 誤ったオプションの場合
else
    puts "wrong OPTION! (\"-ej\" or \"-je\")"
    exit
end

# 検索メソッドへのリクエストURLを指定
url = "http://public.dejizo.jp/NetDicV09.asmx/SearchDicItemLite?Dic=#{dic}&Word=#{searchWord}&Scope=HEADWORD&Match=STARTWITH&Merge=AND&Prof=XHTML&PageSize=20&PageIndex=0"

# 検索メソッドのレスポンスを取得
result = open(url)
# 検索対象を保管するHash
ids = {}

# 英和辞典での処理
if option == "ej" then
    result.each do |r|
        # 確認用
        # p r
        # if r.include?("TotalHitCount") then
        #     r.gsub!("<TotalHitCount>", "")
        #     r.gsub!("</TotalHitCount>", "")
        #     r.strip!
        # end
        # 検索対象のItemIDを取得
        if r.include?("ItemID") then
            r.gsub!("<ItemID>", "")
            r.gsub!("</ItemID>", "")
            r.strip!
            $id = r
        end
        # 検索対象の文字列を取得
        if r.include?("NetDicTitle") then
            r.gsub!(/<.+">/, "")
            r.gsub!(/<.+>/, "")
            r.strip!
            # ItemIDをキーとしてHashに登録
            ids[$id] = r
        end
    end
    
    # 登録されたHashの要素それぞれに対して処理
    ids.each do |id, word|
        # 内容取得メソッドへのリクエストURL
        url = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?Dic=#{dic}&Item=#{id}&Loc=&Prof=XHTML"
        result = open(url)                      # レスポンス
        flag = false                            # 標準出力用フラグ
        result.each do |r|
            # 標準出力用にデータ整形
            if flag == true then
                r.gsub!("<div>", "")
                r.gsub!("</div>", "")
                r.strip!
                r.gsub!("\t", "\n\t")
                r = "\t" + r
                # 出力
                puts word
                puts r
                # フラグリセット
                flag = false
            end
            # フラグをセット
            if r.include?("NetDicBody") then
                flag = true
            end
        end
    end
end

# 和英辞典での処理
if option == "je" then
    result.each do |r|
        # 確認用
        # p r
        # if r.include?("TotalHitCount") then
        #     r.gsub!("<TotalHitCount>", "")
        #     r.gsub!("</TotalHitCount>", "")
        #     r.strip!
        #     p r
        # end
        # 検索対象のItemIDを取得
        if r.include?("ItemID") then
            r.gsub!("<ItemID>", "")
            r.gsub!("</ItemID>", "")
            r.strip!
            $id = r
        end
        # 検索対象の文字列を取得
        if r.include?("NetDicTitle") then
            r.gsub!(/<.+">/, "")
            r.gsub!(/<.+>/, "")
            r.strip!
            # ItemIDをキーとしてHashに登録
            ids[$id] = r
        end
    end
    
    # 登録されたHashの要素それぞれに対して処理
    ids.each do |id, word|
        # 内容取得メソッドへのリクエストURL
        url = "http://public.dejizo.jp/NetDicV09.asmx/GetDicItemLite?Dic=#{dic}&Item=#{id}&Loc=&Prof=XHTML"
        result = open(url)                      # レスポンス
        result.each do |r|
            # 標準出力用にデータ整形
            if r.include?("(n)") or r.include?("(exp)") then
                r.gsub!(/<div>\(n\)/, "")
                r.gsub!(/<div>\(exp\)/, "")
                r.gsub!(/<.+>/, "")
                r.strip!
                r = "\t" + r
                # 出力
                puts word
                puts r
            end
        end
    end
end


