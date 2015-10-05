class Creature {
  public static inline var NUM_GENES: Int = 100;
  public static inline var MUTATION_PROBA_PERCENT: Int = 5;
  private static var nextId = 0;
  private var genome: Array<Gene>;
  public var x: Int;
  public var y: Int;
  public var initialX: Int;
  public var initialY: Int;
  public var id: Int;
  public var currentGeneIdx: Int = 0;

  public static function randomize(): Creature {
    var creature = new Creature();
    for(idx in 0...NUM_GENES) {
      creature.genome[idx] = Gene.randomize();
    }
    return creature;
  }
  public static function evolve(creature1: Creature, creature2: Creature): Creature {
    var creature = new Creature();
    var split = Math.random() * NUM_GENES;
    for(idx in 0...NUM_GENES) {
      if(idx < split) {
        creature.genome[idx] = creature1.genome[idx];
      }
      else {
        creature.genome[idx] = creature2.genome[idx];
      }
      var randPercent = Math.round(Math.random() * 100);
      if(randPercent < MUTATION_PROBA_PERCENT) {
        creature.genome[idx] = Gene.randomize();
      }
    }
    return creature;
  }
  public function new() {
    id = nextId++;
    genome = new Array();
    reset();
  }
  public function reset() {
    x = Math.round((Map.WIDTH / 2));
    y = Math.round((Map.HEIGHT / 2));
    // x = Math.round((Map.WIDTH / 2) + (5 - Math.random() * 10));
    // y = Math.round((Map.HEIGHT / 2) + (5 - Math.random() * 10));
    initialX = x;
    initialY = y;
  }
  public function loop() {
    if(currentGeneIdx < NUM_GENES) {
      // trace('Executing num '+currentGeneIdx+': '+genome[currentGeneIdx]);
      currentGeneIdx = Gene.exec(this, genome[currentGeneIdx]);
/*
      var gene = Gene.randomize();
      gene.type = BOTTOM;
      currentGeneIdx = Gene.exec(this, gene);
*/
    }
  }
  public function toString() {
    var idx = 0;
    var genes: Array<String> = genome.map(function (gene) {
      if(currentGeneIdx == idx++) return "*" + gene.toString() + "*";
      return gene.toString();
    });
    return "Creature:: " + id + " (" + Math.round(x) + ", " + Math.round(y) + ", " + Math.round(initialX) + ", " + Math.round(initialY) + ") [" + genes.join(", ") + "]";
  }
}

