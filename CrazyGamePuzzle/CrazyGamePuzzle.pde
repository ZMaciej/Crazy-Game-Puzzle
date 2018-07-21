final int TOP_SIDE = 0;
final int RIGHT_SIDE = 1;
final int BOTTOM_SIDE = 2;
final int LEFT_SIDE = 3;
final int BLUE_END = 1;
final int BLUE_BEG = -1;
final int BLACK_END = 2;
final int BLACK_BEG = -2;
final int GREEN_END = 3;
final int GREEN_BEG = -3;
final int RED_END = 4;
final int RED_BEG = -4;
final int canvasWidth = 600;
final int topBarHeight = 100;
final int blockMargin = 10;
final int blockWidth = (canvasWidth-4*blockMargin)/3;
final int triangleHeight = blockWidth / 4;
final int triangleWidth = blockWidth /3;
class Block
{
  public int[] sides = new int[4];
  public int rotation = 0; //couterclockwise rotation indicator
  public Block(int top, int right, int bottom, int left)
  {
    sides[0]=top;
    sides[1]=right;
    sides[2]=bottom;
    sides[3]=left;
  }
  boolean CompareBlockOnTheSide(int whichSide, Block whichBlock) //compares this.block to whichBlock on wichside side of this.block
  {
    if (this.sides[(whichSide + this.rotation) % 4] + whichBlock.sides[(whichSide + whichBlock.rotation + 2) % 4] == 0)
      return true;
    return false;
  }
  boolean rotateBlock() //return true when rotation overflow
  {
    rotation++;
    if (rotation>3)
    {
      rotation = 0;
      return true;
    }
    return false;
  }
  void show(float x, float y)
  {
    fill(244, 244, 244);
    noStroke();
    rect(x, y, blockWidth, blockWidth);
    for (int i = 0; i < 4; i++)
      showSymbolOnSide(x, y, i, sides[(i+rotation+3) % 4]);
  }
  void showSymbolOnSide(float x, float y, int side, int symbol)
  { 
    switch(abs(symbol)) {
    case 1: 
      fill(59, 136, 157); //blue
      break;
    case 2: 
      fill(30, 30, 30); //black
      break;
    case 3: 
      fill(59, 157, 80); //green
      break;
    case 4: 
      fill(80, 59, 157); //red
      break;
    }

    pushMatrix();

    translate(x+blockWidth/2, y+blockWidth/2);
    rotate(side * PI/2);
    if (symbol<0)
      rect(-blockWidth/2, -triangleWidth/2, triangleHeight, triangleWidth);
    else
      triangle(-blockWidth/2, -triangleWidth/2, -blockWidth/2 + triangleHeight, 0, -blockWidth/2, triangleWidth/2);

    popMatrix();
  }
}

class SetOfBlocks
{
  public Block[] blocks = new Block[9];
  public int[] order = new int[9];
  private Block blockTemp;
  private int orderTemp;
  private int permutationTable[] = new int[9];
  private int permutationIterator;
  public long counter = 0;
  PFont font = createFont("Arial", 16, true);
  private boolean theEnd = false;
  //block scheme readed from photo
  //positive value means end of symbol, negative value means beginning of symbol
  //values of colors:
  //blue = 1
  //black = 2
  //green = 3
  //red = 4

  public SetOfBlocks()
  {
    blocks[0] = new Block(BLUE_END, RED_BEG, GREEN_BEG, BLACK_END); //this mean: end of blue symbol on top; beginning of red symbol on right; beginning of green symbol on bottom; end of black symbol on left
    blocks[1] = new Block(BLUE_END, RED_BEG, GREEN_BEG, RED_END);
    blocks[2] = new Block(BLUE_END, BLACK_BEG, GREEN_BEG, RED_END);
    blocks[3] = new Block(GREEN_END, RED_BEG, BLACK_BEG, BLUE_END);
    blocks[4] = new Block(GREEN_END, BLACK_BEG, BLUE_BEG, RED_END);
    blocks[5] = new Block(GREEN_END, BLACK_BEG, BLUE_BEG, BLACK_END);
    blocks[6] = new Block(BLACK_END, RED_BEG, BLACK_BEG, GREEN_END);
    blocks[7] = new Block(BLUE_END, RED_BEG, GREEN_BEG, BLACK_END);
    blocks[8] = new Block(BLACK_END, BLACK_BEG, RED_BEG, GREEN_END);
    for (int i=0; i<9; i++)
      order[i]=i;

    for (int i=0; i<9; i++)
      permutationTable[i] = 0;

    permutationIterator = 0;
  }

  int permutationStep() {
    if (permutationIterator < 9) {
      if  (permutationTable[permutationIterator] < permutationIterator) {
        if ((permutationIterator%2)==0)
          swap(0, permutationIterator);          
        else
          swap(permutationTable[permutationIterator], permutationIterator);

        permutationTable[permutationIterator] += 1;
        permutationIterator = 0;
        return 1; //permutation is ready
      } else {
        permutationTable[permutationIterator] = 0;
        permutationIterator += 1;
        return 0; //permutation is not ready yet run Step again
      }
    } else
      return -1; //all permutations were presented
  }

  boolean nextPermutation()
  {
    int result;
    while (true)
    {
      result = permutationStep();
      if (result != 0)
        if (result == 1) {
          counter++;
          return false;
        } else if (result ==-1){ 
          theEnd = true;
          return true;
        }
    }
  }

  public void swap(int a, int b)
  {
    blockTemp = blocks[a];
    blocks[a] = blocks[b];
    blocks[b] = blockTemp;

    orderTemp = order[a];
    order[a] = order[b];
    order[b] = orderTemp;
  }

  public boolean checkSetOfBlocks() //true when correct answer is found
  {
    //comparing from left to right
    if (!blocks[0].CompareBlockOnTheSide(RIGHT_SIDE, blocks[1])) return false;
    if (!blocks[1].CompareBlockOnTheSide(RIGHT_SIDE, blocks[2])) return false;
    if (!blocks[3].CompareBlockOnTheSide(RIGHT_SIDE, blocks[4])) return false;
    if (!blocks[4].CompareBlockOnTheSide(RIGHT_SIDE, blocks[5])) return false;
    if (!blocks[6].CompareBlockOnTheSide(RIGHT_SIDE, blocks[7])) return false;
    if (!blocks[7].CompareBlockOnTheSide(RIGHT_SIDE, blocks[8])) return false;

    //comparing form top to bottom
    if (!blocks[0].CompareBlockOnTheSide(BOTTOM_SIDE, blocks[3])) return false;
    if (!blocks[1].CompareBlockOnTheSide(BOTTOM_SIDE, blocks[4])) return false;
    if (!blocks[2].CompareBlockOnTheSide(BOTTOM_SIDE, blocks[5])) return false;
    if (!blocks[3].CompareBlockOnTheSide(BOTTOM_SIDE, blocks[6])) return false;
    if (!blocks[4].CompareBlockOnTheSide(BOTTOM_SIDE, blocks[7])) return false;
    if (!blocks[5].CompareBlockOnTheSide(BOTTOM_SIDE, blocks[8])) return false;

    return true;
  }

  int findIndex(int k) {
    for (int i=0; i<9; i++)
      if (order[i] == k)
        return i;
    return -1;
  }

  boolean nextRotatation() //return true when all combination of rotation are executed
  {
    int i = 0;
    while (blocks[findIndex(i)].rotateBlock()) {
      if (i==7)  //the last block rotation couses overflow,
        //last block in this case is 7 becouse every possible arrangement of puzzle can be represented in 4 rotations,
        //that means we can avoid one block rotation and we receive every possible arrangement but in only one rotation
        return true;
      i++;
    }
    counter++;
    return false;
  }

  public void printState()
  {
    println();
    for (int i = 0; i< 9; i++) 
    {
      print(blocks[i].rotation);
      print(",");
    }
    println();
    for (int i = 0; i< 9; i++) 
    {
      print(order[i]);
      print(",");
    }
    println();
  }

  void show()
  {
    for (int i = 0; i<3; i++)
    {
      for (int j = 0; j<3; j++)
      {
        blocks[3*i+j].show(blockMargin+j*(blockWidth+blockMargin), topBarHeight+blockMargin+i*(blockWidth+blockMargin));
      }
    }
    textAlign(LEFT);
    textFont(font, 25);
    fill(0);
    text("Permutation:", blockMargin, blockMargin+25);
    textFont(font, 40);
    text((new Long(counter)).toString(), blockMargin, blockMargin*2+50);
    if (theEnd)
    {
      textAlign(RIGHT);
      textFont(font, 40);
      text("The End", canvasWidth - blockMargin, blockMargin*2+25);
    }
  }
}

SetOfBlocks puzzle;
boolean theEnd=false;
boolean solutionFound = false;
boolean nextSolution = false;
boolean hidden = true;
void setup()
{
  size(600, 700);
  puzzle = new SetOfBlocks();
  //do {
  //  do {
  //    if (puzzle.checkSetOfBlocks()) {
  //      puzzle.printState();
  //    }
  //  } while (!puzzle.nextRotatation());
  //} while (!puzzle.nextPermutation());
  //println("koniec");
}
void draw()
{
  for (int i=0; i<5432111; i++) { //not a round number for better flicker effect
    if (!solutionFound && puzzle.checkSetOfBlocks()) {
      if (!nextSolution) {
        puzzle.printState();
        solutionFound = true;
      } else
        nextSolution = false;
    }
    if (!theEnd && !solutionFound) {
      if (puzzle.nextRotatation()) 
        if (puzzle.nextPermutation())
        {
          theEnd = true;
          println("koniec");
        }
    }
  }

  if (keyPressed && (key == 'h' || key == 'H'))
    hidden = true;
  else
    hidden = false;

  if (keyPressed && key == ' ')
  {
    solutionFound = false;
    nextSolution = true;
  } else nextSolution = false;

  if (!hidden) {
    if (solutionFound) {
      background(200);
      fill(69, 193, 96);
      rect(0, topBarHeight, canvasWidth, canvasWidth);
      fill(200);
      rect(blockMargin, topBarHeight+blockMargin, canvasWidth-2*blockMargin, canvasWidth-2*blockMargin);
    } else
      background(200);
    puzzle.show();
  }
}
