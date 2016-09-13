module latticegame;

import std.random;
import std.math;
import std.stdio;
import jive.array;

final class LatticeGame(Strategy)
{
    static struct Player
    {
        float p;
        Strategy s;
        Strategy sNew;
    }

    float temperature = 0.02;
    int maxRange = 2;
    float range = 1;

    CyclicSlice2!Player field;

    this(int width, int height)
    {
        field = CyclicSlice2!Player(height, width);

        foreach(i,j, ref p; field)
            p.s = Strategy.random();
    }

    void step()
    {
        // compute payouts
        foreach(i,j,_; field)
        {
            field[i,j].p = 0;
            float norm = 0;
            for(int a = -maxRange; a <= maxRange; ++a)
                for(int b = -maxRange; b <= maxRange; ++b)
                {
                    float w = exp(-(a*a+b*b)/(2*range*range));
                    field[i,j].p += w * Strategy.play(field[i,j].s, field[i+a,j+b].s);
                    norm += w;
                }
            field[i,j].p /= norm;
        }

        // adapt strategy
        foreach(i,j,_; field)
        {
            size_t i2,j2;
            final switch(uniform(0,8))
            {
                case 0: i2 = i+1; j2 = j; break;
                case 1: i2 = i-1; j2 = j; break;
                case 2: i2 = i; j2 = j+1; break;
                case 3: i2 = i; j2 = j-1; break;

                case 4: i2 = i+1; j2 = j+1; break;
                case 5: i2 = i+1; j2 = j-1; break;
                case 6: i2 = i-1; j2 = j+1; break;
                case 7: i2 = i-1; j2 = j-1; break;
            }

            if(uniform(0.0,1.0) <= 1/(1+exp((field[i,j].p - field[i2,j2].p)/temperature)))
                field[i,j].sNew = field[i2,j2].s;
            else
                field[i,j].sNew = field[i,j].s;
        }

        foreach(i,j,_; field)
            field[i,j].s = field[i,j].sNew;
    }

    void print()
    {
        for(int j = 0; j < field.size[1]; ++j)
        {
            for(int i = 0; i < field.size[0]; ++i)
                writef("%s", field[i,j].s.toString);
            writefln("");
        }
    }
}
