BombEvent
=========

HTML5/Websockets/Eventmachine Bomberman (MIT License)

This is an Bomberman clone consisting of a server written with EventMachine and em-websockets and a client written in CoffeeScript and utilizing the [Crafty](http://craftyjs.com) game engine for drawing and controls.

It was initially developed in two days at the [ADVANCE HACKATHON 2012](http://hackathon.advance-conference.com) and is still an early beta state. Expect the current master to be unstable until we move to a more mature stage.

We'll continue maturing the code and adding more fun features and hopefully some specs soon.

To get it running:

* Clone the project
* Run bundle install
* Start ./server.rb (will listen on port 3000 HTTP, 3001 Websockets)
* Point your (modern) browser(s) at your-hostname:3000
* Start playing

If you'd like to participate, drop a line to [@felixbuenemann](http://twitter.com/felixbuenemann) on twitter.
