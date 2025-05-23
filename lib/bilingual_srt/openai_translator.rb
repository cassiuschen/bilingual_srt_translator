class OpenAITranslator
  def initialize(config, verbose: false)
    @config = config
    @api_key = ENV['OPENAI_API_KEY']
    raise "请在.env文件中设置OPENAI_API_KEY" unless @api_key
    
    # 初始化OpenAI客户端
    @client = OpenAI::Client.new(
      api_key: @api_key,
      base_url: "https://dashscope.aliyuncs.com/compatible-mode/v1"
    )

    @verbose = verbose
  end

  # 获取完整的系统提示
  def get_system_prompt(entries)
    fixed_prompt = @config['fixed_prompt'] || "你是一个精通户外相关知识的专业的翻译，擅长将英文电影字幕翻译成流畅自然的中文。"
    video_context = @config['video_context'] || ""
    full_text = entries.map(&:original_text).join("\n\n")
    
    <<~PROMPT
    #{fixed_prompt}
    
    视频背景信息:
    #{video_context}
    
    字幕全文:
    #{full_text}

    下面我将给出其中一句话，请你结合全文上下文语境，精确的将其翻译成中文，并只输出翻译结果。请注意，结果应该中文为主，可以保留部分专有名词的英文名称；另外输出结果应该仅为文字，不包含任何样式等内容。
    PROMPT
  end

  # 翻译单个条目
  def translate_entry(entry, system_prompt, progress_display = nil, index = nil)
    begin
      puts "正在处理第#{entry.index}条" if @verbose

      response = @client.chat.completions.create(
        model: @config['model'] || "gpt-3.5-turbo",
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: entry.original_text }
        ],
        temperature: 0.3
      )
      puts "#{@config['model'] || 'gpt-3.5-turbo'}回应：#{JSON.pretty_generate response}" if @verbose
      #entry.translated_text = response.to_h.dig(:choices, 0, :message, :content).to_s.strip
      entry.translated_text = response.to_h[:choices][0][:message][:content].to_s.strip
      entry.error = nil
      
      puts "已翻译条目 #{entry.index}" if @verbose
      progress_display&.update(index, true)

      entry
    rescue => e
      puts "翻译条目 #{entry.index} 时出错: #{e.message}" if progress_display.nil?
      entry.translated_text = "[翻译失败]"
      entry.error = e.message
      progress_display&.update(index, false)
      
      entry
    end
  end

  # 并发翻译所有条目
  def translate_entries(entries)
    system_prompt = get_system_prompt(entries)
    progress_display = @verbose ? nil : ProgressDisplay.new(entries.size)

    max_concurrency = [@config['max_concurrency'] || 5, entries.size].min
    puts "将使用 #{max_concurrency} 个并发请求进行翻译" unless @verbose
    
    # 创建线程池
    executor = Concurrent::FixedThreadPool.new(max_concurrency)
    promises = []
    
    entries.each_with_index do |entry, index|
      promises << Concurrent::Promise.execute(executor: executor) do
        translate_entry(entry, system_prompt, progress_display, index)
      end
    end
    
    # 等待所有任务完成
    Concurrent::Promise.zip(*promises).wait.value
    
    # 关闭线程池
    executor.shutdown
    progress_display&.finish
    
    entries
  end

  # 获取未翻译的条目
  def get_failed_entries(entries)
    entries.select { |entry| !entry.translated? }
  end

  # 重试翻译失败的条目
  def retry_failed_entries(entries)
    failed_entries = get_failed_entries(entries)
    
    if failed_entries.empty?
      puts "所有条目均已成功翻译!"
      return entries
    end
    
    puts "有 #{failed_entries.size} 个条目翻译失败，需要重试。"
    
    loop do
      # 重试失败的条目
      failed_entries = get_failed_entries(entries)
      if failed_entries.empty?
        puts "所有条目均已成功翻译!"
        break
      end
      
      puts "正在重试翻译失败的条目..."
      # 创建新的进度显示器，只显示失败的条目
      progress_display = @verbose ? nil : ProgressDisplay.new(failed_entries.size)
      
      failed_entries.each_with_index do |entry, index|
        translate_entry(entry, get_system_prompt(entries), progress_display, index)
      end
      
      progress_display.finish
      
      # 再次检查是否还有失败的条目
      failed_entries = get_failed_entries(entries)
      
      if failed_entries.empty?
        puts "所有条目均已成功翻译!"
        break
      else
        print "仍有 #{failed_entries.size} 个条目翻译失败。是否继续重试? (y/n): "
        answer = gets.chomp.downcase
        
        unless answer == 'y'
          puts "保存当前已翻译的内容..."
          break
        end
      end
    end
    
    entries
  end
end