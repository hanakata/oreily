# -*- coding: utf-8 -*-
import random

capitals = {
'北海道':'札幌',
'青森県':'青森',
'岩手県':'盛岡',
'宮城県':'仙台',
'秋田県':'秋田',
'山形県':'山形',
'福島県':'福島',
'茨城県':'水戸',
'栃木県':'宇都宮',
'群馬県':'前橋',
'埼玉県':'さいたま',
'千葉県':'千葉',
'東京都':'東京',
'神奈川県':'横浜',
'新潟県':'新潟',
'富山県':'富山',
'石川県':'金沢',
'福井県':'福井',
'山梨県':'甲府',
'長野県':'長野',
'岐阜県':'岐阜',
'静岡県':'静岡',
'愛知県':'名古屋',
'三重県':'津',
'滋賀県':'大津',
'京都府':'京都',
'大阪府':'大阪',
'兵庫県':'神戸',
'奈良県':'奈良',
'和歌山県':'和歌山',
'鳥取県':'鳥取',
'島根県':'松江',
'岡山県':'岡山',
'広島県':'広島',
'山口県':'山口',
'徳島県':'徳島',
'香川県':'高松',
'愛媛県':'松山',
'高知県':'高知',
'福岡県':'福岡',
'佐賀県':'佐賀',
'長崎県':'長崎',
'熊本県':'熊本',
'大分県':'大分',
'宮崎県':'宮崎',
'鹿児島':'鹿児島',
'沖縄県':'那覇'
}

for quiz_num in range(35):
    quiz_file = open('capitalsquiz{}.txt'.format(quiz_num + 1), 'w')
    answer_key_file = open('capitalsquiz_answers{}.txt'.format(quiz_num + 1),'w')
    
    quiz_file.write('名前:\n\n日付:\n\n学期:\n\n')
    quiz_file.write(('' * 20) + '都道府県庁所在地クイズ(問題番号 {})'.format(quiz_num + 1))
    quiz_file.write('\n\n')
    
    prefectures = list(capitals.keys())
    random.shuffle(prefectures)
    
    for question_num in range(len(prefectures)):
        correct_answer = capitals[prefectures[question_num]]
        wrong_answers = list(capitals.values())
        del wrong_answers[wrong_answers.index(correct_answer)]
        wrong_answers = random.sample(wrong_answers,3)
        answer_options = wrong_answers + [correct_answer]
        random.shuffle(answer_options)
        
        quiz_file.write('{}. {}の都道府県庁所在地は？\n'.format(question_num + 1,prefectures[question_num]))
        for i in range(4):
            quiz_file.write('{}.{}\n'.format('ABCD'[i], answer_options[i]))
        
        quiz_file.write('\n')
        
        answer_key_file.write('{}.{}\n'.format(question_num + 1, 'ABCD'[answer_options.index(correct_answer)]))
    quiz_file.close()
    answer_key_file.close()