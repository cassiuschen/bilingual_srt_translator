# 双语字幕翻译器
本项目可输入一个英文 srt 文件，通过大模型将生成对应中英双语字幕。

## 使用方法

安装依赖：

```bash
bundle install
```

配置环境变量：
```bash
cp .env.example .env
# 编辑.env文件添加API密钥，当前程序使用阿里云百炼平台作为 base_url，需要填写百炼的 API_KEY
```

编辑配置文件`config.yml`：
```yaml
video_context: "[这是填写要翻译的视频大致内容，以增强翻译准确度]"
model: deepseek-v3 #可根据需要更换模型
system_prompt: "你是一个精通户外相关知识的专业的翻译，擅长将英文电影字幕翻译成流畅自然的中文。" #基础的system_prompt，可用于增加翻译准确性  
max_concurrency: 5 # 最大并发请求数
```

运行程序：
```bash
# 使用默认配置
ruby app.rb input.srt

# 也可以单独指定配置文件
ruby app.rb -c config/custom.yml input.srt

# Verbose 模式下会显示完整模型返回
ruby app.rb input.srt --verbose
```