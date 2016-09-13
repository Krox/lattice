#!/usr/bin/rdmd --shebang -I../DerelictUtil/source -I../DerelictSDL2/source -I../DerelictCL/source -I../jive

import std.stdio;
import std.conv;
import std.exception;
import std.random;
import jive.array;
import derelict.sdl2.sdl;

import latticegame;
import window;



float incentive = 0.20;
float cost = 0.05;
float punish = 0.05;

struct Strategy
{
    bool coop;
    bool moral;

    static float play(Strategy a, Strategy b)
    {
        float r = 0;
        if(!a.coop)
            r += incentive;
        if(b.coop)
            r += 1;

        if(!a.coop && b.moral)
            r -= punish;
        if(a.moral && !b.coop)
            r -= cost;
        return r;
    }

    string toString()
    {
        if(moral)
            if(coop)
                return "M";
            else
                return "I";
        else
            if(coop)
                return "C";
            else
                return ".";
    }

    ubyte toColor()
    {
        if(moral)
            if(coop)
                return 56;
            else
                return 31;
        else
            if(coop)
                return 3;
            else
                return 0;
    }

    static Strategy random()
    {
        Strategy s;
        if(uniform(0,2))
            s.coop = true;
        if(uniform(0,2))
            s.moral = true;
        return s;
    }
}


class App : SDLApplication
{
    SDL_Texture* texture;
    SDL_Rect rect;
    LatticeGame!Strategy game;

    this()
    {
        game = new LatticeGame!Strategy(100,100);

        super(800, 600, "some title");
        rect.x = rect.y = 0;
        rect.w = 200;
        rect.h = 200;
        texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB332, SDL_TEXTUREACCESS_STREAMING, width, height);

        updateTexture();
    }

    void updateTexture()
    {
        auto pixels = Slice2!ubyte(game.field.size[0]*2, game.field.size[1]*2);
        foreach(i,j, _; game.field)
            pixels[2*i,2*j] = pixels[2*i+1,2*j] = pixels[2*i,2*j+1] = pixels[2*i+1,2*j+1] = game.field[i,j].s.toColor();
        SDL_UpdateTexture(texture, &rect, pixels.ptr, cast(int)pixels.size[0]);
    }

    override void onKeyDown(int key)
    {
        switch(key)
        {
            case SDLK_ESCAPE:
                running = false;
                break;

            case SDLK_RETURN:
                game.step();
                updateTexture();
                break;

            default:
                break;
        }
    }

    override void onQuit()
    {
        running = false;
    }

    override void onFrame(double deltaTime)
    {
        game.step();
        updateTexture();
        SDL_RenderCopy(renderer, texture, &rect, &rect);
        SDL_RenderPresent(renderer);
    }
}


void main()
{
    auto app = new App;
    app.main();
}
