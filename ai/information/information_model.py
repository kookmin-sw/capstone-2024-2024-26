from transformers import DetrImageProcessor, DetrForObjectDetection
import torch
from PIL import Image
import cv2

def detect_and_draw(image_path):
    # 모델 및 프로세서 초기화
    # processor = DetrImageProcessor.from_pretrained("./ai/information/detr_processor")
    # model = DetrForObjectDetection.from_pretrained("./ai/information/detr_model")
    processor = DetrImageProcessor.from_pretrained("facebook/detr-resnet-50")
    model = DetrForObjectDetection.from_pretrained("facebook/detr-resnet-50")

    # 이미지 불러오기
    image = Image.open(image_path)
    image1 = cv2.imread(image_path)

    # 이미지 처리 및 객체 탐지
    inputs = processor(images=image, return_tensors="pt")
    outputs = model(**inputs)

    target_sizes = torch.tensor([image.size[::-1]])
    results = processor.post_process_object_detection(outputs, target_sizes=target_sizes, threshold=0.9)[0]

    information = {"desk": 0, "person": 0}

    for score, label, box in zip(results["scores"], results["labels"], results["boxes"]):
        if score.item() >= 0.95:
            label_name = model.config.id2label[label.item()]
            if label_name in ["dining table", "person"]:
                x1, y1, x2, y2 = box.tolist()
                if label_name == "person":
                    information["person"] += 1
                    color = (0, 0, 255)  # 빨간색
                elif label_name == "dining table":
                    information["desk"] += 1
                    color = (255, 0, 0)  # 파란색

                cv2.rectangle(image1, (int(x1), int(y1)), (int(x2), int(y2)), color, 2)
                label_text = f"{label_name}: {round(score.item(), 3)}"
                cv2.putText(image1, label_text, (int(x1), int(y1) - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)

    image1_resized = cv2.resize(image1, (1080, 1080))

    print(f"빈 책상수 : {information['desk']}\n사람수 : {information['person']}")

    cv2.imshow("Detected Objects", image1_resized)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    return

if __name__ == "__main__":
    image_path = "./ai/information/office_image/21.jpg"  # 사용자가 이미지 경로로 변경
    detect_and_draw(image_path)