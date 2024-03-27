import java.util.*;
Ship ship;
Asteroid  asteroid;
ForceField  field;
ArrayList<Asteroid> asteroids;
int score, numAsteroids, lives, level;
void setup()
{
  size(650, 500);
  ship = new Ship();
  field = new ForceField();
  asteroids = new ArrayList();
  score = 0;
  level = 1;
  lives = 5;
  numAsteroids = 3;
  for(int i = 0; i < numAsteroids; i++)
  {
    asteroids.add(new Asteroid(40, random(0, width), random(0, height)));
  }
}
void draw()
{
  background(0);
  textSize(15);
  text("Score: " + score, width - 100, 20);
  text("Lives: " + lives, 20, 20);
  text("Level: " + level, 20, 40);
  ship.show();
  ship.update();
  field.init();
  field.show();
  for(int i = asteroids.size() - 1; i >= 0; i--)
  {
    asteroids.get(i).show();
    asteroids.get(i).followField(field);
    for(int j = ship.bullets.size() - 1; j >= 0; j--)
    {
      if(asteroids.get(i).collideWith(ship.bullets.get(j)))
      {
        int tempRadius = asteroids.get(i).radius;
        float tempx = asteroids.get(i).position.x;
        float tempy = asteroids.get(i).position.y;
        asteroids.remove(i);
        ship.bullets.remove(j);
        score += 100;
        if(tempRadius > 10)
        {
          asteroids.add(new Asteroid(tempRadius/2, tempx, tempy));
          asteroids.add(new Asteroid(tempRadius/2, tempx, tempy));
          asteroids.add(new Asteroid(tempRadius/2, tempx, tempy));
        }
        break;
      }
    }
    if(i >= asteroids.size())
    {
      i = asteroids.size()-1;
    }
    if(asteroids.size() == 0)
    {
      break;
    }
    if(collision(asteroids.get(i), ship))
    {
      asteroids.remove(i);
      ship.position.set(width/2, height/2);
      lives--;
    }
    if(i >= asteroids.size())
    {
      i = asteroids.size()-1;
    }
    if(asteroids.size() == 0)
    {
      break;
    }
    for(int k = asteroids.size() - 1; k >= 0; k--)
    {
      if(asteroids.get(i) != asteroids.get(k))
      {
        asteroids.get(i).avoid(asteroids.get(k));
      }
    }
    asteroids.get(i).update();
  }
  if(asteroids.size() == 0)
  {
    numAsteroids = level*2 + 3;
    level++;
    for(int i = 0; i < numAsteroids; i++)
    {
      asteroids.add(new Asteroid(40, random(0, width), random(0, height)));
    }
  }
}
boolean collision(Asteroid a, Ship s)
{
  float distance = dist(a.position.x, a.position.y, s.position.x, s.position.y);
  if(distance < a.radius + s.size)
  {
    return true;
  }
  else
  {
    return false;
  }
}
class Ship
{
  int size;
  float angle;
  PVector position, velocity, acceleration;
  boolean shot_fired;
  ArrayList<Bullet> bullets;
  Ship()
  {
    size = 30;
    angle = -PI/2;
    position = new PVector(width/2, height/2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    bullets = new ArrayList();
    shot_fired = false;
  }
  void show()
  {
    stroke(255);
    strokeWeight(2);
    noFill();
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    beginShape();
    vertex(0, 0);
    vertex(-size/3, size/3);
    vertex(size, 0);
    vertex(-size/3, -size/3);
    vertex(0, 0);
    endShape();
    popMatrix();
  }
  void update()
  {
    acceleration.set(cos(angle), sin(angle));
    acceleration.setMag(0.1);
    if(keyPressed && keyCode == UP)
    {
      velocity.add(acceleration);
    }
    else if(keyPressed && keyCode == LEFT)
    {
      angle -= 0.15;
    }
    else if(keyPressed && keyCode == RIGHT)
    {
      angle += 0.15;
    }
    else if(keyPressed && keyCode == DOWN)
    {
      shot_fired = true;
    }
    if(!(keyPressed && keyCode == DOWN) && shot_fired)
    {
      bullets.add(new Bullet(position, angle));
      shot_fired = false;
    }
    velocity.limit(5);
    position.add(velocity);
    for(Bullet a: bullets)
    {
      if(a.life > 0)
      {
        a.show();
        a.update();
      }
    }
    if(position.x < 0)
    {
      position.x = width;
    }
    else if(position.x > width)
    {
      position.x = 0;
    }
    else if(position.y < 0)
    {
      position.y = height;
    }
    else if(position.y > height)
    {
      position.y = 0;
    }
  }
}
class Bullet
{
  float size;
  float angle;
  int life;
  PVector position;
  PVector velocity;
  Bullet(PVector position_, float angle_)
  {
    size = 20;
    life = 150;
    position = position_.copy();
    angle = angle_;
    velocity = new PVector(cos(angle), sin(angle));
    velocity.mult(5);
  }
  void show()
  {
    stroke(255, life);
    strokeWeight(2);
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    line(0, 0, size, 0);
    popMatrix();
  }
  void update()
  {
    life--;
    position.add(velocity);
  }
}
class Asteroid
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float[] vertices;
  int radius;
  int maxVel;
  int avoidRadius;
  boolean status;
  Asteroid(int radius_, float x, float y)
  {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    vertices = new float[15];
    radius = radius_;
    avoidRadius = 3*radius;
    maxVel = 1;
    status = true;
    for(int i = 0; i < 15; i++)
    {
      vertices[i] = random(radius*2/3, radius*4/3);
    }
    vertices[14] = vertices[0];
  }
  void show()
  {
    stroke(255);
    strokeWeight(2);
    pushMatrix();
    translate(position.x, position.y);
    beginShape();
    for(int i = 0; i < vertices.length; i++)
    {
      vertex(vertices[i]*cos(i*TWO_PI/(vertices.length-1)), vertices[i]*sin(i*TWO_PI/(vertices.length-1)));
    }
    endShape();
    popMatrix();
    //ellipse(position.x, position.y, 2*radius, 2*radius);
  }
  boolean collideWith(Bullet thisBullet)
  {
    if(dist(position.x, position.y, thisBullet.position.x, thisBullet.position.y) < radius)
    {
      status = false;
      return true;
    }
    else
    {
      return false;
    }
  }
  void update()
  {
    velocity.add(acceleration);
    velocity.setMag(maxVel);
    position.add(velocity);
    if(position.x < -radius)
    {
      position.x = width + radius;
    }
    else if(position.x > width + radius)
    {
      position.x = -radius;
    }
    else if(position.y < -radius)
    {
      position.y = height + radius;
    }
    else if(position.y > height + radius)
    {
      position.y = -radius;
    }
    acceleration.mult(0);
  }
  void applyForce(PVector force)
  {
    PVector copyForce = force.copy();
    acceleration.add(copyForce);
  }
  void avoid(Asteroid other)
  {
    PVector distance = PVector.sub(position, other.position);
    if(distance.mag() < avoidRadius)
    {
      distance.setMag(0.5);
      applyForce(distance);
    }
  }
  void followField(ForceField thisField)
  {
    for(int i = 0; i < thisField.rows; i++)
    {
      for(int j = 0; j < thisField.columns; j++)
      {
        if(position.y > i*thisField.size && position.y < (i+1)*thisField.size && position.x > j*thisField.size && position.x < (j+1)*thisField.size)
        {
          //acceleration = thisField.points[i][j];
          applyForce(thisField.points[i][j]);
        }
      }
    }
  }
}
class ForceField
{
  int size, columns, rows;
  PVector points[][];
  float xOff, yOff, tOff, angle;
  ForceField()
  {
    size = 20;
    columns = width/size + 1;
    rows = height/size + 1;
    points = new PVector[rows][columns];
    xOff = 0;
    yOff = 0;
    tOff = 0;
  }
  void init()
  {
    yOff = 0;
    for(int i = 0; i < rows; i++)
    {
      xOff = 0;
      for(int j = 0; j < columns; j++)
      {
        angle = map(noise(xOff, yOff, tOff), 0, 1, 0, TWO_PI);
        points[i][j] = new PVector(cos(angle), sin(angle));
        xOff += 0.1;
      }
      yOff += 0.1;
    }
    tOff += 0.005;
  }
  void show()
  {
    for(int i = 0; i < rows; i++)
    {
      for(int j = 0; j < columns; j++)
      {
        stroke(100, 100);
        line(j*size, i*size, j*size + size*cos(points[i][j].heading()), i*size + size*sin(points[i][j].heading()));
      }
    }
  }
}
