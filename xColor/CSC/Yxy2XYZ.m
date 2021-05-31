function Img2 = Yxy2XYZ(Img)
    % YXY2XYZ converts Yxy to XYZ

    [Img,meta] = img2raw(Img);

    % Apply Conversion
    Img2(:,2) = Img(:,1);
    Img2(:,1) = (Img(:,2).*Img(:,1)./Img(:,3));
    Img2(:,3) = ((1.0 - Img(:,2) - Img(:,3)).*Img(:,1))./Img(:,3);

    % find out when y from Yxy is ZERO and set XYZ to ZERO
    Img2(repmat((Img(:,3) == 0),[1 3])) = 0;

    Img2 = raw2img(Img2,meta);

end