cmakelists文件中已经链接了log-lib直接使用就可以  
```
#include <android/log.h>
const char * LOG_TGA = "LOG_TGA";

JNICALL
Java_com_simple_nativelogdemo_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++ hhahah";
	//输出debug级别的日志信息
    __android_log_print(ANDROID_LOG_DEBUG, LOG_TGA, "hello native log");
    
    return env->NewStringUTF(hello.c_str());
}

```