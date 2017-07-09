require 'rubygems'
require 'telegram/bot'
require 'openweather2'
require 'nokogiri'
require 'curb'
require 'dotenv'

Dotenv.load('.env')
TGTOKEN = ENV['TGTOKEN']
WEATHERTOKEN = ENV['WEATHERTOKEN']

CITY = "Minsk"
WEATHER_SITE = 'http://api.openweathermap.org/data/2.5/weather'
AFISHA_URL = "https://afisha.tut.by/film/"
AFISHA_FILMS_NAME = 'ul.online_list > li > a:nth-child(2) > span:nth-child(1)'

Openweather2.configure do |config|
  config.endpoint = WEATHER_SITE 
  config.apikey = WEATHERTOKEN
end

http = Curl.get(AFISHA_URL)
page = Nokogiri::HTML(http.body_str)
array_of_name = Array.new(0)
  page.css(AFISHA_FILMS_NAME).each do |name|
  array_of_name << name.text
end

Telegram::Bot::Client.run(TGTOKEN) do |bot|
  bot.listen do |message|		
    case message.text
    when '/start'
      bot.api.sendMessage(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}. Чтобы посмотреть погоду напиши мне /weather. Для просмотра афиши кино - /afisha")
    when '/stop'
      bot.api.sendMessage(chat_id: message.chat.id, text: "Пока, #{message.from.first_name}")
    when '/weather' 
      weather = Openweather2.get_weather(city: CITY, units: 'metric')
      bot.api.sendMessage(chat_id: message.chat.id, text: "#{CITY}: #{weather.temperature} ℃ , Humidity - #{weather.humidity}%, Pressure - #{weather.pressure} hpa")
    when '/afisha'
      bot.api.sendMessage(chat_id: message.chat.id, text: "#{array_of_name}")
    when '/commands'
      bot.api.sendMessage(chat_id: message.chat.id, text: "/start \n/stop \n/weather \n/afisha")
    else
      bot.api.sendMessage(chat_id: message.chat.id, text: "Что ты хочешь узнать? Напиши один из запросов \n/weather \n/afisha \n/commands")
    end
  end
end