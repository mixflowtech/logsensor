
int async_setup_stdin(void);
int async_setup_stdout(void);

ssize_t async_read_stdin(char* buffer, size_t len);
ssize_t async_write_stdout(const char* buffer);