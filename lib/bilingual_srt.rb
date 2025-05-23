# 加载模块
require_relative 'bilingual_srt/subtitle_entry' # 字幕条目结构
require_relative 'bilingual_srt/progress_display' # 进度显示
require_relative 'bilingual_srt/srt_processor' # SRT文件处理
require_relative 'bilingual_srt/openai_translator' # OpenAI翻译及并发翻译逻辑
require_relative 'bilingual_srt/bilingual_srt_app' # 主应用