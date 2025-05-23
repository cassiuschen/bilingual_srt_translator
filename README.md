##使用方法

安装依赖：

```bash
bundle install
```

配置环境变量：
```bash
cp .env.example .env
# 编辑.env文件添加API密钥
```

运行程序：
```bash
# 使用默认配置
ruby app.rb input.srt

# 指定配置文件
ruby app.rb -c config/custom.yml input.srt
```