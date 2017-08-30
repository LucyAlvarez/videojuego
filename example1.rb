require 'chingu'
include Gosu

class Game < Chingu::Window
  def initialize
    super
    self.caption = "Hola, este es mi primer juego en ruby" #titulo
    self.input = {:escape => :exit} #permite salir con la tecla esc
    push_game_state(Inicio) #envia al metodo de inicio

  end
end

class Player < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize(options = {})
    super
    @image = Image["nave.png"] #grafico de la nave
  end

  #metodos que definen los movimientos de las naves
  def holding_left;  @x -= 3
  end
  def holding_right;  @x += 3
  end
  def holding_up;  @y -= 3
  end
  def holding_down;  @y += 3
  end
  def space
    Bullet.create(:x => @x +10, :y => @y)  #permite el movimiento hacia arriba de las balas
    Bullet.create(:x => @x -10, :y => @y) #permite que sean dos balas
  end
end

class Meteor < Chingu::GameObject
  traits :velocity, :collision_detection, :bounding_circle #para las balas y la velocidad
def initialize(options= {})
  super
  @image = Image["meteorito.png"] #imagen de los graficos
  self.velocity_x = rand (-1..1) #permite el movimiento de los meteoritos
  self.velocity_y = rand (-1..1)
end

#permite que los meteoritos tengan limites y regresen a la escena
def update
  if @x < 0 || @x>$window.width; @x %= $window.width; end
  if @y < 0 || @y>$window.height; @y %= $window.height; end
end
end

#es la clase Balas que permite la imagen y el funcionamiento de las mismas
class Bullet < Chingu::GameObject
  traits :collision_detection, :bounding_circle
  def initialize(options = {})
    super
    @image = Image["balas.png"]
  end

#permite que no se acumulen la cantidad de balas que se disparan
  def update
    @y -= 2
    if outside_window?
      self.destroy
    end
  end
end

#es el inicio que se manda llamar desde la clase Game
class Inicio < Chingu::GameState
def initialize
  super
  Chingu::Text.create(:text => "Presiona F1 para continuar", :x=> 200, :y => $window.height/2, :size=>20 )
  self.input = {:f1 => Play }
end
end
 # de aqui en adelante son los estados del juego, es decir:
 #el Play permite jugar
class Play < Chingu::GameState
def initialize
  super
  Chingu::Text.create(:text =>"Presiona P para Pausar y R para Reiniciar el Juego")
  @player = Player.create(:x => 200, :y => 200)
  @player.input = [ :holding_left, :holding_right, :holding_up, :holding_down, :space ]
  self.input = [:p => Pause, :r => :reset_game]
  5.times { Meteor.create(:x=> rand($window.width),:y=> rand($window.height))}
end

#el reset que vuelva a comenzar el juego
def reset_game
  Meteor.destroy_all
  Bullet.destroy_all
  @player.x = $window.width/2
  @player.y = $window.height * 0.95
    5.times { Meteor.create(:x=> rand($window.width),:y=> rand($window.height))}
end

def update
  super
  #si la bala chocacon el meteorito, destruye la bala y el meteorito
  Bullet.each_collision(Meteor) do |bullet, meteor| bullet.destroy; meteor.destroy; end
  Player.each_collision(Meteor) do |player, meteor| push_game_state(Lose) end
  #Meteor.destroy_all do push_game_state (Win) end
end
end

#la clase de game Over
class Lose < Chingu::GameState
def initialize
  super
  Chingu::Text.create(:text => "Game Over!!!", :size=> 50, :y => $window.height/2, :x=> 200)
  self.input = { :c => :denuevo}
end

def denuevo
  pop_game_state
end
=begin
def draw
  super
  previous_game_state.draw
end

=end
end
#el pause que haya resumen dentro del mismo
class Pause < Chingu::GameState
  def initialize
    super
    self.input = {:p => :sinpause}
  end
#que continue después del resumen
  def sinpause
    pop_game_state
  end

def draw
  super
  previous_game_state.draw
end
end


=begin
class Win < Chingu::GameState
  def initialize
    super
    Chingu::Text.create(:text => "You Win", :size=> 50, :y => $window.height/2, :x=> 200)
  end
end
=end

Game.new.show
