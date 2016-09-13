module window;

/**
  *	SDL abstraction. Window Creation and input handling
  */

public import derelict.sdl2.sdl;
private import std.string : toStringz;

static this()
{
	DerelictSDL2.load(SharedLibVersion(2, 0, 2));
}

class SDLApplication
{
	SDL_Window* win;
	SDL_Renderer* renderer;

	bool running = true;
	int windowFPS = 0;
	ubyte* keyState;
	int width = 800, height = 600;

	public this(int width, int height, string title)
	{
		if (SDL_Init(SDL_INIT_VIDEO) < 0)	// we use SDL for video output (+mouse/keyboard) only
			throw new Exception("Unable to init SDL");

		auto flags = SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE;// | SDL_WINDOW_MAXIMIZED ;//| SDL_WINDOW_FULLSCREEN_DESKTOP;
		win = SDL_CreateWindow(toStringz(title), SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, flags);
		if(win is null)
			throw new Exception("could not create SDL window");

		renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED);
		if(renderer is null)
			throw new Exception("could not create SDL renderer");
	}

	public ~this()
	{
		SDL_DestroyWindow(win);
	    SDL_Quit();
	}

	final void pollEvents()
	{
		SDL_Event event;
		while(SDL_PollEvent(&event))
		{
			switch(event.type)
			{
				case SDL_KEYDOWN:
					onKeyDown(event.key.keysym.sym);
					break;

				case SDL_MOUSEMOTION:
					onMouseMove(event.motion.xrel, event.motion.yrel, event.motion.state);
					break;

				case SDL_MOUSEBUTTONDOWN:
					onMouseDown(event.button.button, event.button.x, event.button.y);
					break;

				case SDL_QUIT:
					onQuit();
					break;

				case SDL_WINDOWEVENT:
					switch(event.window.event)
					{
						case SDL_WINDOWEVENT_RESIZED:
							width = event.window.data1;
							height = event.window.data2;
							break;

						case SDL_WINDOWEVENT_CLOSE:
							onQuit();
							break;
						default: break;
					}

				default: break;
			}
		}
	}

	void onKeyDown(int key) {}
	void onMouseMove(int x, int y, uint state){};
	void onMouseDown(int button, int x, int y){};
	void onQuit(){}
	abstract void onFrame(double deltaTime);

	final void main()
	{
		double currTime;
		double lastTime=cast(double)SDL_GetTicks()/1000f;
		double deltaTime = 0;
		int numframes;	// this second
		long frameID;	// all-time

		while(running)
		{
			pollEvents();

			currTime = cast(double)SDL_GetTicks()/1000f;
			deltaTime = currTime - lastTime;

			numframes++;
			frameID++;

			if (cast(uint)currTime > cast(uint)lastTime)
			{
				windowFPS = numframes;
				numframes = 0;
			}

			lastTime = currTime;

			keyState = SDL_GetKeyboardState(null);

			onFrame(deltaTime);

			SDL_RenderPresent(renderer);
		}
	}
}
