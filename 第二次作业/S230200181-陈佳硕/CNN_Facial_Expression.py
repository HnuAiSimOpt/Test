import cv2
import sys
import json
import time
import matplotlib.pyplot as plt
#%matplotlib inline
import numpy as np
from keras.models import model_from_json


emotion_labels = ['angry', 'fear', 'happy', 'sad', 'surprise', 'neutral']

# load json and create model arch
json_file = open('./face/real-time_emotion_analyzer/model.json','r')
loaded_model_json = json_file.read()
json_file.close()
model = model_from_json(loaded_model_json)

# load weights into new model
model.load_weights('./face/real-time_emotion_analyzer/model.h5')

def predict_emotion(face_image_gray): # a single cropped face
    resized_img = cv2.resize(face_image_gray, (48,48), interpolation = cv2.INTER_AREA)
    # cv2.imwrite(str(index)+'.png', resized_img)
    image = resized_img.reshape(1, 1, 48, 48)
    list_of_list = model.predict(image, batch_size=1, verbose=1)
    angry, fear, happy, sad, surprise, neutral = [prob for lst in list_of_list for prob in lst]
    return [angry, fear, happy, sad, surprise, neutral]


# -------------------÷±Ω”‘§≤‚-----------------------
img_gray = cv2.imread("./face/real-time_emotion_analyzer/meme_faces/angry-sad.png")
img_gray = cv2.cvtColor(img_gray, cv2.COLOR_BGR2GRAY)
angry,fear, happy, sad, surprise, neutral = predict_emotion(img_gray)

# -------------------»À¡≥‘§≤‚-----------------------
# º”‘ÿºÏ≤‚∆˜
cascPath = './face/real-time_emotion_analyzer/haarcascade_frontalface_default.xml'
faceCascade = cv2.CascadeClassifier(cascPath)
# ÕºœÒª“ªØ
jpg_file = './face/002.jpg'
image = cv2.imread(jpg_file)
img_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

# »À¡≥ºÏ≤‚
faces = faceCascade.detectMultiScale(
        img_gray,
        scaleFactor=1.1,
        minNeighbors=1,# minNeighbors=5±»Ωœƒ—ºÏ≤‚
        minSize=(30, 30),
        flags=cv2.CASCADE_SCALE_IMAGE
    )
# ±Ì«Èª≠øÚ
for (x, y, w, h) in faces:
    face_image_gray = img_gray[y:y+h, x:x+w]
    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 255, 0), 2)
    angry, fear, happy, sad, surprise, neutral = predict_emotion(face_image_gray)
    fe=(angry,fear, happy, sad, surprise, neutral)
    maxnum=max(fe)
    for i in range(6):
        if fe[i] == maxnum:
            mmaxfe=i
    if mmaxfe==0:
        charactermax='angry'
    elif mmaxfe==1:
        charactermax='fear'
    elif mmaxfe==2:
        charactermax='happy'
    elif mmaxfe==3:
        charactermax='sad'
    elif mmaxfe==4:
        charactermax='surprise'
    elif mmaxfe==5:
        charactermax='neutral'
    else:
        charactermax='neutral'
    cv2.putText(image, charactermax, (x, y), cv2.FONT_HERSHEY_COMPLEX_SMALL, 1,(0, 255, 255), thickness=1)
plt.imshow(image)
print(charactermax)
print(angry, fear, happy, sad, surprise, neutral)
print(mmaxfe)

