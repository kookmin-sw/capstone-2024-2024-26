import torch
import numpy as np
from torchvision import models, transforms
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from sklearn.metrics.pairwise import cosine_similarity
import timm



# 이미지 로드 및 전처리 함수
def load_image(first_image, second_image, device):
    # 이미지 전처리
    preprocess = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])
    
    # input_image = Image.open(first_path).convert('RGB')
    # processed_image = preprocess(input_image)
    # processed_image = processed_image.unsqueeze(0).to(device)  # 차원 추가
    image1 = preprocess(first_image).unsqueeze(0).to(device)
    image2 = preprocess(second_image).unsqueeze(0).to(device)
    
    return image1, image2

#임베딩 추출함수
def get_vit_embeddings(tensor_image, vit):
    with torch.no_grad():
        image_embedding = vit(tensor_image)
    return image_embedding

def get_resnet_embeddings(tensor_image, resnet):
    with torch.no_grad():
        image_embedding = resnet(tensor_image)
    return image_embedding

def get_inception_embeddings(tensor_image, inception):
    with torch.no_grad():
        image_embedding = inception(tensor_image)
    return image_embedding


# 두 이미지 간의 코사인 유사도 계산 함수
def get_similarity_score(first_image, second_image, vit, resnet, inception, device):
    first_image_tensor, second_image_tensor = load_image(first_image, second_image, device)
    

    first_vit_embedding = get_vit_embeddings(first_image_tensor, vit)
    second_vit_embedding = get_vit_embeddings(second_image_tensor, vit)
    
    first_resnet_embedding = get_resnet_embeddings(first_image_tensor, resnet)
    second_resnet_embedding = get_resnet_embeddings(second_image_tensor, resnet)

    first_inception_embedding = get_inception_embeddings(first_image_tensor, inception)
    second_inception_embedding = get_inception_embeddings(second_image_tensor, inception)

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


def show_images(image_path1, image_path2, s1, s2, s3):
    image1 = mpimg.imread(image_path1)
    # image1 = np.rot90(image1, k=-1)

    image2 = mpimg.imread(image_path2)
    image2 = np.rot90(image2, k=-1)

    plt.figure(figsize=(10, 5)) 

    # 첫 번째 이미지 표시
    plt.subplot(1, 2, 1)
    plt.imshow(image1)
    plt.title('Before Image')
    plt.axis('off') 

    # 두 번째 이미지 표시
    plt.subplot(1, 2, 2) 
    plt.imshow(image2)
    plt.title('After Image')
    plt.axis('off') 
    plt.figtext(0.15, 0.95, f'vit: {s1}', ha='center', va='top', fontsize=12, color='red')
    plt.figtext(0.5, 0.95, f'resnet: {s2}', ha='center', va='top', fontsize=12, color='red')
    plt.figtext(0.85, 0.95, f'inc: {s3}', ha='center', va='top', fontsize=12, color='red')

    plt.show()


def classification(image1, image2):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    resnet = models.resnet34().to(device)
    resnet.load_state_dict(torch.load('./model/resnet34.pth'))
    resnet.eval()

    inception = models.googlenet().to(device)
    inception.load_state_dict(torch.load('./model/googlenet.pth'))
    inception.eval()


    vit = timm.create_model('deit_tiny_patch16_224', pretrained=True).to(device)
    vit.load_state_dict(torch.load('./model/deit_tiny.pth'))
    vit.eval()



    # 유사도 점수 계산 및 출력
    score = get_similarity_score(image1, image2, vit, resnet, inception, device)
    print(score)
    #각각의 임계값을 설정 후 셋중 두개 이상인걸로 ㄱㄱ
    # 동아리방 임계값 0.75, 0.8, 0.7로 설정
    #강의실 임계값도 사진 가져와서 테스트 후 정해야됨
    count = 0
    if score["vit_score"] > 0.7:
        count+=1

    if score["resnet_score"] > 0.75:
        count+=1

    if score["inception_score"] > 0.65:
        count+=1

    
    #마지막 출력
    if count >=2:
        # print("합격")
        return {"score" : 1}
    else:
        # print("청소해")
        return {"score" : 0}
    


# before_image = './ai/classification/image/18.jpg'
# after_image = './ai/classification/image/20.jpg'
# score = get_similarity_score(before_image, after_image)

# show_images(before_image, after_image, score["vit_score"], score["resnet_score"], score["inception_score"])