# frozen_string_literal: true

require_relative "jekyll/version"

module Jekyll
  class Error < StandardError; end
  require 'gosu'

  class GameWindow < Gosu::Window
    def initialize
      super(640, 480)
      self.caption = "Space Shooting Game"
      @background_image = Gosu::Image.new("background.png", tileable: true)
  
      @player = Player.new
      @player.warp(320, 240)
  
      @bullets = []
      @enemies = []
      @font = Gosu::Font.new(20)
      @score = 0
    end
  
    def update
      if rand(100) < 4 && @enemies.size < 5
        @enemies.push(Enemy.new)
      end
  
      @player.move_left if Gosu.button_down? Gosu::KB_LEFT
      @player.move_right if Gosu.button_down? Gosu::KB_RIGHT
      @player.move_up if Gosu.button_down? Gosu::KB_UP
      @player.move_down if Gosu.button_down? Gosu::KB_DOWN
  
      @player.shoot(@bullets) if Gosu.button_down? Gosu::KB_SPACE
  
      @bullets.each do |bullet|
        bullet.move
        @enemies.each do |enemy|
          if enemy.collide?(bullet)
            @score += 10
            @enemies.delete(enemy)
            @bullets.delete(bullet)
            break
          end
        end
      end
  
      @enemies.each do |enemy|
        if enemy.collide?(@player)
          initialize
          break
        end
        enemy.move
      end
    end
  
    def draw
      @background_image.draw(0, 0, 0)
      @player.draw
      @bullets.each(&:draw)
      @enemies.each(&:draw)
      @font.draw("Score: #{@score}", 10, 10, 1, 1.0, 1.0, Gosu::Color::WHITE)
    end
  end
  
  class Player
    def initialize
      @image = Gosu::Image.new("player.png")
      @x = @y = @vel_x = @vel_y = 0.0
      @score = 0
    end
  
    def warp(x, y)
      @x, @y = x, y
    end
  
    def move_left
      @vel_x -= 5
    end
  
    def move_right
      @vel_x += 5
    end
  
    def move_up
      @vel_y -= 5
    end
  
    def move_down
      @vel_y += 5
    end
  
    def shoot(bullets)
      bullets.push(Bullet.new(@x + 25, @y))
    end
  
    def draw
      @image.draw(@x, @y, 1)
    end
  end
  
  class Bullet
    def initialize(x, y)
      @image = Gosu::Image.new("bullet.png")
      @x, @y = x, y
    end
  
    def move
      @y -= 10
    end
  
    def draw
      @image.draw(@x, @y, 1)
    end
  end
  
  class Enemy
    def initialize
      @image = Gosu::Image.new("enemy.png")
      @x = rand * 640
      @y = 0
    end
  
    def move
      @y += 5
    end
  
    def draw
      @image.draw(@x, @y, 1)
    end
  
    def collide?(object)
      Gosu.distance(object.x, object.y, @x, @y) < 50
    end
  end
  
  window = GameWindow.new
  window.show
  
end
class PowerUp
  attr_reader :x, :y

  def initialize
    @image = Gosu::Image.new("powerup.png")
    @x = rand * 640
    @y = rand * 480
    @timer = 5000  # Power-up effect duration in milliseconds (5 seconds)
    @effect_active = false
  end

  def draw
    @image.draw(@x, @y, 1)
  end

  def apply_effect(player)
    return if @effect_active
    @effect_active = true
    player.increase_shooting_speed
    Thread.new do
      sleep @timer / 1000.0
      player.reset_shooting_speed
      @effect_active = false
    end
  end

  def collide?(object)
    Gosu.distance(object.x, object.y, @x, @y) < 50
  end
end
class GameWindow < Gosu::Window
  def initialize
    # Existing initialization code...

    @power_ups = []
  end

  def update
    # Existing update code...

    # Power-up spawning
    if rand(1000) < 2 && @power_ups.empty?
      @power_ups.push(PowerUp.new)
    end

    # Player collecting power-up
    @power_ups.each do |power_up|
      if power_up.collide?(@player)
        power_up.apply_effect(@player)
        @power_ups.delete(power_up)
        break
      end
    end
  end

  def draw
    # Existing draw code...

    @power_ups.each(&:draw)
  end
end

