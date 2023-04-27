/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Movement
=======================================================================================*/
#include scripts\_utility;
#include scripts\zombie\_include;


dropToGround()
{
	trace = bulletTrace( self.origin + (0,0,30), self.origin + (0,0,-200), false, self );

    if( trace["fraction"] < 1 && !isdefined(trace["entity"]) )
    {
    	if( !isDefined(trace["entity"]) )
			self.origin = trace["position"];
   }
}

zomDropToGround()
{
	trace = bulletTrace( self.mover.origin+(0,0,30), self.mover.origin+(0,0,-200), false, self );
  
    if( trace["fraction"] < 1 && !isDefined(trace["entity"]) )
    {
		if( !isDefined(trace["entity"]) )
        	self.mover.origin = trace["position"];
   }
}

moveTowards(target_position, delta)
{
	self endon("disconnect");
	self endon("death");
	
	if (!isdefined(self.myWaypoint))
	{
		self.myWaypoint = getNearestWp();
	}
	
	targetWp = getNearestWpOrg(target_position);
	
	nextWp = self.nextWp;
	
	if (targetWp == self.myWaypoint)
	{
		direct = true;
		//self.mover moveto(target_position, delta, 0, 0);
	}
	else
	{
		if (self.lastTargetWp != targetWp || self.myWaypoint == nextWp )
		{
			nextWp = AStarSearch(self.myWaypoint, targetWp);
			self.nextWp = nextWp;
		}
		direct = false;
	}
	
	self.lastTargetWp = targetWp;
	
	//TARGET SET! MOVING!
	if (direct)
	{
		moveToPoint(target_position, self.speed, delta);
	}
	else
	{
		moveToPoint(level.waypoints[nextWp].origin, self.speed, delta);
		if (distance(level.waypoints[nextWp].origin, self.origin) < 32)
		{
			self.myWaypoint = nextWp;
			if (self.myWaypoint != nextWp)
			nextWp = AStarSearch(self.myWaypoint, targetWp);
			//else
			//break;
		}
	}
}

moveToPoint(origin, speed, time)
{
	targetDirection = vectorToAngles(VectorNormalize(origin - self.mover.origin));
	step = anglesToForward(targetDirection) * speed;
					
	self SetPlayerAngles(targetDirection);
	
	self.mover zomMove(step, time);
	//wait time * 0.05;
	self.mover dropToGround();
}

zomMove(forward, time)
{
	self endon("death");
	for (i=0; i<time; i++)
	{
		self pushOutOfPlayers();
		self.origin += forward;
		wait 0.05;
	}
}

moveLockon(target, delta)
{
	self endon("disconnect");
	self endon("killed_player");
	
	for( i=0; i<delta; i++ )
	{
		self thread zomStep(target);
		delta -= 0.05;
		wait 0.05;
	}

}

zomStep(ent)
{
	self.mover pushOutOfPlayers();
	
	if( distance(ent.origin, self.origin) > 32 )
	{
		targetDirection = vectorToAngles(VectorNormalize(ent.origin - self.mover.origin));
		step = anglesToForward(targetDirection) * self.speed;
		self SetPlayerAngles(targetDirection);
		self.mover.origin += step;
		self.mover dropToGround();
	}
}

pushOutOfPlayers() // ON MOVER
{
  //Commented out as of 006p to prevent bots getting stuck
  //zombie mods probably want to re-enable this


  //push out of other players
  players = level.players;
  for(i = 0; i < players.size; i++)
  {
    player = players[i];
    
    if(player == self || !isalive(player))
      continue;
      
    distance = distance(player.origin, self.origin);
    minDistance = 26;
    if(distance < minDistance) //push out
    {
      
      pushOutDir = VectorNormalize((self.origin[0], self.origin[1], 0)-(player.origin[0], player.origin[1], 0));
      //trace = bulletTrace(self.origin + (0,0,20), (self.origin + (0,0,20)) + (pushOutDir * ((minDistance-distance)+10)), false, self);
      //no collision, so push out
      //if(trace["fraction"] == 1)
      //{
        pushoutPos = self.origin + (pushOutDir * (minDistance-distance));
        self.origin = (pushoutPos[0], pushoutPos[1], self.origin[2]);
      //}
    }
  }
}

getNearestWp()
{
	nearestWaypoint = -1;
	nearestDistance = 9999999999;
	
	for(i = 0; i < level.waypointCount; i++)
	{
		distance = Distancesquared(self.origin, level.waypoints[i].origin);
	  
		if(distance < nearestDistance)
		{
	    	nearestDistance = distance;
			nearestWaypoint = i;
		}
	}
  
	return nearestWaypoint;
}

getNearestWpOrg( origin )
{
	nearestWaypoint = -1;
  	nearestDistance = 9999999999;

	for(i = 0; i < level.waypointCount; i++)
	{
   		distance = Distancesquared(origin, level.waypoints[i].origin);

	    if(distance < nearestDistance)
    	{
    		nearestDistance = distance;
    		nearestWaypoint = i;
    	}
	}

	return nearestWaypoint;
}


// AStar by Pezbots mod

AStarSearch(startWp, goalWp)
{
  pQOpen = [];
  pQSize = 0;
  closedList = [];
  listSize = 0;
  s = spawnstruct();
  s.g = 0; //start node
  s.h = distance(level.waypoints[startWp].origin, level.waypoints[goalWp].origin);
  s.f = s.g + s.h;
  s.wpIdx = startWp;
  s.parent = spawnstruct();
  s.parent.wpIdx = -1;
  
  //push s on Open
  pQOpen[pQSize] = spawnstruct();
  pQOpen[pQSize] = s; //push s on Open
  pQSize++;

  //while Open is not empty  
  while(!PQIsEmpty(pQOpen, pQSize))
  {
    //pop node n from Open  // n has the lowest f
    n = pQOpen[0];
    highestPriority = 9999999999;
    bestNode = -1;
    for(i = 0; i < pQSize; i++)
    {
      if(pQOpen[i].f < highestPriority)
      {
        bestNode = i;
        highestPriority = pQOpen[i].f;
      }
    } 
    
    if(bestNode != -1)
    {
      n = pQOpen[bestNode];
      //remove node from queue    
      for(i = bestNode; i < pQSize-1; i++)
      {
        pQOpen[i] = pQOpen[i+1];
      }
      pQSize--;
    }
    else
    {
      return -1;
    }
    
    //if n is a goal node; construct path, return success
    if(n.wpIdx == goalWp)
    {
     
      x = n;
      for(z = 0; z < 1000; z++)
      {
        parent = x.parent;
        if(parent.parent.wpIdx == -1)
        {
          return x.wpIdx;
        }
//        line(level.waypoints[x.wpIdx].origin, level.waypoints[parent.wpIdx].origin, (0,1,0));
        x = parent;
      }

      return -1;      
    }

    //for each successor nc of n
    for(i = 0; i < level.waypoints[n.wpIdx].linkedCount; i++)
    {
      //newg = n.g + cost(n,nc)
      newg = n.g + distance(level.waypoints[n.wpIdx].origin, level.waypoints[level.waypoints[n.wpIdx].linked[i].ID].origin);
      
      //if nc is in Open or Closed, and nc.g <= newg then skip
      if(PQExists(pQOpen, level.waypoints[n.wpIdx].linked[i].ID, pQSize))
      {
        //find nc in open
        nc = spawnstruct();
        for(p = 0; p < pQSize; p++)
        {
          if(pQOpen[p].wpIdx == level.waypoints[n.wpIdx].linked[i].ID)
          {
            nc = pQOpen[p];
            break;
          }
        }
       
        if(nc.g <= newg)
        {
          continue;
        }
      }
      else
      if(ListExists(closedList, level.waypoints[n.wpIdx].linked[i].ID, listSize))
      {
        //find nc in closed list
        nc = spawnstruct();
        for(p = 0; p < listSize; p++)
        {
          if(closedList[p].wpIdx == level.waypoints[n.wpIdx].linked[i].ID)
          {
            nc = closedList[p];
            break;
          }
        }
        
        if(nc.g <= newg)
        {
          continue;
        }
      }
      
//      nc.parent = n
//      nc.g = newg
//      nc.h = GoalDistEstimate( nc )
//      nc.f = nc.g + nc.h
      
      nc = spawnstruct();
      nc.parent = spawnstruct();
      nc.parent = n;
      nc.g = newg;
      nc.h = distance(level.waypoints[level.waypoints[n.wpIdx].linked[i].ID].origin, level.waypoints[goalWp].origin);
	    nc.f = nc.g + nc.h;
	    nc.wpIdx = level.waypoints[n.wpIdx].linked[i].ID;

      //if nc is in Closed,
	    if(ListExists(closedList, nc.wpIdx, listSize))
	    {
	      //remove it from Closed
        deleted = false;
        for(p = 0; p < listSize; p++)
        {
          if(closedList[p].wpIdx == nc.wpIdx)
          {
            for(x = p; x < listSize-1; x++)
            {
              closedList[x] = closedList[x+1];
            }
            deleted = true;
            break;
          }
          if(deleted)
          {
            break;
          }
        }
	      listSize--;
	    }
	    
	    //if nc is not yet in Open, 
	    if(!PQExists(pQOpen, nc.wpIdx, pQSize))
	    {
	      //push nc on Open
        pQOpen[pQSize] = spawnstruct();
        pQOpen[pQSize] = nc;
        pQSize++;
	    }
	  }
	  
	  //Done with children, push n onto Closed
	  if(!ListExists(closedList, n.wpIdx, listSize))
	  {
      closedList[listSize] = spawnstruct();
      closedList[listSize] = n;
	    listSize++;
	  }
  }
}


// PQIsEmpty, returns true if empty

PQIsEmpty(Q, QSize)
{
  if(QSize <= 0)
  {
    return true;
  }
  
  return false;
}


// returns true if n exists in the pQ

PQExists(Q, n, QSize)
{
  for(i = 0; i < QSize; i++)
  {
    if(Q[i].wpIdx == n)
    {
      return true;
    }
  }
  
  return false;
}

////////////////////////////////////////////////////////////
// returns true if n exists in the list
////////////////////////////////////////////////////////////
ListExists(list, n, listSize)
{
  for(i = 0; i < listSize; i++)
  {
    if(list[i].wpIdx == n)
    {
      return true;
    }
  }
  
  return false;
}