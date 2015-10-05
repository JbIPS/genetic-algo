typedef CreatureData = {
  score: Int,
  minX: Float,
  minY: Float,
  maxX: Float,
  maxY: Float,
  maxDist: Float,
  map: Array<Array<Int>>,
  turnOfArrival: Int
}
typedef Coord<T> = { var x:T; var y:T; }
class Teacher {
  public static inline var MAX_TURNS:Int = 200;
  // Fitness params
  public static inline var BONUS_ARRIVAL:Int = 2000;
  public static inline var BONUS_NEW_CASE:Int = 1;
  public static inline var BONUS_NEW_HORIZON:Int = 2;
  public static inline var BONUS_MAX_DISTANCE:Int = 5;

  var turns:Int = 0;
  private var creaturesData:Array<CreatureData> = null;

  public function new(creatures: Array<Creature>) {
    creaturesData = new Array();
    for(creature in creatures) {
      creaturesData[creature.id] = {
        score: 0,
        minX: 0,
        minY: 0,
        maxX: 0,
        maxY: 0,
        maxDist: 0,
        map: createMap(),
        turnOfArrival: MAX_TURNS
      }
    }
  }
  public function createMap():Array<Array<Int>> {
    var empty = new Array();
    for(x in 0...Map.WIDTH) {
      empty[x] = new Array();
      for(y in 0...Map.HEIGHT) {
        empty[x][y] = 0;
      }
    }
    return empty;
  }
  public function start() {
    turns = 0;
  }
  public function stop() {}
  public function turn() {
    turns ++;
  }
  public function loop(creature:Creature) {
    // trace('Turn '+turns);
    if(turns == 0) {
      creaturesData[creature.id].map = createMap();
      creaturesData[creature.id].minX= 0;
      creaturesData[creature.id].minY = 0;
      creaturesData[creature.id].maxX = 0;
      creaturesData[creature.id].maxY = 0;
      creaturesData[creature.id].maxDist = 0;
      creature.reset();
    }
    // reached target
    if(creature.x <= 0 && creature.y < (Map.HEIGHT/2)+5 && creature.y > (Map.HEIGHT/2)-5) {
      creaturesData[creature.id].score += BONUS_ARRIVAL;
      creaturesData[creature.id].turnOfArrival = turns;
      // trace('Creature '+creature.id+' arrived!');
    }
    // gone to a new coord
    if(creaturesData[creature.id].map[creature.x][creature.y] == 0) {
      creaturesData[creature.id].score += BONUS_NEW_CASE;
      // trace('Creature '+creature.id+' discovered '+creature.x+';'+creature.y);
    }
    creaturesData[creature.id].map[creature.x][creature.y]++;
    // gone out of the "known" perimeter
    if(creaturesData[creature.id].minX > creature.x || creaturesData[creature.id].maxX < creature.x ||
        creaturesData[creature.id].minY > creature.y || creaturesData[creature.id].maxY < creature.y) {
      creaturesData[creature.id].score += BONUS_NEW_HORIZON;
      // trace('Creature '+creature.id+' went to new horizon!'+creature.x+';'+creature.y);
    }
    creaturesData[creature.id].minX = Math.min(creature.x, creaturesData[creature.id].minX);
    creaturesData[creature.id].minY = Math.min(creature.y, creaturesData[creature.id].minY);
    creaturesData[creature.id].maxX = Math.max(creature.x, creaturesData[creature.id].maxX);
    creaturesData[creature.id].maxY = Math.max(creature.y, creaturesData[creature.id].maxY);
    // gone further
    // var dist = Math.abs(creature.x - creature.initialX) + Math.abs(creature.y - creature.initialY);
    // if(dist > creaturesData[creature.id].maxDist) {
    //   creaturesData[creature.id].maxDist = dist;
    //   creaturesData[creature.id].score += BONUS_MAX_DISTANCE;
    //   // trace('Creature '+creature.id+' went the farest: '+dist);
    // }
    // Closer to the goal
    creaturesData[creature.id].score -= Math.round(getDistance(creature)/5);

    // trace('Turn score: '+creaturesData[creature.id].score);
  }
  public function getScore(creature:Creature):Int {
    // Sanction too much steps
    return creaturesData[creature.id].score - creaturesData[creature.id].turnOfArrival;
  }
  public function getRoute(creature:Creature): String {
    var res = new Array();
    for(x in 0...Map.WIDTH) {
      res[x] = new Array();
      for(y in 0...Map.HEIGHT) {
        var obs  = Map.getObstruction(x, y);
        if(obs == 0) res[x][y] = "___";
        else res[x][y] = " X ";
        if(x == 0 && y < (Map.HEIGHT/2)+5 && y > (Map.HEIGHT/2)-5) {
          res[x][y] = "!!!";
        }
        var num = creaturesData[creature.id].map[x][y];
        if(num > 0) {
          var numStr = Std.string(num);
          if(numStr.length == 1) numStr = " " + numStr + " ";
          else if(numStr.length == 2) numStr = numStr + " ";
          res[x][y] = numStr;
        }
        if(Math.round(creature.initialX) == x && Math.round(creature.initialY) == y) {
          res[x][y] = "III";
        }
      }
    }
    var str = "";
    for(x in 0...Map.WIDTH) {
      str += res[x].join("") + "\n";
    }
    return str;
  }
  public function isOver():Bool {
    return turns >= MAX_TURNS;
  }

  private function getDistance(c: Creature) : Float
  {
    return c.x + Math.abs(c.y - Map.HEIGHT/2);
  }

}
