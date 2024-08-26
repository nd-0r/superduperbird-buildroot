#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

typedef uint8_t __u8;
typedef uint16_t __u16;
typedef uint32_t __u32;
typedef int32_t __s32;
typedef unsigned int uint;

// From: https://github.com/spsgsb/uboot/blob/buildroot-openlinux-201904-g12a/common/cmd_imgread.c

#define IMG_PRELOAD_SZ  (1U<<20) //Total read 1M at first to read the image header

#define AML_RES_IMG_VERSION_V2      (0x02)
#define AML_RES_IMG_V1_MAGIC_LEN    8
#define AML_RES_IMG_V1_MAGIC        "AML_RES!"//8 chars
#define AML_RES_IMG_ITEM_ALIGN_SZ   16
#define AML_RES_IMG_HEAD_SZ         (AML_RES_IMG_ITEM_ALIGN_SZ * 4)//64

#pragma pack(push, 4)
typedef struct {
    __u32   crc;    //crc32 value for the resouces image
    __s32   version;//current version is 0x01

    __u8    magic[AML_RES_IMG_V1_MAGIC_LEN];  //resources images magic

    __u32   imgSz;  //total image size in byte
    __u32   imgItemNum;//total item packed in the image

    __u32   alignSz;//AML_RES_IMG_ITEM_ALIGN_SZ
    __u8    reserv[AML_RES_IMG_HEAD_SZ - 8 * 3 - 4];

}AmlResImgHead_t;
#pragma pack(pop)

// End from

#define BUFSIZE 4096

// 0 for success, nonzero for failure
int unpackImage(const char* inpath, const char* outpath)
{
  int ret = 0, in_fd = -1, out_fd = -1;
  off_t in_size = (off_t) -1;
  void *map = NULL;

  if (inpath == NULL || outpath == NULL) {
    ret = __LINE__;
    goto Done;
  }

  in_fd = open(inpath, O_RDONLY);
  if (in_fd == -1) {
      perror("open");
      ret = __LINE__;
      goto Done;
  }
  in_size = lseek(in_fd, 0, SEEK_END);
  if (in_size < 0) {
    perror("lseek");
    ret = __LINE__;
    goto Done;
  }
  if (lseek(in_fd, 0, SEEK_SET) != 0) {
    perror("lseek");
    ret = __LINE__;
    goto Done;
  }

  out_fd = open(outpath, O_WRONLY | O_CREAT | O_TRUNC, S_IRWXU | S_IRGRP);
  if (out_fd == -1) {
    perror("open");
    ret = __LINE__;
    goto Done;
  }

  map = mmap(NULL, in_size, PROT_READ, MAP_SHARED, in_fd, 0);
  if (map == MAP_FAILED) {
      perror("mmap");
      ret = __LINE__;
      goto Done;
  }

  AmlResImgHead_t *header = (AmlResImgHead_t*) map;
  __u32 out_size = header->imgSz;
  size_t bytes_written = 0;
  char *rptr = NULL;

  map = (void*) (((char*) map) + IMG_PRELOAD_SZ);
  while (bytes_written < out_size) {
    rptr = ((char *) map) + bytes_written;

    int bytes_to_write = (out_size - bytes_written) < BUFSIZE ? (out_size - bytes_written) : BUFSIZE;
    int buf_bytes_written = write(out_fd, (void *) rptr, bytes_to_write);
    if (buf_bytes_written < 0) {
      perror("write");
      ret = __LINE__;
      goto Done;
    } else if (buf_bytes_written < bytes_to_write) {
      continue;
    }

    bytes_written += bytes_to_write;
  }

Done:
  if (in_fd >= 0)
    close(in_fd);
  if (out_fd >= 0)
    close(out_fd);
  return ret;
}

int main(int argc, char *argv[])
{
  if (argc <= 2) {
    fputs("unpackImage <packed input path> <kernel zImage output path>\n", stderr);
    return 1;
  }

  return unpackImage(argv[1], argv[2]);
}

