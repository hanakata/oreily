# -*- coding: utf-8 -*-
import re

def is_phone_number(text):
    phone_num_regex = re.compile(r'\d\d\d-\d\d\d-\d\d\d\d')
    if phone_num_regex.search(text):
        return True

message = '明日415-555-1011に電話してください。オフィスは415-555-9999です'
for i in range(len(message)):
    chunk = message[i:i+12]
    if is_phone_number(chunk):
        print('電話番号が見つかりました: ' + chunk )
print('完了')