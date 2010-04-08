class Creature
{
  public ArrayList friends;
  public ArrayList targets;
  
  public color bodyColor;
  public float energy;
  public Vec2D location;
  public Vec2D orientation;
  
  public float sz;
  
  public Vec2D sensorLeft;
  public Vec2D sensorRight;
  
  public float energyLeft;
  public float energyRight;
  
  public boolean foundTarget;
  public float lastDetectedEnergy;
  
  public float speed;
  
  Creature(color c, ArrayList f, ArrayList e)
  {
    this.bodyColor = c;
    
    this.friends = f;
    this.targets = e;
    
    this.energy = 100;
    this.sz = 40;
    this.foundTarget = false;
    
    this.lastDetectedEnergy = 0;
    
    this.speed = 1.5;

    this.location = Vec2D.randomVector().scaleSelf(random(2, height / 2)).add(width / 2, height / 2);
    this.orientation = Vec2D.randomVector().scaleSelf(this.sz / 2);
    println(this.orientation.toString() + "(" + this.orientation.magnitude() + ")");
  }
  
  void update()
  {
    
    sensorLeft = this.orientation.copy().rotate(radians(-15));
    sensorRight = this.orientation.copy().rotate(radians(15));
    
    energyLeft = 0;
    energyRight = 0;

    foundTarget = false;
    
    float currentTargetDistance = 9999;
    
    for (int i = 0; i < friends.size(); i++)
    {
      Creature c = (Creature)targets.get(i);
      if (c != null && c != this)
      {
        if (c.location.distanceTo(this.location) < this.sz * 2.5)
        {
          this.location.addSelf(this.location.sub(c.location).normalize().scale(0.2 * this.speed));
        }
      }
    }
    
    for (int i = 0; i < targets.size(); i++)
    {
      Creature c = (Creature)targets.get(i);
      if (c != null && c != this)
      {
        Vec2D direction = c.location.sub(this.location);
        if (direction.angleBetween(this.orientation, true) > PI / 2)
        {
          continue;
        }
        
        float distLeft = this.location.add(sensorLeft).distanceTo(c.location);
        float distRight = this.location.add(sensorRight).distanceTo(c.location);
        
        distLeft = ((int)distLeft / 5) + 1;
        distRight = ((int)distRight / 5) + 1;
        
/*        if (distLeft <= 10 || distRight <= 10)
        {
          foundTarget = true;
        }*/
        
        energyLeft += c.energy * 1 / sq(distLeft);
        energyRight += c.energy * 1 / sq(distRight);
        
/*        if (foundTarget)
        {
          currentTargetDistance = (distLeft + distRight) / 2;

          if (this.targetDistance > currentTargetDistance) // getting closer
          {
            this.energy -= 5;
          }
          else if (this.targetDistance < currentTargetDistance)
          {
            this.energy += 5;
          }
          
          targetDistance = currentTargetDistance;
        }*/
      }
    }
    
    float detectedEnergy = max(energyLeft, energyRight);
    
    if (detectedEnergy >= lastDetectedEnergy || abs(detectedEnergy - lastDetectedEnergy) < lastDetectedEnergy * 0.05)
    {
      this.foundTarget = true;
      this.energy *= 0.9;
    }
    else
    {
      this.foundTarget = false;
      this.energy *= 1.3;
    }
    
    lastDetectedEnergy = detectedEnergy;
    
    this.energy = constrain(this.energy,1,100);
    
    if (!foundTarget)
    {
      if (random(1) < 0.6)
      {
        this.orientation.rotate(random(0, 0.05));
      }        
      else
      {
        this.location.addSelf(this.orientation.copy().normalize().scale(0.2 * this.speed));
      }  
    }
    else
    {
        if (energyLeft > energyRight)
        {
          this.orientation.rotate(random(-0.01,-0.03));
        }
        else
        {
          this.orientation.rotate(random(0.01,0.03));
        }
    }
    
    if (foundTarget && abs(energyLeft - energyRight) < (energyLeft + energyRight) * 0.5 * 0.1) // else if (abs(energyLeft - energyRight) == 0)//
    {
      this.location.addSelf(this.orientation.copy().normalize().scale(0.2 * this.speed));
    }
    
    
    
    
  }
  
  void draw()
  {
    pushMatrix();
    
    translate(this.location.x, this.location.y);
    
    stroke(255);
    if (this.foundTarget)
    {
      stroke(30,255,30);
    }
    
    strokeWeight(1.2f);
    fill(red(this.bodyColor), green(this.bodyColor), blue(this.bodyColor), map(energy,0,100, 0, 250));
    ellipse(0,0,this.sz, this.sz);
    
/*    if (this.foundTarget)
    {
      fill(30,255,30);
      ellipse(0,-8,5,5);
    }*/
    
    if (debug)
    {
      fill(255);
      text(nf(this.energy,1,0), 0, 2);

      float diff = abs(energyLeft - energyRight);

      /*    
      if (energyLeft - energyRight > 0)
      {
        text("-" + nf(diff,1,0), 1, 10);
      }
      else
      {
        text("+" + nf(diff,1,0), 1, 10);
      }*/

      text(nf(this.energyLeft,1,0) + " - " + nf(this.energyRight,1,0), 1, 10);
    }
    
    
    
    //stroke(255);
    //line(0,0, orientation.x,  orientation.y);
    
    noStroke();
    fill(255);
    ellipse(sensorLeft.x, sensorLeft.y, 8, 8);
    ellipse(sensorRight.x, sensorRight.y, 8, 8);
    
    fill(red(this.bodyColor), green(this.bodyColor), blue(this.bodyColor));
    Vec2D eyeLeft = sensorLeft.copy();
    Vec2D eyeRight = sensorRight.copy();
    
    float theta = radians(3);
    
    if (energyLeft - energyRight > 0)
    {
      theta = theta * -1;
    }
    
    if (energyLeft == energyRight)
    {
      theta = 0;
    }
    
    eyeLeft.rotate(theta);
    eyeRight.rotate(theta);
    
    ellipse(eyeLeft.x, eyeLeft.y, 3, 3);
    ellipse(eyeRight.x, eyeRight.y, 3, 3);
    
    
    popMatrix();
  }
}