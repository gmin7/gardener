#include <stdio.h>

int herb_database(int type){

  //this is effectively a conditional block to determine which bitmap will be sent
  //to the VGA display

  #define  rosemary   0
  #define  parsely    1
  #define  mint       2
  #define  basil      3
  #define  lavendar   4
  #define  thyme      5

  switch (type_counter)
  ​{
      case rosemary:
          //load herb_images/rosemary.bmp;
          break;

      case basil:
          //load herb_images/basil.bmp;
          break;

      case mint:
          //load herb_images/mint.bmp;
          break;

      case parsely:
          //load herb_images/parsely.bmp;
          break;

      case lavendar:
          //load herb_images/lavendar.bmp;
          break;

      case thyme:
          //load herb_images/thyme.bmp;
          break;

      default:
          printf("Unknown herb type.")
  }

  return 0;
}
