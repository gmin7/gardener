


int herb_database( int type_counter ){

  //this is effectively a conditional block to determine which bitmap will be sent
  //to the VGA display

  #define  rosemary   0
  #define  parsely    1
  #define  mint       2

  //some bound conditions

  if(type_counter < 3);
    return
  else if(type_counter >= 3 && type_counter < 5);
  else;



      case rosemary:
          //load herb_images/rosemary.bmp;
          break;

      case parsely:
          //load herb_images/basil.bmp;
          break;

      case mint:
          //load herb_images/mint.bmp;

      default:
          printf("Unknown herb type.")
  }

  return 0;
}
