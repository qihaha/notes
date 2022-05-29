### 1.添加jni方法  
java代码中load动态库之后定义native方法
```
static {
       System.loadLibrary("sc");
    }
public native String ccVersion();
```
android studio会在方法的位置提示创建c、c++函数  
选择cpp文件：  
```
JNIEXPORT jstring JNICALL
Java_com_abc_sc_Entrance_ccVersion(JNIEnv *env, jobject thiz) {
    // TODO: implement ccVersion()
}
```  
选择cpp文件(会在函数定义前加上extern "C")：  
```
extern "C"
JNIEXPORT jstring JNICALL
Java_com_abc_sc_Entrance_ccVersion(JNIEnv *env, jobject thiz) {
    // TODO: implement ccVersion()
}
```
### 2.c和c++混用
jni的代码中c和c++是可以混用的，尝试创建一个c文件被cpp调用    
utils.h定义可以被外部引用的函数声明:
```
#include <jni.h> //函数的参数JNIEnv类型的头文件
#ifndef ANDROIDSC_UTILS_H
#define ANDROIDSC_UTILS_H
char *Jstring2CStr(JNIEnv *env, jstring jstr);
#endif //ANDROIDSC_UTILS_H
```
utils.c实现函数：
```
#include <stdlib.h>
#include <string.h>
#include "utils.h"

/*
 * 字符串转换（java->c）
 * */
char *Jstring2CStr(JNIEnv *env, jstring jstr) {
    char *rtn = NULL;
    jclass clsstring = (*env)->FindClass(env, "java/lang/String");
    jstring strencode = (*env)->NewStringUTF(env, "GB2312");
    jmethodID mid = (*env)->GetMethodID(env, clsstring, "getBytes", "(Ljava/lang/String;)[B");
    jbyteArray barr = (jbyteArray)(*env)->CallObjectMethod(env, jstr, mid, strencode);
    jsize alen = (*env)->GetArrayLength(env, barr);
    jbyte *ba = (*env)->GetByteArrayElements(env, barr, JNI_FALSE);
    if (alen > 0) {
        rtn = (char *) malloc(alen + 1);         //new   char[alen+1];
        memcpy(rtn, ba, alen);
        rtn[alen] = 0;
    }
    (*env)->ReleaseByteArrayElements(env, barr, ba, 0);
    return rtn;
}
```
sc.cpp中调用这个函数：  
```
extern "C" {
#include "utils.h" //需要定义到extern "C"块中，否则提示找不到这个头文件中的函数，error: undefined reference to Jstring2CStr 
}
extern "C"
JNIEXPORT jstring JNICALL
Java_com_abc_sc_Entrance_httpGet(JNIEnv *env, jobject thiz, jstring request_url) {
    char *pu = Jstring2CStr(env, request_url); //正常调用
    char *result = http_get(pu);
    return (*env).NewStringUTF(result);
}
```
注意自定义的头文件都是用“” include（<>的一般是标准库函数）  
### 3.cMakelists.txt添加source file，不需要头文件    
如果是jni实现的函数没有添加build aar成功，demo集成会提示： jni java.lang.UnsatisfiedLinkError: No implementation found for xxx  
如果是内部依赖的函数源文件没后添加直接build arr失败，报错：undefined reference to 'Jstring2CStr'    
```
add_library( # Sets the name of the library.
             sc

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
        sc.cpp
        http.c
        utils.c
        )
```

### 4.打包或者是demo工程调试即可

### 5.如果c中使用了socket函数，需要在AndroidManifest文件中声明权限
```
<uses-permission android:name="android.permission.INTERNET"/>
```

### 未解决的问题
1.掉用socket函数的时候由于没有给权限，文件描述符会返回-1，但是通过errno获取错误码却没有获取信息，提示erron no value，不知道后续这种错误详情如何获取   