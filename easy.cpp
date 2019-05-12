#define LOG_TAG "ffmpeg.easy"
#define LOG_NDEBUG 0
#include <ABE/ABE.h>
#include <stdlib.h>     // system

USING_NAMESPACE_ABE

struct FFmpeg : public SharedObject {
    String      cmd;
    String      version;
    
};

sp<FFmpeg> ffmpeg;
bool openFFmpeg(const char * cmd) {
    ffmpeg = new FFmpeg;
    ffmpeg->cmd     = cmd;
    
}


int main(int argc, char ** argv) {
    openFFmpeg("ffmpeg");
}
