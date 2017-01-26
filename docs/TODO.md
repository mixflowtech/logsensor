## TODO

1. 使用 C 提供 App 接口， 默认使用 libuv
    - libuv 和 LuaJIT 集成，在回调上有坑。 主要是回调函数的数量受限制
    
2. osquery 也提供为一个 App
    - 对查询定时， 没有新数据就不发送
    - 对于队列，没有变更也要发消息
    
3. 确定监控配置文件变化的机制（在 osquery 中的可能较大）    

4. 传输过程中，如果超过 N， 则需要设置头部的 hash 作为 数据流特征

5. 允许用户加载自定义脚本

6. 处理文件的流程
    
    - 发现新文件
    - 是否压缩了，如压缩，需要解压前N
    - 计算前 N 的 hash, 确定是否为已知文件
    - 通知读取流程， 读取新增的数据
        * 如果定义了数据分割机制，则依照机制， 默认为 \n
        * 全局定义了最大的数据报文长度M， 超出的事件，会变为 两条， 前M 和 后 M
    - 文件超过限制（eg. 4G ) 应该报警
    - 服务器端，连续收到 U 条 超长记录，应报警； 超长记录应记录其为 前M 还是 后 M
    - 可监控多个目录
    
    【通用配置】
    {{ 配置 YAML 的配置文件需要引入 lyaml | libyaml 的依赖关系, 放弃引入　yaml，　
        改为直接通过命令行配置 }}
        
        - 主机标识符，默认为 hostname， 可以被改写； hostname 作为一个变量
        - 最大文件长度
        - 最长记录长度
        - 默认换行规则
        - Stream 计算特征的抽取规则（Head N bytes)
        - 是否检测压缩文件
        - 传输的目标服务器
        - 加密用的证书
        - 是否启用加密传输
        - 是否启用 HTTP 监控接口（以及默认的监听的网络界面）
        - 是否启用 RSyslog | SyslogNG 服务器
        
    【文件夹】
    【source:匹配文件名的规则】
        - 数据流格式
    
    【定时器】
    【source: query1】
        - 定时执行的 osquery
    
    【conf】  // 监控配置文件
        
    【数据流格式】
        - 换行方式
        - break-before
        - break-after
        ...
    
    
        
7. 读取配置文件的方式    
   进行配置的方式
   
8. 系统的内部接口（监控界面）   

9. Pack 的支持（一个预制了若干模块的配置文件包）
    ?　多种　OS
    ?  多个位置
    ?　一个使用模板会好些
    
10. Pack 的启用与禁用

11. 允许临时配置， 仅在本次启动中使用。 对于此配置，使用 shmem 存储
    
    - 实际为 从 YAML 中加载， 载入内部的一个 树形结构
    - 通过命令行修改，可以直接修改那个树形结构
    - 如果修改后，使用 reload，则修改被丢弃，从配置文件中重新读取

log_sensor -c <config_path> --cert <cert_key> [start|stop|reload]
log_sensor -c <config_path> set key value
log_sensor -c <config_path> del key 
log_sensor -c <config_path> get key 
log_sensor -c <config_path> list key    # 列出某个 key 下面的全部子项
log_sensor -c <config_path> get_cert <password> 根据之前的配置，从服务器上获取对应的传输证书

12. 需要寻找一个 Lua/C 的模板语言， 配置文件可通过模板生成

13. [Done][直接使用了LUV] 似乎 luv 可以直接使用
    https://github.com/czanyou/node.lua 也可
    
14. [Done] 可以考虑创建一个独立线程|进程监控文件系统，因为libuv 的事件流集成到系统中，有困难
    Ref:
        https://github.com/helloshiki/apop/blob/f21b054f1d328562b48f80bbdd5c23b20a9ed8e6/luv/luv/examples/uvbook/onchange.lua
    通过 shm 通信？
        × shm 是否有锁？
        × win32 上的实现
    snabb 内置了一个 ipc 通信
    
   - [ ] 一个读取 Lua 脚本的内置 shm 的程序
   - [ ] 向共享内存写入数据
   - [ ] 从共享内存读取数据
   - [ ] 从标准输入读取数据
   
    > 实际构造了一个主从进程的结构，主进程为　libuv，　监控文件系统；　从进程读取数据，发送
    
15. 使用证书 进行 身份认证 和通信的 demo
    
    - 用户输入用户名 | 密码 | 主机名/主机标识符
    = 返回 通信使用的证书
    
    传输的数据 需要通过 证书加密
    
    在服务器端，可以随时 invoke 证书
    
    Ｒef: https://github.com/ContinuumIO/flask-ssl-authentication
    