import haxe.EnumTools;

enum GeneType {
  LEFT;
  RIGHT;
  TOP;
  BOTTOM;
  GOTO(value:Int);
  GT(property1:WorldProperty, property2:WorldProperty);
  LT(property1:WorldProperty, property2:WorldProperty);
}

enum WorldProperty {
  ME(property:CreatureProperties);
  MAP(x:Int, y:Int);
  MAP_REL(x:Int, y:Int);
  VALUE(value:Int);
}

enum CreatureProperties {
  X;
  Y;
}

class Gene {
  public static inline var NUM_GENE_TYPES:Int = 7;
  public var type: GeneType;
  public function new() {}
  public static function randomize(): Gene {
    var gene = new Gene();
    var randIdx = Math.floor(Math.random() * NUM_GENE_TYPES);
    switch(randIdx) {
      case 0:
        gene.type = LEFT;
      case 1:
        gene.type = RIGHT;
      case 2:
        gene.type = TOP;
      case 3:
        gene.type = BOTTOM;
      case 4:
        gene.type = GOTO(Math.floor(Math.random() * Creature.NUM_GENES));
      case 5:
        gene.type = GT(gene.getRandomProp(), gene.getRandomProp());
      case 6:
        gene.type = GT(gene.getRandomProp(), gene.getRandomProp());
    }
    return gene;
  }
  public function getRandomProp() {
    var randPercent = Math.round(Math.random() * 100);
    if(randPercent < 10) return ME(X);
    if(randPercent < 20) return ME(Y);
    if(randPercent < 30) return VALUE(Math.round(Math.random() * 100000));
    if(randPercent < 40) return MAP_REL(
      Math.floor(Math.random() * Map.WIDTH - Map.WIDTH / 2),
      Math.floor(Math.random() * Map.HEIGHT - Map.HEIGHT / 2)
    );
    return MAP(
      Math.floor(Math.random() * Map.WIDTH),
      Math.floor(Math.random() * Map.HEIGHT)
    );
  }
  public function getValueOf(creature:Creature, property:WorldProperty):Int {
    switch(property) {
      case ME(myProp):
        switch(myProp) {
          case X: return Math.round(creature.x);
          case Y: return Math.round(creature.y);
        }
      case MAP(x, y): return Map.getObstruction(x, y);
      case MAP_REL(x, y): return Map.getObstruction(Math.round(creature.x) + x, Math.round(creature.y) + y);
      case VALUE(value): return value;
    }
  }
  public static function exec(creature: Creature, gene: Gene): Int {
    var gotoIdx = creature.currentGeneIdx + 1;
    switch(gene.type) {
      case LEFT: if(Map.getObstruction(Math.round(creature.x-1), Math.round(creature.y)) == 0) creature.x--;
      case RIGHT: if(Map.getObstruction(Math.round(creature.x+1), Math.round(creature.y)) == 0) creature.x++;
      case TOP: if(Map.getObstruction(Math.round(creature.x), Math.round(creature.y+1)) == 0) creature.y++;
      case BOTTOM: if(Map.getObstruction(Math.round(creature.x), Math.round(creature.y-1)) == 0) creature.y--;
      case GOTO(value): gotoIdx = value;
    case GT(property1, property2): if(gene.getValueOf(creature, property1) <= gene.getValueOf(creature, property2)){
        // trace('GT OK, next');
        gotoIdx++;
      }
      // else trace('Fail, do nothing');
    case LT(property1, property2): if(gene.getValueOf(creature, property1) >= gene.getValueOf(creature, property2)){
        // trace('LT OK, next');
        gotoIdx++;
      }
      // else trace('Fail, do nothing');
    }
    // trace('Going to '+gotoIdx);
    return gotoIdx;
  }
  public function toString(): String {
    return Std.string(type);
  }
}

