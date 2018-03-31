#include <stdio.h>

int herb_database(int type){

  //this is effectively a conditional block to determine which bitmap will be sent
  //to the VGA display

  #define  rosemary   0
  #define  basil      1
  #define  mint       2
  #define  parsely    3
  #define  lavendar   4
  #define  thyme      5

  switch (type)
  ​{
      case rosemary:
          //load rosemary.bmp;
          break;

      case basil:
          //load basil.bmp;
          break;

      case mint:
          //load mint.bmp;
          break;

      case parsely:
          //load parsely.bmp;
          break;

      case lavendar:
          //load lavendar.bmp;
          break;

      case thyme:
          //load thyme.bmp;
          break;

      default:
          printf("Unknown herb type.")
  }

  return 0;
}
