#encoding: utf-8

# Подключение необходимых библиотек
require 'rubygems'         # Управление гемами (не обязательно в современных версиях Ruby, но включено для совместимости).
require 'sinatra'          # Основной фреймворк для создания веб-приложений.
require 'sinatra/reloader' # Позволяет автоматически перезагружать приложение при изменении кода (удобно в процессе разработки).
require 'sqlite3'          # Подключение к библиотеке для работы с базой данных SQLite3.

# Метод для инициализации базы данных
def init_db
  # Открытие или создание файла базы данных 'leprosorium.db'
  @db = SQLite3::Database.new 'leprosorium.db'
  @db.results_as_hash = true # Настройка возврата данных в виде хэша (удобно для работы с колонками по именам).
end

# Выполняется перед каждым запросом
before do
  init_db # Инициализация базы данных для каждого запроса (обеспечивает доступ к @db в обработчиках маршрутов).
end

# Настройка приложения (выполняется один раз при запуске)
configure do
	init_db
	@db.execute 'create table if not exists Posts
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_date TEXT,
      content TEXT
    )'
end

# Обработчик GET-запроса на главную страницу ('/')
get '/' do
  # Использование шаблона erb с HTML-кодом для отображения ссылки.
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

# Обработчик GET-запроса для страницы создания новой записи ('/new')
get '/new' do
  erb :new # Отображение шаблона `views/new.erb`, предназначенного для ввода текста записи.
end

# Обработчик POST-запроса для страницы создания новой записи ('/new')
post '/new' do
  # Получение текста записи из параметров формы
  content = params[:content]

  # Если есть ошибки, перерисовываем страницу с формой записи.
  if content.length <= 0
  	@error = 'Type post text'
    return erb :new # Возвращаем пользователю ту же страницу с ошибками.
  end

  #db = get_db # Подключаемся к базе данных.
  #execute используется для выполнения SQL-запросов к базе данных.
  #Он является частью библиотеки sqlite3 и позволяет отправлять запросы в базу данных SQLite.
  @db.execute "INSERT INTO Posts (created_date, content) VALUES (DATETIME('now'), ?)", [content] # Передаем параметры в запрос.
  # Простая проверка: отображение введённого текста на странице (без сохранения в базе).
  erb "You typed: #{content}" # Вывод введённого текста с использованием шаблона erb.
end