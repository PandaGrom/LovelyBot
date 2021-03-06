require 'telegram/bot'
require './secure.rb'
require './vika_phrases.rb'
require './nastya_phrases.rb'
require './general_phrases.rb'
require './calculate_rest.rb'

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
  send_message(bot, owner_chat_id, 'Она отправила:')
  send_message(bot, owner_chat_id, sender_message.text)
end

def answer_to_not_lovely_girl(bot, chat_id, text)
  send_message(bot, chat_id, text)
end

def send_message_to_brother(bot, chat_id, text)
  case chat_id
  when DENIS_ID
    send_message(bot, ARSENIJ_ID, attach_nickname(DENIS_USERNAME, formatted_text(text)))
  when ARSENIJ_ID
    send_message(bot, DENIS_ID,  attach_nickname(ARSENIJ_USERNAME, formatted_text(text)))
  else
    nil
  end
end

def rest_of_meeting(final_date)
  CalculateRest.new(final_date: final_date).rest
end

def brother_conversation?(text)
  formatted_text(text)
end

def formatted_text(text)
  text.split('/send_to_brother ')[1]
end

def send_info_messages_to_denis(bot, message)
  send_message(bot, message.chat.id, 'Обожаю вас, мой хозяин')
end

def send_info_messages_to_arsenij(bot, message)
  send_message(bot, message.chat.id, 'Вассап, Нигга')
  send_message(bot, message.chat.id, "Вашей любимой доступно #{(PHRASES_FOR_VIKA + GENERAL_PHRASES).count} приятных фраз")
end

def send_rest(bot, message, final_date)
  return unless message.text == '/rest'

  send_message(bot, message.chat.id, rest_of_meeting(final_date))
end

def attach_nickname(nickname, text)
  "[#{nickname}] #{text}"
end

def bot_activity(bot, message)
  case message.from.username
  when VIKA_USERNAME
    send_rest(bot, message, Time.new(2022, 8, 3))
    phrases = PHRASES_FOR_VIKA + GENERAL_PHRASES
    text = "#{phrases.sample}\n\n1 из #{phrases.count}"
    greeting(bot, message, message.chat.id, 'Если тебе не будет хватать меня - ищи здесь')
    answer_to_lovely_girl(bot, message.chat.id, text, ARSENIJ_ID, "Торя ждёт, Торя плачет\nЕё любимый говорит:\n#{text}", message)
  when NASTYA_USERNAME
    send_rest(bot, message, Time.new(2022, 8, 25, 17, 0, 0))
    phrases = PHRASES_FOR_NASTYA + GENERAL_PHRASES
    text = "#{phrases.sample}\n\n1 из #{phrases.count}"
    greeting(bot, message, message.chat.id, "Пиши сюда если очень нужно)")
    answer_to_lovely_girl(bot, message.chat.id, text, DENIS_ID, "Настя скучает\nДенис говорит:\n#{text}", message)
  when DENIS_USERNAME
    send_rest(bot, message, Time.new(2022, 8, 25, 17, 0, 0))
    send_message_to_brother(bot, message.chat.id, message.text) if brother_conversation?(message.text)
    send_info_messages_to_denis(bot, message) unless brother_conversation?(message.text)
  when ARSENIJ_USERNAME
    send_rest(bot, message, Time.new(2022, 8, 3))
    send_message_to_brother(bot, message.chat.id, message.text) if brother_conversation?(message.text)
    send_info_messages_to_arsenij(bot, message) unless brother_conversation?(message.text)
  else
    send_message(bot, message.chat.id, 'Тебя никто не любит, пошел нахуй отсюда. Умри.')
  end
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    bot_activity(bot, message)
  end
end
