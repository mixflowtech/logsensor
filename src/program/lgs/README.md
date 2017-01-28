# LGS, the LogSensor Agent

由一系列的子命令构成，

###　服务端配置

- {prog} set  <key> <value>
    设置　key 下面的值，如果 key 为一个数组形式，则 value　替换所有的值，作为 [0] 号元素
- {prog} get  <key>　[--all]
    读取 key　下面的值, 如果　--all 选项开启，则猎取下面的全部的子配置项目
- {prog} list <key>
    列出　key　下面的全部 subkey
- {prog} add  <key> <value>
    添加　value　到　key 条目下，作为数组的一个元素
- {prog} del  <key> [pos]
    删除　key, 删除　key 的某种　pos 的值
    
其中，key的格式类似 section.key.subkey

###　扩展包管理

- {prog} pkg_install <pkg_name>
- {prog} pkg_list
- {prog} pkg_uninstall <pkg_name>

###　数据处理（按条目划分｜特性抽取）

- {prog} split <stream_name> [filename]

    stream_name, 为要处理的数据流名称；
    filename　为可选的，要处理的文件名
    
- {prog} extract <stream_name> [filename] [--rule <rule_name>] [--sample <N>]

    rule_name　用于抽取数据的规则
    sample     采样频率
    
###　数据传输 (采样？)

- {prog} auth -u <user_name> [-h <host>]
    
    user_name, 登录系统用的用户名；
    host       进行身份认证的服务器；
    
    通过交互式界面输入密码，下载访问系统其他服务所需要的证书；
    当认证成功后，会覆盖原有的证书
    
- {prog} run　[-c conf_path] [--key key_file] [--host <host>]
    
    运行　agent 传输数据
    
- {prog} reload    
    
    重新加载配置相
    
-  {prog} agent        
    
    运行于　Agent 模式，　实际处理文件传输