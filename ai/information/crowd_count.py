import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import matplotlib.pyplot as plt

# 아마 이대로 갈듯


class CSRNet(nn.Module):
    def __init__(self):
        super(CSRNet, self).__init__()
        self.frontend_feat = [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 512, 512, 512]
        self.backend_feat = [512, 512, 512, 256, 128, 64]
        self.frontend = make_layers(self.frontend_feat)
        self.backend = make_layers(self.backend_feat, in_channels=512, dilation=True)
        self.output_layer = nn.Conv2d(64, 1, kernel_size=1)

    def forward(self, x):
        x = self.frontend(x)
        x = self.backend(x)
        x = self.output_layer(x)
        return x

def make_layers(cfg, in_channels = 3, batch_norm=False, dilation = False):
    if dilation:
        d_rate = 2
    else:
        d_rate = 1
    layers = []
    for v in cfg:
        if v == 'M':
            layers += [nn.MaxPool2d(kernel_size=2, stride=2)]
        else:
            conv2d = nn.Conv2d(in_channels, v, kernel_size=3, padding=d_rate, dilation=d_rate)
            if batch_norm:
                layers += [conv2d, nn.BatchNorm2d(v), nn.ReLU(inplace=True)]
            else:
                layers += [conv2d, nn.ReLU(inplace=True)]
            in_channels = v
    return nn.Sequential(*layers)



def detect_and_draw(image_path):
    model = CSRNet()
    # model_weights = torch.load('./ai/information/model.pt')
    model_weights = torch.load('./ai/information/model.pt', map_location=torch.device('cpu'))
    model.load_state_dict(model_weights)
    model.eval()
    # 이미지를 처리할 트랜스폼 설정
    transform = transforms.Compose([
        transforms.Resize((768, 1024)),  # CSRNet 트레이닝에 사용된 입력 크기로 조정
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    # 이미지 로드 및 변환
    # 테스트할 이미지 경로
    image = Image.open(image_path).convert('RGB')
    input_tensor = transform(image).unsqueeze(0)  # 배치 차원 추가

    # 모델을 사용한 밀도 맵 추정
    with torch.no_grad():
        output = model(input_tensor)

    # 결과 출력
    predicted_density_map = output.squeeze(0).squeeze(0)  # 결과 텐서 차원 감소
    print(f"수치: {predicted_density_map.sum().item():.2f}")  # 전체 사람 수 추정

    # 밀도 맵 시각화
    plt.imshow(predicted_density_map.numpy(), cmap='jet')
    plt.colorbar()  # 밀도 값의 색상 막대 표시
    plt.show()

    #밑에꺼 지우고 여기서 바로 수치 return 할듯

if __name__ == "__main__":
    image_path = "./ai/information/office_image/23.jpg"  # 사용자가 이미지 경로로 변경
    detect_and_draw(image_path)