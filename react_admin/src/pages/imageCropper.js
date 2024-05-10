import React, { useCallback, useState } from 'react';
import Cropper from 'react-easy-crop';
import styled from 'styled-components';

const ImageCropper = ({
  croppedImage,  // crop할 이미지 
  setCroppedAreaPixels, // 이미지 {width: , height: , x: , y: } setstate, 잘린 이미지 값
  width = '4',	// 이미지 비율
  height = '2',	// 이미지 비율
  cropShape = 'none', // 이미지 모양 round 설정 시 원으로 바뀜
}) => {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);

  const onCropComplete = useCallback((croppedAreaPixel) => {
    setCroppedAreaPixels(croppedAreaPixel);
  }, []);

  return (
    <Container>
      <Cropper
        image={croppedImage}
        crop={crop}
        zoom={zoom}
        aspect={width / height}
        onCropChange={setCrop}
        onCropComplete={onCropComplete}
        onZoomChange={setZoom}
        cropShape={cropShape}
      />
      <ZoomBox>
        <ZoomInput
          type="range"
          value={zoom}
          min={1}
          max={3}
          step={0.1}
          aria-labelledby="Zoom"
          onChange={(e) => {
            setZoom(e.target.value);
          }}
        />
      </ZoomBox>
    </Container>
  );
};

export default ImageCropper;