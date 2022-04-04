require 'telegram/bot'
require './secure.rb'
require './vika_phrases.rb'
require './nastya_phrases.rb'
require './general_phrases.rb'
require './katya_phrases.rb'

def send_message(bot, chat_id, text)
  bot.api.send_message(
    chat_id:chat_id,
    text: text
  )
end

def greeting(bot, message, chat_id, text)
  if message == '/start'
    send_message(bot, chat_id, text)
  end
end

def answer_to_lovely_girl(bot, chat_id, text, owner_chat_id, owner_text, sender_message)
  send_message(bot, chat_id, text)
  send_message(bot, owner_chat_id, owner_text)
  send_message(bot, owner_chat_id, "Она написала '#{sender_message}'")
end

def bot_activity(bot, message)
  case message.from.username
  when VIKA_USERNAME
    phrases = PHRASES_FOR_VIKA + GENERAL_PHRASES
    text = "#{phrases.sample}\n\n1 из #{phrases.count}"
    greeting(bot, message, message.chat.id, 'Если тебе не будет хватать меня - ищи здесь')
    answer_to_lovely_girl(bot, message.chat.id, text, ARSENIJ_ID, "Торя ждёт, Торя плачет\nЕё любимый говорит:\n#{text}", message)
  when NASTYA_USERNAME
    phrases = PHRASES_FOR_NASTYA + GENERAL_PHRASES
    text = "#{phrases.sample}\n\n1 из #{phrases.count}"
    greeting(bot, message, message.chat.id, "Привет, Настюшка\nКогда тебе будет не хватать меня, помни: я всегда есть здесь\nОтправляй сюда сообщение и получай в ответ фразу, которую я придумал для тебя")
    answer_to_lovely_girl(bot, message.chat.id, text, DENIS_ID, "Настюшка-Сплюшка скучает 💟\nЕе порадовало:\n#{text}", message)
  when KATYA_USERNAME
    phrases = PHRASES_FOR_KATYA
    text = "#{phrases.sample}\n\n1 из #{phrases.count}"
    greeting(bot, message, message.chat.id, "Уважаемая Белочка, прошло недоразумение, вы так ахуенны что ослепили меня и я подумал что это пришел кто-то чужой, простите меня пожалуйста, я к вашим услугам")
    answer_to_lovely_girl(bot, message.chat.id, text, DENIS_ID, "Белочка скучает 💟\nБурундук шепчет ей на ушко:\n#{text}", message)
  when DENIS_USERNAME
    send_message(bot, message.chat.id, 'Обожаю вас, мой хозяин')
    send_message(bot, message.chat.id, "Белочке доступно #{(PHRASES_FOR_KATYA).count} приятных фраз")
  when ARSENIJ_USERNAME
    send_message(bot, message.chat.id, 'Вассап, Нигга')
    send_message(bot, message.chat.id, "Вашей любимой доступно #{(PHRASES_FOR_VIKA + GENERAL_PHRASES).count} приятных фраз")
  else
    send_message(bot, message.chat.id, 'Тебя никто не любит, пошел нахуй отсюда. Умри.')
  end
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    bot_activity(bot, message)
  end
end
