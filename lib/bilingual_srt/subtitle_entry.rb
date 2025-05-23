class SubtitleEntry
  attr_accessor :index, :time_range, :original_text, :translated_text, :error

  def initialize(index, time_range, original_text)
    @index = index
    @time_range = time_range
    @original_text = original_text
    @translated_text = nil
    @error = nil
  end

  def translated?
    !@translated_text.nil? && @translated_text != "[翻译失败]"
  end

  def to_s
    "#{index}\n#{time_range}\n#{original_text}\n#{translated_text}\n\n"
  end
end