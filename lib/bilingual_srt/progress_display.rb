class ProgressDisplay
  def initialize(total)
    @total = total
    @processed = 0
    @success = 0
    @failed = 0
    @symbols = Array.new(total, '.') # 初始化所有为点
    
    # 启用彩色输出
    @green = "\e[32m"
    @red = "\e[31m"
    @reset = "\e[0m"
    
    print_progress
  end

  def update(index, success)
    @processed += 1
    if success
      @success += 1
      @symbols[index] = "#{@green}✓#{@reset}"
    else
      @failed += 1
      @symbols[index] = "#{@red}✗#{@reset}"
    end
    print_progress
  end

  def print_progress
    # 清除当前行
    print "\r"
    
    # 打印进度条
    print @symbols.join(' ')
    
    # 打印统计信息
    print " | 总数: #{@total} | 成功: #{@success} | 失败: #{@failed} | 处理中: #{@processed}/#{@total}"
  end

  def finish
    puts "\n翻译完成!"
  end
end