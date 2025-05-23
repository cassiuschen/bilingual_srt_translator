class BilingualSrtApp
  def initialize
    @options = parse_options
    @config = load_config
  end

  # 解析命令行选项
  def parse_options
    options = {}
    
    OptionParser.new do |opts|
      opts.banner = "用法: ruby app.rb [选项] <输入SRT文件>"
      
      opts.on("-c", "--config CONFIG_FILE", "配置文件路径") do |config_file|
        options[:config_file] = config_file
      end
      
      opts.on("-o", "--output OUTPUT_FILE", "输出SRT文件路径") do |output_file|
        options[:output_file] = output_file
      end
      
      opts.on("-v", "--verbose", "启用详细输出模式") do
        options[:verbose] = true
      end
      
      opts.on_tail("-h", "--help", "显示此帮助信息") do
        puts opts
        exit
      end
    end.parse!
    
    options[:input_file] = ARGV[0]
    raise "请指定输入SRT文件" unless options[:input_file]
    
    options
  end

  # 加载配置文件
  def load_config
    config_file = @options[:config_file] || 'config.yml'
    
    if File.exist?(config_file)
      YAML.load_file(config_file) || {}
    else
      {}
    end
  end

  # 获取输出文件路径
  def get_output_path
    if @options[:output_file]
      @options[:output_file]
    else
      input_file = @options[:input_file]
      dir = File.dirname(input_file)
      base = File.basename(input_file, '.*')
      ext = File.extname(input_file)
      File.join(dir, "#{base}-CN#{ext}")
    end
  end

  # 运行应用
  def run
    input_file = @options[:input_file]
    output_file = get_output_path
    
    puts "开始处理字幕文件: #{input_file}"
    
    processor = SrtProcessor.new(@config)
    translator = OpenAITranslator.new(@config, verbose: @options[:verbose])
    
    # 解析SRT文件
    entries = processor.parse_srt(input_file)
    puts "已解析 #{entries.size} 条字幕"
    
    # 并发翻译所有条目
    translator.translate_entries(entries)
    
    # 重试失败的条目
    translator.retry_failed_entries(entries)
    
    # 保存双语SRT文件
    processor.save_bilingual_srt(entries, output_file)
  end
end