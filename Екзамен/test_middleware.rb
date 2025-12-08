# frozen_string_literal: true
require 'rack'

# Middleware для блокування IP після невдалих спроб
class BlockSuspiciousIP
  MAX_ATTEMPTS = 3       # Кількість невдалих спроб до блокування
  BLOCK_TIME = 60        # Час блокування в секундах

  def initialize(app)
    @app = app
    @failed_attempts = {} # { ip => { count: int, last_attempt: Time } }
    @blocked_ips = {}     # { ip => blocked_until: Time }
  end

  def call(env)
    request = Rack::Request.new(env)
    ip = request.ip

    if blocked?(ip)
      return [403, { 'Content-Type' => 'text/plain' }, ["Access denied for IP #{ip}"]]
    end

    status, headers, response = @app.call(env)

    # Імітація невдалої аутентифікації: status == 401 для '/login'
    if request.path == '/login' && status == 401
      register_failed_attempt(ip)
    end

    [status, headers, response]
  end

  private

  def blocked?(ip)
    blocked_until = @blocked_ips[ip]
    if blocked_until && blocked_until > Time.now
      true
    else
      @blocked_ips.delete(ip)
      false
    end
  end

  def register_failed_attempt(ip)
    data = @failed_attempts[ip] || { count: 0, last_attempt: Time.now }
    data[:count] += 1
    data[:last_attempt] = Time.now
    @failed_attempts[ip] = data

    if data[:count] >= MAX_ATTEMPTS
      @blocked_ips[ip] = Time.now + BLOCK_TIME
      @failed_attempts.delete(ip)
      puts "[INFO] IP #{ip} заблокований на #{BLOCK_TIME} секунд"
    else
      puts "[INFO] Невдала спроба #{data[:count]} для IP #{ip}"
    end
  end
end

# --- Тестовий Rack-додаток ---
app = Proc.new do |env|
  request = Rack::Request.new(env)
  if request.path == '/login'
    # Імітація випадкових успіхів/невдач
    if rand < 0.5
      [401, { 'Content-Type' => 'text/plain' }, ['Unauthorized']]
    else
      [200, { 'Content-Type' => 'text/plain' }, ['Login successful']]
    end
  else
    [200, { 'Content-Type' => 'text/plain' }, ['Hello world']]
  end
end

# Підключаємо middleware
stack = BlockSuspiciousIP.new(app)

# --- Тестування ---
test_ips = ['192.168.0.1', '10.0.0.5']

10.times do
  test_ips.each do |ip|
    env = Rack::MockRequest.env_for('/login', 'REMOTE_ADDR' => ip)
    status, headers, body = stack.call(env)
    puts "IP #{ip} -> Status: #{status}, Response: #{body.join}"
  end
  sleep 1
end
