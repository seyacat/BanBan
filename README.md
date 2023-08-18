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
context: contiene informacion del entorno
{delta:double,postion:vector2,enemies:object{id:string,position:vector2}}

Especial
!update=>(ctx)=>{ .... } La funcion update se ejecuta cada frame, recibe contexto como parametro. ojo consume vida hasta dejarte a un 10%


