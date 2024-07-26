#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <libgen.h>
#include <malloc.h>
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

// 0 for valid path, nonzero for failure
int checkPath(const char* path) {
  char *path_copy = strdup(path);
  char *dir = dirname(path_copy);

  struct stat statbuf;

  int is_dir = !(stat(dir, &statbuf) == 0 && S_ISDIR(statbuf.st_mode));

  free(path_copy);

  return is_dir;
}

// 0 for failure, nonzero denotes size in bytes
size_t getFileSize(const char* path) {
  struct stat statbuf;
  int ret = stat(path, &statbuf);

  if (ret != 0 || !S_ISREG(statbuf.st_mode)) {
    return 0;
  }

  return statbuf.st_size;
}

// 0 for success, nonzero for failure
int packImage(FILE *img_file, size_t img_size, const char* outpath)
{
  if (img_file == NULL || outpath == NULL) {
    return 1;
  }

  void *map;
  size_t size = img_size + IMG_PRELOAD_SZ;

  int fd = open(outpath, O_RDWR | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR);
  if (fd == -1) {
      perror("open");
      close(fd);
      return __LINE__;
  }

  if (lseek(fd, size - 1, SEEK_SET) == -1) {
      perror("lseek");
      close(fd);
      return __LINE__;
  }

  if (write(fd, "", 1) != 1) {
    perror("write");
    close(fd);
    return __LINE__;
  }

  map = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (map == MAP_FAILED) {
      perror("mmap");
      close(fd);
      return __LINE__;
  }

  // Write header
  AmlResImgHead_t header = {
    .crc = 0,
    .version = AML_RES_IMG_VERSION_V2,
    .magic = AML_RES_IMG_V1_MAGIC,
    .imgSz = size,
    .imgItemNum = 1,
    // alignSz;//AML_RES_IMG_ITEM_ALIGN_SZ
    // reserv[AML_RES_IMG_HEAD_SZ - 8 * 3 - 4];
  };
  memcpy(map, &header, sizeof(AmlResImgHead_t));

  // Write kernel image
  int bytes_written = fread((char *) map + IMG_PRELOAD_SZ, 1, img_size, img_file);
  if (bytes_written != img_size) {
    perror("fread");
    close(fd);
    return __LINE__;
  }

  if (munmap(map, size) == -1) {
      perror("munmap");
      close(fd);
      return __LINE__;
  }

  close(fd);
  return 0;
}

int main(int argc, char *argv[])
{
  if (argc <= 2) {
    goto usage;
  }

  FILE *f = fopen(argv[1], "r");

  if (f == NULL) {
    fprintf(stderr, "Could not open kernel zImage file: %s\n", argv[1]);
    goto usage;
  }

  size_t fsize = getFileSize(argv[1]);

  if (fsize == 0) {
    fprintf(stderr, "Could not calculate size of zImage file: %s\n", argv[1]);
    goto usage;
  }

  if (checkPath(argv[2]) != 0) {
    fprintf(stderr, "Invalid output path: %s\n", argv[2]);
    goto usage;
  }

  return packImage(f, fsize, argv[2]);

usage:
  fputs("packImage <kernel zImage> <packed output>\n", stderr);
  return 1;
}

