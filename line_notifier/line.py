from linebot import LineBotApi
from linebot.models import TextSendMessage
from linebot.exceptions import LineBotApiError

def send_to_line(token, id, message):

    line_bot_api = LineBotApi(token)
    try:
        line_bot_api.push_message(id, TextSendMessage(text=message))
    except LineBotApiError as e:
        pass
