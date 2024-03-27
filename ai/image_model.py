import torch
import numpy as np
from torchvision import models, transforms
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from sklearn.metrics.pairwise import cosine_similarity
import os
from torchvision.models import densenet121, DenseNet121_Weights


# model select
# ResNet50
model = models.resnet50(pretrained=True)
model.eval()

for param in model.parameters():
    param.requires_grad = False


# # Inception v3
# model = models.inception_v3(pretrained=True)
# model.eval()

# for param in model.parameters():
#     param.requires_grad = False



# DenseNet
# model = models.densenet121(weights=DenseNet121_Weights.IMAGENET1K_V1)
# model.eval()

# for param in model.parameters():
#     param.requires_grad = False



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

# 이미지 임베딩 추출 함수
def get_image_embeddings(tensor_image):
    with torch.no_grad():
        image_embedding = model(tensor_image)
    return image_embedding


# 두 이미지 간의 코사인 유사도 계산 함수
def get_similarity_score(first_image_path, second_image_path):
    first_image_tensor = load_image(first_image_path)
    second_image_tensor = load_image(second_image_path)
    
    first_image_embedding = get_image_embeddings(first_image_tensor)
    second_image_embedding = get_image_embeddings(second_image_tensor)
    
    first_vector = first_image_embedding.view(first_image_embedding.size(0), -1)
    second_vector = second_image_embedding.view(second_image_embedding.size(0), -1)
    
    similarity_score = torch.nn.functional.cosine_similarity(first_vector, second_vector)
    return similarity_score


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
    before_image = './ai/image/6.jpg'
    after_image = './ai/image/7.jpg'


    # 유사도 점수 계산 및 출력
    similarity_score = get_similarity_score(before_image, after_image)
    print(similarity_score.item())

    # 이미지 청소 조건
    # if similarity_score > 0.85:
    #     print("합격")
    # else:
    #     print("청소안하냐?")


    show_images(before_image, after_image)