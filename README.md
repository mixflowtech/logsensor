# LogSensor

LogSensor (Sensor for short. ) is a general purpose log data processing skeleton.

# Build

git clone --depth 3  --recurse-submodules https://github.com/mixflowtech/logsensor.git
make

mkdir build & cd build
cmake ..


# Design

The System composed with two parts.

### Master

`Master` is the control process. It, 

- Read config from file, and build app-link flow to `Engine` via REPL
- Moniter changes on filesystem, 
- Start/stop Engine
- Auth the machine which Sensor run to `Central`
- [Optional] Provider performance metric via HTTP
- [Optional] Do bulk upload to `S3 compat` backend

### Engine

`Engine` Read data from file/upd_socket, etc. and send data to the target


### Central

The remote servers farm which store, analysis, do cep at the remote side.

### Protocol between Master/Engine

1. APP [type_of_app] nodeId [params_in_json]

2. LINK [link_expr] 
    > src_nodeId.tx -> dst_nodeId.rx
    
    There is no way remove link explicitly, But if src or dst node/app remove, the link removed.
    
3. DEL [nodeId]

4. RESET [nodeId]

5. LIST
    List all the App/Node

6. START

7. RESTART

8. STOP

9. ADMINLISTEN [INTERFACE] [PORT]
    
    Turn on the monitor via HTTP.
    