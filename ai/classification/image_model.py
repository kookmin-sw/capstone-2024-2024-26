import torch
import numpy as np
from torchvision import models, transforms
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from sklearn.metrics.pairwise import cosine_similarity
import os
from torchvision.models import densenet121, DenseNet121_Weights, vit_b_16, ViT_B_16_Weights, resnet50, ResNet50_Weights, inception_v3, Inception_V3_Weights
import timm


# model 3개 가지고 앙상블 
# ResNet50 -> resnet34나 18로 바꿀예정
# weights = ResNet50_Weights.DEFAULT
# resnet = resnet50(weights=weights)
# resnet.eval()

# for param in resnet.parameters():
#     param.requires_grad = False

resnet = models.resnet34()
resnet.load_state_dict(torch.load('./ai/classification/resnet34.pth'))
resnet.eval()


# Inception v3 -> inceptionv1
# weights = Inception_V3_Weights.DEFAULT
# inception = inception_v3(weights=weights)
# inception.eval()

# for param in inception.parameters():
#     param.requires_grad = False

inception = models.googlenet()
inception.load_state_dict(torch.load('./ai/classification/googlenet.pth'))
inception.eval()


# DenseNet
# model = models.densenet121(weights=DenseNet121_Weights.IMAGENET1K_V1)
# model.eval()

# for param in model.parameters():
#     param.requires_grad = False


# 모델 선택: Vision Transformer (ViT-B/16)
# weights = ViT_B_16_Weights.DEFAULT
# vit = vit_b_16(weights=weights)
# vit.eval()

# for param in vit.parameters():
#     param.requires_grad = False

vit = timm.create_model('deit_tiny_patch16_224', pretrained=True)
vit.load_state_dict(torch.load('./ai/classification/deit_tiny.pth'))
vit.eval()

# 이미지 로드 및 전처리 함수
def load_image(image_path):
    # 이미지 전처리
    preprocess = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])
    
    input_image = Image.open(image_path).convert('RGB')
    processed_image = preprocess(input_image)
    processed_image = processed_image.unsqueeze(0)  # 차원 추가
    
    return processed_image

#임베딩 추출함수
def get_vit_embeddings(tensor_image):
    with torch.no_grad():
        image_embedding = vit(tensor_image)
    return image_embedding

def get_resnet_embeddings(tensor_image):
    with torch.no_grad():
        image_embedding = resnet(tensor_image)
    return image_embedding

def get_inception_embeddings(tensor_image):
    with torch.no_grad():
        image_embedding = inception(tensor_image)
    return image_embedding


# 두 이미지 간의 코사인 유사도 계산 함수
def get_similarity_score(first_image_path, second_image_path):
    first_image_tensor = load_image(first_image_path)
    second_image_tensor = load_image(second_image_path)
    

    first_vit_embedding = get_vit_embeddings(first_image_tensor)
    second_vit_embedding = get_vit_embeddings(second_image_tensor)
    
    first_resnet_embedding = get_resnet_embeddings(first_image_tensor)
    second_resnet_embedding = get_resnet_embeddings(second_image_tensor)

    first_inception_embedding = get_inception_embeddings(first_image_tensor)
    second_inception_embedding = get_inception_embeddings(second_image_tensor)

    first_vit_vector = first_vit_embedding.view(first_vit_embedding.size(0), -1)
    second_vit_vector = second_vit_embedding.view(second_vit_embedding.size(0), -1)

    first_resnet_vector = first_resnet_embedding.view(first_resnet_embedding.size(0), -1)
    second_resnet_vector = second_resnet_embedding.view(second_resnet_embedding.size(0), -1)

    first_inception_vector = first_inception_embedding.view(first_inception_embedding.size(0), -1)
    second_inception_vector = second_inception_embedding.view(second_inception_embedding.size(0), -1)
    
    

    vit_score = torch.nn.functional.cosine_similarity(first_vit_vector, second_vit_vector)
    vit_score = round(vit_score.item(), 3)

    resnet_score = torch.nn.functional.cosine_similarity(first_resnet_vector, second_resnet_vector)
    resnet_score = round(resnet_score.item(), 3)

    inception_score = torch.nn.functional.cosine_similarity(first_inception_vector, second_inception_vector)
    inception_score = round(inception_score.item(), 3)

    score = { "vit_score" : vit_score, "resnet_score" : resnet_score, "inception_score" : inception_score}

    return score



def show_images(image_path1, image_path2):
    image1 = mpimg.imread(image_path1)
    image1_rotated = np.rot90(image1, k=-1)

    image2 = mpimg.imread(image_path2)
    image2_rotated = np.rot90(image2, k=-1)

    plt.figure(figsize=(10, 5)) 

    # 첫 번째 이미지 표시
    plt.subplot(1, 2, 1)
    plt.imshow(image1_rotated)
    plt.title('Before Image')
    plt.axis('off') 

    # 두 번째 이미지 표시
    plt.subplot(1, 2, 2) 
    plt.imshow(image2_rotated)
    plt.title('After Image')
    plt.axis('off') 

    plt.show()


if __name__ == '__main__':
    print(os.getcwd())
    
    #이미지 경로
    #첫번째 이미지는 내 폴더에서, 두번째는 사진찍은거 받아와서
    before_image = './ai/classification/image/6.jpg'
    after_image = './ai/classification/image/7.jpg'


    # 유사도 점수 계산 및 출력
    score = get_similarity_score(before_image, after_image)

    #각각의 임계값을 설정 후 셋중 두개 이상인걸로 ㄱㄱ
    count = 0
    if score["vit_score"] > 0.7:
        print("vit 통과, score : {}".format(score["vit_score"]))
        count+=1
    else:
        print("vit 탈락, score : {}".format(score["vit_score"]))

    if score["resnet_score"] > 0.85:
        print("resnet 통과, score : {}".format(score["resnet_score"]))
        count+=1
    else:
        print("resnet 탈락, score : {}".format(score["resnet_score"]))

    if score["inception_score"] > 0.6:
        print("inception 통과, score : {}".format(score["inception_score"]))
        count+=1
    else:
        print("inception 탈락, score : {}".format(score["inception_score"]))

    
    #마지막 출력
    if count >=2:
        print("합격")
    else:
        print("청소해")

    show_images(before_image, after_image)