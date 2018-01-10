# -*- coding: utf-8 -*-
import time

input()
print('スタート')
start_time = time.time()
last_time = start_time
lap_num = 1

try:
    while True:
        input()
        now = time.time()
        lap_time = round(now - last_time,2)
        total_time = round(now - start_time,2)
        print('ラップ #{}: {} ({})'.format(lap_num,total_time,lap_time), end = '')
        lap_num += 1
        last_time = now
except KeyboardInterrupt:
    print('\n終了')
