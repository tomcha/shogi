require_relative 'engine'
# coding:utf-8

class Engine_kifuread < Engine
  attr_reader :filenames
  attr_reader :filename
  attr_reader :kifudata

  def select_kifufile
    puts 'select file no?'
    @filenames.each_with_index do |f, i|
      puts "#{i}:#{f}"
    end
    selected_file_no = STDIN.gets.to_i 
    @filename = @filenames[selected_file_no]
  end

  #ファイルオープン
  def read_kifufile
    File.open("#{@filename}", "rt:shift_jis:utf-8") do |file|
      file.each_line do |kifu_str|
        if(kifu_str =~ /^('|V|N|\$|P|T)/)
        elsif(kifu_str !~(/^\+$/))
          @kifudata.push(kifu_str.chomp)
        end
      end
    end
  end

  def initialize
    @filenames = Array.new
    #../data/内のファイル名取得
    Dir.glob('./data/*.csa').each do |f|
      @filenames.push f
    end
    @kifudata = Array.new
    @game_pointer = 0
    select_kifufile
    read_kifufile
  end

  def get_sasite(last_sasite)
    if(last_sasite == nil)

    elsif((last_sasite =~ /^\+/) && (@game_pointer % 2 == 0))
      @game_pointer += 1
    end

    if(@kifudata[@game_pointer] =~ /^(%.*)$/)
      case $1
      when '%TIME_UP'
        sasite = '%TORYO'
      when '%TORYO'
        sasite = '%TORYO'
      when '%TSUMI'
        sasite = '%TORYO'
      end
    else
      @kifudata[@game_pointer] =~(/^(\+|\-)(.+)/)
      sasite = $2
      @game_pointer += 2
    end

    return sasite
  end
end
