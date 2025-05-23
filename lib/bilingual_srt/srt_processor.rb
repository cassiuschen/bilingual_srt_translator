class SrtProcessor
  def initialize(config)
    @config = config
  end

  # 解析SRT文件
  def parse_srt(file_path)
    content = File.read(file_path)
    entries = []
    
    content.split(/\n\n+/).each do |block|
      next if block.strip.empty?
      
      lines = block.strip.split("\n")
      next if lines.size < 3
      
      index = lines[0].strip
      time_range = lines[1].strip
      original_text = lines[2..-1].join("\n")
      
      entries << SubtitleEntry.new(index, time_range, original_text)
    end
    
    entries
  end

  # 生成双语SRT内容
  def generate_bilingual_srt(entries)
    entries.map do |entry|
      "#{entry.index}\n#{entry.time_range}\n#{entry.original_text}\n#{entry.translated_text}\n\n"
    end.join
  end

  # 保存双语SRT文件
  def save_bilingual_srt(entries, output_path)
    content = generate_bilingual_srt(entries)
    File.write(output_path, content)
    puts "双语字幕已保存至: #{output_path}"
  end
end