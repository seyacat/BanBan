BanBan es un juego simple PVP utilizando el chat de Twitch.  cada jugador tiene un muñeco con interprete de Javascript.

Código:

https://github.com/seyacat/BanBan​

No se ha publicado en versión web por una limitante del exportador de C# en godot 4

UI

Barra Roja: Es tu vida, si llega a cero recibes un ban de 30s

Barra Azul: Cooldown, algunos comandos la requieren al 100%

Comandos
!join, !j: Unirse al juego!

!reset: Reinicia el jugador.

!u ,!d, !l, !r: Up, Down, Left, Right, son accesos cortos por ejemplo de  !u(distance) ...

!h: Golpe melee, es igual a usar !_h = true

Métodos
!m(x,y): Mueve tu personaje a la posicion x,y. OJO usa la funcion update no te salgas de los limites

!b(angle,velocity): Bomba de 10 segundos, usala para matar a tus enemigos

Variables
_v = [0,0]: La variable _v se lee del interprete para mover el jugador

_b = [0,0]: La variable _b se lee del interprete para lanzar una bomba

_h = true: La variable _b se lee del interprete para activar el ataque

BUILTIN FUNCTIONS

getDelta() : Devuelve el tiempo transcurrido desde el ultimo update en segundos
Ejem: 10.2

getPosition() : Devuelve la posicion del jugador
Ejem: (x,y)

getEnemies() : Devuelve la lista de enemigos 
Ejem: [{id:0,position:[0,0]}]

getEnemyCount() : Devuelve el numero de enemigos
Ejem: 3

getEnemy(index) : Devuelve el enemigo con index como parametro 
Ejem: {id:0,position:[0,0]}

getBombs() : Devuelve la lista de bombas
Ejem: [{position:[0,0]}]

getBombCount() : Devuelve el numero de bombas
Ejem: 8

GetBomb(index) : Devuelve la bomba con index como parametro
Ejem: {position:[0,0]}


Especial
!update=>()=>{ .... } La funcion update se ejecuta cada frame, recibe contexto como parametro. 


//English


BanBan is a simple PVP game using Twitch chat. Each player has a doll with a JavaScript interpreter.

Code:

https://github.com/seyacat/BanBan

It has not been released as a web version due to a limitation of the C# exporter in Godot 4.

UI

Red Bar: It represents your life. If it reaches zero, you receive a 30-second ban.

Blue Bar: Cooldown. Some commands require it to be at 100%.

Commands !join, !j: Join the game!

!reset: Reset the player.

!u, !d, !l, !r: Up, Down, Left, Right. These are shortcuts for, for example, !u(distance)...

!h: Melee attack. It is equivalent to using !_h = true.

Methods !m(x,y): Move your character to position x, y. Be careful not to go beyond the boundaries. Use the update function.

!b(angle, velocity): 10-second bomb. Use it to kill your enemies.

Variables _v = [0,0]: The variable _v is read from the interpreter to move the player.

_b = [0,0]: The variable _b is read from the interpreter to throw a bomb.

_h = true: The variable _h is read from the interpreter to activate the attack.

BUILTIN FUNCTIONS

getDelta(): Returns the time elapsed since the last update in seconds. Example: 10.2

getPosition(): Returns the player's position. Example: (x,y)

getEnemies(): Returns the list of enemies. Example: [{id:0,position:[0,0]}]

getEnemyCount(): Returns the number of enemies. Example: 3

getEnemy(index): Returns the enemy with the specified index as a parameter. Example: {id:0,position:[0,0]}

getBombs(): Returns the list of bombs. Example: [{position:[0,0]}]

getBombCount(): Returns the number of bombs. Example: 8

GetBomb(index): Returns the bomb with the specified index as a parameter. Example: {position:[0,0]}

Special !update=>()=>{ .... } The update function is executed every frame and receives context as a parameter.

